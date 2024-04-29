--------------------------------------------------------
--  DDL for Package Body OKL_SIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIF_PVT" AS
/* $Header: OKLSSIFB.pls 115.10 2002/12/22 02:42:07 smahapat noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_trans_num
  ---------------------------------------------------------------------------
  FUNCTION get_trans_num RETURN NUMBER IS
    l_newvalue NUMBER;
  BEGIN
    SELECT OKL_SIF_SEQ.NEXTVAL INTO	l_newvalue FROM dual;
    RETURN(l_newvalue);
  END get_trans_num;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STREAM_INTERFACES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sif_rec                      IN sif_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sif_rec_type IS
    CURSOR sif_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            FASB_ACCT_TREATMENT_METHOD,
            IRS_TAX_TREATMENT_METHOD,
                     SIF_MODE,
			DATE_DELIVERY,
			TOTAL_FUNDING,
			SECURITY_DEPOSIT_AMOUNT,
			SIS_CODE,
			KHR_ID,
			PRICING_TEMPLATE_NAME,
			DATE_PROCESSED,
			DATE_SEC_DEPOSIT_COLLECTED,
			DATE_PAYMENTS_COMMENCEMENT,
			TRANSACTION_NUMBER,
			COUNTRY,
			LENDING_RATE,
			RVI_YN,
			RVI_RATE,
			ADJUST,
			ADJUSTMENT_METHOD,
			IMPLICIT_INTEREST_RATE,
			ORP_CODE,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
	    -- mvasudev -- 05/13/2002
	    JTOT_OBJECT1_CODE,
	    OBJECT1_ID1,
	    OBJECT1_ID2,
	    TERM,
	    STRUCTURE,
	    DEAL_TYPE,
	    LOG_FILE,
	    FIRST_PAYMENT,
	    LAST_PAYMENT,
            -- mvasudev, Bug#2650599
            SIF_ID,
            PURPOSE_CODE
            -- end, mvasudev, Bug#2650599
      FROM Okl_Stream_Interfaces
     WHERE okl_stream_interfaces.id = p_id;
    l_sif_pk                       sif_pk_csr%ROWTYPE;
    l_sif_rec                      sif_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sif_pk_csr (p_sif_rec.id);
    FETCH sif_pk_csr INTO
            l_sif_rec.ID,
            l_sif_rec.OBJECT_VERSION_NUMBER,
            l_sif_rec.FASB_ACCT_TREATMENT_METHOD,
			l_sif_rec.IRS_TAX_TREATMENT_METHOD,
            l_sif_rec.SIF_MODE,
			l_sif_rec.DATE_DELIVERY,
			l_sif_rec.TOTAL_FUNDING,
			l_sif_rec.SECURITY_DEPOSIT_AMOUNT,
			l_sif_rec.SIS_CODE,
			l_sif_rec.KHR_ID,
			l_sif_rec.PRICING_TEMPLATE_NAME,
			l_sif_rec.DATE_PROCESSED,
			l_sif_rec.DATE_SEC_DEPOSIT_COLLECTED,
			l_sif_rec.DATE_PAYMENTS_COMMENCEMENT,
			l_sif_rec.TRANSACTION_NUMBER,
			l_sif_rec.COUNTRY,
			l_sif_rec.LENDING_RATE,
			l_sif_rec.RVI_YN,
			l_sif_rec.RVI_RATE,
			l_sif_rec.ADJUST,
			l_sif_rec.ADJUSTMENT_METHOD,
			l_sif_rec.IMPLICIT_INTEREST_RATE,
			l_sif_rec.ORP_CODE,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE01,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE02,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE03,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE04,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE05,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE06,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE07,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE08,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE09,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE10,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE11,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE12,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE13,
			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			l_sif_rec.STREAM_INTERFACE_ATTRIBUTE15,
            l_sif_rec.CREATED_BY,
            l_sif_rec.LAST_UPDATED_BY,
            l_sif_rec.CREATION_DATE,
            l_sif_rec.LAST_UPDATE_DATE,
            l_sif_rec.LAST_UPDATE_LOGIN,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sif_rec.REQUEST_ID,
            l_sif_rec.PROGRAM_APPLICATION_ID,
            l_sif_rec.PROGRAM_ID,
            l_sif_rec.PROGRAM_UPDATE_DATE,
	    -- mvasudev -- 05/13/2002
	    l_sif_rec.JTOT_OBJECT1_CODE,
	    l_sif_rec.OBJECT1_ID1,
	    l_sif_rec.OBJECT1_ID2,
	    l_sif_rec.TERM,
	    l_sif_rec.STRUCTURE,
	    l_sif_rec.DEAL_TYPE,
	    l_sif_rec.LOG_FILE,
	    l_sif_rec.FIRST_PAYMENT,
	    l_sif_rec.LAST_PAYMENT,
            -- mvasudev, Bug#2650599
            l_sif_rec.SIF_ID,
            l_sif_rec.PURPOSE_CODE;
            -- end, mvasudev, Bug#2650599
    x_no_data_found := sif_pk_csr%NOTFOUND;
    CLOSE sif_pk_csr;
    RETURN(l_sif_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sif_rec                      IN sif_rec_type
  ) RETURN sif_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sif_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STREAM_INTERFACES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sifv_rec                     IN sifv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sifv_rec_type IS
    CURSOR sifv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            FASB_ACCT_TREATMENT_METHOD,
			IRS_TAX_TREATMENT_METHOD,
            SIF_MODE,
			DATE_DELIVERY,
			TOTAL_FUNDING,
			SECURITY_DEPOSIT_AMOUNT,
			SIS_CODE,
			KHR_ID,
			PRICING_TEMPLATE_NAME,
			DATE_PROCESSED,
			DATE_SEC_DEPOSIT_COLLECTED,
			DATE_PAYMENTS_COMMENCEMENT,
			TRANSACTION_NUMBER,
			COUNTRY,
			LENDING_RATE,
			RVI_YN,
			RVI_RATE,
			ADJUST,
			ADJUSTMENT_METHOD,
			IMPLICIT_INTEREST_RATE,
			ORP_CODE,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
	    -- mvasudev -- 05/13/2002
	    JTOT_OBJECT1_CODE,
	    OBJECT1_ID1,
	    OBJECT1_ID2,
	    TERM,
	    STRUCTURE,
	    DEAL_TYPE,
	    LOG_FILE,
	    FIRST_PAYMENT,
	    LAST_PAYMENT,
            -- mvasudev, Bug#2650599
            SIF_ID,
            PURPOSE_CODE
            -- end, mvasudev, Bug#2650599
      FROM OKL_STREAM_INTERFACES_V
     WHERE OKL_STREAM_INTERFACES_V.id = p_id;
    l_sifv_pk                       sifv_pk_csr%ROWTYPE;
    l_sifv_rec                     sifv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sifv_pk_csr (p_sifv_rec.id);
    FETCH sifv_pk_csr INTO
            l_sifv_rec.ID,
            l_sifv_rec.OBJECT_VERSION_NUMBER,
            l_sifv_rec.FASB_ACCT_TREATMENT_METHOD,
			l_sifv_rec.IRS_TAX_TREATMENT_METHOD,
            l_sifv_rec.SIF_MODE,
			l_sifv_rec.DATE_DELIVERY,
			l_sifv_rec.TOTAL_FUNDING,
			l_sifv_rec.SECURITY_DEPOSIT_AMOUNT,
			l_sifv_rec.SIS_CODE,
			l_sifv_rec.KHR_ID,
			l_sifv_rec.PRICING_TEMPLATE_NAME,
			l_sifv_rec.DATE_PROCESSED,
			l_sifv_rec.DATE_SEC_DEPOSIT_COLLECTED,
			l_sifv_rec.DATE_PAYMENTS_COMMENCEMENT,
			l_sifv_rec.TRANSACTION_NUMBER,
			l_sifv_rec.COUNTRY,
			l_sifv_rec.LENDING_RATE,
			l_sifv_rec.RVI_YN,
			l_sifv_rec.RVI_RATE,
			l_sifv_rec.ADJUST,
			l_sifv_rec.ADJUSTMENT_METHOD,
			l_sifv_rec.IMPLICIT_INTEREST_RATE,
			l_sifv_rec.ORP_CODE,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE01,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE02,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE03,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE04,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE05,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE06,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE07,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE08,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE09,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE10,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE11,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE12,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE13,
			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			l_sifv_rec.STREAM_INTERFACE_ATTRIBUTE15,
            l_sifv_rec.CREATED_BY,
            l_sifv_rec.LAST_UPDATED_BY,
            l_sifv_rec.CREATION_DATE,
            l_sifv_rec.LAST_UPDATE_DATE,
            l_sifv_rec.LAST_UPDATE_LOGIN,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sifv_rec.REQUEST_ID,
            l_sifv_rec.PROGRAM_APPLICATION_ID,
            l_sifv_rec.PROGRAM_ID,
            l_sifv_rec.PROGRAM_UPDATE_DATE,
	    -- mvasudev -- 05/13/2002
	    l_sifv_rec.JTOT_OBJECT1_CODE,
	    l_sifv_rec.OBJECT1_ID1,
	    l_sifv_rec.OBJECT1_ID2,
	    l_sifv_rec.TERM,
	    l_sifv_rec.STRUCTURE,
	    l_sifv_rec.DEAL_TYPE,
	    l_sifv_rec.LOG_FILE,
	    l_sifv_rec.FIRST_PAYMENT,
	    l_sifv_rec.LAST_PAYMENT,
            -- mvasudev, Bug#2650599
            l_sifv_rec.SIF_ID,
            l_sifv_rec.PURPOSE_CODE;
            -- end, mvasudev, Bug#2650599
    x_no_data_found := sifv_pk_csr%NOTFOUND;
    CLOSE sifv_pk_csr;
    RETURN(l_sifv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_sifv_rec                     IN sifv_rec_type
  ) RETURN sifv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sifv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STREAM_INTERFACES_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sifv_rec	IN sifv_rec_type
  ) RETURN sifv_rec_type IS
    l_sifv_rec	sifv_rec_type := p_sifv_rec;
  BEGIN
    IF (l_sifv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.id := NULL;
    END IF;
    IF (l_sifv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.object_version_number := NULL;
    END IF;
    IF (l_sifv_rec.fasb_acct_treatment_method = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.fasb_acct_treatment_method := NULL;
    END IF;
    IF (l_sifv_rec.irs_tax_treatment_method = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.irs_tax_treatment_method := NULL;
    END IF;
    IF (l_sifv_rec.sif_mode = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.sif_mode := NULL;
    END IF;
    IF (l_sifv_rec.date_delivery = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.date_delivery := NULL;
    END IF;
    IF (l_sifv_rec.total_funding = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.total_funding := NULL;
    END IF;
    IF (l_sifv_rec.security_deposit_amount = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.security_deposit_amount := NULL;
    END IF;
    IF (l_sifv_rec.sis_code = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.sis_code := NULL;
    END IF;
    IF (l_sifv_rec.khr_id = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.khr_id := NULL;
    END IF;
    IF (l_sifv_rec.pricing_template_name = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.pricing_template_name := NULL;
    END IF;
    IF (l_sifv_rec.date_processed = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.date_processed := NULL;
    END IF;
    IF (l_sifv_rec.date_sec_deposit_collected = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.date_sec_deposit_collected := NULL;
    END IF;
    IF (l_sifv_rec.date_payments_commencement = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.date_payments_commencement := NULL;
    END IF;
    IF (l_sifv_rec.transaction_number = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.transaction_number := NULL;
    END IF;
    IF (l_sifv_rec.country = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.country := NULL;
    END IF;
    IF (l_sifv_rec.lending_rate = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.lending_rate := NULL;
    END IF;
    IF (l_sifv_rec.rvi_yn = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.rvi_yn := NULL;
    END IF;
    IF (l_sifv_rec.rvi_rate = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.rvi_rate := NULL;
    END IF;
    IF (l_sifv_rec.adjust = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.adjust := NULL;
    END IF;
    IF (l_sifv_rec.adjustment_method = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.adjustment_method := NULL;
    END IF;
    IF (l_sifv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.implicit_interest_rate := NULL;
    END IF;
    IF (l_sifv_rec.orp_code = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.orp_code := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_sifv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.stream_interface_attribute15 := NULL;
    END IF;
    IF (l_sifv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.created_by := NULL;
    END IF;
    IF (l_sifv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sifv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.creation_date := NULL;
    END IF;
    IF (l_sifv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.last_update_date := NULL;
    END IF;
    IF (l_sifv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.last_update_login := NULL;
    END IF;

    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    IF (l_sifv_rec.REQUEST_ID = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.REQUEST_ID := NULL;
    END IF;
    IF (l_sifv_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.PROGRAM_APPLICATION_ID := NULL;
    END IF;
    IF (l_sifv_rec.PROGRAM_ID = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.PROGRAM_ID := NULL;
    END IF;
    IF (l_sifv_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      l_sifv_rec.PROGRAM_UPDATE_DATE := NULL;
    END IF;
    -- mvasudev -- 05/13/2002
    IF (l_sifv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.JTOT_OBJECT1_CODE := NULL;
    END IF;
    IF (l_sifv_rec.OBJECT1_ID1 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.OBJECT1_ID1 := NULL;
    END IF;
    IF (l_sifv_rec.OBJECT1_ID2 = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.OBJECT1_ID2 := NULL;
    END IF;
    IF (l_sifv_rec.TERM = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.TERM := NULL;
    END IF;
    IF (l_sifv_rec.STRUCTURE = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.STRUCTURE := NULL;
    END IF;
    IF (l_sifv_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.DEAL_TYPE := NULL;
    END IF;
    IF (l_sifv_rec.LOG_FILE = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.LOG_FILE := NULL;
    END IF;
    IF (l_sifv_rec.FIRST_PAYMENT = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.FIRST_PAYMENT := NULL;
    END IF;
    IF (l_sifv_rec.LAST_PAYMENT = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.LAST_PAYMENT := NULL;
    END IF;
    --  mvasudev, Bug#2650599
    IF (l_sifv_rec.SIF_ID = OKC_API.G_MISS_NUM) THEN
      l_sifv_rec.SIF_ID := NULL;
    END IF;
    IF (l_sifv_rec.purpose_code = OKC_API.G_MISS_CHAR) THEN
      l_sifv_rec.purpose_code := NULL;
    END IF;
    -- end, mvasudev, Bug#2650599
    RETURN(l_sifv_rec);
  END null_out_defaults;

   -- START change : mvasudev , 10/24/2001
    /*
    -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_STREAM_INTERFACES_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sifv_rec IN  sifv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sifv_rec.id = OKC_API.G_MISS_NUM OR
       p_sifv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.FASB_ACCT_TREATMENT_METHOD = OKC_API.G_MISS_CHAR OR
          p_sifv_rec.FASB_ACCT_TREATMENT_METHOD IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'FASB_ACCT_TREATMENT_METHOD');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.date_payments_commencement = OKC_API.G_MISS_DATE OR
          p_sifv_rec.date_payments_commencement IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_payments_commencement');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.country = OKC_API.G_MISS_CHAR OR
          p_sifv_rec.country IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'country');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.date_delivery = OKC_API.G_MISS_DATE OR
          p_sifv_rec.date_delivery IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_delivery');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.irs_tax_treatment_method = OKC_API.G_MISS_CHAR OR
          p_sifv_rec.irs_tax_treatment_method IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'irs_tax_treatment_method');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.pricing_template_name = OKC_API.G_MISS_CHAR OR
          p_sifv_rec.pricing_template_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pricing_template_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.transaction_number = OKC_API.G_MISS_NUM OR
          p_sifv_rec.transaction_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'transaction_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.sis_code = OKC_API.G_MISS_CHAR OR
          p_sifv_rec.sis_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sis_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.khr_id = OKC_API.G_MISS_NUM OR
          p_sifv_rec.khr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'khr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sifv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sifv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

    -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  */
    -- END change : mvasudev , 10/24/2001


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKL_STREAM_INTERFACES_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_sifv_rec IN sifv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.id = Okc_Api.G_MISS_NUM OR
       p_sifv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(P_APP_NAME     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
  	p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_sifv_rec.object_version_number IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OBJECT_VERSION_NUMBER');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(P_APP_NAME     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fasb_Acct_Treatment
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fasb_Acct_Treatment
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Fasb_Acct_Treatment(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.fasb_acct_treatment_method = Okc_Api.G_MISS_CHAR OR
       p_sifv_rec.fasb_acct_treatment_method IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'FASB_ACCT_TREATMENT_METHOD');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(P_APP_NAME     => G_APP_NAME
                         ,P_MSG_NAME     => G_OKL_UNEXPECTED_ERROR
                         ,P_TOKEN1       => G_OKL_SQLCODE_TOKEN
                         ,P_TOKEN1_VALUE => SQLCODE
                         ,P_TOKEN2       => G_OKL_SQLERRM_TOKEN
                         ,P_TOKEN2_VALUE => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Fasb_Acct_Treatment;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Irs_Tax_Treatment
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Irs_Tax_Treatment
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Irs_Tax_Treatment(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.irs_tax_treatment_method = Okc_Api.G_MISS_CHAR OR
       p_sifv_rec.irs_tax_treatment_method IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'IRS_TAX_TREATMENT_METHOD');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(P_APP_NAME     => G_APP_NAME
                         ,P_MSG_NAME     => G_OKL_UNEXPECTED_ERROR
                         ,P_TOKEN1       => G_OKL_SQLCODE_TOKEN
                         ,P_TOKEN1_VALUE => SQLCODE
                         ,P_TOKEN2       => G_OKL_SQLERRM_TOKEN
                         ,P_TOKEN2_VALUE => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Irs_Tax_Treatment;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Delivery
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Delivery
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Date_Delivery(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.date_delivery = Okc_Api.G_MISS_DATE OR
       p_sifv_rec.date_delivery IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'DATE_DELIVERY');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(P_APP_NAME     => G_APP_NAME
                         ,P_MSG_NAME     => G_OKL_UNEXPECTED_ERROR
                         ,P_TOKEN1       => G_OKL_SQLCODE_TOKEN
                         ,P_TOKEN1_VALUE => SQLCODE
                         ,P_TOKEN2       => G_OKL_SQLERRM_TOKEN
                         ,P_TOKEN2_VALUE => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Date_Delivery;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sis_Code
  --------------------------------------------------------------------------
  -- Start of comments
  -- Author          : mvasudev
  -- Procedure Name  : Validate_Sis_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sis_Code(
    p_sifv_rec IN  sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  )  IS

   l_found VARCHAR2(1);

  BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	IF (p_sifv_rec.sis_code IS NULL) OR
		(p_sifv_rec.sis_code  = Okc_Api.G_MISS_CHAR) THEN
	  OKC_API.SET_MESSAGE(P_APP_NAME       => G_OKC_APP
			     ,P_MSG_NAME       => G_REQUIRED_VALUE
			     ,P_TOKEN1         => G_COL_NAME_TOKEN
			     ,P_TOKEN1_VALUE   => 'SIS_CODE');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

   	ELSE
		--Check if Sis_Code exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_SIF_STATUS',
															p_lookup_code => p_sifv_rec.sis_code);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SIS_CODE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	END IF;

  EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
	    	 -- with the next column
	    	 NULL;

	     	WHEN OTHERS THEN
	    	 -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sis_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Khr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Khr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id(
  	p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             BOOLEAN := FALSE;

  -- Cursor For OKL_K_HEADERS - Foreign Key Constraint
  CURSOR okl_Khr_pk_csr (p_id IN OKL_K_HEADERS_V.id%TYPE) IS
  SELECT '1'
    FROM OKL_K_HEADERS_V
   WHERE OKL_K_HEADERS_V.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.Khr_id = Okc_Api.G_MISS_NUM OR
       p_sifv_rec.Khr_id IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_Khr_pk_csr (p_sifv_rec.Khr_id);
    FETCH okl_Khr_pk_csr INTO l_dummy;
    l_row_not_found := okl_Khr_pk_csr%NOTFOUND;
    CLOSE okl_Khr_pk_csr;

    IF l_row_not_found THEN
      OKC_API.SET_MESSAGE(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    IF okl_Khr_pk_csr%ISOPEN THEN
	            CLOSE okl_Khr_pk_csr;
    END IF;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_Khr_pk_csr%ISOPEN THEN
        CLOSE okl_Khr_pk_csr;
      END IF;

  END Validate_Khr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pricing_Template_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pricing_Template_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Pricing_Template_Name(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.pricing_template_name = Okc_Api.G_MISS_CHAR OR
       p_sifv_rec.pricing_template_name IS NULL
    THEN
      OKC_API.SET_MESSAGE(G_OKC_APP,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'PRICING_TEMPLATE_NAME');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Pricing_Template_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Pay_Commence
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Pay_Commence
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Pay_Commence(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2)
  IS
  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_sifv_rec.date_payments_commencement IS NULL) OR
       (p_sifv_rec.date_payments_commencement = Okc_Api.G_MISS_DATE) THEN
       OKC_API.SET_MESSAGE( P_APP_NAME       => G_OKC_APP,
                           P_MSG_NAME       => G_REQUIRED_VALUE,
                           P_TOKEN1         => G_COL_NAME_TOKEN,
                           P_TOKEN1_VALUE   => 'DATE_PAYMENTS_COMMENCEMENT' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( P_APP_NAME     => G_APP_NAME,
                          p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                          p_token1       => G_OKL_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_OKL_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error

      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Pay_Commence;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Country
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Country
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Country(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.country = Okc_Api.G_MISS_CHAR OR
       p_sifv_rec.country IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Country');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Country;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Orp_Code
  --------------------------------------------------------------------------
  -- Start of comments
  -- Author          : mvasudev
  -- Procedure Name  : Validate_Orp_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Orp_Code(
    p_sifv_rec IN  sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  )  IS

   l_found VARCHAR2(1);

  BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	     -- check for data before processing
	IF (p_sifv_rec.orp_code IS NULL) OR
		(p_sifv_rec.orp_code  = Okc_Api.G_MISS_CHAR) THEN
	  OKC_API.SET_MESSAGE(P_APP_NAME       => G_OKC_APP
			     ,P_MSG_NAME       => G_REQUIRED_VALUE
			     ,P_TOKEN1         => G_COL_NAME_TOKEN
			     ,P_TOKEN1_VALUE   => 'ORP_CODE');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;

   	ELSE
		--Check if Orp_Code exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_STRM_G_ORIGINATION_PROCESS',
															p_lookup_code => p_sifv_rec.orp_code);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORP_CODE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;

	END IF;

  EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
	    	 -- with the next column
	    	 NULL;

	     	WHEN OTHERS THEN
	    	 -- store SQL error message on message stack for caller
          Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                              p_token1       => G_OKL_SQLCODE_TOKEN,
                              p_token1_value => SQLCODE,
                              p_token2       => G_OKL_SQLERRM_TOKEN,
                              p_token2_value => SQLERRM);
	    	 -- notify caller of an UNEXPECTED error
	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Orp_Code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Jtot_Object1_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Jtot_Object1_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Jtot_Object1_Code(
    p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;


  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    /*
        -- mvasudev , 07/08/2002
        -- Mandatory Checks moved from TAPI to get rid of
        -- cyclic dependancy of OKL_SIF_PVT with OKL_INVOKE_PRICING_ENGINE_PVT

   -- Check for Mandatory Values (Object_id)
   IF p_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
   AND (p_sifv_rec.Jtot_Object1_Code IS NULL OR p_sifv_rec.Jtot_Object1_Code = OKC_API.G_MISS_CHAR)
   THEN
	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
				p_msg_name	=>	G_REQUIRED_VALUE,
				p_token1	=>	G_COL_NAME_TOKEN,
				p_token1_value	=>	'JTOT_OBJECT1_CODE'
				);
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
   */

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Jtot_Object1_Code;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Object1_Id1
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : mvasudev
    -- Procedure Name  : Validate_Object1_Id1
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Object1_Id1(
      p_sifv_rec IN  sifv_rec_type,
      x_return_status OUT  NOCOPY VARCHAR2
    )  IS

    CURSOR l_okl_jtf_obj_details_csr(p_obj_code IN VARCHAR2)
    IS
    SELECT select_id, from_table
    FROM JTF_OBJECTS_B JOB
    WHERE JOB.OBJECT_CODE = p_obj_code;

    TYPE l_ref_csr_type IS REF CURSOR;
    l_obj_id_csr        l_ref_csr_type;

    l_row_not_found             BOOLEAN := FALSE;

    l_query_string  VARCHAR2(400);
    l_select_clause VARCHAR2(100);
    l_from_clause   VARCHAR2(100);

    l_dummy VARCHAR2(1) := '?';


    BEGIN
  	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

  	/*
         -- mvasudev , 07/08/2002
         -- Mandatory Checks moved from TAPI to get rid of
         -- cyclic dependancy of OKL_SIF_PVT with OKL_INVOKE_PRICING_ENGINE_PVT

  	   -- Check for Mandatory Values (Object_id)
  	   IF p_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
  	   AND (p_sifv_rec.object1_id1 IS NULL OR p_sifv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
  	   THEN
        	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
					p_msg_name	=>	G_REQUIRED_VALUE,
					p_token1	=>	G_COL_NAME_TOKEN,
					p_token1_value	=>	'OBJECT1_ID1'
					);
	      x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	  RAISE G_EXCEPTION_HALT_VALIDATION;
  	   END IF;
  	 */

  	     -- check for data before processing
  	IF  p_sifv_rec.JTOT_OBJECT1_CODE IS NOT NULL AND p_sifv_rec.JTOT_OBJECT1_CODE  <> Okc_Api.G_MISS_CHAR
  	AND p_sifv_rec.OBJECT1_ID1 IS NOT NULL AND p_sifv_rec.OBJECT1_ID1  <> Okc_Api.G_MISS_CHAR
	THEN
  		    OPEN l_okl_jtf_obj_details_csr (p_sifv_rec.JTOT_OBJECT1_CODE);
  		    FETCH l_okl_jtf_obj_details_csr
  		    INTO l_select_clause, l_from_clause;
  		    l_row_not_found := l_okl_jtf_obj_details_csr%NOTFOUND;
  		    CLOSE l_okl_jtf_obj_details_csr;

  		    IF l_row_not_found THEN
  		      OKC_API.SET_MESSAGE(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
  		      x_return_status := Okc_Api.G_RET_STS_ERROR;
  		    END IF;

  		    l_query_string := 'SELECT ''1''' ||
  		                       ' FROM '  || l_from_clause   ||
  		                       ' WHERE ' || l_select_clause || ' = ' || p_sifv_rec.OBJECT1_ID1;

                    OPEN l_obj_id_csr FOR l_query_string;
                    FETCH l_obj_id_csr INTO l_dummy;
  		    l_row_not_found := l_obj_id_csr%NOTFOUND;
  		    CLOSE l_obj_id_csr;

  		    IF l_row_not_found THEN
  		      OKC_API.SET_MESSAGE(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'OBJECT1_ID1');
  		      x_return_status := Okc_Api.G_RET_STS_ERROR;
  		    END IF;
  	END IF;

    EXCEPTION
      	WHEN G_EXCEPTION_HALT_VALIDATION THEN
  	    	 -- no processing necessary;  validation can continue
  	    	 -- with the next column
  	    	 NULL;
                  IF l_okl_jtf_obj_details_csr%ISOPEN THEN
  	            CLOSE l_okl_jtf_obj_details_csr;
                  END IF;

       	WHEN OTHERS THEN
  	    	 -- store SQL error message on message stack for caller
            Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_OKL_UNEXPECTED_ERROR,
                                p_token1       => G_OKL_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2       => G_OKL_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
  	    	 -- notify caller of an UNEXPECTED error
  	    	 x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
            IF l_okl_jtf_obj_details_csr%ISOPEN THEN
  	            CLOSE l_okl_jtf_obj_details_csr;
            END IF;

  END Validate_Object1_Id1;

  -- mvasudev, Bug#2650599
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sif_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sif_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sif_Id(
  	p_sifv_rec      IN   sifv_rec_type,
    x_return_status OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             BOOLEAN := FALSE;

  -- Cursor For OKL_K_HEADERS - Foreign Key Constraint
  CURSOR okl_sif_pk_csr (p_id IN OKL_STREAM_INTERFACES.id%TYPE) IS
  SELECT '1'
    FROM OKL_STREAM_INTERFACES
   WHERE OKL_STREAM_INTERFACES.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sifv_rec.sif_id <> Okc_Api.G_MISS_NUM AND p_sifv_rec.sif_id IS NOT NULL
    THEN
	    OPEN okl_sif_pk_csr (p_sifv_rec.sif_id);
	    FETCH okl_sif_pk_csr INTO l_dummy;
	    l_row_not_found := okl_sif_pk_csr%NOTFOUND;
	    CLOSE okl_sif_pk_csr;

	    IF l_row_not_found THEN
	      OKC_API.SET_MESSAGE(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'SIF_ID');
	      x_return_status := Okc_Api.G_RET_STS_ERROR;
	    END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    IF okl_sif_pk_csr%ISOPEN THEN
	            CLOSE okl_sif_pk_csr;
    END IF;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sif_pk_csr%ISOPEN THEN
        CLOSE okl_sif_pk_csr;
      END IF;

  END Validate_Sif_Id;
  -- end, mvasudev, Bug#2650599

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
      p_sifv_rec IN  sifv_rec_type
    ) RETURN VARCHAR2 IS

      x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      -- call each column-level validation

      -- Validate_Id
      Validate_Id(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;


      -- Validate_Object_Version_Number
      Validate_Object_Version_Number(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;

      -- Validate_Fasb_Acct_Treatment
        Validate_Fasb_Acct_Treatment(p_sifv_rec, x_return_status);
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
        END IF;

      -- Validate_Irs_Tax_Treatment
        Validate_Irs_Tax_Treatment(p_sifv_rec, x_return_status);
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
        END IF;


      -- Validate_Pricing_Template_Name
      Validate_Pricing_Template_Name(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;

      -- Validate_Sis_Code
      Validate_Sis_Code(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;


      -- Validate_Khr_Id
      Validate_Khr_Id(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;


      -- Validate_Date_Delivery
      Validate_Date_Delivery(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;

  	 -- Validate_Date_Pay_Commence
      Validate_Date_Pay_Commence(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;

  	 -- Validate_Country
      Validate_Country(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;

      -- Validate_Orp_Code
        Validate_Orp_Code(p_sifv_rec, x_return_status);
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
        END IF;


      -- Validate_Jtot_Object1_Code
        Validate_Jtot_Object1_Code(p_sifv_rec, x_return_status);
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
        END IF;

      -- Validate_Object1_Id1
        Validate_Object1_Id1(p_sifv_rec, x_return_status);
        IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              -- need to exit
              l_return_status := x_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
              -- there was an error
              l_return_status := x_return_status;
           END IF;
        END IF;

      -- mvasudev, Bug#2650599
      -- Validate_Sif_Id
      Validate_Sif_Id(p_sifv_rec, x_return_status);
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
         IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
            -- need to exit
            l_return_status := x_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            -- there was an error
            l_return_status := x_return_status;
         END IF;
      END IF;
       -- end, mvasudev, Bug#2650599

      RETURN (l_return_status);
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
         -- exit with return status
         NULL;
         RETURN (l_return_status);

      WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                             p_token1           => G_OKL_SQLCODE_TOKEN,
                             p_token1_value     => SQLCODE,
                             p_token2           => G_OKL_SQLERRM_TOKEN,
                             p_token2_value     => SQLERRM);
         -- notify caller of an UNEXPECTED error
         l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      RETURN(l_return_status);
    END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sifv_rec_type,
   -- START
   -- tapi change mvasudev 10/24/2001
   -- chnaged the Variable p_to from OUT to IN OUT

   p_to	IN OUT NOCOPY sif_rec_type
   -- END TAPI change


  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.fasb_acct_treatment_method := p_from.fasb_acct_treatment_method;
    p_to.irs_tax_treatment_method := p_from.irs_tax_treatment_method;
    p_to.sif_mode := p_from.sif_mode;
    p_to.date_delivery := p_from.date_delivery;
    p_to.total_funding := p_from.total_funding;
    p_to.security_deposit_amount := p_from.security_deposit_amount;
    p_to.sis_code := p_from.sis_code;
    p_to.khr_id := p_from.khr_id;
    p_to.pricing_template_name := p_from.pricing_template_name;
    p_to.date_processed := p_from.date_processed;
    p_to.date_sec_deposit_collected := p_from.date_sec_deposit_collected;
    p_to.date_payments_commencement := p_from.date_payments_commencement;
    p_to.transaction_number := p_from.transaction_number;
    p_to.country := p_from.country;
    p_to.lending_rate := p_from.lending_rate;
    p_to.rvi_yn := p_from.rvi_yn;
    p_to.rvi_rate := p_from.rvi_rate;
    p_to.adjust := p_from.adjust;
    p_to.adjustment_method := p_from.adjustment_method;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.orp_code := p_from.orp_code;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    p_to.REQUEST_ID := p_from.REQUEST_ID;
    p_to.PROGRAM_APPLICATION_ID := p_from.PROGRAM_APPLICATION_ID;
    p_to.PROGRAM_ID := p_from.PROGRAM_ID;
    p_to.PROGRAM_UPDATE_DATE := p_from.PROGRAM_UPDATE_DATE;
    -- mvasudev -- 05/13/2002
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.OBJECT1_ID1 := p_from.OBJECT1_ID1;
    p_to.OBJECT1_ID2 := p_from.OBJECT1_ID2;
    p_to.TERM := p_from.TERM;
    p_to.STRUCTURE := p_from.STRUCTURE;
    p_to.DEAL_TYPE := p_from.DEAL_TYPE;
    p_to.LOG_FILE := p_from.LOG_FILE;
    p_to.FIRST_PAYMENT := p_from.FIRST_PAYMENT;
    p_to.LAST_PAYMENT := p_from.LAST_PAYMENT;
    --  mvasudev, Bug#2650599
    p_to.sif_id := p_from.sif_id;
    p_to.purpose_code := p_from.purpose_code;
    -- end, mvasudev, Bug#2650599

  END migrate;
  PROCEDURE migrate (
    p_from	IN sif_rec_type,
    -- START
    -- tapi change mvasudev 10/24/2001
    -- chnaged the Variable p_to from OUT to IN OUT

    p_to	IN OUT NOCOPY sifv_rec_type
    -- END TAPI change

  ) IS
  BEGIN
  p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.fasb_acct_treatment_method := p_from.fasb_acct_treatment_method;
    p_to.irs_tax_treatment_method := p_from.irs_tax_treatment_method;
    p_to.sif_mode := p_from.sif_mode;
    p_to.date_delivery := p_from.date_delivery;
    p_to.total_funding := p_from.total_funding;
    p_to.security_deposit_amount := p_from.security_deposit_amount;
    p_to.sis_code := p_from.sis_code;
    p_to.khr_id := p_from.khr_id;
    p_to.pricing_template_name := p_from.pricing_template_name;
    p_to.date_processed := p_from.date_processed;
    p_to.date_sec_deposit_collected := p_from.date_sec_deposit_collected;
    p_to.date_payments_commencement := p_from.date_payments_commencement;
    p_to.transaction_number := p_from.transaction_number;
    p_to.country := p_from.country;
    p_to.lending_rate := p_from.lending_rate;
    p_to.rvi_yn := p_from.rvi_yn;
    p_to.rvi_rate := p_from.rvi_rate;
    p_to.adjust := p_from.adjust;
    p_to.adjustment_method := p_from.adjustment_method;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.orp_code := p_from.orp_code;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    p_to.REQUEST_ID := p_from.REQUEST_ID;
    p_to.PROGRAM_APPLICATION_ID := p_from.PROGRAM_APPLICATION_ID;
    p_to.PROGRAM_ID := p_from.PROGRAM_ID;
    p_to.PROGRAM_UPDATE_DATE := p_from.PROGRAM_UPDATE_DATE;
    -- mvasudev -- 05/13/2002
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.OBJECT1_ID1 := p_from.OBJECT1_ID1;
    p_to.OBJECT1_ID2 := p_from.OBJECT1_ID2;
    p_to.TERM := p_from.TERM;
    p_to.STRUCTURE := p_from.STRUCTURE;
    p_to.DEAL_TYPE := p_from.DEAL_TYPE;
    p_to.LOG_FILE := p_from.LOG_FILE;
    p_to.FIRST_PAYMENT := p_from.FIRST_PAYMENT;
    p_to.LAST_PAYMENT := p_from.LAST_PAYMENT;
    --  mvasudev, Bug#2650599
    p_to.sif_id := p_from.sif_id;
    p_to.purpose_code := p_from.purpose_code;
    -- end, mvasudev, Bug#2650599

 END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKL_STREAM_INTERFACES_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sifv_rec                     sifv_rec_type := p_sifv_rec;
    l_sif_rec                      sif_rec_type;




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
    l_return_status := Validate_Attributes(l_sifv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sifv_rec);
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
  -- PL/SQL TBL validate_row for:SIFV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;


  -- START change : mvasudev, 10/24/2001
  -- Adding OverAll Status Flag
      l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  -- END change : mvasudev



  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sifv_tbl.COUNT > 0) THEN
      i := p_sifv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sifv_rec                     => p_sifv_tbl(i));


       -- START change : mvasudev, 10/24/2001
       -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
                 l_overall_status := x_return_status;
                END IF;
          END IF;
       -- END change : mvasudev

        EXIT WHEN (i = p_sifv_tbl.LAST);
        i := p_sifv_tbl.NEXT(i);
      END LOOP;
-- START change : mvasudev, 10/24/200
-- return overall status

   x_return_status := l_overall_status;

-- END change : mvasudev
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
  -- insert_row for:OKL_STREAM_INTERFACES --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sif_rec                      IN sif_rec_type,
    x_sif_rec                      OUT NOCOPY sif_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sif_rec                      sif_rec_type := p_sif_rec;
    l_def_sif_rec                  sif_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_STREAM_INTERFACES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sif_rec IN  sif_rec_type,
      x_sif_rec OUT NOCOPY sif_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sif_rec := p_sif_rec;
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
      p_sif_rec,                         -- IN
      l_sif_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_STREAM_INTERFACES(
            id,
            object_version_number,
            fasb_acct_treatment_method,
			irs_tax_treatment_method,
            sif_mode,
			date_delivery,
			total_funding,
			security_deposit_amount,
			sis_code,
			khr_id,
			pricing_template_name,
			date_processed,
			date_sec_deposit_collected,
			date_payments_commencement,
			transaction_number,
			country,
			lending_rate,
			rvi_yn,
			rvi_rate,
			adjust,
			adjustment_method,
			implicit_interest_rate,
			orp_code,
			stream_interface_attribute01,
			stream_interface_attribute02,
			stream_interface_attribute03,
			stream_interface_attribute04,
			stream_interface_attribute05,
			stream_interface_attribute06,
			stream_interface_attribute07,
			stream_interface_attribute08,
			stream_interface_attribute09,
			stream_interface_attribute10,
			stream_interface_attribute11,
			stream_interface_attribute12,
			stream_interface_attribute13,
			stream_interface_attribute14,
   			stream_interface_attribute15,
            created_by,
            last_updated_by,
            creation_date,
            last_update_date,
            last_update_login,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            request_id,
            program_application_id,
            program_id,
            program_update_date,
	    -- mvasudev -- 05/13/2002
	    jtot_object1_code,
	    object1_id1,
	    object1_id2,
	    term,
	    structure,
	    deal_type,
	    log_file,
	    first_payment,
	    last_payment,
             --  mvasudev, Bug#2650599
             sif_id,
             purpose_code
             -- end, mvasudev, Bug#2650599
            )
      VALUES (
            l_sif_rec.id,
            l_sif_rec.object_version_number,
            l_sif_rec.fasb_acct_treatment_method,
			l_sif_rec.irs_tax_treatment_method,
            l_sif_rec.sif_mode,
			l_sif_rec.date_delivery,
			l_sif_rec.total_funding,
			l_sif_rec.security_deposit_amount,
			l_sif_rec.sis_code,
			l_sif_rec.khr_id,
			l_sif_rec.pricing_template_name,
			l_sif_rec.date_processed,
			l_sif_rec.date_sec_deposit_collected,
			l_sif_rec.date_payments_commencement,
			l_sif_rec.transaction_number,
			l_sif_rec.country,
			l_sif_rec.lending_rate,
			l_sif_rec.rvi_yn,
			l_sif_rec.rvi_rate,
			l_sif_rec.adjust,
			l_sif_rec.adjustment_method,
			l_sif_rec.implicit_interest_rate,
			l_sif_rec.orp_code,
			l_sif_rec.stream_interface_attribute01,
			l_sif_rec.stream_interface_attribute02,
			l_sif_rec.stream_interface_attribute03,
			l_sif_rec.stream_interface_attribute04,
			l_sif_rec.stream_interface_attribute05,
			l_sif_rec.stream_interface_attribute06,
			l_sif_rec.stream_interface_attribute07,
			l_sif_rec.stream_interface_attribute08,
			l_sif_rec.stream_interface_attribute09,
			l_sif_rec.stream_interface_attribute10,
			l_sif_rec.stream_interface_attribute11,
			l_sif_rec.stream_interface_attribute12,
			l_sif_rec.stream_interface_attribute13,
			l_sif_rec.stream_interface_attribute14,
   			l_sif_rec.stream_interface_attribute15,
            l_sif_rec.created_by,
            l_sif_rec.last_updated_by,
            l_sif_rec.creation_date,
            l_sif_rec.last_update_date,
            l_sif_rec.last_update_login,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sif_rec.request_id,
            l_sif_rec.program_application_id,
            l_sif_rec.program_id,
            l_sif_rec.program_update_date,
	    -- mvasudev -- 05/13/2002
	    l_sif_rec.JTOT_OBJECT1_CODE,
	    l_sif_rec.OBJECT1_ID1,
	    l_sif_rec.OBJECT1_ID2,
	    l_sif_rec.TERM,
	    l_sif_rec.STRUCTURE,
	    l_sif_rec.DEAL_TYPE,
	    l_sif_rec.LOG_FILE,
	    l_sif_rec.FIRST_PAYMENT,
	    l_sif_rec.LAST_PAYMENT,
            --  mvasudev, Bug#2650599
	    l_sif_rec.sif_id,
	    l_sif_rec.purpose_code
	    -- end, mvasudev, Bug#2650599
            );
    -- Set OUT values
    x_sif_rec := l_sif_rec;
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
  -- insert_row for:OKL_STREAM_INTERFACES_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sifv_rec                     sifv_rec_type;
    l_def_sifv_rec                 sifv_rec_type;
    l_sif_rec                      sif_rec_type;
    lx_sif_rec                     sif_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sifv_rec	IN sifv_rec_type
    ) RETURN sifv_rec_type IS
      l_sifv_rec	sifv_rec_type := p_sifv_rec;
    BEGIN
      l_sifv_rec.CREATION_DATE := SYSDATE;
      l_sifv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sifv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sifv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sifv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sifv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_STREAM_INTERFACES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sifv_rec IN  sifv_rec_type,
      x_sifv_rec OUT NOCOPY sifv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sifv_rec := p_sifv_rec;
      x_sifv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_sifv_rec.REQUEST_ID
            ,x_sifv_rec.PROGRAM_APPLICATION_ID
            ,x_sifv_rec.PROGRAM_ID
            ,x_sifv_rec.PROGRAM_UPDATE_DATE
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
    l_sifv_rec := null_out_defaults(p_sifv_rec);
    -- Set primary key value
    l_sifv_rec.ID := get_seq_id;
    l_sifv_rec.transaction_number := get_trans_num;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sifv_rec,                        -- IN
      l_def_sifv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sifv_rec := fill_who_columns(l_def_sifv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sifv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sifv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sifv_rec, l_sif_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sif_rec,
      lx_sif_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sif_rec, l_def_sifv_rec);
    -- Set OUT values
    x_sifv_rec := l_def_sifv_rec;
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
  -- PL/SQL TBL insert_row for:SIFV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

   -- START change : mvasudev, 10/24/2001
      -- Adding OverAll Status Flag
      l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      -- END change : mvasudev

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sifv_tbl.COUNT > 0) THEN
      i := p_sifv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sifv_rec                     => p_sifv_tbl(i),
          x_sifv_rec                     => x_sifv_tbl(i));
          -- START change : mvasudev, 10/24/2001
          -- store the highest degree of error

	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;

	-- END change : mvasudev

        EXIT WHEN (i = p_sifv_tbl.LAST);
        i := p_sifv_tbl.NEXT(i);
      END LOOP;
        -- START change : mvasudev, 10/24/2001
        -- return overall status
             x_return_status := l_overall_status;
        -- END change : mvasudev
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
  -- lock_row for:OKL_STREAM_INTERFACES --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sif_rec                      IN sif_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sif_rec IN sif_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STREAM_INTERFACES
     WHERE ID = p_sif_rec.id
       AND OBJECT_VERSION_NUMBER = p_sif_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sif_rec IN sif_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STREAM_INTERFACES
    WHERE ID = p_sif_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_STREAM_INTERFACES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_STREAM_INTERFACES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sif_rec);
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
      OPEN lchk_csr(p_sif_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sif_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sif_rec.object_version_number THEN
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
  -- lock_row for:OKL_STREAM_INTERFACES_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sif_rec                      sif_rec_type;
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
    migrate(p_sifv_rec, l_sif_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sif_rec
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
  -- PL/SQL TBL lock_row for:SIFV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 10/24/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : mvasudev

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sifv_tbl.COUNT > 0) THEN
      i := p_sifv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sifv_rec                     => p_sifv_tbl(i));

        -- START change : mvasudev, 10/24/2001
        -- store the highest degree of error

       	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
       	             l_overall_status := x_return_status;
       	    END IF;
       	END IF;

       	-- END change : mvasudev


       EXIT WHEN (i = p_sifv_tbl.LAST);
        i := p_sifv_tbl.NEXT(i);
      END LOOP;
        -- START change : mvasudev, 10/24/2001
        -- return overall status
             x_return_status := l_overall_status;
        -- END change : mvasudev

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
  -- update_row for:OKL_STREAM_INTERFACES --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sif_rec                      IN sif_rec_type,
    x_sif_rec                      OUT NOCOPY sif_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sif_rec                      sif_rec_type := p_sif_rec;
    l_def_sif_rec                  sif_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sif_rec	IN sif_rec_type,
      x_sif_rec	OUT NOCOPY sif_rec_type
    ) RETURN VARCHAR2 IS
      l_sif_rec                      sif_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sif_rec := p_sif_rec;
      -- Get current database values
      l_sif_rec := get_rec(p_sif_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sif_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.id := l_sif_rec.id;
      END IF;
      IF (x_sif_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.object_version_number := l_sif_rec.object_version_number;
      END IF;
      IF (x_sif_rec.fasb_acct_treatment_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.fasb_acct_treatment_method := l_sif_rec.fasb_acct_treatment_method;
      END IF;
      IF (x_sif_rec.irs_tax_treatment_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.irs_tax_treatment_method := l_sif_rec.irs_tax_treatment_method;
      END IF;
      IF (x_sif_rec.sif_mode = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.sif_mode := l_sif_rec.sif_mode;
      END IF;
      IF (x_sif_rec.date_delivery = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.date_delivery := l_sif_rec.date_delivery;
      END IF;
      IF (x_sif_rec.total_funding = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.total_funding := l_sif_rec.total_funding;
      END IF;
      IF (x_sif_rec.security_deposit_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.security_deposit_amount := l_sif_rec.security_deposit_amount;
      END IF;
      IF (x_sif_rec.sis_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.sis_code := l_sif_rec.sis_code;
      END IF;
      IF (x_sif_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.khr_id := l_sif_rec.khr_id;
      END IF;
      IF (x_sif_rec.pricing_template_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.pricing_template_name := l_sif_rec.pricing_template_name;
      END IF;
      IF (x_sif_rec.date_processed = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.date_processed := l_sif_rec.date_processed;
      END IF;
      IF (x_sif_rec.date_sec_deposit_collected = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.date_sec_deposit_collected := l_sif_rec.date_sec_deposit_collected;
      END IF;
      IF (x_sif_rec.date_payments_commencement = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.date_payments_commencement := l_sif_rec.date_payments_commencement;
      END IF;
      IF (x_sif_rec.transaction_number = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.transaction_number := l_sif_rec.transaction_number;
      END IF;
      IF (x_sif_rec.country = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.country := l_sif_rec.country;
      END IF;
      IF (x_sif_rec.lending_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.lending_rate := l_sif_rec.lending_rate;
      END IF;
      IF (x_sif_rec.rvi_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.rvi_yn := l_sif_rec.rvi_yn;
      END IF;
      IF (x_sif_rec.rvi_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.rvi_rate := l_sif_rec.rvi_rate;
      END IF;
      IF (x_sif_rec.adjust = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.adjust := l_sif_rec.adjust;
      END IF;
      IF (x_sif_rec.adjustment_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.adjustment_method := l_sif_rec.adjustment_method;
      END IF;
      IF (x_sif_rec.implicit_interest_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.implicit_interest_rate := l_sif_rec.implicit_interest_rate;
      END IF;
      IF (x_sif_rec.orp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.orp_code := l_sif_rec.orp_code;
      END IF;
      IF (x_sif_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute01 := l_sif_rec.stream_interface_attribute01;
      END IF;
      IF (x_sif_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute02 := l_sif_rec.stream_interface_attribute02;
      END IF;
      IF (x_sif_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute03 := l_sif_rec.stream_interface_attribute03;
      END IF;
      IF (x_sif_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute04 := l_sif_rec.stream_interface_attribute04;
      END IF;
      IF (x_sif_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute05 := l_sif_rec.stream_interface_attribute05;
      END IF;
      IF (x_sif_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute06 := l_sif_rec.stream_interface_attribute06;
      END IF;
      IF (x_sif_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute07 := l_sif_rec.stream_interface_attribute07;
      END IF;
      IF (x_sif_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute08 := l_sif_rec.stream_interface_attribute08;
      END IF;
      IF (x_sif_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute09 := l_sif_rec.stream_interface_attribute09;
      END IF;
      IF (x_sif_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute10 := l_sif_rec.stream_interface_attribute10;
      END IF;
      IF (x_sif_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute11 := l_sif_rec.stream_interface_attribute11;
      END IF;
      IF (x_sif_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute12 := l_sif_rec.stream_interface_attribute12;
      END IF;
      IF (x_sif_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute13 := l_sif_rec.stream_interface_attribute13;
      END IF;
      IF (x_sif_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute14 := l_sif_rec.stream_interface_attribute14;
      END IF;
      IF (x_sif_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.stream_interface_attribute15 := l_sif_rec.stream_interface_attribute15;
      END IF;
      IF (x_sif_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.created_by := l_sif_rec.created_by;
      END IF;
      IF (x_sif_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.last_updated_by := l_sif_rec.last_updated_by;
      END IF;
      IF (x_sif_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.creation_date := l_sif_rec.creation_date;
      END IF;
      IF (x_sif_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.last_update_date := l_sif_rec.last_update_date;
      END IF;
      IF (x_sif_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.last_update_login := l_sif_rec.last_update_login;
      END IF;
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
      IF (x_sif_rec.REQUEST_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.REQUEST_ID := l_sif_rec.REQUEST_ID;
      END IF;
      IF (x_sif_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.PROGRAM_APPLICATION_ID := l_sif_rec.PROGRAM_APPLICATION_ID;
      END IF;
      IF (x_sif_rec.PROGRAM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sif_rec.PROGRAM_ID := l_sif_rec.PROGRAM_ID;
      END IF;
      IF (x_sif_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_sif_rec.PROGRAM_UPDATE_DATE := l_sif_rec.PROGRAM_UPDATE_DATE;
      END IF;
      -- mvasudev -- 05/13/2002
      IF (x_sif_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_sif_rec.JTOT_OBJECT1_CODE := l_sif_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_sif_rec.OBJECT1_ID1 = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.OBJECT1_ID1 := l_sif_rec.OBJECT1_ID1;
      END IF;
      IF (x_sif_rec.OBJECT1_ID2 = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.OBJECT1_ID2 := l_sif_rec.OBJECT1_ID2;
      END IF;
      IF (x_sif_rec.TERM = OKC_API.G_MISS_NUM)
            THEN
              x_sif_rec.TERM := l_sif_rec.TERM;
      END IF;
      IF (x_sif_rec.STRUCTURE = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.STRUCTURE := l_sif_rec.STRUCTURE;
      END IF;
      IF (x_sif_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.DEAL_TYPE := l_sif_rec.DEAL_TYPE;
      END IF;
      IF (x_sif_rec.LOG_FILE = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.LOG_FILE := l_sif_rec.LOG_FILE;
      END IF;
      IF (x_sif_rec.FIRST_PAYMENT = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.FIRST_PAYMENT := l_sif_rec.FIRST_PAYMENT;
      END IF;
      IF (x_sif_rec.LAST_PAYMENT = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.LAST_PAYMENT := l_sif_rec.LAST_PAYMENT;
      END IF;
    --  mvasudev, Bug#2650599
      IF (x_sif_rec.sif_id = OKC_API.G_MISS_NUM)
            THEN
              x_sif_rec.sif_id := l_sif_rec.sif_id;
      END IF;
      IF (x_sif_rec.purpose_code = OKC_API.G_MISS_CHAR)
            THEN
              x_sif_rec.purpose_code := l_sif_rec.purpose_code;
      END IF;
    -- end, mvasudev, Bug#2650599
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_STREAM_INTERFACES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sif_rec IN  sif_rec_type,
      x_sif_rec OUT NOCOPY sif_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sif_rec := p_sif_rec;
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
      p_sif_rec,                         -- IN
      l_sif_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sif_rec, l_def_sif_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STREAM_INTERFACES
    SET FASB_ACCT_TREATMENT_METHOD = l_def_sif_rec.FASB_ACCT_TREATMENT_METHOD,
		IRS_TAX_TREATMENT_METHOD = l_def_sif_rec.IRS_TAX_TREATMENT_METHOD,
		SIF_MODE = l_def_sif_rec.SIF_MODE,
		DATE_DELIVERY = l_def_sif_rec.DATE_DELIVERY,
		TOTAL_FUNDING = l_def_sif_rec.TOTAL_FUNDING,
		SECURITY_DEPOSIT_AMOUNT = l_def_sif_rec.SECURITY_DEPOSIT_AMOUNT,
		SIS_CODE = l_def_sif_rec.SIS_CODE,
		KHR_ID = l_def_sif_rec.KHR_ID,
		PRICING_TEMPLATE_NAME = l_def_sif_rec.PRICING_TEMPLATE_NAME,
		DATE_PROCESSED = l_def_sif_rec.DATE_PROCESSED,
		DATE_SEC_DEPOSIT_COLLECTED = l_def_sif_rec.DATE_SEC_DEPOSIT_COLLECTED,
		DATE_PAYMENTS_COMMENCEMENT = l_def_sif_rec.DATE_PAYMENTS_COMMENCEMENT,
		TRANSACTION_NUMBER = l_def_sif_rec.TRANSACTION_NUMBER,
		COUNTRY = l_def_sif_rec.COUNTRY,
		LENDING_RATE = l_def_sif_rec.LENDING_RATE,
		RVI_YN = l_def_sif_rec.RVI_YN,
		RVI_RATE = l_def_sif_rec.RVI_RATE,
		ADJUST = l_def_sif_rec.ADJUST,
		ADJUSTMENT_METHOD = l_def_sif_rec.ADJUSTMENT_METHOD,
		IMPLICIT_INTEREST_RATE = l_def_sif_rec.IMPLICIT_INTEREST_RATE,
		ORP_CODE = l_def_sif_rec.ORP_CODE,
		STREAM_INTERFACE_ATTRIBUTE01 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE01,
		STREAM_INTERFACE_ATTRIBUTE02 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE02,
		STREAM_INTERFACE_ATTRIBUTE03 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE03,
		STREAM_INTERFACE_ATTRIBUTE04 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE04,
		STREAM_INTERFACE_ATTRIBUTE05 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE05,
		STREAM_INTERFACE_ATTRIBUTE06 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE06,
		STREAM_INTERFACE_ATTRIBUTE07 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE07,
		STREAM_INTERFACE_ATTRIBUTE08 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE08,
		STREAM_INTERFACE_ATTRIBUTE09 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE09,
		STREAM_INTERFACE_ATTRIBUTE10 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE10,
		STREAM_INTERFACE_ATTRIBUTE11 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE11,
		STREAM_INTERFACE_ATTRIBUTE12 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE12,
		STREAM_INTERFACE_ATTRIBUTE13 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE13,
		STREAM_INTERFACE_ATTRIBUTE14 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE14,
		STREAM_INTERFACE_ATTRIBUTE15 = l_def_sif_rec.STREAM_INTERFACE_ATTRIBUTE15,
		CREATED_BY = l_def_sif_rec.CREATED_BY,
		LAST_UPDATED_BY = l_def_sif_rec.LAST_UPDATED_BY,
		CREATION_DATE = l_def_sif_rec.CREATION_DATE,
		LAST_UPDATE_DATE = l_def_sif_rec.LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN = l_def_sif_rec.LAST_UPDATE_LOGIN,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
		REQUEST_ID = l_def_sif_rec.REQUEST_ID,
		PROGRAM_APPLICATION_ID = l_def_sif_rec.PROGRAM_APPLICATION_ID,
		PROGRAM_ID = l_def_sif_rec.PROGRAM_ID,
		PROGRAM_UPDATE_DATE = l_def_sif_rec.PROGRAM_UPDATE_DATE,
            -- mvasudev -- 05/13/2002
                JTOT_OBJECT1_CODE = l_def_sif_rec.JTOT_OBJECT1_CODE,
                OBJECT1_ID1 = l_def_sif_rec.OBJECT1_ID1,
                OBJECT1_ID2 = l_def_sif_rec.OBJECT1_ID2,
                TERM = l_def_sif_rec.TERM,
                STRUCTURE = l_def_sif_rec.STRUCTURE,
                DEAL_TYPE = l_def_sif_rec.DEAL_TYPE,
                LOG_FILE = l_def_sif_rec.LOG_FILE,
                FIRST_PAYMENT = l_def_sif_rec.FIRST_PAYMENT,
                LAST_PAYMENT = l_def_sif_rec.LAST_PAYMENT,
                --  mvasudev, Bug#2650599
                SIF_ID = l_def_sif_rec.SIF_ID,
                PURPOSE_CODE = l_def_sif_rec.PURPOSE_CODE
                -- end, mvasudev, Bug#2650599
    WHERE ID = l_def_sif_rec.id;

    x_sif_rec := l_def_sif_rec;
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
  -- update_row for:OKL_STREAM_INTERFACES_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type,
    x_sifv_rec                     OUT NOCOPY sifv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sifv_rec                     sifv_rec_type := p_sifv_rec;
    l_def_sifv_rec                 sifv_rec_type;
    l_sif_rec                      sif_rec_type;
    lx_sif_rec                     sif_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sifv_rec	IN sifv_rec_type
    ) RETURN sifv_rec_type IS
      l_sifv_rec	sifv_rec_type := p_sifv_rec;
    BEGIN
      l_sifv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sifv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sifv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sifv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sifv_rec	IN sifv_rec_type,
      x_sifv_rec	OUT NOCOPY sifv_rec_type
    ) RETURN VARCHAR2 IS
      l_sifv_rec                     sifv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sifv_rec := p_sifv_rec;
      -- Get current database values
      l_sifv_rec := get_rec(p_sifv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sifv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.id := l_sifv_rec.id;
      END IF;
      IF (x_sifv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.object_version_number := l_sifv_rec.object_version_number;
      END IF;
      IF (x_sifv_rec.fasb_acct_treatment_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.fasb_acct_treatment_method := l_sifv_rec.FASB_ACCT_TREATMENT_METHOD;
      END IF;
      IF (x_sifv_rec.irs_tax_treatment_method = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.irs_tax_treatment_method := l_sifv_rec.irs_tax_treatment_method;
      END IF;
      IF (x_sifv_rec.sif_mode = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.sif_mode := l_sifv_rec.sif_mode;
      END IF;
      IF (x_sifv_rec.date_delivery = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.date_delivery := l_sifv_rec.date_delivery;
      END IF;
      IF (x_sifv_rec.total_funding = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.total_funding := l_sifv_rec.total_funding;
      END IF;
      IF (x_sifv_rec.security_deposit_amount = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.security_deposit_amount := l_sifv_rec.security_deposit_amount;
      END IF;
      IF (x_sifv_rec.sis_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.sis_code := l_sifv_rec.sis_code;
      END IF;
      IF (x_sifv_rec.khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.khr_id := l_sifv_rec.khr_id;
      END IF;
      IF (x_sifv_rec.pricing_template_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.pricing_template_name := l_sifv_rec.pricing_template_name;
      END IF;
      IF (x_sifv_rec.date_processed = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.date_processed := l_sifv_rec.date_delivery;
      END IF;
      IF (x_sifv_rec.date_sec_deposit_collected = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.date_sec_deposit_collected := l_sifv_rec.DATE_SEC_DEPOSIT_COLLECTED;
      END IF;
      IF (x_sifv_rec.date_payments_commencement = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.date_payments_commencement := l_sifv_rec.date_payments_commencement;
      END IF;
      IF (x_sifv_rec.transaction_number = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.transaction_number := l_sifv_rec.transaction_number;
      END IF;
      IF (x_sifv_rec.country = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.country := l_sifv_rec.country;
      END IF;
      IF (l_sifv_rec.lending_rate = OKC_API.G_MISS_NUM) THEN
        l_sifv_rec.lending_rate := NULL;
      END IF;
      IF (l_sifv_rec.rvi_yn = OKC_API.G_MISS_CHAR) THEN
        l_sifv_rec.rvi_yn := NULL;
      END IF;
      IF (l_sifv_rec.rvi_rate = OKC_API.G_MISS_NUM) THEN
        l_sifv_rec.rvi_rate := NULL;
      END IF;
      IF (l_sifv_rec.adjust = OKC_API.G_MISS_CHAR) THEN
        l_sifv_rec.adjust := NULL;
      END IF;
      IF (l_sifv_rec.adjustment_method = OKC_API.G_MISS_CHAR) THEN
        l_sifv_rec.adjustment_method := NULL;
      END IF;
      IF (l_sifv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM) THEN
        l_sifv_rec.implicit_interest_rate := NULL;
      END IF;
      IF (l_sifv_rec.orp_code = OKC_API.G_MISS_CHAR) THEN
        l_sifv_rec.orp_code := NULL;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute01 := l_sifv_rec.stream_interface_attribute01;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute02 := l_sifv_rec.stream_interface_attribute02;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute03 := l_sifv_rec.stream_interface_attribute03;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute04 := l_sifv_rec.stream_interface_attribute04;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute05 := l_sifv_rec.stream_interface_attribute05;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute06 := l_sifv_rec.stream_interface_attribute06;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute07 := l_sifv_rec.stream_interface_attribute07;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute08 := l_sifv_rec.stream_interface_attribute08;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute09 := l_sifv_rec.stream_interface_attribute09;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute10 := l_sifv_rec.stream_interface_attribute10;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute11 := l_sifv_rec.stream_interface_attribute11;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute12 := l_sifv_rec.stream_interface_attribute12;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute13 := l_sifv_rec.stream_interface_attribute13;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute14 := l_sifv_rec.stream_interface_attribute14;
      END IF;
      IF (x_sifv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.stream_interface_attribute15 := l_sifv_rec.stream_interface_attribute15;
      END IF;
      IF (x_sifv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.created_by := l_sifv_rec.created_by;
      END IF;
      IF (x_sifv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.last_updated_by := l_sifv_rec.last_updated_by;
      END IF;
      IF (x_sifv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.creation_date := l_sifv_rec.creation_date;
      END IF;
      IF (x_sifv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.last_update_date := l_sifv_rec.last_update_date;
      END IF;
      IF (x_sifv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.last_update_login := l_sifv_rec.last_update_login;
      END IF;
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
      IF (x_sifv_rec.REQUEST_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.REQUEST_ID := l_sifv_rec.REQUEST_ID;
      END IF;
      IF (x_sifv_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.PROGRAM_APPLICATION_ID := l_sifv_rec.PROGRAM_APPLICATION_ID;
      END IF;
      IF (x_sifv_rec.PROGRAM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sifv_rec.PROGRAM_ID := l_sifv_rec.PROGRAM_ID;
      END IF;
      IF (x_sifv_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_sifv_rec.PROGRAM_UPDATE_DATE := l_sifv_rec.PROGRAM_UPDATE_DATE;
      END IF;
      -- mvasudev -- 05/13/2002
      IF (x_sifv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_sifv_rec.JTOT_OBJECT1_CODE := l_sifv_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_sifv_rec.OBJECT1_ID1 = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.OBJECT1_ID1 := l_sifv_rec.OBJECT1_ID1;
      END IF;
      IF (x_sifv_rec.OBJECT1_ID2 = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.OBJECT1_ID2 := l_sifv_rec.OBJECT1_ID2;
      END IF;
      IF (x_sifv_rec.TERM = OKC_API.G_MISS_NUM)
            THEN
              x_sifv_rec.TERM := l_sifv_rec.TERM;
      END IF;
      IF (x_sifv_rec.STRUCTURE = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.STRUCTURE := l_sifv_rec.STRUCTURE;
      END IF;
      IF (x_sifv_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.DEAL_TYPE := l_sifv_rec.DEAL_TYPE;
      END IF;
      IF (x_sifv_rec.LOG_FILE = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.LOG_FILE := l_sifv_rec.LOG_FILE;
      END IF;
      IF (x_sifv_rec.FIRST_PAYMENT = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.FIRST_PAYMENT := l_sifv_rec.FIRST_PAYMENT;
      END IF;
      IF (x_sifv_rec.LAST_PAYMENT = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.LAST_PAYMENT := l_sifv_rec.LAST_PAYMENT;
      END IF;
      -- mvasudev, Bug#2650599
      IF (x_sifv_rec.SIF_ID = OKC_API.G_MISS_NUM)
            THEN
              x_sifv_rec.SIF_ID := l_sifv_rec.SIF_ID;
      END IF;
      IF (x_sifv_rec.purpose_code = OKC_API.G_MISS_CHAR)
            THEN
              x_sifv_rec.purpose_code := l_sifv_rec.purpose_code;
      END IF;
      -- end, mvasudev, Bug#2650599
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_STREAM_INTERFACES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sifv_rec IN  sifv_rec_type,
      x_sifv_rec OUT NOCOPY sifv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sifv_rec := p_sifv_rec;
      x_sifv_rec.OBJECT_VERSION_NUMBER := NVL(x_sifv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sifv_rec,                        -- IN
      l_sifv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sifv_rec, l_def_sifv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sifv_rec := fill_who_columns(l_def_sifv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sifv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sifv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sifv_rec, l_sif_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sif_rec,
      lx_sif_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sif_rec, l_def_sifv_rec);
    x_sifv_rec := l_def_sifv_rec;
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
  -- PL/SQL TBL update_row for:SIFV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type,
    x_sifv_tbl                     OUT NOCOPY sifv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 10/24/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- END change : mvasudev

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sifv_tbl.COUNT > 0) THEN
      i := p_sifv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sifv_rec                     => p_sifv_tbl(i),
          x_sifv_rec                     => x_sifv_tbl(i));

        -- START change : mvasudev, 10/24/2001
	        -- store the highest degree of error

	       	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	       	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	       	             l_overall_status := x_return_status;
	       	    END IF;
	       	END IF;

	       	-- END change : mvasudev



        EXIT WHEN (i = p_sifv_tbl.LAST);
        i := p_sifv_tbl.NEXT(i);
      END LOOP;

      -- START change : mvasudev, 10/24/2001
      -- return overall status

      x_return_status := l_overall_status;

      -- END change : mvasudev

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
  -- delete_row for:OKL_STREAM_INTERFACES --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sif_rec                      IN sif_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INTERFACES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sif_rec                      sif_rec_type:= p_sif_rec;
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
    DELETE FROM OKL_STREAM_INTERFACES
     WHERE ID = l_sif_rec.id;

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
  -- delete_row for:OKL_STREAM_INTERFACES_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_rec                     IN sifv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sifv_rec                     sifv_rec_type := p_sifv_rec;
    l_sif_rec                      sif_rec_type;
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
    migrate(l_sifv_rec, l_sif_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sif_rec
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
  -- PL/SQL TBL delete_row for:SIFV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sifv_tbl                     IN sifv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
   -- START change : mvasudev, 10/24/2001
   -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   -- END change : mvasudev


  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sifv_tbl.COUNT > 0) THEN
      i := p_sifv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sifv_rec                     => p_sifv_tbl(i));
          -- START change : mvasudev, 10/24/2001
	  -- store the highest degree of error

	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		     l_overall_status := x_return_status;
	    END IF;
	END IF;

	-- END change : mvasudev
        EXIT WHEN (i = p_sifv_tbl.LAST);
        i := p_sifv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 10/24/2001
      -- return overall status

      x_return_status := l_overall_status;

      -- END change : mvasudev
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
END Okl_Sif_Pvt;

/
