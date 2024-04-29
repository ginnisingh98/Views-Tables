--------------------------------------------------------
--  DDL for Package Body OKL_TCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TCL_PVT" AS
/* $Header: OKLSTCLB.pls 120.10 2007/04/19 12:45:30 nikshah noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  l_seq NUMBER;
  BEGIN
-- Changed by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    SELECT OKL_TXL_CNTRCT_LNS_ALL_S.NEXTVAL INTO l_seq FROM DUAL;
    RETURN l_seq;
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
  -- FUNCTION get_rec for: OKL_TXL_CNTRCT_LNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tcl_rec                      IN tcl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tcl_rec_type IS
    CURSOR okl_txl_cntrct_lns_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            BEFORE_TRANSFER_YN,
            TCN_ID,
            RCT_ID,
            BTC_ID,
            STY_ID,
            LINE_NUMBER,
            TCL_TYPE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            ORG_ID,
            DESCRIPTION,
            PROGRAM_ID,
            GL_REVERSAL_YN,
            AMOUNT,
            PROGRAM_APPLICATION_ID,
            CURRENCY_CODE,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
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
            LAST_UPDATE_LOGIN,
            AVL_ID,
	    BKT_ID,
	    KLE_ID_NEW,
	    PERCENTAGE,
	-- Added by hkpatel on 17-Sep-2003
	    ACCRUAL_RULE_YN,
        -- 21 Oct 2004 PAGARG Bug# 3964726
        SOURCE_COLUMN_1,
        SOURCE_VALUE_1,
        SOURCE_COLUMN_2,
        SOURCE_VALUE_2,
        SOURCE_COLUMN_3,
        SOURCE_VALUE_3,
        CANCELED_DATE,
	TAX_LINE_ID,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
        STREAM_TYPE_CODE,
	STREAM_TYPE_PURPOSE,
	ASSET_BOOK_TYPE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
        UPGRADE_STATUS_FLAG
      FROM Okl_Txl_Cntrct_Lns
     WHERE okl_txl_cntrct_lns.id = p_id;
    l_okl_txl_cntrct_lns_pk        okl_txl_cntrct_lns_pk_csr%ROWTYPE;
    l_tcl_rec                      tcl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_cntrct_lns_pk_csr (p_tcl_rec.id);
    FETCH okl_txl_cntrct_lns_pk_csr INTO
              l_tcl_rec.ID,
              l_tcl_rec.KHR_ID,
              l_tcl_rec.KLE_ID,
              l_tcl_rec.BEFORE_TRANSFER_YN,
              l_tcl_rec.TCN_ID,
              l_tcl_rec.RCT_ID,
              l_tcl_rec.BTC_ID,
              l_tcl_rec.STY_ID,
              l_tcl_rec.LINE_NUMBER,
              l_tcl_rec.TCL_TYPE,
              l_tcl_rec.OBJECT_VERSION_NUMBER,
              l_tcl_rec.CREATED_BY,
              l_tcl_rec.CREATION_DATE,
              l_tcl_rec.LAST_UPDATED_BY,
              l_tcl_rec.LAST_UPDATE_DATE,
              l_tcl_rec.ORG_ID,
              l_tcl_rec.DESCRIPTION,
              l_tcl_rec.PROGRAM_ID,
              l_tcl_rec.GL_REVERSAL_YN,
              l_tcl_rec.AMOUNT,
              l_tcl_rec.PROGRAM_APPLICATION_ID,
              l_tcl_rec.CURRENCY_CODE,
              l_tcl_rec.REQUEST_ID,
              l_tcl_rec.PROGRAM_UPDATE_DATE,
              l_tcl_rec.ATTRIBUTE_CATEGORY,
              l_tcl_rec.ATTRIBUTE1,
              l_tcl_rec.ATTRIBUTE2,
              l_tcl_rec.ATTRIBUTE3,
              l_tcl_rec.ATTRIBUTE4,
              l_tcl_rec.ATTRIBUTE5,
              l_tcl_rec.ATTRIBUTE6,
              l_tcl_rec.ATTRIBUTE7,
              l_tcl_rec.ATTRIBUTE8,
              l_tcl_rec.ATTRIBUTE9,
              l_tcl_rec.ATTRIBUTE10,
              l_tcl_rec.ATTRIBUTE11,
              l_tcl_rec.ATTRIBUTE12,
              l_tcl_rec.ATTRIBUTE13,
              l_tcl_rec.ATTRIBUTE14,
              l_tcl_rec.ATTRIBUTE15,
              l_tcl_rec.LAST_UPDATE_LOGIN,
              l_tcl_rec.AVL_ID,
              l_tcl_rec.BKT_ID,
              l_tcl_rec.KLE_ID_NEW,
              l_tcl_rec.PERCENTAGE,
              -- Added by hkpatel on 17-Sep-2003
              l_tcl_rec.ACCRUAL_RULE_YN,
              --21 Oct 2004 PAGARG Bug# 3964726
              l_tcl_rec.SOURCE_COLUMN_1,
              l_tcl_rec.SOURCE_VALUE_1,
              l_tcl_rec.SOURCE_COLUMN_2,
              l_tcl_rec.SOURCE_VALUE_2,
              l_tcl_rec.SOURCE_COLUMN_3,
              l_tcl_rec.SOURCE_VALUE_3,
              l_tcl_rec.CANCELED_DATE,
	      l_tcl_rec.TAX_LINE_ID,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
              l_tcl_rec.STREAM_TYPE_CODE,
	      l_tcl_rec.STREAM_TYPE_PURPOSE,
	      l_tcl_rec.ASSET_BOOK_TYPE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
              l_tcl_rec.UPGRADE_STATUS_FLAG;

    x_no_data_found := okl_txl_cntrct_lns_pk_csr%NOTFOUND;
    CLOSE okl_txl_cntrct_lns_pk_csr;
    RETURN(l_tcl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tcl_rec                      IN tcl_rec_type
  ) RETURN tcl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tcl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_CNTRCT_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tclv_rec                     IN tclv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tclv_rec_type IS
    CURSOR okl_tclv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STY_ID,
            RCT_ID,
            BTC_ID,
            TCN_ID,
            KHR_ID,
            KLE_ID,
            BEFORE_TRANSFER_YN,
            LINE_NUMBER,
            DESCRIPTION,
            AMOUNT,
            CURRENCY_CODE,
            GL_REVERSAL_YN,
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
            TCL_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            ORG_ID,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            PROGRAM_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            AVL_ID,
            BKT_ID,
            KLE_ID_NEW,
            PERCENTAGE,
   -- Added by hkpatel on 17-Sep-2003
            ACCRUAL_RULE_YN,
            -- 21 Oct 2004 PAGARG Bug# 3964726
            SOURCE_COLUMN_1,
            SOURCE_VALUE_1,
            SOURCE_COLUMN_2,
            SOURCE_VALUE_2,
            SOURCE_COLUMN_3,
            SOURCE_VALUE_3,
            CANCELED_DATE,
	    TAX_LINE_ID,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
            STREAM_TYPE_CODE,
	    STREAM_TYPE_PURPOSE,
	    ASSET_BOOK_TYPE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
            UPGRADE_STATUS_FLAG
      FROM OKL_TXL_CNTRCT_LNS
     WHERE OKL_TXL_CNTRCT_LNS.id = p_id;
    l_okl_tclv_pk                  okl_tclv_pk_csr%ROWTYPE;
    l_tclv_rec                     tclv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tclv_pk_csr (p_tclv_rec.id);
    FETCH okl_tclv_pk_csr INTO
              l_tclv_rec.ID,
              l_tclv_rec.OBJECT_VERSION_NUMBER,
              l_tclv_rec.STY_ID,
              l_tclv_rec.RCT_ID,
              l_tclv_rec.BTC_ID,
              l_tclv_rec.TCN_ID,
              l_tclv_rec.KHR_ID,
              l_tclv_rec.KLE_ID,
              l_tclv_rec.BEFORE_TRANSFER_YN,
              l_tclv_rec.LINE_NUMBER,
              l_tclv_rec.DESCRIPTION,
              l_tclv_rec.AMOUNT,
              l_tclv_rec.CURRENCY_CODE,
              l_tclv_rec.GL_REVERSAL_YN,
              l_tclv_rec.ATTRIBUTE_CATEGORY,
              l_tclv_rec.ATTRIBUTE1,
              l_tclv_rec.ATTRIBUTE2,
              l_tclv_rec.ATTRIBUTE3,
              l_tclv_rec.ATTRIBUTE4,
              l_tclv_rec.ATTRIBUTE5,
              l_tclv_rec.ATTRIBUTE6,
              l_tclv_rec.ATTRIBUTE7,
              l_tclv_rec.ATTRIBUTE8,
              l_tclv_rec.ATTRIBUTE9,
              l_tclv_rec.ATTRIBUTE10,
              l_tclv_rec.ATTRIBUTE11,
              l_tclv_rec.ATTRIBUTE12,
              l_tclv_rec.ATTRIBUTE13,
              l_tclv_rec.ATTRIBUTE14,
              l_tclv_rec.ATTRIBUTE15,
              l_tclv_rec.TCL_TYPE,
              l_tclv_rec.CREATED_BY,
              l_tclv_rec.CREATION_DATE,
              l_tclv_rec.LAST_UPDATED_BY,
              l_tclv_rec.LAST_UPDATE_DATE,
              l_tclv_rec.ORG_ID,
              l_tclv_rec.PROGRAM_ID,
              l_tclv_rec.PROGRAM_APPLICATION_ID,
              l_tclv_rec.REQUEST_ID,
              l_tclv_rec.PROGRAM_UPDATE_DATE,
              l_tclv_rec.LAST_UPDATE_LOGIN,
              l_tclv_rec.AVL_ID,
              l_tclv_rec.BKT_ID,
              l_tclv_rec.KLE_ID_NEW,
              l_tclv_rec.PERCENTAGE,
              -- Added by hkpatel on 17-Sep-2003
              l_tclv_rec.ACCRUAL_RULE_YN,
              --21 Oct 2004 PAGARG Bug# 3964726
              l_tclv_rec.SOURCE_COLUMN_1,
              l_tclv_rec.SOURCE_VALUE_1,
              l_tclv_rec.SOURCE_COLUMN_2,
              l_tclv_rec.SOURCE_VALUE_2,
              l_tclv_rec.SOURCE_COLUMN_3,
              l_tclv_rec.SOURCE_VALUE_3,
              l_tclv_rec.CANCELED_DATE,
	      l_tclv_rec.TAX_LINE_ID,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
              l_tclv_rec.STREAM_TYPE_CODE,
	      l_tclv_rec.STREAM_TYPE_PURPOSE,
	      l_tclv_rec.ASSET_BOOK_TYPE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
              l_tclv_rec.UPGRADE_STATUS_FLAG;

    x_no_data_found := okl_tclv_pk_csr%NOTFOUND;
    CLOSE okl_tclv_pk_csr;
    RETURN(l_tclv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tclv_rec                     IN tclv_rec_type
  ) RETURN tclv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tclv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_CNTRCT_LNS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tclv_rec	IN tclv_rec_type
  ) RETURN tclv_rec_type IS
    l_tclv_rec	tclv_rec_type := p_tclv_rec;
  BEGIN
    IF (l_tclv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.object_version_number := NULL;
    END IF;
    IF (l_tclv_rec.sty_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.sty_id := NULL;
    END IF;
    IF (l_tclv_rec.rct_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.rct_id := NULL;
    END IF;
    IF (l_tclv_rec.btc_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.btc_id := NULL;
    END IF;
    IF (l_tclv_rec.tcn_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.tcn_id := NULL;
    END IF;
    IF (l_tclv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.khr_id := NULL;
    END IF;
    IF (l_tclv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.kle_id := NULL;
    END IF;
    IF (l_tclv_rec.before_transfer_yn = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.before_transfer_yn := NULL;
    END IF;
    IF (l_tclv_rec.line_number = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.line_number := NULL;
    END IF;
    IF (l_tclv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.description := NULL;
    END IF;
    IF (l_tclv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.amount := NULL;
    END IF;
    IF (l_tclv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.currency_code := NULL;
    END IF;
    IF (l_tclv_rec.gl_reversal_yn = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.gl_reversal_yn := NULL;
    END IF;
    IF (l_tclv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute_category := NULL;
    END IF;
    IF (l_tclv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute1 := NULL;
    END IF;
    IF (l_tclv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute2 := NULL;
    END IF;
    IF (l_tclv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute3 := NULL;
    END IF;
    IF (l_tclv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute4 := NULL;
    END IF;
    IF (l_tclv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute5 := NULL;
    END IF;
    IF (l_tclv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute6 := NULL;
    END IF;
    IF (l_tclv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute7 := NULL;
    END IF;
    IF (l_tclv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute8 := NULL;
    END IF;
    IF (l_tclv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute9 := NULL;
    END IF;
    IF (l_tclv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute10 := NULL;
    END IF;
    IF (l_tclv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute11 := NULL;
    END IF;
    IF (l_tclv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute12 := NULL;
    END IF;
    IF (l_tclv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute13 := NULL;
    END IF;
    IF (l_tclv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute14 := NULL;
    END IF;
    IF (l_tclv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.attribute15 := NULL;
    END IF;
    IF (l_tclv_rec.tcl_type = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.tcl_type := NULL;
    END IF;
    IF (l_tclv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.created_by := NULL;
    END IF;
    IF (l_tclv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_tclv_rec.creation_date := NULL;
    END IF;
    IF (l_tclv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tclv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_tclv_rec.last_update_date := NULL;
    END IF;
    IF (l_tclv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.org_id := NULL;
    END IF;
    IF (l_tclv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.request_id := NULL;
    END IF;
    IF (l_tclv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.program_application_id := NULL;
    END IF;
    IF (l_tclv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.program_id := NULL;
    END IF;
    IF (l_tclv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_tclv_rec.program_update_date := NULL;
    END IF;
    IF (l_tclv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.last_update_login := NULL;
    END IF;
    IF (l_tclv_rec.avl_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.avl_id := NULL;
    END IF;
    IF (l_tclv_rec.bkt_id = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.bkt_id := NULL;
    END IF;
    IF (l_tclv_rec.kle_id_new = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.kle_id_new := NULL;
    END IF;
    IF (l_tclv_rec.percentage = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.percentage := NULL;
    END IF;
    -- Added by hkpatel on 17-Sep-2003
    IF (l_tclv_rec.accrual_rule_yn = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.accrual_rule_yn := NULL;
    END IF;
    --21 Oct 2004 PAGARG Bug# 3964726
    IF (l_tclv_rec.SOURCE_COLUMN_1 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.SOURCE_COLUMN_1 := NULL;
    END IF;
    IF (l_tclv_rec.SOURCE_VALUE_1 = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.SOURCE_VALUE_1 := NULL;
    END IF;
    IF (l_tclv_rec.SOURCE_COLUMN_2 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.SOURCE_COLUMN_2 := NULL;
    END IF;
    IF (l_tclv_rec.SOURCE_VALUE_2 = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.SOURCE_VALUE_2 := NULL;
    END IF;
    IF (l_tclv_rec.SOURCE_COLUMN_3 = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.SOURCE_COLUMN_3 := NULL;
    END IF;
    IF (l_tclv_rec.SOURCE_VALUE_3 = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.SOURCE_VALUE_3 := NULL;
    END IF;
    IF (l_tclv_rec.CANCELED_DATE = OKC_API.G_MISS_DATE) THEN
      l_tclv_rec.CANCELED_DATE := NULL;
    END IF;
    IF (l_tclv_rec.TAX_LINE_ID = OKC_API.G_MISS_NUM) THEN
      l_tclv_rec.TAX_LINE_ID := NULL;
    END IF;
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
    IF (l_tclv_rec.STREAM_TYPE_CODE = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.STREAM_TYPE_CODE := NULL;
    END IF;
    IF (l_tclv_rec.STREAM_TYPE_PURPOSE = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.STREAM_TYPE_PURPOSE := NULL;
    END IF;
    IF (l_tclv_rec.ASSET_BOOK_TYPE_NAME = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.ASSET_BOOK_TYPE_NAME := NULL;
    END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    IF (l_tclv_rec.UPGRADE_STATUS_FLAG = OKC_API.G_MISS_CHAR) THEN
      l_tclv_rec.UPGRADE_STATUS_FLAG := NULL;
    END IF;
    RETURN(l_tclv_rec);
  END null_out_defaults;

/* Renu Gurudev 4/17/2001 - Commented out generated code in favor of manually written code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_CNTRCT_LNS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tclv_rec IN  tclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_tclv_rec.id = OKC_API.G_MISS_NUM OR
       p_tclv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tclv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_tclv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tclv_rec.tcn_id = OKC_API.G_MISS_NUM OR
          p_tclv_rec.tcn_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tcn_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tclv_rec.khr_id = OKC_API.G_MISS_NUM OR
          p_tclv_rec.khr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'khr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tclv_rec.line_number = OKC_API.G_MISS_NUM OR
          p_tclv_rec.line_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tclv_rec.tcl_type = OKC_API.G_MISS_CHAR OR
          p_tclv_rec.tcl_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tcl_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_TXL_CNTRCT_LNS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_tclv_rec IN tclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

*/
  /*********** begin manual coding *****************/


 -- Added by santonyr on 11-Jun-2003 to fix bug 2999776
 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Tcl_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Tcl_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- line_number         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  Procedure Validate_Unique_Tcl_Record(x_return_status OUT NOCOPY  VARCHAR2
                                      ,p_tclv_rec      IN   tclv_rec_type)
  IS

  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

    CURSOR unique_tcl_csr(p_tcn_id OKL_TXL_CNTRCT_LNS.tcn_id%TYPE
                         ,p_line_number OKL_TXL_CNTRCT_LNS.line_number%TYPE
                         ,p_id OKL_TXL_CNTRCT_LNS.id%TYPE) IS
    SELECT 1
    FROM OKL_TXL_CNTRCT_LNS
    WHERE  tcn_id = p_tcn_id
    AND    line_number = p_line_number
    AND    id <> p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN unique_tcl_csr(p_tclv_rec.tcn_id,
                        p_tclv_rec.line_number,
                        p_tclv_rec.id);
    FETCH unique_tcl_csr INTO l_dummy;
    l_row_found := unique_tcl_csr%FOUND;
    CLOSE unique_tcl_csr;

    IF l_row_found THEN
        Okc_Api.set_message('OKL','OKL_TCN_LINE_NUMBER_UNIQUE');
        x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Tcl_Record;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.id IS NULL) OR
       (p_tclv_rec.id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'id');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Khr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Khr_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers_V
  WHERE okl_k_headers_v.id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.khr_id IS NULL) OR
       (p_tclv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'khr_id');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        OPEN okl_tclv_fk_csr(p_tclv_rec.KHR_ID);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tcn_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Tcn_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tcn_Id (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_TRX_CONTRACTS
  WHERE OKL_TRX_CONTRACTS.id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.tcn_id IS NULL) OR
       (p_tclv_rec.tcn_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'tcn_id');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
        OPEN okl_tclv_fk_csr(p_tclv_rec.TCN_ID);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TCN_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Tcn_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rct_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Rct_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rct_Id (p_tclv_rec IN  tclv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR rct_csr (v_rct_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_STRM_TYPE_V
  WHERE id = v_rct_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tclv_rec.rct_id IS NOT NULL) AND
       (p_tclv_rec.rct_id <> OKC_API.G_MISS_NUM) THEN

        OPEN rct_csr(p_tclv_rec.RCT_ID);
        FETCH rct_csr INTO l_dummy_var;
        l_row_notfound := rct_csr%NOTFOUND;
        CLOSE rct_csr;

        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RCT_ID');
          RAISE item_not_found_error;
        END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

 END Validate_RCT_ID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Btc_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Btc_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Btc_Id (p_tclv_rec IN  tclv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR btc_csr (v_btc_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_TRX_CSH_BATCH_V
  WHERE id = v_btc_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tclv_rec.btc_id IS NOT NULL) AND
       (p_tclv_rec.btc_id <> OKC_API.G_MISS_NUM) THEN

        OPEN btc_csr(p_tclv_rec.BTC_ID);
        FETCH btc_csr INTO l_dummy_var;
        l_row_notfound := btc_csr%NOTFOUND;
        CLOSE btc_csr;

        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BTC_ID');
          RAISE item_not_found_error;
        END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Validate_BTC_ID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sty_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Sty_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sty_Id (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_Strm_Type_V
  WHERE okl_strm_type_v.id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.sty_id IS NOT NULL) AND
       (p_tclv_rec.sty_id <> OKC_API.G_MISS_NUM) THEN
        OPEN okl_tclv_fk_csr(p_tclv_rec.STY_ID);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME,
                              G_INVALID_VALUE,
                              G_COL_NAME_TOKEN,
                              'STY_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Sty_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Line_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Line_Number
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Line_Number (p_tclv_rec IN  tclv_rec_type
                                  ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.line_number IS NULL) OR
       (p_tclv_rec.line_number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'line_number');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Line_Number;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Object_Version_Number
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number (p_tclv_rec      IN  tclv_rec_type
                                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.object_version_number IS NULL) OR
       (p_tclv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'object_version_number');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tcl_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Tcl_Type
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tcl_Type (p_tclv_rec      IN  tclv_rec_type
                               ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.tcl_type IS NULL) OR
       (p_tclv_rec.tcl_type = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'tcl_type');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                   (p_lookup_type  => 'OKL_TCL_TYPE',
                    p_lookup_code  => p_tclv_rec.tcl_type);
    --dbms_output.put_line('TCL TYpe Is ' || p_tclv_rec.tcl_type);
    --dbms_output.put_line('l_dummy is ' || l_dummy);

    IF (l_dummy = OKC_API.G_FALSE) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'tcl_type');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_tcl_Type;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_GL_Reversal_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_GL_Reversal_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_GL_Reversal_YN(p_tclv_rec      IN      tclv_rec_type
						   ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := OKL_API.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id  NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.gl_reversal_yn IS NOT NULL) AND
       (p_tclv_rec.gl_reversal_yn <>  OKC_API.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                            p_lookup_type => 'YES_NO',
                            p_lookup_code => p_tclv_rec.gl_reversal_yn,
                            p_app_id      => l_app_id,
                            p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'gl_reversal_yn');
          x_return_status    := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_GL_Reversal_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_currency_code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_currency_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_currency_code(p_tclv_rec      IN      tclv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKL_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.currency_code IS NULL) OR
       (p_tclv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'currency_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	l_return_status := OKL_ACCOUNTING_UTIL.VALIDATE_CURRENCY_CODE (
				p_tclv_rec.currency_code);

	IF l_return_status = okl_api.g_false THEN
	      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'CURRENCY_CODE');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_currency_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amount
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Amount
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Amount (p_tclv_rec      IN  tclv_rec_type
                                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.amount IS NULL) OR
       (p_tclv_rec.amount = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'amount');
       x_return_status     := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Amount;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AVL_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_AVL_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AVL_Id (p_tclv_rec IN  tclv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR avl_csr (v_avl_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_AE_TEMPLATES
  WHERE id = v_avl_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tclv_rec.avl_id IS NOT NULL) AND
       (p_tclv_rec.avl_id <> OKC_API.G_MISS_NUM) THEN

        OPEN avl_csr(p_tclv_rec.AVL_ID);
        FETCH avl_csr INTO l_dummy_var;
        l_row_notfound := avl_csr%NOTFOUND;
        CLOSE avl_csr;

        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AVL_ID');
          RAISE item_not_found_error;
        END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Validate_AVL_ID;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_BKT_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_BKT_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_BKT_Id (p_tclv_rec IN  tclv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR bkt_csr (v_bkt_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_BUCKETS_V
  WHERE id = v_bkt_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_tclv_rec.bkt_id IS NOT NULL) AND
       (p_tclv_rec.bkt_id <> OKC_API.G_MISS_NUM) THEN

        OPEN bkt_csr(p_tclv_rec.BKT_ID);
        FETCH bkt_csr INTO l_dummy_var;
        l_row_notfound := bkt_csr%NOTFOUND;
        CLOSE bkt_csr;

        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BKT_ID');
          RAISE item_not_found_error;
        END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END Validate_BKT_ID;


-- Added by Santonyr Bug : 2305542
---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id_New
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Kle_Id_New
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Kle_Id_New (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM okl_k_lines_v
  WHERE okl_k_lines_v.id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.kle_id_new IS NOT NULL) AND
       (p_tclv_rec.kle_id_new <> OKC_API.G_MISS_NUM) THEN
        OPEN okl_tclv_fk_csr(p_tclv_rec.kle_id_new);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN,'KLE_ID_NEW');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Kle_Id_New;

    -- Added by Santonyr Bug : 2305542
---------------------------------------------------------------------------
  -- PROCEDURE Validate_Percentage
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Percentage
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Percentage (p_tclv_rec IN  tclv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.percentage IS NOT NULL) AND
       (p_tclv_rec.percentage <> OKC_API.G_MISS_NUM) THEN
       IF ((p_tclv_rec.percentage < 0) OR
          (p_tclv_rec.percentage > 100)) THEN
            OKC_API.set_message(G_APP_NAME, 'OKL_LLA_PERCENT');
            RAISE item_not_found_error;
       END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Percentage;

  ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Accrual_Rule_YN
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name   : Validate_Accrual_Rule_YN
    -- Description      :
    -- Business Rules   :
    -- Parameters       :
    -- Version          : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Accrual_Rule_YN(p_tclv_rec      IN      tclv_rec_type
    				      ,x_return_status OUT NOCOPY     VARCHAR2)
      IS

      l_dummy         VARCHAR2(1)  := OKL_API.G_FALSE;
      l_app_id        NUMBER := 0;
      l_view_app_id  NUMBER := 0;

      BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- check for data before processing
        IF (p_tclv_rec.accrual_rule_yn IS NOT NULL) AND
           (p_tclv_rec.accrual_rule_yn <>  OKC_API.G_MISS_CHAR) THEN
           -- check in fnd_lookups for validity

           l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(
                                p_lookup_type => 'YES_NO',
                                p_lookup_code => p_tclv_rec.accrual_rule_yn,
                                p_app_id      => l_app_id,
                                p_view_app_id => l_view_app_id);

           IF (l_dummy = OKL_API.G_FALSE) THEN
              OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                                 ,p_msg_name       => g_invalid_value
                                 ,p_token1         => g_col_name_token
                                 ,p_token1_value   => 'accrual_rule_yn');
              x_return_status    := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;


      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing neccessary; validation can continue
        -- with the next column
        NULL;

        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);

          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Accrual_Rule_YN;

