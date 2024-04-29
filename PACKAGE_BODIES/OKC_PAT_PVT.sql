--------------------------------------------------------
--  DDL for Package Body OKC_PAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PAT_PVT" AS
/* $Header: OKCSPATB.pls 120.1 2005/09/12 00:17:39 mchoudha noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_PRICE_ADJUSTMENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pat_rec                      IN pat_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pat_rec_type IS
    CURSOR pat_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            CHR_ID,
            CLE_ID,
            BSL_ID,
            BCL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            MODIFIED_FROM,
            MODIFIED_TO,
            MODIFIER_MECHANISM_TYPE_CODE,
            OPERAND,
            ARITHMETIC_OPERATOR,
            AUTOMATIC_FLAG,
            UPDATE_ALLOWED,
            UPDATED_FLAG,
            APPLIED_FLAG,
            ON_INVOICE_FLAG,
            PRICING_PHASE_ID,
           CONTEXT,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
	    REQUEST_ID,
	    LIST_HEADER_ID,
 	    LIST_LINE_ID,
	    LIST_LINE_TYPE_CODE,
	    CHANGE_REASON_CODE,
	    CHANGE_REASON_TEXT,
	    ESTIMATED_FLAG,
 	    ADJUSTED_AMOUNT,
	   CHARGE_TYPE_CODE,
	   CHARGE_SUBTYPE_CODE,
	   RANGE_BREAK_QUANTITY,
           ACCRUAL_CONVERSION_RATE,
           PRICING_GROUP_SEQUENCE,
           ACCRUAL_FLAG,
	   LIST_LINE_NO,
           SOURCE_SYSTEM_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           EXPIRATION_DATE,
           MODIFIER_LEVEL_CODE,
           PRICE_BREAK_TYPE_CODE,
           SUBSTITUTION_ATTRIBUTE,
           PRORATION_TYPE_CODE,
           INCLUDE_ON_RETURNS_FLAG,
           OBJECT_VERSION_NUMBER,
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
            REBATE_TRANSACTION_TYPE_CODE
       FROM Okc_Price_Adjustments
     WHERE okc_price_adjustments.id = p_id;
    l_pat_pk                       pat_pk_csr%ROWTYPE;
    l_pat_rec                      pat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN pat_pk_csr (p_pat_rec.id);
    FETCH pat_pk_csr INTO
              l_pat_rec.ID,
              l_pat_rec.PAT_ID,
              l_pat_rec.CHR_ID,
              l_pat_rec.CLE_ID,
              l_pat_rec.BSL_ID,
              l_pat_rec.BCL_ID,
              l_pat_rec.CREATED_BY,
              l_pat_rec.CREATION_DATE,
              l_pat_rec.LAST_UPDATED_BY,
              l_pat_rec.LAST_UPDATE_DATE,
              l_pat_rec.MODIFIED_FROM,
              l_pat_rec.MODIFIED_TO,
              l_pat_rec.MODIFIER_MECHANISM_TYPE_CODE,
              l_pat_rec.OPERAND,
              l_pat_rec.ARITHMETIC_OPERATOR,
              l_pat_rec.AUTOMATIC_FLAG,
              l_pat_rec.UPDATE_ALLOWED,
              l_pat_rec.UPDATED_FLAG,
              l_pat_rec.APPLIED_FLAG,
              l_pat_rec.ON_INVOICE_FLAG,
              l_pat_rec.PRICING_PHASE_ID,
              l_pat_rec.CONTEXT,
           l_pat_rec.PROGRAM_APPLICATION_ID,
           l_pat_rec.PROGRAM_ID,
           l_pat_rec.PROGRAM_UPDATE_DATE,
           l_pat_rec.REQUEST_ID,
            l_pat_rec.LIST_HEADER_ID,
            l_pat_rec.LIST_LINE_ID,
           l_pat_rec.LIST_LINE_TYPE_CODE,
            l_pat_rec.CHANGE_REASON_CODE,
            l_pat_rec.CHANGE_REASON_TEXT,
            l_pat_rec.ESTIMATED_FLAG,
            l_pat_rec.ADJUSTED_AMOUNT,
           l_pat_rec.CHARGE_TYPE_CODE,
           l_pat_rec.CHARGE_SUBTYPE_CODE,
           l_pat_rec.RANGE_BREAK_QUANTITY,
           l_pat_rec.ACCRUAL_CONVERSION_RATE,
           l_pat_rec.PRICING_GROUP_SEQUENCE,
           l_pat_rec.ACCRUAL_FLAG,
           l_pat_rec.LIST_LINE_NO,
           l_pat_rec.SOURCE_SYSTEM_CODE,
           l_pat_rec.BENEFIT_QTY,
           l_pat_rec.BENEFIT_UOM_CODE,
           l_pat_rec.EXPIRATION_DATE,
           l_pat_rec.MODIFIER_LEVEL_CODE,
           l_pat_rec.PRICE_BREAK_TYPE_CODE,
           l_pat_rec.SUBSTITUTION_ATTRIBUTE,
           l_pat_rec.PRORATION_TYPE_CODE,
           l_pat_rec.INCLUDE_ON_RETURNS_FLAG,
           l_pat_rec.OBJECT_VERSION_NUMBER,
              l_pat_rec.ATTRIBUTE1,
              l_pat_rec.ATTRIBUTE2,
              l_pat_rec.ATTRIBUTE3,
              l_pat_rec.ATTRIBUTE4,
              l_pat_rec.ATTRIBUTE5,
              l_pat_rec.ATTRIBUTE6,
              l_pat_rec.ATTRIBUTE7,
              l_pat_rec.ATTRIBUTE8,
              l_pat_rec.ATTRIBUTE9,
              l_pat_rec.ATTRIBUTE10,
              l_pat_rec.ATTRIBUTE11,
              l_pat_rec.ATTRIBUTE12,
              l_pat_rec.ATTRIBUTE13,
              l_pat_rec.ATTRIBUTE14,
              l_pat_rec.ATTRIBUTE15,
              l_pat_rec.LAST_UPDATE_LOGIN,
              l_pat_rec.REBATE_TRANSACTION_TYPE_CODE;
    x_no_data_found := pat_pk_csr%NOTFOUND;
    CLOSE pat_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('550: Leaving get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_pat_rec);

  END get_rec;

  FUNCTION get_rec (
    p_pat_rec                      IN pat_rec_type
  ) RETURN pat_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_pat_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ADJUSTMENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_patv_rec                     IN patv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN patv_rec_type IS
    CURSOR okc_patv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            CHR_ID,
            CLE_ID,
            BSL_ID,
            BCL_ID,
            MODIFIED_FROM,
            MODIFIED_TO,
            MODIFIER_MECHANISM_TYPE_CODE,
            OPERAND,
            ARITHMETIC_OPERATOR,
            AUTOMATIC_FLAG,
            UPDATE_ALLOWED,
            UPDATED_FLAG,
            APPLIED_FLAG,
            ON_INVOICE_FLAG,
            PRICING_PHASE_ID,
            CONTEXT,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            LIST_HEADER_ID,
            LIST_LINE_ID,
            LIST_LINE_TYPE_CODE,
            CHANGE_REASON_CODE,
            CHANGE_REASON_TEXT,
            ESTIMATED_FLAG,
            ADJUSTED_AMOUNT,
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           RANGE_BREAK_QUANTITY,
           ACCRUAL_CONVERSION_RATE,
           PRICING_GROUP_SEQUENCE,
           ACCRUAL_FLAG,
           LIST_LINE_NO,
           SOURCE_SYSTEM_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           EXPIRATION_DATE,
           MODIFIER_LEVEL_CODE,
           PRICE_BREAK_TYPE_CODE,
           SUBSTITUTION_ATTRIBUTE,
           PRORATION_TYPE_CODE,
           INCLUDE_ON_RETURNS_FLAG,
           OBJECT_VERSION_NUMBER,
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
           REBATE_TRANSACTION_TYPE_CODE
      FROM Okc_Price_Adjustments_V
     WHERE okc_price_adjustments_v.id = p_id;
    l_okc_patv_pk                  okc_patv_pk_csr%ROWTYPE;
    l_patv_rec                     patv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_patv_pk_csr (p_patv_rec.id);
    FETCH okc_patv_pk_csr INTO
              l_patv_rec.ID,
              l_patv_rec.PAT_ID,
              l_patv_rec.CHR_ID,
              l_patv_rec.CLE_ID,
              l_patv_rec.BSL_ID,
              l_patv_rec.BCL_ID,
              l_patv_rec.MODIFIED_FROM,
              l_patv_rec.MODIFIED_TO,
              l_patv_rec.MODIFIER_MECHANISM_TYPE_CODE,
              l_patv_rec.OPERAND,
              l_patv_rec.ARITHMETIC_OPERATOR,
              l_patv_rec.AUTOMATIC_FLAG,
              l_patv_rec.UPDATE_ALLOWED,
              l_patv_rec.UPDATED_FLAG,
              l_patv_rec.APPLIED_FLAG,
              l_patv_rec.ON_INVOICE_FLAG,
              l_patv_rec.PRICING_PHASE_ID,
              l_patv_rec.CONTEXT,
              l_patv_rec.PROGRAM_APPLICATION_ID,
           l_patv_rec.PROGRAM_ID,
           l_patv_rec.PROGRAM_UPDATE_DATE,
           l_patv_rec.REQUEST_ID,
            l_patv_rec.LIST_HEADER_ID,
            l_patv_rec.LIST_LINE_ID,
           l_patv_rec.LIST_LINE_TYPE_CODE,
            l_patv_rec.CHANGE_REASON_CODE,
            l_patv_rec.CHANGE_REASON_TEXT,
            l_patv_rec.ESTIMATED_FLAG,
            l_patv_rec.ADJUSTED_AMOUNT,
           l_patv_rec.CHARGE_TYPE_CODE,
           l_patv_rec.CHARGE_SUBTYPE_CODE,
           l_patv_rec.RANGE_BREAK_QUANTITY,
           l_patv_rec.ACCRUAL_CONVERSION_RATE,
           l_patv_rec.PRICING_GROUP_SEQUENCE,
           l_patv_rec.ACCRUAL_FLAG,
           l_patv_rec.LIST_LINE_NO,
           l_patv_rec.SOURCE_SYSTEM_CODE,
           l_patv_rec.BENEFIT_QTY,
           l_patv_rec.BENEFIT_UOM_CODE,
           l_patv_rec.EXPIRATION_DATE,
           l_patv_rec.MODIFIER_LEVEL_CODE,
           l_patv_rec.PRICE_BREAK_TYPE_CODE,
           l_patv_rec.SUBSTITUTION_ATTRIBUTE,
           l_patv_rec.PRORATION_TYPE_CODE,
           l_patv_rec.INCLUDE_ON_RETURNS_FLAG,
           l_patv_rec.OBJECT_VERSION_NUMBER,
              l_patv_rec.ATTRIBUTE1,
              l_patv_rec.ATTRIBUTE2,
              l_patv_rec.ATTRIBUTE3,
              l_patv_rec.ATTRIBUTE4,
              l_patv_rec.ATTRIBUTE5,
              l_patv_rec.ATTRIBUTE6,
              l_patv_rec.ATTRIBUTE7,
              l_patv_rec.ATTRIBUTE8,
              l_patv_rec.ATTRIBUTE9,
              l_patv_rec.ATTRIBUTE10,
              l_patv_rec.ATTRIBUTE11,
              l_patv_rec.ATTRIBUTE12,
              l_patv_rec.ATTRIBUTE13,
              l_patv_rec.ATTRIBUTE14,
              l_patv_rec.ATTRIBUTE15,
              l_patv_rec.CREATED_BY,
              l_patv_rec.CREATION_DATE,
              l_patv_rec.LAST_UPDATED_BY,
              l_patv_rec.LAST_UPDATE_DATE,
              l_patv_rec.LAST_UPDATE_LOGIN,
              l_patv_rec.REBATE_TRANSACTION_TYPE_CODE;
    x_no_data_found := okc_patv_pk_csr%NOTFOUND;
    CLOSE okc_patv_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('750: Leaving get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_patv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_patv_rec                     IN patv_rec_type
  ) RETURN patv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_patv_rec, l_row_notfound));

  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PRICE_ADJUSTMENTS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_patv_rec	IN patv_rec_type
  ) RETURN patv_rec_type IS
    l_patv_rec	patv_rec_type := p_patv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('900: Entered null_out_defaults', 2);
    END IF;

    IF (l_patv_rec.pat_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.pat_id := NULL;
    END IF;
    IF (l_patv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.chr_id := NULL;
    END IF;
    IF (l_patv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.cle_id := NULL;
    END IF;
    IF (l_patv_rec.bsl_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.bsl_id := NULL;
    END IF;
    IF (l_patv_rec.bcl_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.bcl_id := NULL;
    END IF;
    IF (l_patv_rec.modified_from = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.modified_from := NULL;
    END IF;
    IF (l_patv_rec.modified_to = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.modified_to := NULL;
    END IF;
    IF (l_patv_rec.modifier_mechanism_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.modifier_mechanism_type_code := NULL;
    END IF;
    IF (l_patv_rec.operand = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.operand := NULL;
    END IF;
    IF (l_patv_rec.arithmetic_operator = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.arithmetic_operator := NULL;
    END IF;
    IF (l_patv_rec.automatic_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.automatic_flag := NULL;
    END IF;
    IF (l_patv_rec.update_allowed = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.update_allowed := NULL;
    END IF;
    IF (l_patv_rec.updated_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.updated_flag := NULL;
    END IF;
    IF (l_patv_rec.applied_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.applied_flag := NULL;
    END IF;
    IF (l_patv_rec.on_invoice_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.on_invoice_flag := NULL;
    END IF;
    IF (l_patv_rec.pricing_phase_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.pricing_phase_id := NULL;
    END IF;
    IF (l_patv_rec.context = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.context := NULL;
    END IF;

     IF (l_patv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.program_application_id := NULL;
    END IF;
    IF (l_patv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.program_id := NULL;
    END IF;
    IF(l_patv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_patv_rec.program_update_date := NULL;
    END IF;
    IF (l_patv_rec.request_id= OKC_API.G_MISS_NUM) THEN
      l_patv_rec.request_id := NULL;
    END IF;
    IF (l_patv_rec.list_header_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.list_header_id := NULL;
    END IF;

    IF (l_patv_rec.list_line_id = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.list_line_id := NULL;
    END IF;
    IF (l_patv_rec.list_line_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.list_line_type_code := NULL;
    END IF;
    IF (l_patv_rec.change_reason_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.change_reason_code := NULL;
    END IF;
    IF (l_patv_rec.change_reason_text = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.change_reason_text := NULL;
    END IF;
   IF (l_patv_rec.estimated_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.estimated_flag := NULL;
    END IF;
    IF(l_patv_rec.adjusted_amount = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.adjusted_amount := NULL;
    END IF;
   IF (l_patv_rec.charge_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.charge_type_code := NULL;
    END IF;
    IF(l_patv_rec.charge_subtype_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.charge_subtype_code := NULL;
    END IF;
   IF (l_patv_rec.range_break_quantity = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.range_break_quantity := NULL;
    END IF;
   IF (l_patv_rec.accrual_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.accrual_conversion_rate := NULL;
    END IF;
   IF (l_patv_rec.pricing_group_sequence = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.pricing_group_sequence := NULL;
    END IF;
    IF(l_patv_rec.accrual_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.accrual_flag := NULL;
    END IF;
    IF(l_patv_rec.list_line_no = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.list_line_no := NULL;
    END IF;
    IF (l_patv_rec.source_system_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.source_system_code := NULL;
    END IF;
     IF (l_patv_rec.benefit_qty = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.benefit_qty := NULL;
    END IF;
     IF (l_patv_rec.benefit_uom_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.benefit_uom_code := NULL;
    END IF;
     IF (l_patv_rec.expiration_date = OKC_API.G_MISS_DATE) THEN
      l_patv_rec.expiration_date := NULL;
    END IF;
     IF (l_patv_rec.modifier_level_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.modifier_level_code := NULL;
    END IF;
     IF (l_patv_rec.price_break_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.price_break_type_code := NULL;
    END IF;
     IF (l_patv_rec.substitution_attribute = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.substitution_attribute := NULL;
    END IF;
   IF (l_patv_rec.proration_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.proration_type_code := NULL;
    END IF;
    IF (l_patv_rec.include_on_returns_flag = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.include_on_returns_flag := NULL;
    END IF;
    IF (l_patv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.object_version_number := NULL;
    END IF;

    IF (l_patv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute1 := NULL;
    END IF;
    IF (l_patv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute2 := NULL;
    END IF;
    IF (l_patv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute3 := NULL;
    END IF;
    IF (l_patv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute4 := NULL;
    END IF;
    IF (l_patv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute5 := NULL;
    END IF;
    IF (l_patv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute6 := NULL;
    END IF;
    IF (l_patv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute7 := NULL;
    END IF;
    IF (l_patv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute8 := NULL;
    END IF;
    IF (l_patv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute9 := NULL;
    END IF;
    IF (l_patv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute10 := NULL;
    END IF;
    IF (l_patv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute11 := NULL;
    END IF;
    IF (l_patv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute12 := NULL;
    END IF;
    IF (l_patv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute13 := NULL;
    END IF;
    IF (l_patv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute14 := NULL;
    END IF;
    IF (l_patv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.attribute15 := NULL;
    END IF;
    IF (l_patv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.created_by := NULL;
    END IF;
    IF (l_patv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_patv_rec.creation_date := NULL;
    END IF;
    IF (l_patv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.last_updated_by := NULL;
    END IF;
    IF (l_patv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_patv_rec.last_update_date := NULL;
    END IF;
    IF (l_patv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_patv_rec.last_update_login := NULL;
    END IF;
    IF (l_patv_rec.rebate_transaction_type_code = OKC_API.G_MISS_CHAR) THEN
      l_patv_rec.rebate_transaction_type_code := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('950: Leaving null_out_defaults ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_patv_rec);

  END null_out_defaults;

-------------------------------------------------------------------------------------
  --Attribute Level Validation Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------\\\\\\

---------------------------------------------------------------------------------
     -----Foreign key validations
---------------------------------------------------------------------------------
     PROCEDURE validate_list_header_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_patv_rec      IN    patv_rec_type) is

   G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
  G_VIEW                         CONSTANT       VARCHAR2(200) := 'QP_LIST_HEADERS_V';
  G_EXCEPTION_HALT_VALIDATION   exception;
  l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_patv_csr Is
                select 'x'
                from QP_LIST_HEADERS_B
                where LIST_HEADER_ID = p_patv_rec.list_header_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('1000: Entered validate_list_header_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_patv_rec.list_header_id <> OKC_API.G_MISS_NUM and
           p_patv_rec.chr_id IS NOT NULL)
    Then
      Open l_patv_csr;
      Fetch l_patv_csr Into l_dummy_var;
      Close l_patv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
            OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  => g_no_parent_record,
                                            p_token1    => g_col_name_token,
                                            p_token1_value=> 'chr_id',
                                            p_token2    => g_child_table_token,
                                            p_token2_value=> G_VIEW,
                                            p_token3    => g_parent_table_token,
                                            p_token3_value=> 'QP_LIST_HEADERS_V');
            -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving validate_list_header_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_list_header_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

          -- store SQL error message on message stack
  OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);
           -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_patv_csr%ISOPEN then
              close l_patv_csr;
        end if;

  End validate_list_header_id;


 PROCEDURE validate_list_line_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_patv_rec      IN    patv_rec_type) is

   G_NO_PARENT_RECORD CONSTANT   VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
  G_VIEW                         CONSTANT       VARCHAR2(200) := 'QP_LIST_HEADERS_V';
  G_EXCEPTION_HALT_VALIDATION   exception;
  l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_patv_csr Is
                select 'x'
                from QP_LIST_LINES
                where LIST_LINE_ID = p_patv_rec.list_line_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('1300: Entered validate_list_line_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_patv_rec.list_line_id <> OKC_API.G_MISS_NUM and
           p_patv_rec.list_line_id IS NOT NULL)
    Then
      Open l_patv_csr;
      Fetch l_patv_csr Into l_dummy_var;
      Close l_patv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
            OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  => g_no_parent_record,
                                            p_token1    => g_col_name_token,
                                            p_token1_value=> 'chr_id',
                                            p_token2    => g_child_table_token,
                                            p_token2_value=> G_VIEW,
                                            p_token3    => g_parent_table_token,
                                            p_token3_value=> 'QP_LIST_LINE_V');
            -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Leaving validate_list_line_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_list_line_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

          -- store SQL error message on message stack
  OKC_API.SET_MESSAGE(p_app_name                => g_app_name,
                                          p_msg_name            => g_unexpected_error,
                                          p_token1              => g_sqlcode_token,
                                          p_token1_value        => sqlcode,
                                          p_token2              => g_sqlerrm_token,
                                          p_token2_value        => sqlerrm);
           -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_patv_csr%ISOPEN then
              close l_patv_csr;
        end if;

  End validate_list_line_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('1600: Entered validate_id', 2);
    END IF;

    IF p_patv_rec.id = OKC_API.G_MISS_NUM OR
       p_patv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Leaving validate_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_automatic_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_automatic_flag(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('1900: Entered validate_automatic_flag', 2);
    END IF;

      -- Check if automatic_flag is Y or N.

    IF p_patv_rec.automatic_flag NOT IN ('Y', 'N')
    THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'automatic_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving validate_automatic_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Exiting validate_automatic_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      NULL;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_automatic_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END validate_automatic_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_update_allowed
  ---------------------------------------------------------------------------
  PROCEDURE validate_update_allowed(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('2300: Entered validate_update_allowed', 2);
    END IF;


    IF p_patv_rec.update_allowed NOT IN ('Y', 'N')
    THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'update_allowed');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2400: Leaving validate_update_allowed', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Exiting validate_update_allowed:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      NULL;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_update_allowed:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_update_allowed;


---------------------------------------------------------------------------
  -- PROCEDURE Validate_updated_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_updated_flag(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('2700: Entered validate_updated_flag', 2);
    END IF;


IF p_patv_rec.updated_flag NOT IN ('Y', 'N')
    THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'updated_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Leaving validate_updated_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Exiting validate_updated_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      NULL;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_updated_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_updated_flag;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_applied_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_applied_flag(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('3100: Entered validate_applied_flag', 2);
    END IF;


IF p_patv_rec.applied_flag NOT IN ('Y', 'N')
    THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'applied_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Leaving validate_applied_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting validate_applied_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      NULL;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_applied_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END validate_applied_flag;


    ---------------------------------------------------------------------------
  -- PROCEDURE Validate_on_invoice_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_on_invoice_flag(
    p_patv_rec          IN patv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('3500: Entered validate_on_invoice_flag', 2);
    END IF;


    IF p_patv_rec.on_invoice_flag NOT IN ('Y', 'N')
    THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'on_invoice_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Leaving validate_on_invoice_flag', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Exiting validate_on_invoice_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      NULL;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Exiting validate_on_invoice_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END validate_on_invoice_flag;

---------------------------------------------------------------------
----PROCEDURE Validate_chr_id   -------------
--------------------------------------------------------------------
procedure validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                          p_patv_rec      IN    patv_rec_type) is
l_dummy_var                 varchar2(1) := '?';
cursor l_chr_csr is
  select 'x'
  from OKC_K_HEADERS_B
  where id = p_patv_rec.chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('3900: Entered validate_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_patv_rec.chr_id = OKC_API.G_MISS_NUM or p_patv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
  open l_chr_csr;
  fetch l_chr_csr into l_dummy_var;
  close l_chr_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Leaving validate_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('4100: Exiting validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_chr_csr%ISOPEN then
      close l_chr_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_chr_id;
--------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_PRICE_ADJUSTMENTS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_patv_rec IN  patv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('4200: Entered Validate_Attributes', 2);
    END IF;

    ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

    VALIDATE_id(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

  VALIDATE_automatic_flag(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

  VALIDATE_update_allowed(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   VALIDATE_updated_flag(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   VALIDATE_applied_flag(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

validate_list_header_id(l_return_status,p_patv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_chr_id(l_return_status,p_patv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;


  validate_list_line_id(l_return_status ,p_patv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;


  VALIDATE_on_invoice_flag(p_patv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4300: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

  RETURN(x_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4400: Exiting Validate_Attributes:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      return(x_return_status);
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);


 ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------


END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_PRICE_ADJUSTMENTS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_patv_rec IN patv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_patv_rec IN patv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_patv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_Price_Adjustments_V
       WHERE okc_price_adjustments_v.id = p_id;
      l_okc_patv_pk                  okc_patv_pk_csr%ROWTYPE;
      CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_K_Headers_B
       WHERE okc_k_headers_b.id   = p_id;
      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
      CURSOR okc_clev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_K_Lines_B
       WHERE okc_k_lines_b.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;

      /*01-SEP-2005 -mchoudha
        Bug#4520703: Commenting these validations as they are
        not required during insertion of okc_price_adjustments.
        Moreover, these are already validated during initial phase
        of Main billing.As per discussion with Umesh.


      CURSOR oks_bslv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Oks_Bill_Sub_Lines_V
       WHERE oks_bill_sub_lines_v.id = p_id;
      l_oks_bslv_pk                  oks_bslv_pk_csr%ROWTYPE;

      CURSOR okc_bclv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Oks_Bill_Cont_Lines_V
       WHERE oks_bill_cont_lines_v.id = p_id;
      l_okc_bclv_pk                  okc_bclv_pk_csr%ROWTYPE;
      */


      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('4600: Entered validate_foreign_keys', 2);
    END IF;

      IF (p_patv_rec.PAT_ID IS NOT NULL)
      THEN
        OPEN okc_patv_pk_csr(p_patv_rec.PAT_ID);
        FETCH okc_patv_pk_csr INTO l_okc_patv_pk;
        l_row_notfound := okc_patv_pk_csr%NOTFOUND;
        CLOSE okc_patv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PAT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_patv_rec.CHR_ID IS NOT NULL)
      THEN
        OPEN okc_chrv_pk_csr(p_patv_rec.CHR_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_patv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_patv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

      /*01-SEP-2005 -mchoudha
        Bug#4520703: Commenting these validations as they are
        not required during insertion of okc_price_adjustments.
        Moreover, these are already validated during initial phase
        of Main billing.As per discussion with Umesh.

      IF (p_patv_rec.BSL_ID IS NOT NULL)
      THEN
        OPEN oks_bslv_pk_csr(p_patv_rec.BSL_ID);
        FETCH oks_bslv_pk_csr INTO l_oks_bslv_pk;
        l_row_notfound := oks_bslv_pk_csr%NOTFOUND;
        CLOSE oks_bslv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_patv_rec.BCL_ID IS NOT NULL)
      THEN
        OPEN okc_bclv_pk_csr(p_patv_rec.BCL_ID);
        FETCH okc_bclv_pk_csr INTO l_okc_bclv_pk;
        l_row_notfound := okc_bclv_pk_csr%NOTFOUND;
        CLOSE okc_bclv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BCL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      */
    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving validate_foreign_keys', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN (l_return_status);

    EXCEPTION
      WHEN item_not_found_error THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_foreign_keys:item_not_found_error Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);

    END validate_foreign_keys;
  BEGIN

    l_return_status := validate_foreign_keys (p_patv_rec);
    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN patv_rec_type,
    p_to        IN OUT NOCOPY pat_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.modified_from := p_from.modified_from;
    p_to.modified_to := p_from.modified_to;
    p_to.modifier_mechanism_type_code := p_from.modifier_mechanism_type_code;
    p_to.operand := p_from.operand;
    p_to.arithmetic_operator := p_from.arithmetic_operator;
    p_to.automatic_flag := p_from.automatic_flag;
    p_to.update_allowed := p_from.update_allowed;
    p_to.updated_flag := p_from.updated_flag;
    p_to.applied_flag := p_from.applied_flag;
    p_to.on_invoice_flag := p_from.on_invoice_flag;
    p_to.pricing_phase_id := p_from.pricing_phase_id;
    p_to.context := p_from.context;

     p_to.program_application_id := p_from.program_application_id;
      p_to.program_id := p_from.program_id;
      p_to.program_update_date:= p_from.program_update_date;
      p_to.request_id := p_from.request_id;
      p_to.list_header_id := p_from.list_header_id;
      p_to.list_line_id := p_from.list_line_id;
      p_to.list_line_type_code := p_from.list_line_type_code;
      p_to.change_reason_code := p_from.change_reason_code;
      p_to.change_reason_text := p_from.change_reason_text;
      p_to.estimated_flag := p_from.estimated_flag;
      p_to.adjusted_amount := p_from.adjusted_amount;
      p_to.charge_type_code := p_from.charge_type_code;
      p_to.charge_subtype_code := p_from.charge_subtype_code;
      p_to.range_break_quantity := p_from.range_break_quantity;
      p_to.accrual_conversion_rate := p_from.accrual_conversion_rate;
      p_to.pricing_group_sequence := p_from.pricing_group_sequence;
      p_to.accrual_flag := p_from.accrual_flag;
      p_to.list_line_no := p_from.list_line_no;
      p_to.source_system_code := p_from.source_system_code;
      p_to.benefit_qty := p_from.benefit_qty;
      p_to.benefit_uom_code := p_from.benefit_uom_code;
      p_to.expiration_date := p_from.expiration_date;
      p_to.modifier_level_code := p_from.modifier_level_code;
      p_to.price_break_type_code := p_from.price_break_type_code;
      p_to.substitution_attribute := p_from.substitution_attribute;
      p_to.proration_type_code := p_from.proration_type_code;
      p_to.include_on_returns_flag := p_from.include_on_returns_flag;
      p_to.object_version_number := p_from.object_version_number;
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
    p_to.rebate_transaction_type_code :=  p_from.rebate_transaction_type_code;

    END migrate;
  PROCEDURE migrate (
    p_from	IN pat_rec_type,
    p_to	IN OUT NOCOPY patv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.modified_from := p_from.modified_from;
    p_to.modified_to := p_from.modified_to;
    p_to.modifier_mechanism_type_code := p_from.modifier_mechanism_type_code;
    p_to.operand := p_from.operand;
    p_to.arithmetic_operator := p_from.arithmetic_operator;
    p_to.automatic_flag := p_from.automatic_flag;
    p_to.update_allowed := p_from.update_allowed;
    p_to.updated_flag := p_from.updated_flag;
    p_to.applied_flag := p_from.applied_flag;
    p_to.on_invoice_flag := p_from.on_invoice_flag;
    p_to.pricing_phase_id := p_from.pricing_phase_id;
    p_to.context := p_from.context;
    p_to.program_application_id := p_from.program_application_id;
      p_to.program_id := p_from.program_id;
      p_to.program_update_date:= p_from.program_update_date;
      p_to.request_id := p_from.request_id;
      p_to.list_header_id := p_from.list_header_id;
      p_to.list_line_id := p_from.list_line_id;
      p_to.list_line_type_code := p_from.list_line_type_code;
      p_to.change_reason_code := p_from.change_reason_code;
      p_to.change_reason_text := p_from.change_reason_text;
      p_to.estimated_flag := p_from.estimated_flag;
      p_to.adjusted_amount := p_from.adjusted_amount;
      p_to.charge_type_code := p_from.charge_type_code;
      p_to.charge_subtype_code := p_from.charge_subtype_code;
      p_to.range_break_quantity := p_from.range_break_quantity;
      p_to.accrual_conversion_rate := p_from.accrual_conversion_rate;
      p_to.pricing_group_sequence := p_from.pricing_group_sequence;
      p_to.accrual_flag := p_from.accrual_flag;
      p_to.list_line_no := p_from.list_line_no;
      p_to.source_system_code := p_from.source_system_code;
      p_to.benefit_qty := p_from.benefit_qty;
      p_to.benefit_uom_code := p_from.benefit_uom_code;
      p_to.expiration_date := p_from.expiration_date;
      p_to.modifier_level_code := p_from.modifier_level_code;
      p_to.price_break_type_code := p_from.price_break_type_code;
      p_to.substitution_attribute := p_from.substitution_attribute;
      p_to.proration_type_code := p_from.proration_type_code;
      p_to.include_on_returns_flag := p_from.include_on_returns_flag;
      p_to.object_version_number := p_from.object_version_number;


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
    p_to.rebate_transaction_type_code :=  p_from.rebate_transaction_type_code;

    END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_PRICE_ADJUSTMENTS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_patv_rec                     patv_rec_type := p_patv_rec;
    l_pat_rec                      pat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('5200: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_patv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_patv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:PATV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('5700: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_patv_tbl.COUNT > 0) THEN
      i := p_patv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_patv_rec                     => p_patv_tbl(i));
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Exiting validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- insert_row for:OKC_PRICE_ADJUSTMENTS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pat_rec                      IN pat_rec_type,
    x_pat_rec                      OUT NOCOPY pat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ADJUSTMENTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pat_rec                      pat_rec_type := p_pat_rec;
    l_def_pat_rec                  pat_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJUSTMENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pat_rec IN  pat_rec_type,
      x_pat_rec OUT NOCOPY pat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pat_rec := p_pat_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('6300: Entered insert_row', 2);
    END IF;

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
      p_pat_rec,                         -- IN
      l_pat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PRICE_ADJUSTMENTS(
        id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
      adjusted_amount,
      charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
        rebate_transaction_type_code)
      VALUES (
        l_pat_rec.id,
        l_pat_rec.pat_id,
        l_pat_rec.chr_id,
        l_pat_rec.cle_id,
        l_pat_rec.bsl_id,
        l_pat_rec.bcl_id,
        l_pat_rec.created_by,
        l_pat_rec.creation_date,
        l_pat_rec.last_updated_by,
        l_pat_rec.last_update_date,
        l_pat_rec.modified_from,
        l_pat_rec.modified_to,
        l_pat_rec.modifier_mechanism_type_code,
        l_pat_rec.operand,
        l_pat_rec.arithmetic_operator,
        l_pat_rec.automatic_flag,
        l_pat_rec.update_allowed,
        l_pat_rec.updated_flag,
        l_pat_rec.applied_flag,
        l_pat_rec.on_invoice_flag,
        l_pat_rec.pricing_phase_id,
        l_pat_rec.context,
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
       decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
       decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        l_pat_rec.list_header_id,
        l_pat_rec.list_line_id,
        l_pat_rec.list_line_type_code,
      l_pat_rec.change_reason_code,
      l_pat_rec.change_reason_text,
      l_pat_rec.estimated_flag,
      l_pat_rec.adjusted_amount,
      l_pat_rec.charge_type_code,
      l_pat_rec.charge_subtype_code,
      l_pat_rec.range_break_quantity,
      l_pat_rec.accrual_conversion_rate,
      l_pat_rec.pricing_group_sequence,
      l_pat_rec.accrual_flag,
      l_pat_rec.list_line_no,
      l_pat_rec.source_system_code,
      l_pat_rec.benefit_qty,
      l_pat_rec.benefit_uom_code,
      l_pat_rec.expiration_date,
      l_pat_rec.modifier_level_code,
      l_pat_rec.price_break_type_code,
      l_pat_rec.substitution_attribute,
      l_pat_rec.proration_type_code,
      l_pat_rec.include_on_returns_flag,
      l_pat_rec.object_version_number,
        l_pat_rec.attribute1,
        l_pat_rec.attribute2,
        l_pat_rec.attribute3,
        l_pat_rec.attribute4,
        l_pat_rec.attribute5,
        l_pat_rec.attribute6,
        l_pat_rec.attribute7,
        l_pat_rec.attribute8,
        l_pat_rec.attribute9,
        l_pat_rec.attribute10,
        l_pat_rec.attribute11,
        l_pat_rec.attribute12,
        l_pat_rec.attribute13,
        l_pat_rec.attribute14,
        l_pat_rec.attribute15,
        l_pat_rec.last_update_login,
        l_pat_rec.rebate_transaction_type_code);
    -- Set OUT values
    x_pat_rec := l_pat_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6700: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- insert_row for:OKC_PRICE_ADJUSTMENTS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_patv_rec                     patv_rec_type;
    l_def_patv_rec                 patv_rec_type;
    l_pat_rec                      pat_rec_type;
    lx_pat_rec                     pat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_patv_rec	IN patv_rec_type
    ) RETURN patv_rec_type IS
      l_patv_rec	patv_rec_type := p_patv_rec;
    BEGIN

      l_patv_rec.CREATION_DATE := SYSDATE;
      l_patv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_patv_rec.LAST_UPDATE_DATE := l_patv_rec.CREATION_DATE;
      l_patv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_patv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_patv_rec);

    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJUSTMENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_patv_rec IN  patv_rec_type,
      x_patv_rec OUT NOCOPY patv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_patv_rec := p_patv_rec;
      x_patv_rec.OBJECT_VERSION_NUMBER := 1;
  RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('7000: Entered insert_row', 2);
    END IF;

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
    l_patv_rec := null_out_defaults(p_patv_rec);
    -- Set primary key value
    l_patv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_patv_rec,                        -- IN
      l_def_patv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_patv_rec := fill_who_columns(l_def_patv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_patv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_patv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_patv_rec, l_pat_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pat_rec,
      lx_pat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pat_rec, l_def_patv_rec);
    -- Set OUT values
    x_patv_rec := l_def_patv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:PATV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('7500: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_patv_tbl.COUNT > 0) THEN
      i := p_patv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_patv_rec                     => p_patv_tbl(i),
          x_patv_rec                     => x_patv_tbl(i));
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- lock_row for:OKC_PRICE_ADJUSTMENTS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pat_rec                      IN pat_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pat_rec IN pat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PRICE_ADJUSTMENTS
     WHERE ID = p_pat_rec.id
	 AND OBJECT_VERSION_NUMBER = p_pat_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pat_rec IN pat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PRICE_ADJUSTMENTS
    WHERE ID = p_pat_rec.id;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ADJUSTMENTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_PRICE_ADJUSTMENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_PRICE_ADJUSTMENTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('8000: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('8100: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_pat_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_pat_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pat_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pat_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- lock_row for:OKC_PRICE_ADJUSTMENTS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pat_rec                      pat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('8800: Entered lock_row', 2);
    END IF;

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
    migrate(p_patv_rec, l_pat_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9200: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:PATV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('9300: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_patv_tbl.COUNT > 0) THEN
      i := p_patv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_patv_rec                     => p_patv_tbl(i));
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- update_row for:OKC_PRICE_ADJUSTMENTS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pat_rec                      IN pat_rec_type,
    x_pat_rec                      OUT NOCOPY pat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ADJUSTMENTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pat_rec                      pat_rec_type := p_pat_rec;
    l_def_pat_rec                  pat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pat_rec	IN pat_rec_type,
      x_pat_rec	OUT NOCOPY pat_rec_type
    ) RETURN VARCHAR2 IS
      l_pat_rec                      pat_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('9800: Entered populate_new_record', 2);
    END IF;

      x_pat_rec := p_pat_rec;
      -- Get current database values
      l_pat_rec := get_rec(p_pat_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pat_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.id := l_pat_rec.id;
      END IF;
      IF (x_pat_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.pat_id := l_pat_rec.pat_id;
      END IF;
      IF (x_pat_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.chr_id := l_pat_rec.chr_id;
      END IF;
      IF (x_pat_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.cle_id := l_pat_rec.cle_id;
      END IF;
      IF (x_pat_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.bsl_id := l_pat_rec.bsl_id;
      END IF;
      IF (x_pat_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.bcl_id := l_pat_rec.bcl_id;
      END IF;
      IF (x_pat_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.created_by := l_pat_rec.created_by;
      END IF;
      IF (x_pat_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pat_rec.creation_date := l_pat_rec.creation_date;
      END IF;
      IF (x_pat_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.last_updated_by := l_pat_rec.last_updated_by;
      END IF;
      IF (x_pat_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pat_rec.last_update_date := l_pat_rec.last_update_date;
      END IF;
      IF (x_pat_rec.modified_from = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.modified_from := l_pat_rec.modified_from;
      END IF;
      IF (x_pat_rec.modified_to = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.modified_to := l_pat_rec.modified_to;
      END IF;
      IF (x_pat_rec.modifier_mechanism_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.modifier_mechanism_type_code := l_pat_rec.modifier_mechanism_type_code;
      END IF;
      IF (x_pat_rec.operand = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.operand := l_pat_rec.operand;
      END IF;
      IF (x_pat_rec.arithmetic_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.arithmetic_operator := l_pat_rec.arithmetic_operator;
      END IF;
      IF (x_pat_rec.automatic_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.automatic_flag := l_pat_rec.automatic_flag;
      END IF;
      IF (x_pat_rec.update_allowed = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.update_allowed := l_pat_rec.update_allowed;
      END IF;
      IF (x_pat_rec.updated_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.updated_flag := l_pat_rec.updated_flag;
      END IF;
      IF (x_pat_rec.applied_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.applied_flag := l_pat_rec.applied_flag;
      END IF;
      IF (x_pat_rec.on_invoice_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.on_invoice_flag := l_pat_rec.on_invoice_flag;
      END IF;
      IF (x_pat_rec.pricing_phase_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.pricing_phase_id := l_pat_rec.pricing_phase_id;
      END IF;
      IF (x_pat_rec.context = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.context := l_pat_rec.context;
      END IF;
      IF (x_pat_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.program_application_id := l_pat_rec.program_application_id;
      END IF;
      IF (x_pat_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.program_id := l_pat_rec.program_id;
      END IF;
      IF (x_pat_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pat_rec.program_update_date := l_pat_rec.program_update_date;
      END IF;
      IF (x_pat_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.request_id := l_pat_rec.request_id;
      END IF;
      IF (x_pat_rec.list_header_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.list_header_id := l_pat_rec.list_header_id;
      END IF;
      IF (x_pat_rec.list_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.list_line_id := l_pat_rec.list_line_id;
      END IF;
      IF (x_pat_rec.list_line_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.list_line_type_code := l_pat_rec.list_line_type_code;
      END IF;
      IF (x_pat_rec.change_reason_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.change_reason_code := l_pat_rec.change_reason_code;
      END IF;
      IF (x_pat_rec.change_reason_text = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.change_reason_text := l_pat_rec.change_reason_text;
      END IF;
      IF (x_pat_rec.estimated_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.estimated_flag := l_pat_rec.estimated_flag;
      END IF;
      IF (x_pat_rec.adjusted_amount = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.adjusted_amount := l_pat_rec.adjusted_amount;
      END IF;
      IF (x_pat_rec.charge_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.charge_type_code  := l_pat_rec.charge_type_code ;
      END IF;
      IF (x_pat_rec.charge_subtype_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.charge_subtype_code := l_pat_rec.charge_subtype_code;
      END IF;
      IF (x_pat_rec.range_break_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.range_break_quantity := l_pat_rec.range_break_quantity;
      END IF;
      IF (x_pat_rec.accrual_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.accrual_conversion_rate := l_pat_rec.accrual_conversion_rate;
      END IF;
      IF (x_pat_rec.pricing_group_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.pricing_group_sequence := l_pat_rec.pricing_group_sequence;
      END IF;
      IF (x_pat_rec.accrual_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.accrual_flag := l_pat_rec.accrual_flag;
      END IF;
      IF (x_pat_rec.list_line_no = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.list_line_no := l_pat_rec.list_line_no;
      END IF;
      IF (x_pat_rec.source_system_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.source_system_code := l_pat_rec.source_system_code;
      END IF;
      IF (x_pat_rec.benefit_qty = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.benefit_qty := l_pat_rec.benefit_qty;
      END IF;
      IF (x_pat_rec.benefit_uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.benefit_uom_code := l_pat_rec.benefit_uom_code;
      END IF;
      IF (x_pat_rec.expiration_date = OKC_API.G_MISS_DATE)
      THEN
        x_pat_rec.expiration_date := l_pat_rec.expiration_date;
      END IF;
      IF (x_pat_rec.modifier_level_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.modifier_level_code := l_pat_rec.modifier_level_code;
      END IF;
      IF (x_pat_rec.price_break_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.price_break_type_code := l_pat_rec.price_break_type_code;
      END IF;
      IF (x_pat_rec.substitution_attribute = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.substitution_attribute := l_pat_rec.substitution_attribute;
      END IF;
      IF (x_pat_rec.proration_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.proration_type_code := l_pat_rec.proration_type_code;
      END IF;
      IF (x_pat_rec.include_on_returns_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.include_on_returns_flag := l_pat_rec.include_on_returns_flag;
      END IF;
      IF (x_pat_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.object_version_number := l_pat_rec.object_version_number;
      END IF;

      IF (x_pat_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute1 := l_pat_rec.attribute1;
      END IF;
      IF (x_pat_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute2 := l_pat_rec.attribute2;
      END IF;
      IF (x_pat_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute3 := l_pat_rec.attribute3;
      END IF;
      IF (x_pat_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute4 := l_pat_rec.attribute4;
      END IF;
      IF (x_pat_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute5 := l_pat_rec.attribute5;
      END IF;
      IF (x_pat_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute6 := l_pat_rec.attribute6;
      END IF;
      IF (x_pat_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute7 := l_pat_rec.attribute7;
      END IF;
      IF (x_pat_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute8 := l_pat_rec.attribute8;
      END IF;
      IF (x_pat_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute9 := l_pat_rec.attribute9;
      END IF;
      IF (x_pat_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute10 := l_pat_rec.attribute10;
      END IF;
      IF (x_pat_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute11 := l_pat_rec.attribute11;
      END IF;
      IF (x_pat_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute12 := l_pat_rec.attribute12;
      END IF;
      IF (x_pat_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute13 := l_pat_rec.attribute13;
      END IF;
      IF (x_pat_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute14 := l_pat_rec.attribute14;
      END IF;
      IF (x_pat_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.attribute15 := l_pat_rec.attribute15;
      END IF;
      IF (x_pat_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pat_rec.last_update_login := l_pat_rec.last_update_login;
      END IF;
      IF (x_pat_rec.rebate_transaction_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pat_rec.rebate_transaction_type_code  := l_pat_rec.rebate_transaction_type_code;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('9850: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_return_status);

    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJUSTMENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_pat_rec IN  pat_rec_type,
      x_pat_rec OUT NOCOPY pat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pat_rec := p_pat_rec;
    RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('10000: Entered update_row', 2);
    END IF;

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
      p_pat_rec,                         -- IN
      l_pat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pat_rec, l_def_pat_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PRICE_ADJUSTMENTS
    SET --PAT_ID = l_def_pat_rec.pat_id,
        --CHR_ID = l_def_pat_rec.chr_id,
        --CLE_ID = l_def_pat_rec.cle_id,
        BSL_ID = l_def_pat_rec.bsl_id,
        BCL_ID = l_def_pat_rec.bcl_id,
        --CREATED_BY = l_def_pat_rec.created_by,
        --CREATION_DATE = l_def_pat_rec.creation_date,
        LAST_UPDATED_BY = l_def_pat_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pat_rec.last_update_date,
        MODIFIED_FROM = l_def_pat_rec.modified_from,
        MODIFIED_TO = l_def_pat_rec.modified_to,
        MODIFIER_MECHANISM_TYPE_CODE = l_def_pat_rec.modifier_mechanism_type_code,
        OPERAND = l_def_pat_rec.operand,
        ARITHMETIC_OPERATOR = l_def_pat_rec.arithmetic_operator,
        AUTOMATIC_FLAG = l_def_pat_rec.automatic_flag,
        UPDATE_ALLOWED = l_def_pat_rec.update_allowed,
        UPDATED_FLAG = l_def_pat_rec.updated_flag,
        APPLIED_FLAG = l_def_pat_rec.applied_flag,
        ON_INVOICE_FLAG = l_def_pat_rec.on_invoice_flag,
        PRICING_PHASE_ID = l_def_pat_rec.pricing_phase_id,
       CONTEXT = l_def_pat_rec.context,
   REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_pat_rec.request_id),
PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_pat_rec.program_application_id),
PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_pat_rec.program_id),
PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_pat_rec.program_update_date,SYSDATE),

            LIST_HEADER_ID = l_def_pat_rec.list_header_id,
            LIST_LINE_ID = l_def_pat_rec.list_line_id,
            LIST_LINE_TYPE_CODE = l_def_pat_rec.list_line_type_code,
            CHANGE_REASON_CODE = l_def_pat_rec.change_reason_code,
            CHANGE_REASON_TEXT = l_def_pat_rec.change_reason_text,
            ESTIMATED_FLAG = l_def_pat_rec.estimated_flag,
            ADJUSTED_AMOUNT = l_def_pat_rec.adjusted_amount,
           CHARGE_TYPE_CODE = l_def_pat_rec.charge_type_code,
           CHARGE_SUBTYPE_CODE = l_def_pat_rec.charge_subtype_code,
           RANGE_BREAK_QUANTITY = l_def_pat_rec.range_break_quantity,
           ACCRUAL_CONVERSION_RATE = l_def_pat_rec.accrual_conversion_rate,
           PRICING_GROUP_SEQUENCE = l_def_pat_rec.pricing_group_sequence,
           ACCRUAL_FLAG = l_def_pat_rec.accrual_flag,
           LIST_LINE_NO = l_def_pat_rec.list_line_no,
           SOURCE_SYSTEM_CODE = l_def_pat_rec.source_system_code,
           BENEFIT_QTY = l_def_pat_rec.benefit_qty,
           BENEFIT_UOM_CODE = l_def_pat_rec.benefit_uom_code,
           EXPIRATION_DATE =  l_def_pat_rec.expiration_date,
           MODIFIER_LEVEL_CODE = l_def_pat_rec.modifier_level_code,
           PRICE_BREAK_TYPE_CODE = l_def_pat_rec.price_break_type_code,
           SUBSTITUTION_ATTRIBUTE = l_def_pat_rec.substitution_attribute,
           PRORATION_TYPE_CODE = l_def_pat_rec.proration_type_code,
           INCLUDE_ON_RETURNS_FLAG = l_def_pat_rec.include_on_returns_flag,
           OBJECT_VERSION_NUMBER = l_def_pat_rec.object_version_number,
        ATTRIBUTE1 = l_def_pat_rec.attribute1,
        ATTRIBUTE2 = l_def_pat_rec.attribute2,
        ATTRIBUTE3 = l_def_pat_rec.attribute3,
        ATTRIBUTE4 = l_def_pat_rec.attribute4,
        ATTRIBUTE5 = l_def_pat_rec.attribute5,
        ATTRIBUTE6 = l_def_pat_rec.attribute6,
        ATTRIBUTE7 = l_def_pat_rec.attribute7,
        ATTRIBUTE8 = l_def_pat_rec.attribute8,
        ATTRIBUTE9 = l_def_pat_rec.attribute9,
        ATTRIBUTE10 = l_def_pat_rec.attribute10,
        ATTRIBUTE11 = l_def_pat_rec.attribute11,
        ATTRIBUTE12 = l_def_pat_rec.attribute12,
        ATTRIBUTE13 = l_def_pat_rec.attribute13,
        ATTRIBUTE14 = l_def_pat_rec.attribute14,
        ATTRIBUTE15 = l_def_pat_rec.attribute15,
        LAST_UPDATE_LOGIN = l_def_pat_rec.last_update_login,
        REBATE_TRANSACTION_TYPE_CODE = l_def_pat_rec.rebate_transaction_type_code
    WHERE ID = l_def_pat_rec.id;

    x_pat_rec := l_def_pat_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('10100: Exiting update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10200: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- update_row for:OKC_PRICE_ADJUSTMENTS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_patv_rec                     patv_rec_type := p_patv_rec;
    l_def_patv_rec                 patv_rec_type;
    l_pat_rec                      pat_rec_type;
    lx_pat_rec                     pat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_patv_rec	IN patv_rec_type
    ) RETURN patv_rec_type IS
      l_patv_rec	patv_rec_type := p_patv_rec;
    BEGIN

      l_patv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_patv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_patv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_patv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_patv_rec	IN patv_rec_type,
      x_patv_rec	OUT NOCOPY patv_rec_type
    ) RETURN VARCHAR2 IS
      l_patv_rec                     patv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('10600: Entered populate_new_record', 2);
    END IF;

      x_patv_rec := p_patv_rec;
      -- Get current database values
      l_patv_rec := get_rec(p_patv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_patv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.id := l_patv_rec.id;
      END IF;
      IF (x_patv_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.pat_id := l_patv_rec.pat_id;
      END IF;
      IF (x_patv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.chr_id := l_patv_rec.chr_id;
      END IF;
      IF (x_patv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.cle_id := l_patv_rec.cle_id;
      END IF;
      IF (x_patv_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.bsl_id := l_patv_rec.bsl_id;
      END IF;
      IF (x_patv_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.bcl_id := l_patv_rec.bcl_id;
      END IF;
      IF (x_patv_rec.modified_from = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.modified_from := l_patv_rec.modified_from;
      END IF;
      IF (x_patv_rec.modified_to = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.modified_to := l_patv_rec.modified_to;
      END IF;
      IF (x_patv_rec.modifier_mechanism_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.modifier_mechanism_type_code := l_patv_rec.modifier_mechanism_type_code;
      END IF;
      IF (x_patv_rec.operand = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.operand := l_patv_rec.operand;
      END IF;
      IF (x_patv_rec.arithmetic_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.arithmetic_operator := l_patv_rec.arithmetic_operator;
      END IF;
      IF (x_patv_rec.automatic_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.automatic_flag := l_patv_rec.automatic_flag;
      END IF;
      IF (x_patv_rec.update_allowed = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.update_allowed := l_patv_rec.update_allowed;
      END IF;
      IF (x_patv_rec.updated_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.updated_flag := l_patv_rec.updated_flag;
      END IF;
      IF (x_patv_rec.applied_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.applied_flag := l_patv_rec.applied_flag;
      END IF;
      IF (x_patv_rec.on_invoice_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.on_invoice_flag := l_patv_rec.on_invoice_flag;
      END IF;
      IF (x_patv_rec.pricing_phase_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.pricing_phase_id := l_patv_rec.pricing_phase_id;
      END IF;
      IF (x_patv_rec.context = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.context := l_patv_rec.context;
      END IF;

      IF (x_patv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.program_application_id := l_patv_rec.program_application_id;
      END IF;
      IF (x_patv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.program_id := l_patv_rec.program_id;
      END IF;
      IF (x_patv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_patv_rec.program_update_date := l_patv_rec.program_update_date;
      END IF;
      IF (x_patv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.request_id := l_patv_rec.request_id;
      END IF;
      IF (x_patv_rec.list_header_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.list_header_id := l_patv_rec.list_header_id;
      END IF;
      IF (x_patv_rec.list_line_id = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.list_line_id := l_patv_rec.list_line_id;
      END IF;
      IF (x_patv_rec.list_line_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.list_line_type_code := l_patv_rec.list_line_type_code;
      END IF;
      IF (x_patv_rec.change_reason_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.change_reason_code := l_patv_rec.change_reason_code;
      END IF;
      IF (x_patv_rec.change_reason_text = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.change_reason_text := l_patv_rec.change_reason_text;
      END IF;
      IF (x_patv_rec.estimated_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.estimated_flag := l_patv_rec.estimated_flag;
      END IF;
      IF (x_patv_rec.adjusted_amount = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.adjusted_amount := l_patv_rec.adjusted_amount;
      END IF;
      IF (x_patv_rec.charge_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.charge_type_code  := l_patv_rec.charge_type_code ;
      END IF;
      IF (x_patv_rec.charge_subtype_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.charge_subtype_code := l_patv_rec.charge_subtype_code;
      END IF;
      IF (x_patv_rec.range_break_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.range_break_quantity := l_patv_rec.range_break_quantity;
      END IF;
      IF (x_patv_rec.accrual_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.accrual_conversion_rate := l_patv_rec.accrual_conversion_rate;
      END IF;
      IF (x_patv_rec.pricing_group_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.pricing_group_sequence := l_patv_rec.pricing_group_sequence;
      END IF;
      IF (x_patv_rec.accrual_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.accrual_flag := l_patv_rec.accrual_flag;
      END IF;
      IF (x_patv_rec.list_line_no = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.list_line_no := l_patv_rec.list_line_no;
      END IF;
      IF (x_patv_rec.source_system_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.source_system_code := l_patv_rec.source_system_code;
      END IF;
      IF (x_patv_rec.benefit_qty = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.benefit_qty := l_patv_rec.benefit_qty;
      END IF;
      IF (x_patv_rec.benefit_uom_code = OKC_API.G_MISS_CHAR)
      THEN
       x_patv_rec.benefit_uom_code := l_patv_rec.benefit_uom_code;
      END IF;

      IF (x_patv_rec.expiration_date = OKC_API.G_MISS_DATE)
      THEN
        x_patv_rec.expiration_date := l_patv_rec.expiration_date;
      END IF;
      IF (x_patv_rec.modifier_level_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.modifier_level_code := l_patv_rec.modifier_level_code;
      END IF;
      IF (x_patv_rec.price_break_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.price_break_type_code := l_patv_rec.price_break_type_code;
      END IF;
      IF (x_patv_rec.substitution_attribute = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.substitution_attribute := l_patv_rec.substitution_attribute;
      END IF;
      IF (x_patv_rec.proration_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.proration_type_code := l_patv_rec.proration_type_code;
      END IF;
      IF (x_patv_rec.include_on_returns_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.include_on_returns_flag := l_patv_rec.include_on_returns_flag;
      END IF;
      IF (x_patv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.object_version_number := l_patv_rec.object_version_number;
      END IF;

      IF (x_patv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute1 := l_patv_rec.attribute1;
      END IF;
      IF (x_patv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute2 := l_patv_rec.attribute2;
      END IF;
      IF (x_patv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute3 := l_patv_rec.attribute3;
      END IF;
      IF (x_patv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute4 := l_patv_rec.attribute4;
      END IF;
      IF (x_patv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute5 := l_patv_rec.attribute5;
      END IF;
      IF (x_patv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute6 := l_patv_rec.attribute6;
      END IF;
      IF (x_patv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute7 := l_patv_rec.attribute7;
      END IF;
      IF (x_patv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute8 := l_patv_rec.attribute8;
      END IF;
      IF (x_patv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute9 := l_patv_rec.attribute9;
      END IF;
      IF (x_patv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute10 := l_patv_rec.attribute10;
      END IF;
      IF (x_patv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute11 := l_patv_rec.attribute11;
      END IF;
      IF (x_patv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute12 := l_patv_rec.attribute12;
      END IF;
      IF (x_patv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute13 := l_patv_rec.attribute13;
      END IF;
      IF (x_patv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute14 := l_patv_rec.attribute14;
      END IF;
      IF (x_patv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.attribute15 := l_patv_rec.attribute15;
      END IF;
      IF (x_patv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.created_by := l_patv_rec.created_by;
      END IF;
      IF (x_patv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_patv_rec.creation_date := l_patv_rec.creation_date;
      END IF;
      IF (x_patv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.last_updated_by := l_patv_rec.last_updated_by;
      END IF;
      IF (x_patv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_patv_rec.last_update_date := l_patv_rec.last_update_date;
      END IF;
      IF (x_patv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_patv_rec.last_update_login := l_patv_rec.last_update_login;
      END IF;
      IF (x_patv_rec.rebate_transaction_type_code = OKC_API.G_MISS_CHAR)
      THEN
        x_patv_rec.rebate_transaction_type_code := l_patv_rec.rebate_transaction_type_code;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('10650: Exiting update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJUSTMENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_patv_rec IN  patv_rec_type,
      x_patv_rec OUT NOCOPY patv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_patv_rec := p_patv_rec;
      x_patv_rec.OBJECT_VERSION_NUMBER := NVL(x_patv_rec.OBJECT_VERSION_NUMBER,0)+1;
    RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('10800: Entered update_row', 2);
    END IF;

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
      p_patv_rec,                        -- IN
      l_patv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_patv_rec, l_def_patv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_patv_rec := fill_who_columns(l_def_patv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_patv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_patv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_patv_rec, l_pat_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pat_rec,
      lx_pat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pat_rec, l_def_patv_rec);
    x_patv_rec := l_def_patv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:PATV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('11300: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_patv_tbl.COUNT > 0) THEN
      i := p_patv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_patv_rec                     => p_patv_tbl(i),
          x_patv_rec                     => x_patv_tbl(i));
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('11400: Exiting update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- delete_row for:OKC_PRICE_ADJUSTMENTS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pat_rec                      IN pat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ADJUSTMENTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pat_rec                      pat_rec_type:= p_pat_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('11800: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_PRICE_ADJUSTMENTS
     WHERE ID = l_pat_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('11900: Exiting delete_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- delete_row for:OKC_PRICE_ADJUSTMENTS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_patv_rec                     patv_rec_type := p_patv_rec;
    l_pat_rec                      pat_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('12300: Entered delete_row', 2);
    END IF;

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
    migrate(l_patv_rec, l_pat_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12500: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12700: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:PATV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('12800: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_patv_tbl.COUNT > 0) THEN
      i := p_patv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_patv_rec                     => p_patv_tbl(i));
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12900: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('13200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_PRICE_ADJUSTMENTS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_patv_tbl patv_tbl_type) IS
  l_tabsize NUMBER := p_patv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_pat_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_bsl_id                        OKC_DATATYPES.NumberTabTyp;
  in_bcl_id                        OKC_DATATYPES.NumberTabTyp;
  in_modified_from                 OKC_DATATYPES.NumberTabTyp;
  in_modified_to                   OKC_DATATYPES.NumberTabTyp;
  in_mod_mech_type_code  OKC_DATATYPES.Var90TabTyp;
  in_operand                       OKC_DATATYPES.NumberTabTyp;
  in_arithmetic_operator           OKC_DATATYPES.Var90TabTyp;
  in_automatic_flag                OKC_DATATYPES.Var3TabTyp;
  in_update_allowed                OKC_DATATYPES.Var3TabTyp;
  in_updated_flag                  OKC_DATATYPES.Var3TabTyp;
  in_applied_flag                  OKC_DATATYPES.Var3TabTyp;
  in_on_invoice_flag               OKC_DATATYPES.Var3TabTyp;
  in_pricing_phase_id              OKC_DATATYPES.NumberTabTyp;
  in_context                       OKC_DATATYPES.Var90TabTyp;
  in_program_application_id        OKC_DATATYPES.NumberTabTyp;
  in_program_id                    OKC_DATATYPES.NumberTabTyp;
  in_program_update_date          OKC_DATATYPES.DateTabTyp;
  in_request_id                   OKC_DATATYPES.NumberTabTyp;
  in_list_header_id                OKC_DATATYPES.NumberTabTyp;
 in_list_line_id                  OKC_DATATYPES.NumberTabTyp;
in_list_line_type_code            OKC_DATATYPES.Var90TabTyp;
in_change_reason_code             OKC_DATATYPES.Var90TabTyp;
in_change_reason_text              OKC_DATATYPES.Var1995TabTyp;
in_estimated_flag                 OKC_DATATYPES.Var3TabTyp;
in_adjusted_amount                OKC_DATATYPES.NumberTabTyp;
in_charge_type_code               OKC_DATATYPES.Var90TabTyp;
in_charge_subtype_code            OKC_DATATYPES.Var90TabTyp;
in_range_break_quantity           OKC_DATATYPES.NumberTabTyp;
in_accrual_conversion_rate        OKC_DATATYPES.NumberTabTyp;
in_pricing_group_sequence          OKC_DATATYPES.NumberTabTyp;
in_accrual_flag                  OKC_DATATYPES.Var3TabTyp;
in_list_line_no                  OKC_DATATYPES.Var240TabTyp;
in_source_system_code             OKC_DATATYPES.Var90TabTyp;
in_benefit_qty                    OKC_DATATYPES.NumberTabTyp;
in_benefit_uom_code               OKC_DATATYPES.Var3TabTyp;
in_expiration_date                OKC_DATATYPES.DateTabTyp;
in_modifier_level_code            OKC_DATATYPES.Var90TabTyp;
in_price_break_type_code          OKC_DATATYPES.Var90TabTyp;
in_substitution_attribute          OKC_DATATYPES.Var90TabTyp;
in_proration_type_code            OKC_DATATYPES.Var90TabTyp;
in_include_on_returns_flag        OKC_DATATYPES.Var3TabTyp;
in_object_version_number           OKC_DATATYPES.NumberTabTyp;
 in_attribute1                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute2                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute3                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute4                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute5                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute6                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute7                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute8                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute9                    OKC_DATATYPES.Var1995TabTyp;
  in_attribute10                   OKC_DATATYPES.Var1995TabTyp;
  in_attribute11                   OKC_DATATYPES.Var1995TabTyp;
  in_attribute12                   OKC_DATATYPES.Var1995TabTyp;
  in_attribute13                   OKC_DATATYPES.Var1995TabTyp;
  in_attribute14                   OKC_DATATYPES.Var1995TabTyp;
  in_attribute15                   OKC_DATATYPES.Var1995TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  in_rebate_transaction_type_cod   OKC_DATATYPES.Var30TabTyp;
  i number;
  j number;
BEGIN

   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('13300: Entered INSERT_ROW_UPG', 2);
    END IF;

  i := p_patv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_patv_tbl(i).id;
    in_pat_id                   (j) := p_patv_tbl(i).pat_id;
    in_chr_id                   (j) := p_patv_tbl(i).chr_id;
    in_cle_id                   (j) := p_patv_tbl(i).cle_id;
    in_bsl_id                   (j) := p_patv_tbl(i).bsl_id;
    in_bcl_id                   (j) := p_patv_tbl(i).bcl_id;
    in_modified_from            (j) := p_patv_tbl(i).modified_from;
    in_modified_to              (j) := p_patv_tbl(i).modified_to;
    in_mod_mech_type_code(j) := p_patv_tbl(i).modifier_mechanism_type_code;
    in_operand                  (j) := p_patv_tbl(i).operand;
    in_arithmetic_operator      (j) := p_patv_tbl(i).arithmetic_operator;
    in_automatic_flag           (j) := p_patv_tbl(i).automatic_flag;
    in_update_allowed           (j) := p_patv_tbl(i).update_allowed;
    in_updated_flag             (j) := p_patv_tbl(i).updated_flag;
    in_applied_flag             (j) := p_patv_tbl(i).applied_flag;
    in_on_invoice_flag          (j) := p_patv_tbl(i).on_invoice_flag;
    in_pricing_phase_id         (j) := p_patv_tbl(i).pricing_phase_id;
    in_context                  (j) := p_patv_tbl(i).context;
    in_program_application_id     (j) := p_patv_tbl(i).program_application_id;
  in_program_id                  (j) := p_patv_tbl(i).program_id;
  in_program_update_date        (j) := p_patv_tbl(i).program_update_date;
  in_request_id             (j) := p_patv_tbl(i).request_id;
in_list_header_id              (j) := p_patv_tbl(i).list_header_id;
 in_list_line_id               (j) := p_patv_tbl(i).list_line_id;
in_list_line_type_code          (j) := p_patv_tbl(i).list_line_type_code;
in_change_reason_code         (j) := p_patv_tbl(i).change_reason_code;
in_change_reason_text         (j) := p_patv_tbl(i).change_reason_text;
in_estimated_flag              (j) := p_patv_tbl(i).estimated_flag;
in_adjusted_amount              (j) := p_patv_tbl(i).adjusted_amount;
in_charge_type_code             (j) := p_patv_tbl(i).charge_type_code;
in_charge_subtype_code           (j) := p_patv_tbl(i).charge_subtype_code;
in_range_break_quantity          (j) := p_patv_tbl(i).range_break_quantity;
in_accrual_conversion_rate     (j) := p_patv_tbl(i).accrual_conversion_rate;
in_pricing_group_sequence        (j) := p_patv_tbl(i).pricing_group_sequence;
in_accrual_flag                (j) := p_patv_tbl(i).accrual_flag;
in_list_line_no              (j) := p_patv_tbl(i).list_line_no;
in_source_system_code          (j) := p_patv_tbl(i).source_system_code;
in_benefit_qty                  (j) := p_patv_tbl(i).benefit_qty;
in_benefit_uom_code            (j) := p_patv_tbl(i).benefit_uom_code;
in_expiration_date              (j) := p_patv_tbl(i).expiration_date;
in_modifier_level_code       (j) := p_patv_tbl(i).modifier_level_code;
in_price_break_type_code       (j) := p_patv_tbl(i).price_break_type_code;
in_substitution_attribute      (j) := p_patv_tbl(i).substitution_attribute;
in_proration_type_code         (j) := p_patv_tbl(i).proration_type_code;
in_include_on_returns_flag     (j) := p_patv_tbl(i).include_on_returns_flag;
in_object_version_number        (j) := p_patv_tbl(i).object_version_number;
    in_attribute1               (j) := p_patv_tbl(i).attribute1;
    in_attribute2               (j) := p_patv_tbl(i).attribute2;
    in_attribute3               (j) := p_patv_tbl(i).attribute3;
    in_attribute4               (j) := p_patv_tbl(i).attribute4;
    in_attribute5               (j) := p_patv_tbl(i).attribute5;
    in_attribute6               (j) := p_patv_tbl(i).attribute6;
    in_attribute7               (j) := p_patv_tbl(i).attribute7;
    in_attribute8               (j) := p_patv_tbl(i).attribute8;
    in_attribute9               (j) := p_patv_tbl(i).attribute9;
    in_attribute10              (j) := p_patv_tbl(i).attribute10;
    in_attribute11              (j) := p_patv_tbl(i).attribute11;
    in_attribute12              (j) := p_patv_tbl(i).attribute12;
    in_attribute13              (j) := p_patv_tbl(i).attribute13;
    in_attribute14              (j) := p_patv_tbl(i).attribute14;
    in_attribute15              (j) := p_patv_tbl(i).attribute15;
    in_created_by               (j) := p_patv_tbl(i).created_by;
    in_creation_date            (j) := p_patv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_patv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_patv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_patv_tbl(i).last_update_login;
    in_rebate_transaction_type_cod (j):= p_patv_tbl(i).rebate_transaction_type_code;
    i:=p_patv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_PRICE_ADJUSTMENTS
      (
        id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
      adjusted_amount,
      charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
        rebate_transaction_type_code
     )
     VALUES (
        in_id(i),
        in_pat_id(i),
        in_chr_id(i),
        in_cle_id(i),
        in_bsl_id(i),
        in_bcl_id(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_modified_from(i),
        in_modified_to(i),
        in_mod_mech_type_code(i),
        in_operand(i),
        in_arithmetic_operator(i),
        in_automatic_flag(i),
        in_update_allowed(i),
        in_updated_flag(i),
        in_applied_flag(i),
        in_on_invoice_flag(i),
        in_pricing_phase_id(i),
        in_context(i),

       in_program_application_id(i),
     in_program_id(i),
     in_program_update_date(i),
      in_request_id(i),
     in_list_header_id(i),
      in_list_line_id(i),
      in_list_line_type_code(i),
      in_change_reason_code(i),
      in_change_reason_text(i),
      in_estimated_flag(i),
      in_adjusted_amount(i),
      in_charge_type_code(i),
      in_charge_subtype_code(i),
      in_range_break_quantity(i),
      in_accrual_conversion_rate(i),
      in_pricing_group_sequence(i),
      in_accrual_flag(i),
      in_list_line_no(i),
      in_source_system_code(i),
      in_benefit_qty(i),
      in_benefit_uom_code(i),
      in_expiration_date(i),
      in_modifier_level_code(i),
      in_price_break_type_code(i),
      in_substitution_attribute(i),
      in_proration_type_code(i),
      in_include_on_returns_flag(i),
      in_object_version_number(i),

        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i),
        in_last_update_login(i),
        in_rebate_transaction_type_cod(i));

    IF (l_debug = 'Y') THEN
       okc_debug.log('13400: Exiting INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
     --Store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

--    okc_debug.log('13500: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
--    okc_debug.Reset_Indentation;

 --   RAISE;

END INSERT_ROW_UPG;

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('13600: Entered create_version', 2);
    END IF;

INSERT INTO okc_price_adjustments_h
  (
      id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
        adjusted_amount,
      charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
        rebate_transaction_type_code,
        major_version
       )
      SELECT

          id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
        adjusted_amount,
      charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
       rebate_transaction_type_code,
       p_major_version

      FROM okc_price_adjustments
WHERE chr_id = p_chr_id;

    IF (l_debug = 'Y') THEN
       okc_debug.log('13700: Exiting create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13800: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END create_version;

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAT_PVT');
       okc_debug.log('13900: Entered restore_version', 2);
    END IF;

INSERT INTO okc_price_adjustments
   (
      id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
      adjusted_amount,
      charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
        rebate_transaction_type_code)

       SELECT

          id,
        pat_id,
        chr_id,
        cle_id,
        bsl_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        modified_from,
        modified_to,
        modifier_mechanism_type_code,
        operand,
        arithmetic_operator,
        automatic_flag,
        update_allowed,
        updated_flag,
        applied_flag,
        on_invoice_flag,
        pricing_phase_id,
        context,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      list_header_id,
      list_line_id,
      list_line_type_code,
      change_reason_code,
      change_reason_text,
      estimated_flag,
        adjusted_amount,
        charge_type_code,
      charge_subtype_code,
      range_break_quantity,
      accrual_conversion_rate,
      pricing_group_sequence,
      accrual_flag,
      list_line_no,
      source_system_code,
      benefit_qty,
      benefit_uom_code,
      expiration_date,
      modifier_level_code,
      price_break_type_code,
      substitution_attribute,
      proration_type_code,
      include_on_returns_flag,
      object_version_number,
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
        rebate_transaction_type_code

FROM okc_price_adjustments_h
WHERE chr_id = p_chr_id
   AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('14000: Exiting restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('14100: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;

 END OKC_PAT_PVT;

/