-- Added by zrehman for SLA project (Bug 5707866) 16-Feb-2007  start
  ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Asset_Book_Type_Name
    ---------------------------------------------------------------------------
    -- Start of comments
    -- Procedure Name   : Validate_Asset_Book_Type_Name
    -- Description      :
    -- Business Rules   :
    -- Parameters       :
    -- Version          : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Asset_Book_Type_Name(p_tclv_rec      IN      tclv_rec_type
    				            ,x_return_status OUT NOCOPY     VARCHAR2)
      IS

      l_found        VARCHAR2(1);
      l_app_id       NUMBER := 0;
      l_view_app_id  NUMBER := 0;

      CURSOR book_type_csr(bk_type_name fa_book_controls.BOOK_TYPE_NAME%TYPE) IS
      SELECT '1'
      FROM fa_book_controls
      WHERE BOOK_TYPE_NAME = bk_type_name;

      BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- check for data before processing
        IF (p_tclv_rec.asset_book_type_name IS NOT NULL) AND
           (p_tclv_rec.asset_book_type_name <>  OKC_API.G_MISS_CHAR) THEN

         OPEN book_type_csr(p_tclv_rec.asset_book_type_name);
	 FETCH book_type_csr into l_found;
         CLOSE book_type_csr;

           IF l_found IS NULL THEN
              OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                                 ,p_msg_name       => g_invalid_value
                                 ,p_token1         => g_col_name_token
                                 ,p_token1_value   => 'asset_book_type_name');
              x_return_status    := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;


      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing neccessary; validation can continue
        -- with the next column
        NULL;

        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);

          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Asset_Book_Type_Name;

-- Added by zrehman for SLA project (Bug 5707866) 20-Mar-2007  start
  ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Tax_Line_Id
    ---------------------------------------------------------------------------
    -- Start of comments
    -- Procedure Name   : Validate_Tax_Line_Id
    -- Description      :
    -- Business Rules   :
    -- Parameters       :
    -- Version          : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Tax_Line_Id(p_tclv_rec      IN      tclv_rec_type
    				   ,x_return_status OUT NOCOPY     VARCHAR2)
      IS

      l_found        VARCHAR2(1);
      l_app_id       NUMBER := 0;
      l_view_app_id  NUMBER := 0;

      CURSOR tax_line_id_csr(p_tax_line_id zx_lines.TAX_LINE_ID%TYPE) IS
      SELECT '1'
      FROM zx_lines
      WHERE TAX_LINE_ID = p_tax_line_id;

      BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- check for data before processing
        IF (p_tclv_rec.tax_line_id IS NOT NULL) AND
           (p_tclv_rec.tax_line_id <>  OKC_API.G_MISS_NUM) THEN

          OPEN tax_line_id_csr(p_tclv_rec.tax_line_id);
	  FETCH tax_line_id_csr into l_found;
          CLOSE tax_line_id_csr;

           IF l_found IS NULL THEN
              OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                                 ,p_msg_name       => g_invalid_value
                                 ,p_token1         => g_col_name_token
                                 ,p_token1_value   => 'tax_line_id');
              x_return_status    := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;


      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing neccessary; validation can continue
        -- with the next column
        NULL;

        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);

          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Tax_Line_Id;
-- Added by zrehman for SLA project (Bug 5707866) 20-Mar-2007 end

-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
---------------------------------------------------------------------------
  -- PROCEDURE Validate_Upgrade_Status_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Upgrade_Status_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Upgrade_Status_Flag (p_tclv_rec IN tclv_rec_type, x_return_status OUT NOCOPY VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tclv_rec.UPGRADE_STATUS_FLAG IS NOT NULL) AND
       (p_tclv_rec.UPGRADE_STATUS_FLAG <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_YES_NO',
                               p_lookup_code => p_tclv_rec.UPGRADE_STATUS_FLAG);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'UPGRADE_STATUS_FLAG');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Upgrade_Status_Flag;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_tclv_rec IN  tclv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Khr_Id
    Validate_Khr_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Tcn_Id
    Validate_Tcn_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Rct_Id
    Validate_Rct_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Btc_Id
    Validate_Btc_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Sty_Id
    Validate_Sty_Id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Line_Number
    Validate_Line_Number(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Tcl_Type
    Validate_Tcl_Type(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_GL_Reversal_YN
    Validate_GL_Reversal_YN(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Amount
/*  This validation Removed, since in some cases lines are created without Amount
    Amount may be plugged in later
    Validate_Amount(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
*/

    -- Validate_currency_code
    Validate_currency_code(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_avl_id
    Validate_avl_id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_bkt_id
    Validate_bkt_id(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Kle_Id_New
    -- Added by Santonyr Bug : 2305542
    Validate_Kle_Id_New(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Percentage
    -- Added by Santonyr Bug : 2305542
    Validate_Percentage(p_tclv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Accrual_Rule_YN
        Validate_Accrual_Rule_YN(p_tclv_rec, x_return_status);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
    END IF;

    -- Added by zrehman for SLA project (Bug 5707866) 16-Feb-2007
        Validate_Asset_Book_Type_Name(p_tclv_rec, x_return_status);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
    END IF;

    -- Added by zrehman for SLA project (Bug 5707866) 20-Mar-2007
        Validate_Tax_Line_Id(p_tclv_rec, x_return_status);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
    END IF;
    -- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
        Validate_Upgrade_Status_Flag(p_tclv_rec, x_return_status);
        IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
    END IF;


    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_tclv_rec IN tclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

-- Added by santonyr on 11-Jun-2003 to fix bug 2999776
    -- Validate_Unique_Bkt_Record
      Validate_Unique_Tcl_Record(x_return_status, p_tclv_rec );
      -- store the highest degree of error
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to leave
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            -- record that there was an error
            l_return_status := x_return_status;
        END IF;
      END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Record;

  /*********************** END MANUAL CODE **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tclv_rec_type,
    p_to	IN OUT NOCOPY tcl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.before_transfer_yn := p_from.before_transfer_yn;
    p_to.tcn_id := p_from.tcn_id;
    p_to.rct_id := p_from.rct_id;
    p_to.btc_id := p_from.btc_id;
    p_to.sty_id := p_from.sty_id;
    p_to.line_number := p_from.line_number;
    p_to.tcl_type := p_from.tcl_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.org_id := p_from.org_id;
    p_to.description := p_from.description;
    p_to.program_id := p_from.program_id;
    p_to.gl_reversal_yn := p_from.gl_reversal_yn;
    p_to.amount := p_from.amount;
    p_to.program_application_id := p_from.program_application_id;
    p_to.currency_code := p_from.currency_code;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_to.last_update_login := p_from.last_update_login;
    p_to.avl_id := p_from.avl_id;
    p_to.bkt_id := p_from.bkt_id;
    p_to.kle_id_new := p_from.kle_id_new;
    p_to.percentage := p_from.percentage;
    p_to.accrual_rule_yn := p_from.accrual_rule_yn;
    --21 Oct 2004 PAGARG Bug# 3964726
    p_to.source_column_1 := p_from.source_column_1;
    p_to.source_value_1 := p_from.source_value_1;
    p_to.source_column_2 := p_from.source_column_2;
    p_to.source_value_2 := p_from.source_value_2;
    p_to.source_column_3 := p_from.source_column_3;
    p_to.source_value_3 := p_from.source_value_3;
    p_to.canceled_date := p_from.canceled_date;
    p_to.tax_line_id := p_from.tax_line_id;
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
    p_to.stream_type_code := p_from.stream_type_code;
    p_to.stream_type_purpose := p_from.stream_type_purpose;
    p_to.asset_book_type_name := p_from.asset_book_type_name;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tcl_rec_type,
    p_to	IN OUT NOCOPY tclv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.before_transfer_yn := p_from.before_transfer_yn;
    p_to.tcn_id := p_from.tcn_id;
    p_to.rct_id := p_from.rct_id;
    p_to.btc_id := p_from.btc_id;
    p_to.sty_id := p_from.sty_id;
    p_to.line_number := p_from.line_number;
    p_to.tcl_type := p_from.tcl_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.org_id := p_from.org_id;
    p_to.description := p_from.description;
    p_to.program_id := p_from.program_id;
    p_to.gl_reversal_yn := p_from.gl_reversal_yn;
    p_to.amount := p_from.amount;
    p_to.program_application_id := p_from.program_application_id;
    p_to.currency_code := p_from.currency_code;
    p_to.request_id := p_from.request_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_to.last_update_login := p_from.last_update_login;
    p_to.avl_id := p_from.avl_id;
    p_to.bkt_id := p_from.bkt_id;
    p_to.kle_id_new := p_from.kle_id_new;
    p_to.percentage := p_from.percentage;
    p_to.accrual_rule_yn := p_from.accrual_rule_yn;
    --21 Oct 2004 PAGARG Bug# 3964726
    p_to.source_column_1 := p_from.source_column_1;
    p_to.source_value_1 := p_from.source_value_1;
    p_to.source_column_2 := p_from.source_column_2;
    p_to.source_value_2 := p_from.source_value_2;
    p_to.source_column_3 := p_from.source_column_3;
    p_to.source_value_3 := p_from.source_value_3;
    p_to.canceled_date := p_from.canceled_date;
    p_to.tax_line_id := p_from.tax_line_id;
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    p_to.stream_type_code := p_from.stream_type_code;
    p_to.stream_type_purpose := p_from.stream_type_purpose;
    p_to.asset_book_type_name := p_from.asset_book_type_name;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_TXL_CNTRCT_LNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_rec                     tclv_rec_type := p_tclv_rec;
    l_tcl_rec                      tcl_rec_type;
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
    l_return_status := Validate_Attributes(l_tclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tclv_rec);
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
  -- PL/SQL TBL validate_row for:TCLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

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
  ---------------------------------------
  -- insert_row for:OKL_TXL_CNTRCT_LNS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcl_rec                      IN tcl_rec_type,
    x_tcl_rec                      OUT NOCOPY tcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcl_rec                      tcl_rec_type := p_tcl_rec;
    l_def_tcl_rec                  tcl_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_TXL_CNTRCT_LNS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_tcl_rec IN  tcl_rec_type,
      x_tcl_rec OUT NOCOPY tcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcl_rec := p_tcl_rec;
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
      p_tcl_rec,                         -- IN
      l_tcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_CNTRCT_LNS(
        id,
        khr_id,
        kle_id,
        before_transfer_yn,
        tcn_id,
        rct_id,
        btc_id,
        sty_id,
        line_number,
        tcl_type,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        org_id,
        description,
        program_id,
        gl_reversal_yn,
        amount,
        program_application_id,
        currency_code,
        request_id,
        program_update_date,
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
        last_update_login,
        avl_id,
        bkt_id,
        kle_id_new,
        percentage,
        accrual_rule_yn,
        --21 Oct 2004 PAGARG Bug# 3964726
        source_column_1,
        source_value_1,
        source_column_2,
        source_value_2,
        source_column_3,
        source_value_3,
        canceled_date,
	tax_line_id,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
        stream_type_code,
        stream_type_purpose,
	asset_book_type_name,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
        UPGRADE_STATUS_FLAG)
      VALUES (
        l_tcl_rec.id,
        l_tcl_rec.khr_id,
        l_tcl_rec.kle_id,
        l_tcl_rec.before_transfer_yn,
        l_tcl_rec.tcn_id,
        l_tcl_rec.rct_id,
        l_tcl_rec.btc_id,
        l_tcl_rec.sty_id,
        l_tcl_rec.line_number,
        l_tcl_rec.tcl_type,
        l_tcl_rec.object_version_number,
        l_tcl_rec.created_by,
        l_tcl_rec.creation_date,
        l_tcl_rec.last_updated_by,
        l_tcl_rec.last_update_date,
        l_tcl_rec.org_id,
        l_tcl_rec.description,
        l_tcl_rec.program_id,
        l_tcl_rec.gl_reversal_yn,
        l_tcl_rec.amount,
        l_tcl_rec.program_application_id,
        l_tcl_rec.currency_code,
        l_tcl_rec.request_id,
        l_tcl_rec.program_update_date,
        l_tcl_rec.attribute_category,
        l_tcl_rec.attribute1,
        l_tcl_rec.attribute2,
        l_tcl_rec.attribute3,
        l_tcl_rec.attribute4,
        l_tcl_rec.attribute5,
        l_tcl_rec.attribute6,
        l_tcl_rec.attribute7,
        l_tcl_rec.attribute8,
        l_tcl_rec.attribute9,
        l_tcl_rec.attribute10,
        l_tcl_rec.attribute11,
        l_tcl_rec.attribute12,
        l_tcl_rec.attribute13,
        l_tcl_rec.attribute14,
        l_tcl_rec.attribute15,
        l_tcl_rec.last_update_login,
        l_tcl_rec.avl_id,
        l_tcl_rec.bkt_id,
        l_tcl_rec.kle_id_new,
        l_tcl_rec.percentage,
        l_tcl_rec.accrual_rule_yn,
        --21 Oct 2004 PAGARG Bug# 3964726
        l_tcl_rec.source_column_1,
        l_tcl_rec.source_value_1,
        l_tcl_rec.source_column_2,
        l_tcl_rec.source_value_2,
        l_tcl_rec.source_column_3,
        l_tcl_rec.source_value_3,
        l_tcl_rec.canceled_date,
	l_tcl_rec.tax_line_id,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
        l_tcl_rec.stream_type_code,
        l_tcl_rec.stream_type_purpose,
	l_tcl_rec.asset_book_type_name,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
        l_tcl_rec.UPGRADE_STATUS_FLAG);
    -- Set OUT values
    x_tcl_rec := l_tcl_rec;
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
  -----------------------------------------
  -- insert_row for:OKL_TXL_CNTRCT_LNS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type,
    x_tclv_rec                     OUT NOCOPY tclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_rec                     tclv_rec_type;
    l_def_tclv_rec                 tclv_rec_type;
    l_tcl_rec                      tcl_rec_type;
    lx_tcl_rec                     tcl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tclv_rec	IN tclv_rec_type
    ) RETURN tclv_rec_type IS
      l_tclv_rec	tclv_rec_type := p_tclv_rec;
    BEGIN
      l_tclv_rec.CREATION_DATE := SYSDATE;
      l_tclv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tclv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_CNTRCT_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tclv_rec IN  tclv_rec_type,
      x_tclv_rec OUT NOCOPY tclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_request_id 	NUMBER 	:= Fnd_Global.CONC_REQUEST_ID;
	l_prog_app_id 	NUMBER 	:= Fnd_Global.PROG_APPL_ID;
	l_program_id 	NUMBER 	:= Fnd_Global.CONC_PROGRAM_ID;


-- Added by Santonyr on 25-Nov-2002
-- Cursor to fetch the currency code of a transaction

	CURSOR trx_curr_csr (l_id NUMBER) IS
	SELECT currency_code
	FROM okl_trx_contracts
	WHERE id = l_id;

    BEGIN
      x_tclv_rec := p_tclv_rec;
      x_tclv_rec.OBJECT_VERSION_NUMBER := 1;

      x_tclv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

      SELECT DECODE(l_request_id, -1, NULL, l_request_id),
      	DECODE(l_prog_app_id, -1, NULL, l_prog_app_id),
	      DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
	      DECODE(l_request_id, -1, NULL, SYSDATE)
      INTO  x_tclv_rec.REQUEST_ID
          	,x_tclv_rec.PROGRAM_APPLICATION_ID
          	,x_tclv_rec.PROGRAM_ID
          	,x_tclv_rec.PROGRAM_UPDATE_DATE
     	FROM DUAL;

-- Commented out by Santonyr on 25-Nov-2002
-- Multi-Currency Changes - The currency code of the transaction line will
-- be the currency code of the transaction.

/*
	IF (x_tclv_rec.currency_code IS NULL) OR
           (x_tclv_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
            x_tclv_rec.currency_code := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
        END IF;
*/

-- Added by Santonyr on 25-Nov-2002
-- If the passed currency code is null get the code from contract transactions

	IF (x_tclv_rec.currency_code IS NULL) OR (x_tclv_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
	     FOR  trx_curr_rec IN trx_curr_csr (p_tclv_rec.tcn_id) LOOP
	       x_tclv_rec.currency_code := trx_curr_rec.currency_code;
	     END LOOP;
        END IF;
-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
        x_tclv_rec.UPGRADE_STATUS_FLAG := 'N';
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
    l_tclv_rec := null_out_defaults(p_tclv_rec);
    -- Set primary key value
    l_tclv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tclv_rec,                        -- IN
      l_def_tclv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tclv_rec := fill_who_columns(l_def_tclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tclv_rec, l_tcl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcl_rec,
      lx_tcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcl_rec, l_def_tclv_rec);
    -- Set OUT values
    x_tclv_rec := l_def_tclv_rec;
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
  -- PL/SQL TBL insert_row for:TCLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type,
    x_tclv_tbl                     OUT NOCOPY tclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i),
          x_tclv_rec                     => x_tclv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

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
  -------------------------------------
  -- lock_row for:OKL_TXL_CNTRCT_LNS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcl_rec                      IN tcl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tcl_rec IN tcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_CNTRCT_LNS
     WHERE ID = p_tcl_rec.id
       AND OBJECT_VERSION_NUMBER = p_tcl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tcl_rec IN tcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_CNTRCT_LNS
    WHERE ID = p_tcl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_CNTRCT_LNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_CNTRCT_LNS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_tcl_rec);
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
      OPEN lchk_csr(p_tcl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tcl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tcl_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_CNTRCT_LNS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcl_rec                      tcl_rec_type;
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
    migrate(p_tclv_rec, l_tcl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcl_rec
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
  -- PL/SQL TBL lock_row for:TCLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

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
  ---------------------------------------
  -- update_row for:OKL_TXL_CNTRCT_LNS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcl_rec                      IN tcl_rec_type,
    x_tcl_rec                      OUT NOCOPY tcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcl_rec                      tcl_rec_type := p_tcl_rec;
    l_def_tcl_rec                  tcl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tcl_rec	IN tcl_rec_type,
      x_tcl_rec	OUT NOCOPY tcl_rec_type
    ) RETURN VARCHAR2 IS
      l_tcl_rec                      tcl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcl_rec := p_tcl_rec;
      -- Get current database values
      l_tcl_rec := get_rec(p_tcl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tcl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.id := l_tcl_rec.id;
      END IF;
      IF (x_tcl_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.khr_id := l_tcl_rec.khr_id;
      END IF;
      IF (x_tcl_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.kle_id := l_tcl_rec.kle_id;
      END IF;
      IF (x_tcl_rec.before_transfer_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.before_transfer_yn := l_tcl_rec.before_transfer_yn;
      END IF;
      IF (x_tcl_rec.tcn_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.tcn_id := l_tcl_rec.tcn_id;
      END IF;
      IF (x_tcl_rec.rct_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.rct_id := l_tcl_rec.rct_id;
      END IF;
      IF (x_tcl_rec.btc_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.btc_id := l_tcl_rec.btc_id;
      END IF;
      IF (x_tcl_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.sty_id := l_tcl_rec.sty_id;
      END IF;
      IF (x_tcl_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.line_number := l_tcl_rec.line_number;
      END IF;
      IF (x_tcl_rec.tcl_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.tcl_type := l_tcl_rec.tcl_type;
      END IF;
      IF (x_tcl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.object_version_number := l_tcl_rec.object_version_number;
      END IF;
      IF (x_tcl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.created_by := l_tcl_rec.created_by;
      END IF;
      IF (x_tcl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcl_rec.creation_date := l_tcl_rec.creation_date;
      END IF;
      IF (x_tcl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.last_updated_by := l_tcl_rec.last_updated_by;
      END IF;
      IF (x_tcl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcl_rec.last_update_date := l_tcl_rec.last_update_date;
      END IF;
      IF (x_tcl_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.org_id := l_tcl_rec.org_id;
      END IF;
      IF (x_tcl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.description := l_tcl_rec.description;
      END IF;
      IF (x_tcl_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.program_id := l_tcl_rec.program_id;
      END IF;
      IF (x_tcl_rec.gl_reversal_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.gl_reversal_yn := l_tcl_rec.gl_reversal_yn;
      END IF;
      IF (x_tcl_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.amount := l_tcl_rec.amount;
      END IF;
      IF (x_tcl_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.program_application_id := l_tcl_rec.program_application_id;
      END IF;
      IF (x_tcl_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.currency_code := l_tcl_rec.currency_code;
      END IF;
      IF (x_tcl_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.request_id := l_tcl_rec.request_id;
      END IF;
      IF (x_tcl_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcl_rec.program_update_date := l_tcl_rec.program_update_date;
      END IF;
      IF (x_tcl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute_category := l_tcl_rec.attribute_category;
      END IF;
      IF (x_tcl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute1 := l_tcl_rec.attribute1;
      END IF;
      IF (x_tcl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute2 := l_tcl_rec.attribute2;
      END IF;
      IF (x_tcl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute3 := l_tcl_rec.attribute3;
      END IF;
      IF (x_tcl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute4 := l_tcl_rec.attribute4;
      END IF;
      IF (x_tcl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute5 := l_tcl_rec.attribute5;
      END IF;
      IF (x_tcl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute6 := l_tcl_rec.attribute6;
      END IF;
      IF (x_tcl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute7 := l_tcl_rec.attribute7;
      END IF;
      IF (x_tcl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute8 := l_tcl_rec.attribute8;
      END IF;
      IF (x_tcl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute9 := l_tcl_rec.attribute9;
      END IF;
      IF (x_tcl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute10 := l_tcl_rec.attribute10;
      END IF;
      IF (x_tcl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute11 := l_tcl_rec.attribute11;
      END IF;
      IF (x_tcl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute12 := l_tcl_rec.attribute12;
      END IF;
      IF (x_tcl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute13 := l_tcl_rec.attribute13;
      END IF;
      IF (x_tcl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute14 := l_tcl_rec.attribute14;
      END IF;
      IF (x_tcl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.attribute15 := l_tcl_rec.attribute15;
      END IF;
      IF (x_tcl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.last_update_login := l_tcl_rec.last_update_login;
      END IF;
      IF (x_tcl_rec.avl_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.avl_id := l_tcl_rec.avl_id;
      END IF;
      IF (x_tcl_rec.bkt_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.bkt_id := l_tcl_rec.bkt_id;
      END IF;
      IF (x_tcl_rec.kle_id_new = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.kle_id_new := l_tcl_rec.kle_id_new;
      END IF;
      IF (x_tcl_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.percentage := l_tcl_rec.percentage;
      END IF;
      IF (x_tcl_rec.accrual_rule_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.accrual_rule_yn := l_tcl_rec.accrual_rule_yn;
      END IF;
      --21 Oct 2004 PAGARG Bug# 3964726
      IF (x_tcl_rec.source_column_1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.source_column_1 := l_tcl_rec.source_column_1;
      END IF;
      IF (x_tcl_rec.source_value_1 = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.source_value_1 := l_tcl_rec.source_value_1;
      END IF;
      IF (x_tcl_rec.source_column_2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.source_column_2 := l_tcl_rec.source_column_2;
      END IF;
      IF (x_tcl_rec.source_value_2 = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.source_value_2 := l_tcl_rec.source_value_2;
      END IF;
      IF (x_tcl_rec.source_column_3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.source_column_3 := l_tcl_rec.source_column_3;
      END IF;
      IF (x_tcl_rec.source_value_3 = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.source_value_3 := l_tcl_rec.source_value_3;
      END IF;
      IF (x_tcl_rec.canceled_date = OKC_API.G_MISS_DATE)
      THEN
        x_tcl_rec.canceled_date := l_tcl_rec.canceled_date;
      END IF;
      IF (x_tcl_rec.tax_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_tcl_rec.tax_line_id := l_tcl_rec.tax_line_id;
      END IF;
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
      IF (x_tcl_rec.stream_type_purpose = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.stream_type_purpose := l_tcl_rec.stream_type_purpose;
      END IF;
      IF (x_tcl_rec.stream_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.stream_type_code := l_tcl_rec.stream_type_code;
      END IF;
      IF (x_tcl_rec.asset_book_type_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.asset_book_type_name := l_tcl_rec.asset_book_type_name;
      END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
      IF (x_tcl_rec.UPGRADE_STATUS_FLAG = OKC_API.G_MISS_CHAR)
      THEN
        x_tcl_rec.UPGRADE_STATUS_FLAG := l_tcl_rec.UPGRADE_STATUS_FLAG;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_TXL_CNTRCT_LNS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_tcl_rec IN  tcl_rec_type,
      x_tcl_rec OUT NOCOPY tcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tcl_rec := p_tcl_rec;
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
      p_tcl_rec,                         -- IN
      l_tcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tcl_rec, l_def_tcl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_CNTRCT_LNS
    SET KHR_ID = l_def_tcl_rec.khr_id,
        KLE_ID = l_def_tcl_rec.kle_id,
        BEFORE_TRANSFER_YN = l_def_tcl_rec.before_transfer_yn,
        TCN_ID = l_def_tcl_rec.tcn_id,
        RCT_ID = l_def_tcl_rec.rct_id,
        BTC_ID = l_def_tcl_rec.btc_id,
        STY_ID = l_def_tcl_rec.sty_id,
        LINE_NUMBER = l_def_tcl_rec.line_number,
        TCL_TYPE = l_def_tcl_rec.tcl_type,
        OBJECT_VERSION_NUMBER = l_def_tcl_rec.object_version_number,
        CREATED_BY = l_def_tcl_rec.created_by,
        CREATION_DATE = l_def_tcl_rec.creation_date,
        LAST_UPDATED_BY = l_def_tcl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tcl_rec.last_update_date,
        ORG_ID = l_def_tcl_rec.org_id,
        DESCRIPTION = l_def_tcl_rec.description,
        PROGRAM_ID = l_def_tcl_rec.program_id,
        GL_REVERSAL_YN = l_def_tcl_rec.gl_reversal_yn,
        AMOUNT = l_def_tcl_rec.amount,
        PROGRAM_APPLICATION_ID = l_def_tcl_rec.program_application_id,
        currency_code = l_def_tcl_rec.currency_code,
        REQUEST_ID = l_def_tcl_rec.request_id,
        PROGRAM_UPDATE_DATE = l_def_tcl_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_tcl_rec.attribute_category,
        ATTRIBUTE1 = l_def_tcl_rec.attribute1,
        ATTRIBUTE2 = l_def_tcl_rec.attribute2,
        ATTRIBUTE3 = l_def_tcl_rec.attribute3,
        ATTRIBUTE4 = l_def_tcl_rec.attribute4,
        ATTRIBUTE5 = l_def_tcl_rec.attribute5,
        ATTRIBUTE6 = l_def_tcl_rec.attribute6,
        ATTRIBUTE7 = l_def_tcl_rec.attribute7,
        ATTRIBUTE8 = l_def_tcl_rec.attribute8,
        ATTRIBUTE9 = l_def_tcl_rec.attribute9,
        ATTRIBUTE10 = l_def_tcl_rec.attribute10,
        ATTRIBUTE11 = l_def_tcl_rec.attribute11,
        ATTRIBUTE12 = l_def_tcl_rec.attribute12,
        ATTRIBUTE13 = l_def_tcl_rec.attribute13,
        ATTRIBUTE14 = l_def_tcl_rec.attribute14,
        ATTRIBUTE15 = l_def_tcl_rec.attribute15,
        LAST_UPDATE_LOGIN = l_def_tcl_rec.last_update_login,
        AVL_ID = l_def_tcl_rec.avl_id,
        BKT_ID = l_def_tcl_rec.bkt_id,
        KLE_ID_NEW = l_def_tcl_rec.kle_id_new,
        PERCENTAGE = l_def_tcl_rec.percentage,
        ACCRUAL_RULE_YN = l_def_tcl_rec.accrual_rule_yn,
        --21 Oct 2004 PAGARG Bug# 3964726
        SOURCE_COLUMN_1 = l_def_tcl_rec.SOURCE_COLUMN_1,
        SOURCE_VALUE_1 = l_def_tcl_rec.SOURCE_VALUE_1,
        SOURCE_COLUMN_2 = l_def_tcl_rec.SOURCE_COLUMN_2,
        SOURCE_VALUE_2 = l_def_tcl_rec.SOURCE_VALUE_2,
        SOURCE_COLUMN_3 = l_def_tcl_rec.SOURCE_COLUMN_3,
        SOURCE_VALUE_3 = l_def_tcl_rec.SOURCE_VALUE_3,
        CANCELED_DATE = l_def_tcl_rec.CANCELED_DATE,
	TAX_LINE_ID = l_def_tcl_rec.TAX_LINE_ID,
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
	STREAM_TYPE_PURPOSE = l_def_tcl_rec.STREAM_TYPE_PURPOSE,
	STREAM_TYPE_CODE = l_def_tcl_rec.STREAM_TYPE_CODE,
	ASSET_BOOK_TYPE_NAME = l_def_tcl_rec.ASSET_BOOK_TYPE_NAME,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
        UPGRADE_STATUS_FLAG = l_def_tcl_rec.UPGRADE_STATUS_FLAG
    WHERE ID = l_def_tcl_rec.id;

    x_tcl_rec := l_def_tcl_rec;
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
  -----------------------------------------
  -- update_row for:OKL_TXL_CNTRCT_LNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type,
    x_tclv_rec                     OUT NOCOPY tclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_rec                     tclv_rec_type := p_tclv_rec;
    l_def_tclv_rec                 tclv_rec_type;
    l_tcl_rec                      tcl_rec_type;
    lx_tcl_rec                     tcl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tclv_rec	IN tclv_rec_type
    ) RETURN tclv_rec_type IS
      l_tclv_rec	tclv_rec_type := p_tclv_rec;
    BEGIN
      l_tclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tclv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tclv_rec	IN tclv_rec_type,
      x_tclv_rec	OUT NOCOPY tclv_rec_type
    ) RETURN VARCHAR2 IS
      l_tclv_rec                     tclv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tclv_rec := p_tclv_rec;
      -- Get current database values
      l_tclv_rec := get_rec(p_tclv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tclv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.id := l_tclv_rec.id;
      END IF;
      IF (x_tclv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.object_version_number := l_tclv_rec.object_version_number;
      END IF;
      IF (x_tclv_rec.sty_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.sty_id := l_tclv_rec.sty_id;
      END IF;
      IF (x_tclv_rec.rct_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.rct_id := l_tclv_rec.rct_id;
      END IF;
      IF (x_tclv_rec.btc_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.btc_id := l_tclv_rec.btc_id;
      END IF;
      IF (x_tclv_rec.tcn_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.tcn_id := l_tclv_rec.tcn_id;
      END IF;
      IF (x_tclv_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.khr_id := l_tclv_rec.khr_id;
      END IF;
      IF (x_tclv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.kle_id := l_tclv_rec.kle_id;
      END IF;
      IF (x_tclv_rec.before_transfer_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.before_transfer_yn := l_tclv_rec.before_transfer_yn;
      END IF;
      IF (x_tclv_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.line_number := l_tclv_rec.line_number;
      END IF;
      IF (x_tclv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.description := l_tclv_rec.description;
      END IF;
      IF (x_tclv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.amount := l_tclv_rec.amount;
      END IF;
      IF (x_tclv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.currency_code := l_tclv_rec.currency_code;
      END IF;
      IF (x_tclv_rec.gl_reversal_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.gl_reversal_yn := l_tclv_rec.gl_reversal_yn;
      END IF;
      IF (x_tclv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute_category := l_tclv_rec.attribute_category;
      END IF;
      IF (x_tclv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute1 := l_tclv_rec.attribute1;
      END IF;
      IF (x_tclv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute2 := l_tclv_rec.attribute2;
      END IF;
      IF (x_tclv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute3 := l_tclv_rec.attribute3;
      END IF;
      IF (x_tclv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute4 := l_tclv_rec.attribute4;
      END IF;
      IF (x_tclv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute5 := l_tclv_rec.attribute5;
      END IF;
      IF (x_tclv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute6 := l_tclv_rec.attribute6;
      END IF;
      IF (x_tclv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute7 := l_tclv_rec.attribute7;
      END IF;
      IF (x_tclv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute8 := l_tclv_rec.attribute8;
      END IF;
      IF (x_tclv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute9 := l_tclv_rec.attribute9;
      END IF;
      IF (x_tclv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute10 := l_tclv_rec.attribute10;
      END IF;
      IF (x_tclv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute11 := l_tclv_rec.attribute11;
      END IF;
      IF (x_tclv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute12 := l_tclv_rec.attribute12;
      END IF;
      IF (x_tclv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute13 := l_tclv_rec.attribute13;
      END IF;
      IF (x_tclv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute14 := l_tclv_rec.attribute14;
      END IF;
      IF (x_tclv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.attribute15 := l_tclv_rec.attribute15;
      END IF;
      IF (x_tclv_rec.tcl_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.tcl_type := l_tclv_rec.tcl_type;
      END IF;
      IF (x_tclv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.created_by := l_tclv_rec.created_by;
      END IF;
      IF (x_tclv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tclv_rec.creation_date := l_tclv_rec.creation_date;
      END IF;
      IF (x_tclv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.last_updated_by := l_tclv_rec.last_updated_by;
      END IF;
      IF (x_tclv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tclv_rec.last_update_date := l_tclv_rec.last_update_date;
      END IF;
      IF (x_tclv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.org_id := l_tclv_rec.org_id;
      END IF;
      IF (x_tclv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.program_id := l_tclv_rec.program_id;
      END IF;
      IF (x_tclv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.program_application_id := l_tclv_rec.program_application_id;
      END IF;
      IF (x_tclv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.request_id := l_tclv_rec.request_id;
      END IF;
      IF (x_tclv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tclv_rec.program_update_date := l_tclv_rec.program_update_date;
      END IF;
      IF (x_tclv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.last_update_login := l_tclv_rec.last_update_login;
      END IF;
      IF (x_tclv_rec.avl_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.avl_id := l_tclv_rec.avl_id;
      END IF;
      IF (x_tclv_rec.bkt_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.bkt_id := l_tclv_rec.bkt_id;
      END IF;
      IF (x_tclv_rec.kle_id_new = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.kle_id_new := l_tclv_rec.kle_id_new;
      END IF;
      IF (x_tclv_rec.percentage = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.percentage := l_tclv_rec.percentage;
      END IF;
      IF (x_tclv_rec.accrual_rule_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.accrual_rule_yn := l_tclv_rec.accrual_rule_yn;
      END IF;
      --21 Oct 2004 PAGARG Bug# 3964726
      IF (x_tclv_rec.source_column_1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.source_column_1 := l_tclv_rec.source_column_1;
      END IF;
      IF (x_tclv_rec.source_value_1 = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.source_value_1 := l_tclv_rec.source_value_1;
      END IF;
      IF (x_tclv_rec.source_column_2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.source_column_2 := l_tclv_rec.source_column_2;
      END IF;
      IF (x_tclv_rec.source_value_2 = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.source_value_2 := l_tclv_rec.source_value_2;
      END IF;
      IF (x_tclv_rec.source_column_3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.source_column_3 := l_tclv_rec.source_column_3;
      END IF;
      IF (x_tclv_rec.source_value_3 = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.source_value_3 := l_tclv_rec.source_value_3;
      END IF;
      IF (x_tclv_rec.canceled_date = OKC_API.G_MISS_DATE)
      THEN
        x_tclv_rec.canceled_date := l_tclv_rec.canceled_date;
      END IF;
      IF (x_tclv_rec.tax_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_tclv_rec.tax_line_id := l_tclv_rec.tax_line_id;
      END IF;
-- Added by zrehman for SLA project (Bug 5707866) 9-Feb-2007
      IF (x_tclv_rec.stream_type_purpose = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.stream_type_purpose := l_tclv_rec.stream_type_purpose;
      END IF;
      IF (x_tclv_rec.stream_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.stream_type_code := l_tclv_rec.stream_type_code;
      END IF;
      IF (x_tclv_rec.asset_book_type_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.asset_book_type_name := l_tclv_rec.asset_book_type_name;
      END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
      IF (x_tclv_rec.UPGRADE_STATUS_FLAG = OKC_API.G_MISS_CHAR)
      THEN
        x_tclv_rec.UPGRADE_STATUS_FLAG := l_tclv_rec.UPGRADE_STATUS_FLAG;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_CNTRCT_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_tclv_rec IN  tclv_rec_type,
      x_tclv_rec OUT NOCOPY tclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_request_id 	NUMBER 	:= Fnd_Global.CONC_REQUEST_ID;
	l_prog_app_id 	NUMBER 	:= Fnd_Global.PROG_APPL_ID;
	l_program_id 	NUMBER 	:= Fnd_Global.CONC_PROGRAM_ID;
    BEGIN
      x_tclv_rec := p_tclv_rec;

      SELECT  NVL(DECODE(l_request_id, -1, NULL, l_request_id) ,p_tclv_rec.REQUEST_ID)
    ,NVL(DECODE(l_prog_app_id, -1, NULL, l_prog_app_id) ,p_tclv_rec.PROGRAM_APPLICATION_ID)
    ,NVL(DECODE(l_program_id, -1, NULL, l_program_id)  ,p_tclv_rec.PROGRAM_ID)
    ,DECODE(DECODE(l_request_id, -1, NULL, SYSDATE) ,NULL, p_tclv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
        INTO x_tclv_rec.REQUEST_ID
    ,x_tclv_rec.PROGRAM_APPLICATION_ID
    ,x_tclv_rec.PROGRAM_ID
    ,x_tclv_rec.PROGRAM_UPDATE_DATE
    FROM DUAL;

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
      p_tclv_rec,                        -- IN
      l_tclv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tclv_rec, l_def_tclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tclv_rec := fill_who_columns(l_def_tclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tclv_rec, l_tcl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcl_rec,
      lx_tcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcl_rec, l_def_tclv_rec);
    x_tclv_rec := l_def_tclv_rec;
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
  -- PL/SQL TBL update_row for:TCLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type,
    x_tclv_tbl                     OUT NOCOPY tclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i),
          x_tclv_rec                     => x_tclv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

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
  ---------------------------------------
  -- delete_row for:OKL_TXL_CNTRCT_LNS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcl_rec                      IN tcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LNS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tcl_rec                      tcl_rec_type:= p_tcl_rec;
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
    DELETE FROM OKL_TXL_CNTRCT_LNS
     WHERE ID = l_tcl_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_TXL_CNTRCT_LNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_rec                     IN tclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_rec                     tclv_rec_type := p_tclv_rec;
    l_tcl_rec                      tcl_rec_type;
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
    migrate(l_tclv_rec, l_tcl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcl_rec
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
  -- PL/SQL TBL delete_row for:TCLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tclv_tbl                     IN tclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

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
END OKL_TCL_PVT;

/
