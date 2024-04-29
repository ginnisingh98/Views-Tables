--------------------------------------------------------
--  DDL for Package Body OKL_TCN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TCN_PVT" AS
/* $Header: OKLSTCNB.pls 120.17.12010000.7 2009/10/13 21:24:26 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  l_seq NUMBER;
  BEGIN
-- Changed by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    SELECT OKL_TRX_CONTRACTS_ALL_S.NEXTVAL INTO l_seq FROM DUAL;
    RETURN l_seq;
  END get_seq_id;

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
  -- FUNCTION get_rec for: OKL_TRX_CONTRACTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tcn_rec                      IN tcn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tcn_rec_type IS
    CURSOR okl_trx_contracts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            KHR_ID_NEW,
            PVN_ID,
            PDT_ID,
            RBR_CODE,
            RPY_CODE,
            RVN_CODE,
            TRN_CODE,
            QTE_ID,
            AES_ID,
            CODE_COMBINATION_ID,
            TCN_TYPE,
            RJN_CODE,
            PARTY_REL_ID1_OLD,
            PARTY_REL_ID2_OLD,
            PARTY_REL_ID1_NEW,
            PARTY_REL_ID2_NEW,
            COMPLETE_TRANSFER_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            DATE_ACCRUAL,
            ACCRUAL_STATUS_YN,
            UPDATE_STATUS_YN,
            ORG_ID,
            KHR_ID,
            TAX_DEDUCTIBLE_LOCAL,
            tax_deductible_corporate,
            AMOUNT,
            REQUEST_ID,
            CURRENCY_CODE,
            PROGRAM_APPLICATION_ID,
            KHR_ID_OLD,
            PROGRAM_ID,
            PROGRAM_update_DATE,
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
	    TRY_ID,
	    TSU_CODE,
	    SET_OF_BOOKS_ID,
	    DESCRIPTION,
	    DATE_TRANSACTION_OCCURRED,
            TRX_NUMBER,
            TMT_EVERGREEN_YN,
            TMT_CLOSE_BALANCES_YN,
            TMT_ACCOUNTING_ENTRIES_YN,
            TMT_CANCEL_INSURANCE_YN,
            TMT_ASSET_DISPOSITION_YN,
            TMT_AMORTIZATION_YN,
            TMT_ASSET_RETURN_YN,
            TMT_CONTRACT_UPDATED_YN,
            TMT_RECYCLE_YN,
            TMT_VALIDATED_YN,
            TMT_STREAMS_UPDATED_YN ,
            ACCRUAL_ACTIVITY,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
            TMT_SPLIT_ASSET_YN,
	    TMT_GENERIC_FLAG1_YN,
	    TMT_GENERIC_FLAG2_YN,
	    TMT_GENERIC_FLAG3_YN,
-- Added by HKPATEL 14-NOV-2002. Multi-Currency Changes
   	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE,
-- Added by Keerthi for Service Contracts
            CHR_ID ,
-- Added by Keerthi for Bug No 3195713
         SOURCE_TRX_ID,
         SOURCE_TRX_TYPE,
-- Added by kmotepal for bug 3621485
         CANCELED_DATE,
        --Added by dpsingh for LE Uptake
         LEGAL_ENTITY_ID,
      --Added by dpsingh for SLA Uptake (Bug 5707866)
         ACCRUAL_REVERSAL_DATE,
     -- Added by DJANASWA for SLA project
         ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
         PRODUCT_NAME,
	 BOOK_CLASSIFICATION_CODE,
	 TAX_OWNER_CODE,
	 TMT_STATUS_CODE,
         REPRESENTATION_NAME,
         REPRESENTATION_CODE,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
         UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
	 TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
         primary_rep_trx_id,
         REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon-report 01-Nov-2008
         TRANSACTION_REVERSAL_DATE
      FROM OKL_TRX_CONTRACTS
      WHERE OKL_TRX_CONTRACTS.id = p_id;
    l_okl_trx_contracts_pk         okl_trx_contracts_pk_csr%ROWTYPE;
    l_tcn_rec                      tcn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_contracts_pk_csr (p_tcn_rec.id);
    FETCH okl_trx_contracts_pk_csr INTO
              l_tcn_rec.ID,
              l_tcn_rec.KHR_ID_NEW,
              l_tcn_rec.PVN_ID,
              l_tcn_rec.PDT_ID,
              l_tcn_rec.RBR_CODE,
              l_tcn_rec.RPY_CODE,
              l_tcn_rec.RVN_CODE,
              l_tcn_rec.TRN_CODE,
              l_tcn_rec.QTE_ID,
              l_tcn_rec.AES_ID,
              l_tcn_rec.CODE_COMBINATION_ID,
              l_tcn_rec.TCN_TYPE,
              l_tcn_rec.RJN_CODE,
              l_tcn_rec.PARTY_REL_ID1_OLD,
              l_tcn_rec.PARTY_REL_ID2_OLD,
              l_tcn_rec.PARTY_REL_ID1_NEW,
              l_tcn_rec.PARTY_REL_ID2_NEW,
              l_tcn_rec.COMPLETE_TRANSFER_YN,
              l_tcn_rec.OBJECT_VERSION_NUMBER,
              l_tcn_rec.CREATED_BY,
              l_tcn_rec.CREATION_DATE,
              l_tcn_rec.LAST_UPDATED_BY,
              l_tcn_rec.LAST_UPDATE_DATE,
              l_tcn_rec.DATE_ACCRUAL,
              l_tcn_rec.ACCRUAL_STATUS_YN,
              l_tcn_rec.UPDATE_STATUS_YN,
              l_tcn_rec.ORG_ID,
              l_tcn_rec.KHR_ID,
              l_tcn_rec.TAX_DEDUCTIBLE_LOCAL,
              l_tcn_rec.tax_deductible_corporate,
              l_tcn_rec.AMOUNT,
              l_tcn_rec.REQUEST_ID,
              l_tcn_rec.currency_code,
              l_tcn_rec.PROGRAM_APPLICATION_ID,
              l_tcn_rec.KHR_ID_OLD,
              l_tcn_rec.PROGRAM_ID,
              l_tcn_rec.PROGRAM_update_DATE,
              l_tcn_rec.ATTRIBUTE_CATEGORY,
              l_tcn_rec.ATTRIBUTE1,
              l_tcn_rec.ATTRIBUTE2,
              l_tcn_rec.ATTRIBUTE3,
              l_tcn_rec.ATTRIBUTE4,
              l_tcn_rec.ATTRIBUTE5,
              l_tcn_rec.ATTRIBUTE6,
              l_tcn_rec.ATTRIBUTE7,
              l_tcn_rec.ATTRIBUTE8,
              l_tcn_rec.ATTRIBUTE9,
              l_tcn_rec.ATTRIBUTE10,
              l_tcn_rec.ATTRIBUTE11,
              l_tcn_rec.ATTRIBUTE12,
              l_tcn_rec.ATTRIBUTE13,
              l_tcn_rec.ATTRIBUTE14,
              l_tcn_rec.ATTRIBUTE15,
              l_tcn_rec.LAST_UPDATE_LOGIN,
	      l_tcn_rec.TRY_ID,
	      l_tcn_rec.TSU_CODE,
              l_tcn_rec.SET_OF_BOOKS_ID,
	      l_tcn_rec.DESCRIPTION,
	      l_tcn_rec.DATE_TRANSACTION_OCCURRED,
              l_tcn_rec.TRX_NUMBER ,
              l_tcn_rec.TMT_EVERGREEN_YN ,
              l_tcn_rec.TMT_CLOSE_BALANCES_YN ,
              l_tcn_rec.TMT_ACCOUNTING_ENTRIES_YN ,
              l_tcn_rec.TMT_CANCEL_INSURANCE_YN ,
              l_tcn_rec.TMT_ASSET_DISPOSITION_YN ,
              l_tcn_rec.TMT_AMORTIZATION_YN ,
              l_tcn_rec.TMT_ASSET_RETURN_YN ,
              l_tcn_rec.TMT_CONTRACT_UPDATED_YN ,
              l_tcn_rec.TMT_RECYCLE_YN ,
              l_tcn_rec.TMT_VALIDATED_YN ,
              l_tcn_rec.TMT_STREAMS_UPDATED_YN,
              l_tcn_rec.ACCRUAL_ACTIVITY,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
              l_tcn_rec.TMT_SPLIT_ASSET_YN,
	      l_tcn_rec.TMT_GENERIC_FLAG1_YN,
	      l_tcn_rec.TMT_GENERIC_FLAG2_YN,
	      l_tcn_rec.TMT_GENERIC_FLAG3_YN ,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	      l_tcn_rec.CURRENCY_CONVERSION_TYPE,
	      l_tcn_rec.CURRENCY_CONVERSION_RATE,
	      l_tcn_rec.CURRENCY_CONVERSION_DATE,
-- Added by Keerthi 04-SEP-2003.
	      l_tcn_rec.CHR_ID,
-- Added by Keerthi for Bug No 3195713
          l_tcn_rec.SOURCE_TRX_ID,
          l_tcn_rec.SOURCE_TRX_TYPE,
-- Added by kmotepal for Bug No 3621485
          l_tcn_rec.CANCELED_DATE,
          ---- Added by dpsingh for LE Uptake
	  l_tcn_rec.LEGAL_ENTITY_ID,
	  --Added by dpsingh for SLA Uptake (Bug 5707866)
          l_tcn_rec.ACCRUAL_REVERSAL_DATE,
          -- Added by DJANASWA for SLA project
          l_tcn_rec.ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
         l_tcn_rec.PRODUCT_NAME,
         l_tcn_rec.BOOK_CLASSIFICATION_CODE,
	 l_tcn_rec.TAX_OWNER_CODE,
	 l_tcn_rec.TMT_STATUS_CODE,
         l_tcn_rec.REPRESENTATION_NAME,
         l_tcn_rec.REPRESENTATION_CODE,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
         l_tcn_rec.UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
	 l_tcn_rec.TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
         l_tcn_rec.primary_rep_trx_id,
         l_tcn_rec.REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
         l_tcn_rec.TRANSACTION_REVERSAL_DATE;

    x_no_data_found := okl_trx_contracts_pk_csr%NOTFOUND;
    CLOSE okl_trx_contracts_pk_csr;
    RETURN(l_tcn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tcn_rec                      IN tcn_rec_type
  ) RETURN tcn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tcn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_CONTRACTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tcnv_rec                     IN tcnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tcnv_rec_type IS
    CURSOR okl_tcnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            RBR_CODE,
            RPY_CODE,
            RVN_CODE,
            TRN_CODE,
            KHR_ID_NEW,
            PVN_ID,
            PDT_ID,
            QTE_ID,
            AES_ID,
            CODE_COMBINATION_ID,
            TAX_DEDUCTIBLE_LOCAL,
            tax_deductible_corporate,
            DATE_ACCRUAL,
            ACCRUAL_STATUS_YN,
            UPDATE_STATUS_YN,
            AMOUNT,
            CURRENCY_CODE,
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
            TCN_TYPE,
            RJN_CODE,
            PARTY_REL_ID1_OLD,
            PARTY_REL_ID2_OLD,
            PARTY_REL_ID1_NEW,
            PARTY_REL_ID2_NEW,
            COMPLETE_TRANSFER_YN,
            ORG_ID,
            KHR_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            KHR_ID_OLD,
            PROGRAM_ID,
            PROGRAM_update_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
	    TRY_ID,
	    TSU_CODE,
	    SET_OF_BOOKS_ID,
	    DESCRIPTION,
	    DATE_TRANSACTION_OCCURRED,
            TRX_NUMBER,
            TMT_EVERGREEN_YN,
            TMT_CLOSE_BALANCES_YN,
            TMT_ACCOUNTING_ENTRIES_YN,
            TMT_CANCEL_INSURANCE_YN,
            TMT_ASSET_DISPOSITION_YN,
            TMT_AMORTIZATION_YN,
            TMT_ASSET_RETURN_YN,
            TMT_CONTRACT_UPDATED_YN,
            TMT_RECYCLE_YN,
            TMT_VALIDATED_YN,
            TMT_STREAMS_UPDATED_YN ,
            accrual_activity,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
	    TMT_SPLIT_ASSET_YN,
	    TMT_GENERIC_FLAG1_YN,
	    TMT_GENERIC_FLAG2_YN,
	    TMT_GENERIC_FLAG3_YN,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	    CURRENCY_CONVERSION_TYPE,
	    CURRENCY_CONVERSION_RATE,
	    CURRENCY_CONVERSION_DATE,
-- Added by Keerthi 04-SEP-2003 Sevice Contracts
	    CHR_ID ,
-- Added by Keerthi for Bug No 3195713
        SOURCE_TRX_ID,
        SOURCE_TRX_TYPE,
-- Added by kmotepal for Bug 3621485
        CANCELED_DATE,
        --Added by dpsingh for LE Uptake
        LEGAL_ENTITY_ID,
	--Added by dpsingh for SLA Uptake (Bug 5707866)
        ACCRUAL_REVERSAL_DATE,
        -- Added by DJANASWA for SLA project
        ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
         PRODUCT_NAME,
	 BOOK_CLASSIFICATION_CODE,
	 TAX_OWNER_CODE,
	 TMT_STATUS_CODE,
         REPRESENTATION_NAME,
         REPRESENTATION_CODE,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
         UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
	 TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
         primary_rep_trx_id,
         REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
        TRANSACTION_REVERSAL_DATE
      FROM OKL_TRX_CONTRACTS
     WHERE OKL_TRX_CONTRACTS.id = p_id;
    l_okl_tcnv_pk                  okl_tcnv_pk_csr%ROWTYPE;
    l_tcnv_rec                     tcnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tcnv_pk_csr (p_tcnv_rec.id);
    FETCH okl_tcnv_pk_csr INTO
              l_tcnv_rec.ID,
              l_tcnv_rec.OBJECT_VERSION_NUMBER,
              l_tcnv_rec.RBR_CODE,
              l_tcnv_rec.RPY_CODE,
              l_tcnv_rec.RVN_CODE,
              l_tcnv_rec.TRN_CODE,
              l_tcnv_rec.KHR_ID_NEW,
              l_tcnv_rec.PVN_ID,
              l_tcnv_rec.PDT_ID,
              l_tcnv_rec.QTE_ID,
              l_tcnv_rec.AES_ID,
              l_tcnv_rec.CODE_COMBINATION_ID,
              l_tcnv_rec.TAX_DEDUCTIBLE_LOCAL,
              l_tcnv_rec.tax_deductible_corporate,
              l_tcnv_rec.DATE_ACCRUAL,
              l_tcnv_rec.ACCRUAL_STATUS_YN,
              l_tcnv_rec.UPDATE_STATUS_YN,
              l_tcnv_rec.AMOUNT,
              l_tcnv_rec.currency_code,
              l_tcnv_rec.ATTRIBUTE_CATEGORY,
              l_tcnv_rec.ATTRIBUTE1,
              l_tcnv_rec.ATTRIBUTE2,
              l_tcnv_rec.ATTRIBUTE3,
              l_tcnv_rec.ATTRIBUTE4,
              l_tcnv_rec.ATTRIBUTE5,
              l_tcnv_rec.ATTRIBUTE6,
              l_tcnv_rec.ATTRIBUTE7,
              l_tcnv_rec.ATTRIBUTE8,
              l_tcnv_rec.ATTRIBUTE9,
              l_tcnv_rec.ATTRIBUTE10,
              l_tcnv_rec.ATTRIBUTE11,
              l_tcnv_rec.ATTRIBUTE12,
              l_tcnv_rec.ATTRIBUTE13,
              l_tcnv_rec.ATTRIBUTE14,
              l_tcnv_rec.ATTRIBUTE15,
              l_tcnv_rec.TCN_TYPE,
              l_tcnv_rec.RJN_CODE,
              l_tcnv_rec.PARTY_REL_ID1_OLD,
              l_tcnv_rec.PARTY_REL_ID2_OLD,
              l_tcnv_rec.PARTY_REL_ID1_NEW,
              l_tcnv_rec.PARTY_REL_ID2_NEW,
              l_tcnv_rec.COMPLETE_TRANSFER_YN,
              l_tcnv_rec.ORG_ID,
              l_tcnv_rec.KHR_ID,
              l_tcnv_rec.REQUEST_ID,
              l_tcnv_rec.PROGRAM_APPLICATION_ID,
              l_tcnv_rec.KHR_ID_OLD,
              l_tcnv_rec.PROGRAM_ID,
              l_tcnv_rec.PROGRAM_update_DATE,
              l_tcnv_rec.CREATED_BY,
              l_tcnv_rec.CREATION_DATE,
              l_tcnv_rec.LAST_UPDATED_BY,
              l_tcnv_rec.LAST_UPDATE_DATE,
              l_tcnv_rec.LAST_UPDATE_LOGIN,
	      l_tcnv_rec.TRY_ID,
	      l_tcnv_rec.TSU_CODE,
              l_tcnv_rec.SET_OF_BOOKS_ID,
	      l_tcnv_rec.DESCRIPTION,
	      l_tcnv_rec.DATE_TRANSACTION_OCCURRED,
              l_tcnv_rec.TRX_NUMBER,
              l_tcnv_rec.TMT_EVERGREEN_YN ,
              l_tcnv_rec.TMT_CLOSE_BALANCES_YN ,
              l_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN ,
              l_tcnv_rec.TMT_CANCEL_INSURANCE_YN ,
              l_tcnv_rec.TMT_ASSET_DISPOSITION_YN ,
              l_tcnv_rec.TMT_AMORTIZATION_YN ,
              l_tcnv_rec.TMT_ASSET_RETURN_YN ,
              l_tcnv_rec.TMT_CONTRACT_UPDATED_YN ,
              l_tcnv_rec.TMT_RECYCLE_YN ,
              l_tcnv_rec.TMT_VALIDATED_YN ,
              l_tcnv_rec.TMT_STREAMS_UPDATED_YN,
              l_tcnv_rec.accrual_activity,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
              l_tcnv_rec.TMT_SPLIT_ASSET_YN,
	      l_tcnv_rec.TMT_GENERIC_FLAG1_YN,
	      l_tcnv_rec.TMT_GENERIC_FLAG2_YN,
	      l_tcnv_rec.TMT_GENERIC_FLAG3_YN,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	      l_tcnv_rec.CURRENCY_CONVERSION_TYPE,
	      l_tcnv_rec.CURRENCY_CONVERSION_RATE,
	      l_tcnv_rec.CURRENCY_CONVERSION_DATE,
-- Added by Keerthi 04-SEP-2003
	      l_tcnv_rec.CHR_ID,
-- Added by Keerthi for Bug No 3195713
          l_tcnv_rec.SOURCE_TRX_ID,
          l_tcnv_rec.SOURCE_TRX_TYPE,
-- Added by kmotepal for Bug 3621485
          l_tcnv_rec.CANCELED_DATE,
--Added by dpsingh for LE Uptake
           l_tcnv_rec.LEGAL_ENTITY_ID,
--Added by dpsingh for SLA Uptake (Bug 5707866)
          l_tcnv_rec.ACCRUAL_REVERSAL_DATE,
          l_tcnv_rec.ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
         l_tcnv_rec.PRODUCT_NAME,
         l_tcnv_rec.BOOK_CLASSIFICATION_CODE,
	 l_tcnv_rec.TAX_OWNER_CODE,
	 l_tcnv_rec.TMT_STATUS_CODE,
         l_tcnv_rec.REPRESENTATION_NAME,
         l_tcnv_rec.REPRESENTATION_CODE,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
         l_tcnv_rec.UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
	l_tcnv_rec.TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
         l_tcnv_rec.primary_rep_trx_id,
         l_tcnv_rec.REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
         l_tcnv_rec.TRANSACTION_REVERSAL_DATE;
    x_no_data_found := okl_tcnv_pk_csr%NOTFOUND;
    CLOSE okl_tcnv_pk_csr;
    RETURN(l_tcnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tcnv_rec                     IN tcnv_rec_type
  ) RETURN tcnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tcnv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_CONTRACTS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tcnv_rec	IN tcnv_rec_type
  ) RETURN tcnv_rec_type IS
    l_tcnv_rec	tcnv_rec_type := p_tcnv_rec;
  BEGIN
    IF (l_tcnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.object_version_number := NULL;
    END IF;
    IF (l_tcnv_rec.rbr_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.rbr_code := NULL;
    END IF;
    IF (l_tcnv_rec.rpy_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.rpy_code := NULL;
    END IF;
    IF (l_tcnv_rec.rvn_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.rvn_code := NULL;
    END IF;
    IF (l_tcnv_rec.trn_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.trn_code := NULL;
    END IF;
    IF (l_tcnv_rec.khr_id_new = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.khr_id_new := NULL;
    END IF;
    IF (l_tcnv_rec.pvn_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.pvn_id := NULL;
    END IF;
    IF (l_tcnv_rec.pdt_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.pdt_id := NULL;
    END IF;
    IF (l_tcnv_rec.qte_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.qte_id := NULL;
    END IF;
    IF (l_tcnv_rec.aes_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.aes_id := NULL;
    END IF;
    IF (l_tcnv_rec.code_combination_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.code_combination_id := NULL;
    END IF;
    IF (l_tcnv_rec.tax_deductible_local = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tax_deductible_local := NULL;
    END IF;
    IF (l_tcnv_rec.tax_deductible_corporate = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tax_deductible_corporate := NULL;
    END IF;
    IF (l_tcnv_rec.date_accrual = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.date_accrual := NULL;
    END IF;
    IF (l_tcnv_rec.accrual_status_yn = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.accrual_status_yn := NULL;
    END IF;
    IF (l_tcnv_rec.update_status_yn = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.update_status_yn := NULL;
    END IF;
    IF (l_tcnv_rec.amount = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.amount := NULL;
    END IF;
    IF (l_tcnv_rec.currency_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.currency_code := NULL;
    END IF;
    IF (l_tcnv_rec.attribute_category = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute_category := NULL;
    END IF;
    IF (l_tcnv_rec.attribute1 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute1 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute2 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute2 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute3 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute3 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute4 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute4 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute5 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute5 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute6 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute6 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute7 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute7 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute8 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute8 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute9 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute9 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute10 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute10 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute11 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute11 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute12 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute12 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute13 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute13 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute14 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute14 := NULL;
    END IF;
    IF (l_tcnv_rec.attribute15 = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.attribute15 := NULL;
    END IF;
    IF (l_tcnv_rec.tcn_type = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tcn_type := NULL;
    END IF;

    IF (l_tcnv_rec.rjn_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.rjn_code := NULL;
    END IF;

    IF (l_tcnv_rec.party_rel_id1_old = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.party_rel_id1_old := NULL;
    END IF;

    IF (l_tcnv_rec.party_rel_id2_old = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.party_rel_id2_old := NULL;
    END IF;

    IF (l_tcnv_rec.party_rel_id1_new = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.party_rel_id1_new := NULL;
    END IF;

    IF (l_tcnv_rec.party_rel_id2_new = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.party_rel_id2_new := NULL;
    END IF;

    IF (l_tcnv_rec.complete_transfer_yn = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.complete_transfer_yn := NULL;
    END IF;

    IF (l_tcnv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.org_id := NULL;
    END IF;
    IF (l_tcnv_rec.khr_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.khr_id := NULL;
    END IF;
    IF (l_tcnv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.request_id := NULL;
    END IF;
    IF (l_tcnv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.program_application_id := NULL;
    END IF;
    IF (l_tcnv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.program_id := NULL;
    END IF;
    IF (l_tcnv_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.program_update_date := NULL;
    END IF;
    IF (l_tcnv_rec.khr_id_old = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.khr_id_old := NULL;
    END IF;
    IF (l_tcnv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.created_by := NULL;
    END IF;
    IF (l_tcnv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.creation_date := NULL;
    END IF;
    IF (l_tcnv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tcnv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.last_update_date := NULL;
    END IF;
    IF (l_tcnv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.last_update_login := NULL;
    END IF;

	IF (l_tcnv_rec.try_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.try_id := NULL;
    END IF;
	IF (l_tcnv_rec.tsu_code = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tsu_code := NULL;
    END IF;
	IF (l_tcnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.set_of_books_id := NULL;
    END IF;
	IF (l_tcnv_rec.description = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.description := NULL;
    END IF;
	IF (l_tcnv_rec.date_transaction_occurred = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.date_transaction_occurred := NULL;
    END IF;
	IF (l_tcnv_rec.trx_number = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.trx_number := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_evergreen_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_evergreen_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_close_balances_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_close_balances_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_accounting_entries_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_accounting_entries_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_cancel_insurance_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_cancel_insurance_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_asset_disposition_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_asset_disposition_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_amortization_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_amortization_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_asset_return_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_asset_return_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_contract_updated_yn  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_contract_updated_yn  := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_recycle_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_recycle_yn   := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_validated_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_validated_yn   := NULL;
    END IF;
	IF (l_tcnv_rec.tmt_streams_updated_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_streams_updated_yn   := NULL;
    END IF;
	IF (l_tcnv_rec.accrual_activity   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.accrual_activity   := NULL;
    END IF;

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517

    IF (l_tcnv_rec.tmt_split_asset_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_split_asset_yn   := NULL;
    END IF;
    IF (l_tcnv_rec.tmt_generic_flag1_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_generic_flag1_yn   := NULL;
    END IF;
    IF (l_tcnv_rec.tmt_generic_flag2_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_generic_flag2_yn   := NULL;
    END IF;
    IF (l_tcnv_rec.tmt_generic_flag3_yn   = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.tmt_generic_flag3_yn   := NULL;
    END IF;

-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes

    IF (l_tcnv_rec.CURRENCY_CONVERSION_TYPE  = Okc_Api.G_MISS_CHAR) THEN
        l_tcnv_rec.CURRENCY_CONVERSION_TYPE  := NULL;
    END IF;
    IF (l_tcnv_rec.CURRENCY_CONVERSION_RATE  = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.CURRENCY_CONVERSION_RATE   := NULL;
    END IF;
    IF (l_tcnv_rec.CURRENCY_CONVERSION_DATE  = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.CURRENCY_CONVERSION_DATE   := NULL;
    END IF;

-- Added by Keerthi 04-SEP-2003
    IF (l_tcnv_rec.CHR_ID  = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.CHR_ID   := NULL;
    END IF;

-- Added by Keerthi for Bug No 3195713

    IF (l_tcnv_rec.SOURCE_TRX_ID  = Okc_Api.G_MISS_NUM) THEN
      l_tcnv_rec.SOURCE_TRX_ID   := NULL;
    END IF;

    IF (l_tcnv_rec.SOURCE_TRX_TYPE  = Okc_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.SOURCE_TRX_TYPE  := NULL;
    END IF;

-- Added by kmotepal for Bug 3621485
    IF (l_tcnv_rec.CANCELED_DATE = Okc_Api.G_MISS_DATE) THEN
      l_tcnv_rec.CANCELED_DATE := NULL;
    END IF;

    --Added by dpsingh for LE Uptake
     IF (l_tcnv_rec.LEGAL_ENTITY_ID = Okl_Api.G_MISS_NUM) THEN
      l_tcnv_rec.LEGAL_ENTITY_ID := NULL;
    END IF;

    --Added by dpsingh for SLA Uptake (Bug 5707866)
     IF (l_tcnv_rec.ACCRUAL_REVERSAL_DATE = Okl_Api.G_MISS_DATE) THEN
      l_tcnv_rec.ACCRUAL_REVERSAL_DATE := NULL;
    END IF;

-- Added by DJANASWA for SLA project
    IF (l_tcnv_rec.ACCOUNTING_REVERSAL_YN = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.ACCOUNTING_REVERSAL_YN := NULL;
    END IF;
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    IF (l_tcnv_rec.PRODUCT_NAME = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.PRODUCT_NAME := NULL;
    END IF;
    IF (l_tcnv_rec.BOOK_CLASSIFICATION_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.BOOK_CLASSIFICATION_CODE := NULL;
    END IF;
    IF (l_tcnv_rec.TAX_OWNER_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.TAX_OWNER_CODE := NULL;
    END IF;
    IF (l_tcnv_rec.TMT_STATUS_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.TMT_STATUS_CODE := NULL;
    END IF;
    IF (l_tcnv_rec.REPRESENTATION_NAME = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.REPRESENTATION_NAME := NULL;
    END IF;
    IF (l_tcnv_rec.REPRESENTATION_CODE = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.REPRESENTATION_CODE := NULL;
    END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    IF (l_tcnv_rec.UPGRADE_STATUS_FLAG = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.UPGRADE_STATUS_FLAG := NULL;
    END IF;
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
    IF (l_tcnv_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE) THEN
      l_tcnv_rec.TRANSACTION_DATE := NULL;
    END IF;
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
    IF (l_tcnv_rec.primary_rep_trx_id = Okl_Api.G_MISS_NUM) THEN
      l_tcnv_rec.primary_rep_trx_id := NULL;
    END IF;
    IF (l_tcnv_rec.REPRESENTATION_TYPE = Okl_Api.G_MISS_CHAR) THEN
      l_tcnv_rec.REPRESENTATION_TYPE := NULL;
    END IF;
-- Added by sosharma for Income Account recon- report 01-Nov-2008
     IF (l_tcnv_rec.TRANSACTION_REVERSAL_DATE = Okl_Api.G_MISS_DATE) THEN
      l_tcnv_rec.TRANSACTION_REVERSAL_DATE := NULL;
    END IF;

    RETURN(l_tcnv_rec);
  END null_out_defaults;

/* Renu Gurudev 4/17/2001 - Commented out generated code in favor of manually written code
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_CONTRACTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_tcnv_rec IN  tcnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_tcnv_rec.id = OKC_API.G_MISS_NUM OR
       p_tcnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tcnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_tcnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tcnv_rec.tcn_type = OKC_API.G_MISS_CHAR OR
          p_tcnv_rec.tcn_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'tcn_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_TRX_CONTRACTS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_tcnv_rec IN tcnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
*/

  /*********** begin manual coding *****************/
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
  PROCEDURE Validate_Id (p_tcnv_rec      IN  tcnv_rec_type
				 ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.id IS NULL) OR
       (p_tcnv_rec.id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'id');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

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
  PROCEDURE Validate_Khr_Id (p_tcnv_rec IN  tcnv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcnv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers_V
  WHERE okl_k_headers_v.id = p_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.khr_id IS NOT NULL) AND
       (p_tcnv_rec.khr_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_tcnv_fk_csr(p_tcnv_rec.KHR_ID);
        FETCH okl_tcnv_fk_csr INTO l_dummy;
        l_row_notfound := okl_tcnv_fk_csr%NOTFOUND;
        CLOSE okl_tcnv_fk_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id;


  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Khr_Id_New
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id_New (p_tcnv_rec IN  tcnv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcnv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers_V
  WHERE okl_k_headers_v.id = p_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.khr_id_New IS NOT NULL) AND
       (p_tcnv_rec.khr_id_New <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_tcnv_fk_csr(p_tcnv_rec.KHR_ID_NEW);
        FETCH okl_tcnv_fk_csr INTO l_dummy;
        l_row_notfound := okl_tcnv_fk_csr%NOTFOUND;
        CLOSE okl_tcnv_fk_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID_NEW');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id_New;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Khr_Id_Old
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Khr_Id_Old
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id_Old (p_tcnv_rec IN  tcnv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcnv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers_V
  WHERE okl_k_headers_v.id = p_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.khr_id_Old IS NOT NULL) AND
       (p_tcnv_rec.khr_id_Old <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_tcnv_fk_csr(p_tcnv_rec.KHR_ID_OLD);
        FETCH okl_tcnv_fk_csr INTO l_dummy;
        l_row_notfound := okl_tcnv_fk_csr%NOTFOUND;
        CLOSE okl_tcnv_fk_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID_OLD');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id_Old;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pvn_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Pvn_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pvn_Id (p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR pvn_csr (v_pvn_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_PROVISIONS_V
  WHERE ID = v_pvn_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.pvn_id IS NOT NULL) AND
       (p_tcnv_rec.pvn_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN pvn_csr(p_tcnv_rec.PVN_ID);
        FETCH pvn_csr INTO l_dummy;
        l_row_notfound := pvn_csr%NOTFOUND;
        CLOSE pvn_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PVN_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_PVN_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_PDT_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Pdt_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pdt_Id (p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR pdt_csr (v_pdt_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_PRODUCTS_V
  WHERE ID = v_pdt_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.pdt_id IS NOT NULL) AND
       (p_tcnv_rec.pdt_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN pdt_csr(p_tcnv_rec.PDT_ID);
        FETCH pdt_csr INTO l_dummy;
        l_row_notfound := pdt_csr%NOTFOUND;
        CLOSE pdt_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDT_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_PDT_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Qte_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Qte_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Qte_Id (p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR qte_csr (v_qte_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_TRX_QUOTES_V
  WHERE ID = v_qte_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.qte_id IS NOT NULL) AND
       (p_tcnv_rec.qte_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN qte_csr(p_tcnv_rec.QTE_ID);
        FETCH qte_csr INTO l_dummy;
        l_row_notfound := qte_csr%NOTFOUND;
        CLOSE qte_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'QTE_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Qte_Id;

--Added by dpsingh for LE Uptake
---------------------------------------------------------------------------
  -- PROCEDURE Validate_LE_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_LE_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_LE_Id(p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  item_not_found_error              EXCEPTION;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.legal_entity_id IS NOT NULL) AND
       (p_tcnv_rec.legal_entity_id <> Okl_Api.G_MISS_NUM) THEN

        l_dummy := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_tcnv_rec.legal_entity_id);
          IF  l_dummy <>1 THEN
          Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_LE_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_AES_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_AES_ID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_AES_Id (p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR aes_csr (v_aes_id IN NUMBER) IS
  SELECT  '1'
  FROM OKL_AE_TMPT_SETS_V
  WHERE ID = v_aes_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.aes_id IS NOT NULL) AND
       (p_tcnv_rec.aes_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN aes_csr(p_tcnv_rec.AES_ID);
        FETCH aes_csr INTO l_dummy;
        l_row_notfound := aes_csr%NOTFOUND;
        CLOSE aes_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AES_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_AES_Id;

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
  PROCEDURE Validate_Object_Version_Number (p_tcnv_rec      IN  tcnv_rec_type
                                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.object_version_number IS NULL) OR
       (p_tcnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'object_version_number');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tcn_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Tcn_Type
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tcn_Type (p_tcnv_rec      IN  tcnv_rec_type
                               ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.tcn_type IS NULL) OR
       (p_tcnv_rec.tcn_type = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'tcn_type');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check in fnd_lookups for validity

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_TCN_TYPE',
                               p_lookup_code => p_tcnv_rec.tcn_type);

    IF (l_dummy = OKL_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'tcn_type');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Tcn_Type;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rjn_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Rjn_Code
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rjn_Code (p_tcnv_rec      IN  tcnv_rec_type
                              ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

     -- check in fnd_lookups for validity

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_REJECTION_REASON',
                               p_lookup_code => p_tcnv_rec.rjn_code);

    IF (l_dummy = OKL_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rjn_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
   -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Rjn_Code;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_CCID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_CCID
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_CCID (p_tcnv_rec      IN  tcnv_rec_type
                          ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.code_combination_id IS NOT NULL) AND
       (p_tcnv_rec.code_combination_id <> Okc_Api.G_MISS_NUM) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_GL_CCID(p_tcnv_rec.Code_Combination_Id);

      IF (l_dummy = OKL_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'code_Combination_id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_CCID;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accrual_Status_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Accrual_Status_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Accrual_Status_YN(p_tcnv_rec      IN      tcnv_rec_type
				      ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy         VARCHAR2(1)  := Okc_Api.G_FALSE;
  l_app_id        NUMBER := 0;
  l_view_app_id   NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.accrual_status_yn IS NOT NULL) AND
       (p_tcnv_rec.accrual_status_yn <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.accrual_status_yn,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);
       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'accrual_status_yn');
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

  END Validate_Accrual_Status_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Update_Status_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Update_Status_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Update_Status_YN(p_tcnv_rec      IN      tcnv_rec_type
						   ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id  NUMBER := 0;
  l_view_app_id NUMBER := 0;


  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.update_status_yn IS NOT NULL) AND
       (p_tcnv_rec.update_status_yn <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.update_status_yn,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'update_status_yn');
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

  END Validate_Update_Status_YN;

-- Added DJANASWA 02-Feb-2007 SLA project  begin
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Account_Reversal_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Account_Reversal_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Account_Reversal_YN (p_tcnv_rec      IN      tcnv_rec_type
                                                   ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id  NUMBER := 0;
  l_view_app_id NUMBER := 0;


  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.Accounting_Reversal_YN IS NOT NULL) AND
       (p_tcnv_rec.Accounting_Reversal_YN <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.Accounting_Reversal_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'Accounting_Reversal_YN');
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

  END Validate_Account_Reversal_YN;
-- Added DJANASWA 02-Feb-2007 SLA project  end

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tax_Deductible_Local
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tax_Deductible_Local
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tax_Deductible_Local(p_tcnv_rec      IN      tcnv_rec_type
						   ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id  NUMBER := 0;
  l_view_app_id NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.tax_deductible_local IS NOT NULL) AND
       (p_tcnv_rec.tax_deductible_local <> Okc_Api.G_MISS_CHAR) THEN
       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.tax_deductible_local,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'tax_deductible_local');
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

  END Validate_Tax_Deductible_Local;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_tax_deductible_corp
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_tax_deductible_corp
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE validate_tax_deductible_corp(p_tcnv_rec      IN      tcnv_rec_type
						   ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id  NUMBER := 0;
  l_view_app_id NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.tax_deductible_corporate IS NOT NULL) AND
       (p_tcnv_rec.tax_deductible_corporate <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.tax_deductible_corporate,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'tax_deductible_corporate');
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

  END validate_tax_deductible_corp;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_RBR_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_RBR_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_RBR_Code(p_tcnv_rec      IN      tcnv_rec_type
			      ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.RBR_CODE IS NOT NULL) AND
       (p_tcnv_rec.RBR_CODE <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_REBOOK_REASON',
                               p_lookup_code => p_tcnv_rec.RBR_CODE);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'RBR_CODE');
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

  END Validate_RBR_Code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_RPY_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_RPY_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_RPY_Code(p_tcnv_rec      IN      tcnv_rec_type
			      ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.RPY_CODE IS NOT NULL) AND
       (p_tcnv_rec.RPY_CODE <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_REBOOK_PROCESS_TYPE',
                               p_lookup_code => p_tcnv_rec.RPY_CODE);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'RPY_CODE');
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

  END Validate_RPY_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_RVN_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_RVN_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_RVN_Code(p_tcnv_rec      IN      tcnv_rec_type
			      ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.RVN_CODE IS NOT NULL) AND
       (p_tcnv_rec.RVN_CODE <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_REVERSE_REASON',
                               p_lookup_code => p_tcnv_rec.RVN_CODE);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'RVN_CODE');
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

  END Validate_RVN_Code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_TSU_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_TSU_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_TSU_Code(p_tcnv_rec      IN      tcnv_rec_type
			     ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.tsu_code IS NULL) OR
       (p_tcnv_rec.tsu_code = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'TSU_CODE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_TRANSACTION_STATUS',
                               p_lookup_code => p_tcnv_rec.TSU_CODE);

    IF (l_dummy = OKL_API.G_FALSE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TSU_CODE');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

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

  END Validate_TSU_Code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_TRN_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_TRN_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_TRN_Code(p_tcnv_rec      IN      tcnv_rec_type
			      ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id NUMBER := 510;
  l_view_app_id NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.TRN_CODE IS NOT NULL) AND
       (p_tcnv_rec.TRN_CODE <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKC_TERMINATION_REASON',
                               p_lookup_code => p_tcnv_rec.TRN_CODE,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TRN_CODE');
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

  END Validate_TRN_Code;

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
  PROCEDURE Validate_currency_code(p_tcnv_rec      IN      tcnv_rec_type
						  ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_Dummy         VARCHAR2(1)  := OKL_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.currency_code IS NULL) OR
       (p_tcnv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'CURRENCY_CODE');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_CURRENCY_CODE (p_tcnv_rec.currency_code);

    IF (l_dummy = okl_api.g_false) THEN
        Okc_Api.SET_MESSAGE(p_app_name   => g_app_name,
                       	    p_msg_name     => g_invalid_value,
                       	    p_token1       => g_col_name_token,
                       	    p_token1_value => 'CURRENCY_CODE');
        x_return_status := Okc_Api.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
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

  END Validate_currency_code;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Try_ID
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_TRY_ID
  -- Description      : Although in table it is NULLABLE, we are still making it
  --                    sure that TRY_ID must be given and should be valid.
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_TRY_Id (p_tcnv_rec      IN  tcnv_rec_type
			    ,x_return_status OUT NOCOPY VARCHAR2)

  IS
  l_dummy                   VARCHAR2(1)    ;

  CURSOR try_csr(v_try_id NUMBER) IS
  SELECT '1'
  FROM OKL_TRX_TYPES_V
  WHERE ID = v_try_id;


  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.Try_id IS NULL) OR
       (p_tcnv_rec.TRY_id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'TRY_ID');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN try_csr(p_tcnv_rec.TRY_ID);
    FETCH try_csr INTO l_dummy;
    IF (try_csr%NOTFOUND) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_invalid_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'TRY_ID');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       CLOSE try_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE try_csr;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_TRY_Id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_Transaction
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Date_Transaction
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Transaction (p_tcnv_rec      IN  tcnv_rec_type
			              ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.date_transaction_occurred IS NULL) OR
       (p_tcnv_rec.date_transaction_occurred = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'Date_Transaction_Occurred');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Date_Transaction;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_trx_number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_trx_number
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Trx_number (p_tcnv_rec      IN  tcnv_rec_type
			         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_trx_number                      OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE;

 CURSOR tcn_csr(v_trx_number VARCHAR2,
                 v_id NUMBER, v_rep_code VARCHAR2) IS
  SELECT trx_number
  FROM OKL_TRX_CONTRACTS
  WHERE trx_number = v_trx_number
  and representation_code = v_rep_code
  AND   id   <> v_id;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.trx_number IS NULL) OR
       (p_tcnv_rec.trx_number = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'trx_number');
       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN tcn_csr(p_tcnv_rec.trx_number,
                 p_tcnv_rec.ID, p_tcnv_rec.representation_code);
    FETCH tcn_csr INTO l_trx_number;
    IF (tcn_csr%FOUND) THEN
       OKC_API.SET_MESSAGE(p_app_name     => 'OKL' ,
                           p_msg_name     => 'OKL_TRX_NUM_NOT_UNIQUE',
                           p_token1       => 'TRX_NUMBER',
                           p_token1_value => p_tcnv_rec.trx_number);

       x_return_status     := Okc_Api.G_RET_STS_ERROR;
       CLOSE tcn_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE tcn_csr;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_trx_number;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Terminate_Attribs
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Terminate_Attribs
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Terminate_Attribs(p_tcnv_rec      IN      tcnv_rec_type
			              ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;
  l_app_id       NUMBER := 0;
  l_view_app_id  NUMBER := 0;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing

    IF (p_tcnv_rec.TMT_EVERGREEN_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_EVERGREEN_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_EVERGREEN_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_EVERGREEN_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;


    IF (p_tcnv_rec.TMT_CLOSE_BALANCES_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_CLOSE_BALANCES_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_CLOSE_BALANCES_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_CLOSE_BALANCES_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;


    IF (p_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_ACCOUNTING_ENTRIES_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_ACCOUNTING_ENTRIES_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;


    IF (p_tcnv_rec.TMT_CANCEL_INSURANCE_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_CANCEL_INSURANCE_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_CANCEL_INSURANCE_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_CANCEL_INSURANCE_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_ASSET_DISPOSITION_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_ASSET_DISPOSITION_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_ASSET_DISPOSITION_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_ASSET_DISPOSITION_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;


    IF (p_tcnv_rec.TMT_AMORTIZATION_YN  IS NOT NULL) AND
       (p_tcnv_rec.TMT_AMORTIZATION_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_AMORTIZATION_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_AMORTIZATION_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_ASSET_RETURN_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_ASSET_RETURN_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_ASSET_RETURN_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_ASSET_RETURN_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_CONTRACT_UPDATED_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_CONTRACT_UPDATED_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_CONTRACT_UPDATED_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_CONTRACT_UPDATED_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_RECYCLE_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_RECYCLE_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_RECYCLE_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_RECYCLE_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_VALIDATED_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_VALIDATED_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_VALIDATED_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_VALIDATED_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

       END IF;

    END IF;

    IF (p_tcnv_rec.TMT_STREAMS_UPDATED_YN IS NOT NULL) AND
       (p_tcnv_rec.TMT_STREAMS_UPDATED_YN <> Okc_Api.G_MISS_CHAR) THEN

       l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'YES_NO',
                               p_lookup_code => p_tcnv_rec.TMT_STREAMS_UPDATED_YN,
                               p_app_id      => l_app_id,
                               p_view_app_id => l_view_app_id);

       IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_STREAMS_UPDATED_YN');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

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

  END Validate_Terminate_Attribs;

-- Added by Santonyr 31-Jul-2002 Added New Filed Accrual_Activity
-- Fixed Bug 2486088

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accrual_Activity
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Accrual_Activity
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Accrual_Activity (p_tcnv_rec      IN  tcnv_rec_type
                              ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_dummy                   VARCHAR2(1)    := OKL_API.G_FALSE;

  BEGIN
    -- initialize return status
   x_return_status := Okc_Api.G_RET_STS_SUCCESS;

     -- check in fnd_lookups for validity
   IF  p_tcnv_rec.accrual_activity IS NOT NULL THEN
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_ACCRUAL_ACTIVITY',
                               p_lookup_code => p_tcnv_rec.accrual_activity);

      IF (l_dummy = OKL_API.G_FALSE) THEN
         Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_invalid_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'Accrual Activity');
         x_return_status    := Okc_Api.G_RET_STS_ERROR;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
   -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Accrual_Activity;


--Added by Keerthi 25-Aug-2003
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Chr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Chr_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Chr_Id (p_tcnv_rec IN  tcnv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                           VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcn_chrid_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okc_k_headers_b
  WHERE okc_k_headers_b.id = p_id;


  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.chr_id IS NOT NULL) AND
       (p_tcnv_rec.chr_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_tcn_chrid_csr(p_tcnv_rec.CHR_ID);
        FETCH okl_tcn_chrid_csr INTO l_dummy;
        l_row_notfound := okl_tcn_chrid_csr%NOTFOUND;
        CLOSE okl_tcn_chrid_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Chr_Id;


--Added by Keerthi for Bug No 3195713
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_Trx_Id_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Source_Trx_Id_Type
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Source_Trx_Id_Type (p_tcnv_rec IN  tcnv_rec_type
                                    ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                           VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;


  CURSOR okl_tcn_csr (p_source_id IN NUMBER) IS
  SELECT '1'
  FROM okl_trx_contracts otc
  WHERE otc.id = p_source_id;

  CURSOR okl_tas_csr (p_source_id IN NUMBER) IS
  SELECT '1'
  FROM okl_trx_assets ota
  WHERE ota.id = p_source_id;

  -- rmunjulu bug 6736148
  CURSOR okl_qte_csr (p_source_id IN NUMBER) IS
  SELECT '1'
  FROM okl_trx_quotes_b qte
  WHERE qte.id = p_source_id;

  BEGIN
 -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
 -- check for data before processing

  IF (p_tcnv_rec.source_trx_type IS NOT NULL) THEN
   IF (p_tcnv_rec.source_trx_id IS NULL) THEN
        Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'SOURCE_TRX_ID');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_SOURCE_TRX_TYPE',
                                                           p_lookup_code =>  p_tcnv_rec.source_trx_type);

     IF (l_dummy = Okc_Api.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'SOURCE_TRX_TYPE');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
  	      RAISE G_EXCEPTION_HALT_VALIDATION;
     ELSE

         IF (p_tcnv_rec.source_trx_type = 'TCN') THEN
           OPEN okl_tcn_csr(p_tcnv_rec.SOURCE_TRX_ID);
           FETCH okl_tcn_csr INTO l_dummy;
           l_row_notfound := okl_tcn_csr%NOTFOUND;
           CLOSE okl_tcn_csr;
           IF (l_row_notfound) THEN
             Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SOURCE_TRX_ID');
             RAISE item_not_found_error;
           END IF;

         ELSIF (p_tcnv_rec.source_trx_type = 'TAS') THEN
           OPEN okl_tas_csr(p_tcnv_rec.SOURCE_TRX_ID);
           FETCH okl_tas_csr INTO l_dummy;
           l_row_notfound := okl_tas_csr%NOTFOUND;
           CLOSE okl_tas_csr;
           IF (l_row_notfound) THEN
             Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SOURCE_TRX_ID');
             RAISE item_not_found_error;
           END IF;
           -- rmunjulu bug 6736148
          ELSIF (p_tcnv_rec.source_trx_type = 'QTE') THEN

           OPEN okl_qte_csr(p_tcnv_rec.SOURCE_TRX_ID);
           FETCH okl_qte_csr INTO l_dummy;
           l_row_notfound := okl_qte_csr%NOTFOUND;
           CLOSE okl_qte_csr;
           IF (l_row_notfound) THEN
             Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SOURCE_TRX_ID');
             RAISE item_not_found_error;
           END IF;
  	    END IF;
     END IF;
    END IF;
  ELSE
       IF (p_tcnv_rec.source_trx_id IS NOT NULL) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                            ,p_token1_value   => 'SOURCE_TRX_ID');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
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

  END Validate_Source_Trx_Id_Type;

-- added by DJANASWA 06-Feb-07 SLA project
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Accrual_Reversal_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Accrual_Reversal_Date
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


 PROCEDURE Validate_Accrual_Reversal_Date (p_tcnv_rec  IN  tcnv_rec_type,
                              x_return_status OUT NOCOPY  VARCHAR2)
     IS
       l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
       l_date_transaction_occurred             DATE         := Okc_Api.G_MISS_DATE;
      BEGIN
       -- initialize return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       l_date_transaction_occurred := p_tcnv_rec.date_transaction_occurred;
       -- check for data before processing
        IF   p_tcnv_rec.accrual_reversal_date <> OKC_API.G_MISS_DATE
        OR p_tcnv_rec.accrual_reversal_date IS NOT NULL
        THEN
            IF  p_tcnv_rec.accrual_reversal_date  < l_date_transaction_occurred
            THEN
              Okc_Api.SET_MESSAGE( p_app_name   => g_app_name,
                           p_msg_name       => g_invalid_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'ACCRUAL_REVERSAL_DATE' );
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
        END IF;

    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
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
  END Validate_Accrual_Reversal_Date;

-- Added by zrehman for SLA project (Bug 5707866) 21-Feb-2007
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tmt_Status_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Tmt_Status_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Tmt_Status_Code(p_tcnv_rec      IN      tcnv_rec_type
			            ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.tmt_status_code IS NOT NULL) AND (p_tcnv_rec.tmt_status_code <> OKC_API.G_MISS_CHAR) THEN

      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_TRANSACTION_STATUS',
                               p_lookup_code => p_tcnv_rec.TMT_STATUS_CODE);

        IF (l_dummy = OKL_API.G_FALSE) THEN
          Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => g_invalid_value
                             ,p_token1         => g_col_name_token
                             ,p_token1_value   => 'TMT_STATUS_CODE');
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

  END Validate_Tmt_Status_Code;

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
  PROCEDURE Validate_Upgrade_Status_Flag (x_return_status OUT NOCOPY VARCHAR2, p_tcnv_rec IN tcnv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy VARCHAR2(1) := OKC_API.G_FALSE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_tcnv_rec.UPGRADE_STATUS_FLAG IS NOT NULL) AND
       (p_tcnv_rec.UPGRADE_STATUS_FLAG <> Okc_Api.G_MISS_CHAR) THEN
       -- check in fnd_lookups for validity
      l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE
                              (p_lookup_type => 'OKL_YES_NO',
                               p_lookup_code => p_tcnv_rec.UPGRADE_STATUS_FLAG);

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

-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
---------------------------------------------------------------------------
  -- PROCEDURE Validate_primary_rep_trx_id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_primary_rep_trx_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_primary_rep_trx_id (p_tcnv_rec IN tcnv_rec_type, x_return_status OUT NOCOPY VARCHAR2)
  IS

  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                           VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcn_id_csr (p_id IN NUMBER, p_chr_id IN NUMBER) IS
  SELECT  '1'
  FROM okl_trx_contracts
  WHERE okl_trx_contracts.id = p_id
  AND okl_trx_contracts.primary_rep_trx_id is null
  and okl_trx_contracts.khr_id = p_chr_id;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.primary_rep_trx_id IS NOT NULL AND
         p_tcnv_rec.primary_rep_trx_id <> Okc_Api.G_MISS_NUM AND
          p_tcnv_rec.khr_id IS NOT NULL AND
           p_tcnv_rec.khr_id <> Okc_Api.G_MISS_NUM) THEN

        OPEN okl_tcn_id_csr(p_tcnv_rec.primary_rep_trx_id,p_tcnv_rec.khr_id );
        FETCH okl_tcn_id_csr INTO l_dummy;
        l_row_notfound := okl_tcn_id_csr%NOTFOUND;
        CLOSE okl_tcn_id_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_primary_rep_trx_id;

-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
---------------------------------------------------------------------------
  -- PROCEDURE Validate_representation_type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_representation_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_representation_type (p_tcnv_rec IN tcnv_rec_type, x_return_status OUT NOCOPY VARCHAR2)
  IS

  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                           VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR rep_type_csr (p_rep_code IN VARCHAR2) IS
  SELECT  '1'
  from fnd_lookups lkp
  where lkp.lookup_type = 'OKL_REPRESENTATION_TYPE'
  and lkp.lookup_code = p_rep_code;
  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tcnv_rec.representation_type IS NOT NULL AND
         p_tcnv_rec.representation_type <> Okc_Api.G_MISS_CHAR) THEN

        OPEN rep_type_csr(p_tcnv_rec.representation_type);
        FETCH rep_type_csr INTO l_dummy;
        l_row_notfound := rep_type_csr%NOTFOUND;
        CLOSE rep_type_csr;
        IF (l_row_notfound) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN,'ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_representation_type;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rep_Name_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Rep_Name_Code
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rep_Name_Code (p_tcnv_rec IN  tcnv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okc_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;

  l_11i_row_notfound                BOOLEAN := TRUE;--sechawla 8967918
  item_not_found_error              EXCEPTION;

  CURSOR rep_valid_csr(p_rep_name VARCHAR2,
                       p_rep_code VARCHAR2)
  IS
  SELECT '1'
  FROM gl_ledgers
  WHERE name = p_rep_name
  AND short_name = p_rep_code;

  --sechawla 8967918 : during upgrade, gl_ledgers may not have data. Use gl_sets_of_books_11i in that case
  CURSOR rep_valid_csr_11i(p_rep_name VARCHAR2,
                       p_rep_code VARCHAR2)
  IS
  SELECT '1'
  FROM gl_sets_of_books_11i
  WHERE name = p_rep_name
  AND short_name = p_rep_code;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF(p_tcnv_rec.representation_name IS NOT NULL) AND (p_tcnv_rec.representation_name <> Okc_Api.G_MISS_CHAR)
    AND (p_tcnv_rec.representation_code IS NOT NULL) AND (p_tcnv_rec.representation_code <> Okc_Api.G_MISS_CHAR) THEN
        OPEN rep_valid_csr(p_rep_name => p_tcnv_rec.representation_name,
                           p_rep_code => p_tcnv_rec.representation_code);
        FETCH rep_valid_csr INTO l_dummy;
        l_row_notfound := rep_valid_csr%NOTFOUND;
        CLOSE rep_valid_csr;
        IF (l_row_notfound) THEN
            --sechawla 8967918 : during upgrade, gl_ledgers may not have data. Use gl_sets_of_books_11i in that case : begin
             OPEN rep_valid_csr_11i(p_rep_name => p_tcnv_rec.representation_name,
                           p_rep_code => p_tcnv_rec.representation_code);
             FETCH rep_valid_csr_11i INTO l_dummy;
             l_11i_row_notfound := rep_valid_csr_11i%NOTFOUND;
             CLOSE rep_valid_csr_11i;

             IF (l_11i_row_notfound) THEN
              --sechawla 8967918 : during upgrade, gl_ledgers may not have data. Use gl_sets_of_books_11i in that case : end
               Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REPRESENTATION_CODE');
               RAISE item_not_found_error;
             END IF;
        END IF;
    ELSE
        Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'REPRESENTATION_CODE');
        x_return_status     := Okc_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Rep_Name_Code;


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
    p_tcnv_rec IN  tcnv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Id
    Validate_Id(p_tcnv_rec, x_return_status);
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
    Validate_Khr_Id(p_tcnv_rec, x_return_status);
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

    -- Validate_Khr_Id_New
    Validate_Khr_Id_New(p_tcnv_rec, x_return_status);
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

    -- Validate_Khr_Id_Old
    Validate_Khr_Id_Old(p_tcnv_rec, x_return_status);
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

    -- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
    -- Validate_primary_rep_trx_id
    Validate_primary_rep_trx_id(p_tcnv_rec, x_return_status);
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

    -- Validate_representation_type
    Validate_representation_type(p_tcnv_rec, x_return_status);
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

    -- Validate_Pvn_Id
    Validate_PVN_ID(p_tcnv_rec, x_return_status);
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


    -- Validate_PDT_Id
    Validate_PDT_ID(p_tcnv_rec, x_return_status);
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

    -- Validate_QTE_ID
    Validate_QTE_ID(p_tcnv_rec, x_return_status);
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

    -- Validate_AES_ID
    Validate_AES_ID(p_tcnv_rec, x_return_status);
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


    -- Validate_CCID
    Validate_CCID(p_tcnv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_tcnv_rec, x_return_status);
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

    -- Validate_Tcn_Type
    Validate_Tcn_Type(p_tcnv_rec, x_return_status);
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

    -- Validate_Accrual_Status_YN
    Validate_Accrual_Status_YN(p_tcnv_rec, x_return_status);
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

    -- Validate_Update_Status_YN
    Validate_Update_Status_YN(p_tcnv_rec, x_return_status);
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

-- Added DJANASWA for SLA project
    -- Validate_Account_Reversal_YN
    Validate_Account_Reversal_YN (p_tcnv_rec, x_return_status);
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

    -- Validate_Tax_Deductible_Local
    Validate_Tax_Deductible_Local(p_tcnv_rec, x_return_status);
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

    -- validate_tax_deductible_corp
    validate_tax_deductible_corp(p_tcnv_rec, x_return_status);
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

    -- Validate_currency_code
    Validate_currency_code(p_tcnv_rec, x_return_status);
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

    -- Validate_TRY_ID
    Validate_TRY_ID(p_tcnv_rec, x_return_status);
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


    -- Validate_Date_Transaction
    Validate_Date_Transaction(p_tcnv_rec, x_return_status);
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


    -- Validate_RBR_CODE
    Validate_RBR_CODE(p_tcnv_rec, x_return_status);
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

    -- Validate_RPY_CODE
    Validate_RPY_CODE(p_tcnv_rec, x_return_status);
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

    -- Validate_RVN_CODE
    Validate_RVN_CODE(p_tcnv_rec, x_return_status);
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

    -- Validate_TSU_CODE
    Validate_TSU_CODE(p_tcnv_rec, x_return_status);
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

    -- Validate_TRN_CODE
    Validate_TRN_CODE(p_tcnv_rec, x_return_status);
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


    -- Validate_Trx_Number
    Validate_Trx_Number(p_tcnv_rec, x_return_status);
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


    -- Validate_Terminate_Attribs
    Validate_Terminate_Attribs(p_tcnv_rec, x_return_status);
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

-- Added by Santonyr 31-Jul-2002
-- Added New Filed Accrual_Activity. Fixed Bug 2486088

    -- Validate Accrual Activity
    Validate_Accrual_Activity(p_tcnv_rec, x_return_status);
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

--Added be Keerthi 25-Aug-03
-- Validate_Chr_Id

    Validate_Chr_Id(p_tcnv_rec, x_return_status);
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

--Added by dpsingh

-- Validate_LE_Id
    Validate_LE_Id(p_tcnv_rec, x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

--Added be Keerthi for Bug No 3195713
-- Validate_Source_Trx_Id_Type

    Validate_Source_Trx_Id_Type(p_tcnv_rec, x_return_status);
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

-- Added by DJANASWA for SLA project 06-Feb-07
    Validate_Accrual_Reversal_Date (p_tcnv_rec, x_return_status);
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

    -- Added by zrehman for SLA project 21-Feb-07
    Validate_Tmt_Status_Code (p_tcnv_rec, x_return_status);
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

    -- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
    Validate_Upgrade_Status_Flag(x_return_status, p_tcnv_rec);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
              l_return_status := x_return_status;
          END IF;
       END IF;

    -- Added by kthiruva for SLA project (Bug 5707866) 10-May-2007
    Validate_Rep_Name_Code(p_tcnv_rec,x_return_status);

       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := x_return_Status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
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
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
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
    p_tcnv_rec IN tcnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

  /*********************** END MANUAL CODE **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN tcnv_rec_type,
    p_to	IN OUT NOCOPY tcn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id_new := p_from.khr_id_new;
    p_to.pvn_id := p_from.pvn_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.rbr_code := p_from.rbr_code;
    p_to.rpy_code := p_from.rpy_code;
    p_to.rvn_code := p_from.rvn_code;
    p_to.trn_code := p_from.trn_code;
    p_to.qte_id := p_from.qte_id;
    p_to.aes_id := p_from.aes_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.tcn_type := p_from.tcn_type;

    p_to.rjn_code := p_from.rjn_code;
    p_to.party_rel_id1_old := p_from.party_rel_id1_old;
    p_to.party_rel_id2_old := p_from.party_rel_id2_old;
    p_to.party_rel_id1_new := p_from.party_rel_id1_new;
    p_to.party_rel_id2_new := p_from.party_rel_id2_new;
    p_to.complete_transfer_yn := p_from.complete_transfer_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.date_accrual := p_from.date_accrual;
    p_to.accrual_status_yn := p_from.accrual_status_yn;
    p_to.update_status_yn := p_from.update_status_yn;
    p_to.org_id := p_from.org_id;
    p_to.khr_id := p_from.khr_id;
    p_to.tax_deductible_local := p_from.tax_deductible_local;
    p_to.tax_deductible_corporate := p_from.tax_deductible_corporate;
    p_to.amount := p_from.amount;
    p_to.request_id := p_from.request_id;
    p_to.currency_code := p_from.currency_code;
    p_to.program_application_id := p_from.program_application_id;
    p_to.khr_id_old := p_from.khr_id_old;
    p_to.program_id := p_from.program_id;
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
    p_to.try_id  := p_from.try_id;
    p_to.tsu_code  := p_from.tsu_code;
    p_to.set_of_books_id  := p_from.set_of_books_id;
    p_to.description  := p_from.description;
    p_to.date_transaction_occurred  := p_from.date_transaction_occurred;
    p_to.trx_number  := p_from.trx_number;
    p_to.tmt_evergreen_yn  := p_from.tmt_evergreen_yn;
    p_to.tmt_close_balances_yn := p_from.tmt_close_balances_yn;
    p_to.tmt_accounting_entries_yn := p_from.tmt_accounting_entries_yn;
    p_to.tmt_cancel_insurance_yn := p_from.tmt_cancel_insurance_yn;
    p_to.tmt_asset_disposition_yn := p_from.tmt_asset_disposition_yn;
    p_to.tmt_amortization_yn := p_from.tmt_amortization_yn;
    p_to.tmt_asset_return_yn := p_from.tmt_asset_return_yn;
    p_to.tmt_contract_updated_yn := p_from.tmt_contract_updated_yn;
    p_to.tmt_recycle_yn := p_from.tmt_recycle_yn;
    p_to.tmt_validated_yn := p_from.tmt_validated_yn;
    p_to.tmt_streams_updated_yn := p_from.tmt_streams_updated_yn;
    p_to.accrual_activity := p_from.accrual_activity;
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
    p_to.tmt_split_asset_yn := p_from.tmt_split_asset_yn;
    p_to.tmt_generic_flag1_yn := p_from.tmt_generic_flag1_yn;
    p_to.tmt_generic_flag2_yn := p_from.tmt_generic_flag2_yn;
    p_to.tmt_generic_flag3_yn := p_from.tmt_generic_flag3_yn;
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
-- Added by Keerthi 04-SEP-2003
    p_to.chr_id := p_from.chr_id;
-- Added by Keerthi for Bug No 3195713
    p_to.source_trx_id := p_from.source_trx_id;
    p_to.source_trx_type := p_from.source_trx_type;
-- Added by kmotepal for Bug 3621485
    p_to.canceled_date := p_from.canceled_date;

     --Added by dpsingh for LE Uptake
    p_to.legal_entity_id := p_from.legal_entity_id;

   --Added by dpsingh for SLA Uptake (Bug 5707866)
    p_to.accrual_reversal_date := p_from.accrual_reversal_date;
  -- Added by DJANASWA for SLA project
    p_to.accounting_reversal_yn := p_from.accounting_reversal_yn;
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    p_to.product_name := p_from.product_name;
    p_to.book_classification_code := p_from.book_classification_code;
    p_to.tax_owner_code := p_from.tax_owner_code;
    p_to.tmt_status_code := p_from.tmt_status_code;
    p_to.representation_name := p_from.representation_name;
    p_to.representation_code := p_from.representation_code;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
    p_to.TRANSACTION_DATE := p_from.TRANSACTION_DATE;
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
    p_to.primary_rep_trx_id := p_from.primary_rep_trx_id;
    p_to.REPRESENTATION_TYPE := p_from.REPRESENTATION_TYPE;
-- Added by sosharma for Income Account recon- report 01-Nov-2008
    p_to.TRANSACTION_REVERSAL_DATE := p_from.TRANSACTION_REVERSAL_DATE;
  END migrate;
  PROCEDURE migrate (
    p_from	IN tcn_rec_type,
    p_to	IN OUT NOCOPY tcnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id_new := p_from.khr_id_new;
    p_to.pvn_id := p_from.pvn_id;
    p_to.pdt_id := p_from.pdt_id;
    p_to.rbr_code := p_from.rbr_code;
    p_to.rpy_code := p_from.rpy_code;
    p_to.rvn_code := p_from.rvn_code;
    p_to.trn_code := p_from.trn_code;
    p_to.qte_id := p_from.qte_id;
    p_to.aes_id := p_from.aes_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.tcn_type := p_from.tcn_type;

    p_to.rjn_code := p_from.rjn_code;
    p_to.party_rel_id1_old := p_from.party_rel_id1_old;
    p_to.party_rel_id2_old := p_from.party_rel_id2_old;
    p_to.party_rel_id1_new := p_from.party_rel_id1_new;
    p_to.party_rel_id2_new := p_from.party_rel_id2_new;
    p_to.complete_transfer_yn := p_from.complete_transfer_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.date_accrual := p_from.date_accrual;
    p_to.accrual_status_yn := p_from.accrual_status_yn;
    p_to.update_status_yn := p_from.update_status_yn;
    p_to.org_id := p_from.org_id;
    p_to.khr_id := p_from.khr_id;
    p_to.tax_deductible_local := p_from.tax_deductible_local;
    p_to.tax_deductible_corporate := p_from.tax_deductible_corporate;
    p_to.amount := p_from.amount;
    p_to.request_id := p_from.request_id;
    p_to.currency_code := p_from.currency_code;
    p_to.program_application_id := p_from.program_application_id;
    p_to.khr_id_old := p_from.khr_id_old;
    p_to.program_id := p_from.program_id;
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
    p_to.try_id  := p_from.try_id;
    p_to.tsu_code  := p_from.tsu_code;
    p_to.set_of_books_id  := p_from.set_of_books_id;
    p_to.description  := p_from.description;
    p_to.date_transaction_occurred  := p_from.date_transaction_occurred;
    p_to.trx_number  := p_from.trx_number;
    p_to.tmt_evergreen_yn  := p_from.tmt_evergreen_yn;
    p_to.tmt_close_balances_yn := p_from.tmt_close_balances_yn;
    p_to.tmt_accounting_entries_yn := p_from.tmt_accounting_entries_yn;
    p_to.tmt_cancel_insurance_yn := p_from.tmt_cancel_insurance_yn;
    p_to.tmt_asset_disposition_yn := p_from.tmt_asset_disposition_yn;
    p_to.tmt_amortization_yn := p_from.tmt_amortization_yn;
    p_to.tmt_asset_return_yn := p_from.tmt_asset_return_yn;
    p_to.tmt_contract_updated_yn := p_from.tmt_contract_updated_yn;
    p_to.tmt_recycle_yn := p_from.tmt_recycle_yn;
    p_to.tmt_validated_yn := p_from.tmt_validated_yn;
    p_to.tmt_streams_updated_yn := p_from.tmt_streams_updated_yn;
    p_to.accrual_activity := p_from.accrual_activity;

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
    p_to.tmt_split_asset_yn := p_from.tmt_split_asset_yn;
    p_to.tmt_generic_flag1_yn := p_from.tmt_generic_flag1_yn;
    p_to.tmt_generic_flag2_yn := p_from.tmt_generic_flag2_yn;
    p_to.tmt_generic_flag3_yn := p_from.tmt_generic_flag3_yn;
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
-- Added by Keerthi 04-SEP-2003
    p_to.chr_id := p_from.chr_id;
-- Added by Keerthi for Bug No 3195713
    p_to.source_trx_id := p_from.source_trx_id;
    p_to.source_trx_type := p_from.source_trx_type;
-- Added by kmotepal for Bug 3621485
    p_to.canceled_date := p_from.canceled_date;
--Added by dpsingh for LE Uptake
   p_to.legal_entity_id := p_from.legal_entity_id;
   --Added by dpsingh for SLA Uptake (Bug 5707866)
   p_to.accrual_reversal_date := p_from.accrual_reversal_date;
-- Added by DJANASWA for SLA project
   p_to.accounting_reversal_yn := p_from.accounting_reversal_yn;
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
   p_to.product_name := p_from.product_name;
   p_to.book_classification_code := p_from.book_classification_code;
   p_to.tax_owner_code := p_from.tax_owner_code;
   p_to.tmt_status_code := p_from.tmt_status_code;
   p_to.representation_name := p_from.representation_name;
   p_to.representation_code := p_from.representation_code;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
   p_to.UPGRADE_STATUS_FLAG := p_from.UPGRADE_STATUS_FLAG;
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
   p_to.TRANSACTION_DATE := p_from.TRANSACTION_DATE;
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
   p_to.primary_rep_trx_id := p_from.primary_rep_trx_id;
   p_to.REPRESENTATION_TYPE := p_from.REPRESENTATION_TYPE;
-- Added by sosharma for Income Account recon- report 01-Nov-2008
   p_to.TRANSACTION_REVERSAL_DATE := p_from.TRANSACTION_REVERSAL_DATE;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_TRX_CONTRACTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcnv_rec                     tcnv_rec_type := p_tcnv_rec;
    l_tcn_rec                      tcn_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_tcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tcnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:TCNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- insert_row for:OKL_TRX_CONTRACTS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcn_rec                      IN tcn_rec_type,
    x_tcn_rec                      OUT NOCOPY tcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTRACTS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcn_rec                      tcn_rec_type := p_tcn_rec;
    l_def_tcn_rec                  tcn_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_CONTRACTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_tcn_rec IN  tcn_rec_type,
      x_tcn_rec OUT NOCOPY tcn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tcn_rec := p_tcn_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tcn_rec,                         -- IN
      l_tcn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_CONTRACTS(
        id,
        khr_id_new,
        pvn_id,
        pdt_id,
        rbr_code,
        rpy_code,
        rvn_code,
        trn_code,
        qte_id,
        aes_id,
        code_combination_id,
        tcn_type,
        RJN_CODE,
        PARTY_REL_ID1_OLD,
        PARTY_REL_ID2_OLD,
        PARTY_REL_ID1_NEW,
        PARTY_REL_ID2_NEW,
        COMPLETE_TRANSFER_YN,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        date_accrual,
        accrual_status_yn,
        update_status_yn,
        org_id,
        khr_id,
        tax_deductible_local,
        tax_deductible_corporate,
        amount,
        request_id,
        currency_CODE,
        program_application_id,
        khr_id_old,
        program_id,
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
	try_id,
	tsu_code,
	set_of_books_id,
	description,
	date_transaction_occurred,
        trx_number,
        TMT_EVERGREEN_YN,
        TMT_CLOSE_BALANCES_YN,
        TMT_ACCOUNTING_ENTRIES_YN,
        TMT_CANCEL_INSURANCE_YN,
        TMT_ASSET_DISPOSITION_YN,
        TMT_AMORTIZATION_YN,
        TMT_ASSET_RETURN_YN,
        TMT_CONTRACT_UPDATED_YN,
        TMT_RECYCLE_YN,
        TMT_VALIDATED_YN,
        TMT_STREAMS_UPDATED_YN,
        accrual_activity,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
        TMT_SPLIT_ASSET_YN,
	TMT_GENERIC_FLAG1_YN,
	TMT_GENERIC_FLAG2_YN,
	TMT_GENERIC_FLAG3_YN,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_RATE,
	CURRENCY_CONVERSION_DATE,
        CHR_ID,
    -- Added by Keerthi for Bug No 3195713
       SOURCE_TRX_ID,
       SOURCE_TRX_TYPE,
   -- Added by kmotepal for Bug 3621485
      CANCELED_DATE,
     --Added by dpsingh for LE Uptake
      LEGAL_ENTITY_ID,
     --Added by dpsingh for SLA Uptake (Bug 5707866)
      ACCRUAL_REVERSAL_DATE,
    -- Added by DJANASWA for SLA project
      ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
      product_name,
      BOOK_CLASSIFICATION_CODE,
      TAX_OWNER_CODE,
      TMT_STATUS_CODE,
      REPRESENTATION_NAME,
      REPRESENTATION_CODE,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
      UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
      TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
      primary_rep_trx_id,
      REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
      TRANSACTION_REVERSAL_DATE
      )
      VALUES (
        l_tcn_rec.id,
        l_tcn_rec.khr_id_new,
        l_tcn_rec.pvn_id,
        l_tcn_rec.pdt_id,
        l_tcn_rec.rbr_code,
        l_tcn_rec.rpy_code,
        l_tcn_rec.rvn_code,
        l_tcn_rec.trn_code,
        l_tcn_rec.qte_id,
        l_tcn_rec.aes_id,
        l_tcn_rec.code_combination_id,
        l_tcn_rec.tcn_type,
        l_tcn_rec.RJN_CODE,
        l_tcn_rec.PARTY_REL_ID1_OLD,
        l_tcn_rec.PARTY_REL_ID2_OLD,
        l_tcn_rec.PARTY_REL_ID1_NEW,
        l_tcn_rec.PARTY_REL_ID2_NEW,
        l_tcn_rec.COMPLETE_TRANSFER_YN,
        l_tcn_rec.object_version_number,
        l_tcn_rec.created_by,
        l_tcn_rec.creation_date,
        l_tcn_rec.last_updated_by,
        l_tcn_rec.last_update_date,
        l_tcn_rec.date_accrual,
        l_tcn_rec.accrual_status_yn,
        l_tcn_rec.update_status_yn,
        l_tcn_rec.org_id,
        l_tcn_rec.khr_id,
        l_tcn_rec.tax_deductible_local,
        l_tcn_rec.tax_deductible_corporate,
        l_tcn_rec.amount,
        l_tcn_rec.request_id,
        l_tcn_rec.currency_code,
        l_tcn_rec.program_application_id,
        l_tcn_rec.khr_id_old,
        l_tcn_rec.program_id,
        l_tcn_rec.program_update_date,
        l_tcn_rec.attribute_category,
        l_tcn_rec.attribute1,
        l_tcn_rec.attribute2,
        l_tcn_rec.attribute3,
        l_tcn_rec.attribute4,
        l_tcn_rec.attribute5,
        l_tcn_rec.attribute6,
        l_tcn_rec.attribute7,
        l_tcn_rec.attribute8,
        l_tcn_rec.attribute9,
        l_tcn_rec.attribute10,
        l_tcn_rec.attribute11,
        l_tcn_rec.attribute12,
        l_tcn_rec.attribute13,
        l_tcn_rec.attribute14,
        l_tcn_rec.attribute15,
        l_tcn_rec.last_update_login,
	l_tcn_rec.try_id,
	l_tcn_rec.tsu_code,
	l_tcn_rec.set_of_books_id,
	l_tcn_rec.description,
	l_tcn_rec.date_transaction_occurred,
        l_tcn_rec.trx_number,
        l_tcn_rec.TMT_EVERGREEN_YN ,
        l_tcn_rec.TMT_CLOSE_BALANCES_YN ,
        l_tcn_rec.TMT_ACCOUNTING_ENTRIES_YN ,
        l_tcn_rec.TMT_CANCEL_INSURANCE_YN ,
        l_tcn_rec.TMT_ASSET_DISPOSITION_YN ,
        l_tcn_rec.TMT_AMORTIZATION_YN ,
        l_tcn_rec.TMT_ASSET_RETURN_YN ,
        l_tcn_rec.TMT_CONTRACT_UPDATED_YN ,
        l_tcn_rec.TMT_RECYCLE_YN ,
        l_tcn_rec.TMT_VALIDATED_YN ,
        l_tcn_rec.TMT_STREAMS_UPDATED_YN,
        l_tcn_rec.accrual_activity,

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
        l_tcn_rec.TMT_SPLIT_ASSET_YN,
	l_tcn_rec.TMT_GENERIC_FLAG1_YN,
	l_tcn_rec.TMT_GENERIC_FLAG2_YN,
	l_tcn_rec.TMT_GENERIC_FLAG3_YN,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	l_tcn_rec.CURRENCY_CONVERSION_TYPE,
	l_tcn_rec.CURRENCY_CONVERSION_RATE,
	l_tcn_rec.CURRENCY_CONVERSION_DATE,
-- Added by Keerthi 04-SEP-2003
        l_tcn_rec.CHR_ID,
-- Added by Keerthi for Bug No 3195713
    l_tcn_rec.SOURCE_TRX_ID,
    l_tcn_rec.SOURCE_TRX_TYPE,
-- Added by kmotepal for Bug 3621485
    l_tcn_rec.CANCELED_DATE,
    --Added by dpsingh for LE Uptake
   l_tcn_rec.LEGAL_ENTITY_ID,
   --Added by dpsingh for SLA Uptake (Bug 5707866)
   l_tcn_rec.ACCRUAL_REVERSAL_DATE,
   -- Added by DJANASWA for SLA project
   l_tcn_rec.ACCOUNTING_REVERSAL_YN,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
   l_tcn_rec.product_name,
   l_tcn_rec.book_classification_code,
   l_tcn_rec.tax_owner_code,
   l_tcn_rec.tmt_status_code,
   l_tcn_rec.representation_name,
   l_tcn_rec.representation_code,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
   l_tcn_rec.UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
   l_tcn_rec.TRANSACTION_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
   l_tcn_rec.primary_rep_trx_id,
   l_tcn_rec.REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
   l_tcn_rec.TRANSACTION_REVERSAL_DATE
  );

    -- Set OUT values
    x_tcn_rec := l_tcn_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_TRX_CONTRACTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type,
    x_tcnv_rec                     OUT NOCOPY tcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcnv_rec                     tcnv_rec_type;
    l_def_tcnv_rec                 tcnv_rec_type;
    l_tcn_rec                      tcn_rec_type;
    lx_tcn_rec                     tcn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tcnv_rec	IN tcnv_rec_type
    ) RETURN tcnv_rec_type IS
      l_tcnv_rec	tcnv_rec_type := p_tcnv_rec;
    BEGIN
      l_tcnv_rec.CREATION_DATE := SYSDATE;
      l_tcnv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_tcnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tcnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tcnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

      IF (l_tcnv_rec.TRANSACTION_DATE IS NULL) OR
	(l_tcnv_rec.TRANSACTION_DATE = OKL_API.G_MISS_DATE) THEN
		l_tcnv_rec.TRANSACTION_DATE := SYSDATE;
      END IF;

      RETURN(l_tcnv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CONTRACTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_tcnv_rec IN  tcnv_rec_type,
      x_tcnv_rec OUT NOCOPY tcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_request_id 	NUMBER 	:= Fnd_Global.CONC_REQUEST_ID;
	l_prog_app_id 	NUMBER 	:= Fnd_Global.PROG_APPL_ID;
	l_program_id 	NUMBER 	:= Fnd_Global.CONC_PROGRAM_ID;
    BEGIN
      x_tcnv_rec := p_tcnv_rec;
      x_tcnv_rec.OBJECT_VERSION_NUMBER := 1;


      x_tcnv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

      SELECT DECODE(l_request_id, -1, NULL, l_request_id),
      	DECODE(l_prog_app_id, -1, NULL, l_prog_app_id),
	      DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
	      DECODE(l_request_id, -1, NULL, SYSDATE)
      INTO  x_tcnv_rec.REQUEST_ID
          	,x_tcnv_rec.PROGRAM_APPLICATION_ID
          	,x_tcnv_rec.PROGRAM_ID
          	,x_tcnv_rec.PROGRAM_UPDATE_DATE
     	FROM DUAL;
-- Commented by zrehman for SLA project (Bug 5707866) 21-Feb-2007
-- The derivation for the column is moved to OKL_TRX_CONTRACTS_PVT which in turn is
-- used to derive representation_name  and representation_code
-- start
	-- x_tcnv_rec.set_of_books_id := okl_accounting_util.get_set_of_books_id;
-- end

-- Added by nikshah for SLA project (Bug 5707866) 17-Apr-2007
        x_tcnv_rec.UPGRADE_STATUS_FLAG := 'N';

        BEGIN

           IF (x_tcnv_rec.trx_number IS NULL) OR
              (x_tcnv_rec.trx_number = OKL_API.G_MISS_CHAR) THEN
              SELECT OKL_TCN_SEQ.NEXTVAL INTO x_tcnv_rec.trx_number FROM DUAL;
           END IF;

           IF (x_tcnv_rec.currency_code IS NULL) OR
              (x_tcnv_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
              x_tcnv_rec.currency_code := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
           END IF;

        EXCEPTION
          WHEN OTHERS THEN l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        END;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_tcnv_rec := null_out_defaults(p_tcnv_rec);
    -- Set primary key value
    l_tcnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tcnv_rec,                        -- IN
      l_def_tcnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tcnv_rec := fill_who_columns(l_def_tcnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tcnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tcnv_rec, l_tcn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcn_rec,
      lx_tcn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcn_rec, l_def_tcnv_rec);
    -- Set OUT values
    x_tcnv_rec := l_def_tcnv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TCNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type,
    x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i),
          x_tcnv_rec                     => x_tcnv_tbl(i));
        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- lock_row for:OKL_TRX_CONTRACTS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcn_rec                      IN tcn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tcn_rec IN tcn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CONTRACTS
     WHERE ID = p_tcn_rec.id
       AND OBJECT_VERSION_NUMBER = p_tcn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tcn_rec IN tcn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_CONTRACTS
    WHERE ID = p_tcn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTRACTS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_CONTRACTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_CONTRACTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tcn_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_tcn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tcn_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tcn_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_TRX_CONTRACTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcn_rec                      tcn_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tcnv_rec, l_tcn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:TCNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- update_row for:OKL_TRX_CONTRACTS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcn_rec                      IN tcn_rec_type,
    x_tcn_rec                      OUT NOCOPY tcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTRACTS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcn_rec                      tcn_rec_type := p_tcn_rec;
    l_def_tcn_rec                  tcn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tcn_rec	IN tcn_rec_type,
      x_tcn_rec	OUT NOCOPY tcn_rec_type
    ) RETURN VARCHAR2 IS
      l_tcn_rec                      tcn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tcn_rec := p_tcn_rec;
      -- Get current database values
      l_tcn_rec := get_rec(p_tcn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tcn_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.id := l_tcn_rec.id;
      END IF;
      IF (x_tcn_rec.khr_id_new = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.khr_id_new := l_tcn_rec.khr_id_new;
      END IF;
      IF (x_tcn_rec.pvn_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.pvn_id := l_tcn_rec.pvn_id;
      END IF;
      IF (x_tcn_rec.pdt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.pdt_id := l_tcn_rec.pdt_id;
      END IF;
      IF (x_tcn_rec.rbr_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.rbr_code := l_tcn_rec.rbr_code;
      END IF;
      IF (x_tcn_rec.rpy_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.rpy_code := l_tcn_rec.rpy_code;
      END IF;
      IF (x_tcn_rec.rvn_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.rvn_code := l_tcn_rec.rvn_code;
      END IF;
      IF (x_tcn_rec.trn_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.trn_code := l_tcn_rec.trn_code;
      END IF;
      IF (x_tcn_rec.qte_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.qte_id := l_tcn_rec.qte_id;
      END IF;
      IF (x_tcn_rec.aes_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.aes_id := l_tcn_rec.aes_id;
      END IF;
      IF (x_tcn_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.code_combination_id := l_tcn_rec.code_combination_id;
      END IF;

      IF (x_tcn_rec.tcn_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tcn_type := l_tcn_rec.tcn_type;
      END IF;

      IF (x_tcn_rec.rjn_code = Okc_Api.G_MISS_CHAR) THEN
         x_tcn_rec.rjn_code := l_tcn_rec.rjn_code;
      END IF;

      IF (x_tcn_rec.party_rel_id1_old = Okc_Api.G_MISS_NUM) THEN
        x_tcn_rec.party_rel_id1_old := l_tcn_rec.party_rel_id1_old;
      END IF;

      IF (x_tcn_rec.party_rel_id2_old = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.party_rel_id2_old := l_tcn_rec.party_rel_id2_old;
      END IF;

      IF (x_tcn_rec.party_rel_id1_new = Okc_Api.G_MISS_NUM) THEN
        x_tcn_rec.party_rel_id1_new := l_tcn_rec.party_rel_id1_new;
      END IF;

      IF (x_tcn_rec.party_rel_id2_new = Okc_Api.G_MISS_CHAR) THEN
        x_tcn_rec.party_rel_id2_new := l_tcn_rec.party_rel_id2_new;
      END IF;

      IF (x_tcn_rec.complete_transfer_yn = Okc_Api.G_MISS_CHAR) THEN
        x_tcn_rec.complete_transfer_yn := l_tcn_rec.complete_transfer_yn;
      END IF;

      IF (x_tcn_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.object_version_number := l_tcn_rec.object_version_number;
      END IF;
      IF (x_tcn_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.created_by := l_tcn_rec.created_by;
      END IF;
      IF (x_tcn_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.creation_date := l_tcn_rec.creation_date;
      END IF;
      IF (x_tcn_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.last_updated_by := l_tcn_rec.last_updated_by;
      END IF;
      IF (x_tcn_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.last_update_date := l_tcn_rec.last_update_date;
      END IF;
      IF (x_tcn_rec.date_accrual = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.date_accrual := l_tcn_rec.date_accrual;
      END IF;
      IF (x_tcn_rec.accrual_status_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.accrual_status_yn := l_tcn_rec.accrual_status_yn;
      END IF;
      IF (x_tcn_rec.update_status_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.update_status_yn := l_tcn_rec.update_status_yn;
      END IF;
      IF (x_tcn_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.org_id := l_tcn_rec.org_id;
      END IF;
      IF (x_tcn_rec.khr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.khr_id := l_tcn_rec.khr_id;
      END IF;
      IF (x_tcn_rec.tax_deductible_local = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tax_deductible_local := l_tcn_rec.tax_deductible_local;
      END IF;
      IF (x_tcn_rec.tax_deductible_corporate = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tax_deductible_corporate := l_tcn_rec.tax_deductible_corporate;
      END IF;
      IF (x_tcn_rec.amount = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.amount := l_tcn_rec.amount;
      END IF;
      IF (x_tcn_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.request_id := l_tcn_rec.request_id;
      END IF;
      IF (x_tcn_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.currency_code := l_tcn_rec.currency_code;
      END IF;
      IF (x_tcn_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.program_application_id := l_tcn_rec.program_application_id;
      END IF;
      IF (x_tcn_rec.khr_id_old = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.khr_id_old := l_tcn_rec.khr_id_old;
      END IF;
      IF (x_tcn_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.program_id := l_tcn_rec.program_id;
      END IF;
      IF (x_tcn_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.program_update_date := l_tcn_rec.program_update_date;
      END IF;
      IF (x_tcn_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute_category := l_tcn_rec.attribute_category;
      END IF;
      IF (x_tcn_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute1 := l_tcn_rec.attribute1;
      END IF;
      IF (x_tcn_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute2 := l_tcn_rec.attribute2;
      END IF;
      IF (x_tcn_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute3 := l_tcn_rec.attribute3;
      END IF;
      IF (x_tcn_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute4 := l_tcn_rec.attribute4;
      END IF;
      IF (x_tcn_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute5 := l_tcn_rec.attribute5;
      END IF;
      IF (x_tcn_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute6 := l_tcn_rec.attribute6;
      END IF;
      IF (x_tcn_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute7 := l_tcn_rec.attribute7;
      END IF;
      IF (x_tcn_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute8 := l_tcn_rec.attribute8;
      END IF;
      IF (x_tcn_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute9 := l_tcn_rec.attribute9;
      END IF;
      IF (x_tcn_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute10 := l_tcn_rec.attribute10;
      END IF;
      IF (x_tcn_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute11 := l_tcn_rec.attribute11;
      END IF;
      IF (x_tcn_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute12 := l_tcn_rec.attribute12;
      END IF;
      IF (x_tcn_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute13 := l_tcn_rec.attribute13;
      END IF;
      IF (x_tcn_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute14 := l_tcn_rec.attribute14;
      END IF;
      IF (x_tcn_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.attribute15 := l_tcn_rec.attribute15;
      END IF;
      IF (x_tcn_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.last_update_login := l_tcn_rec.last_update_login;
      END IF;

	  IF (x_tcn_rec.try_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.try_id := l_tcn_rec.try_id;
      END IF;
	  IF (x_tcn_rec.tsu_code = Okc_Api.G_MISS_CHAR)
	  THEN
        x_tcn_rec.tsu_code := l_tcn_rec.tsu_code;
      END IF;
	  IF (x_tcn_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.set_of_books_id := l_tcn_rec.set_of_books_id;
      END IF;
	  IF (x_tcn_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.description := l_tcn_rec.description;
      END IF;
	  IF (x_tcn_rec.date_transaction_occurred = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.date_transaction_occurred := l_tcn_rec.date_transaction_occurred;
      END IF;

      IF (x_tcn_rec.trx_number = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.trx_number := l_tcn_rec.trx_number;
      END IF;

      IF (x_tcn_rec.tmt_evergreen_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_evergreen_yn := l_tcn_rec.tmt_evergreen_yn;
      END IF;

      IF (x_tcn_rec.tmt_close_balances_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_close_balances_yn := l_tcn_rec.tmt_close_balances_yn;
      END IF;

      IF (x_tcn_rec.tmt_accounting_entries_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_accounting_entries_yn  := l_tcn_rec.tmt_accounting_entries_yn ;
      END IF;

      IF (x_tcn_rec.tmt_cancel_insurance_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_cancel_insurance_yn  := l_tcn_rec.tmt_cancel_insurance_yn ;
      END IF;

      IF (x_tcn_rec.tmt_asset_disposition_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_asset_disposition_yn  := l_tcn_rec.tmt_asset_disposition_yn ;
      END IF;

      IF (x_tcn_rec.tmt_amortization_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_amortization_yn  := l_tcn_rec.tmt_amortization_yn ;
      END IF;

      IF (x_tcn_rec.tmt_asset_return_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_asset_return_yn  := l_tcn_rec.tmt_asset_return_yn ;
      END IF;

      IF (x_tcn_rec.tmt_contract_updated_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_contract_updated_yn  := l_tcn_rec.tmt_contract_updated_yn ;
      END IF;

      IF (x_tcn_rec.tmt_recycle_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_recycle_yn  := l_tcn_rec.tmt_recycle_yn ;
      END IF;

      IF (x_tcn_rec.tmt_validated_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_validated_yn  := l_tcn_rec.tmt_validated_yn ;
      END IF;

      IF (x_tcn_rec.tmt_streams_updated_yn  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_streams_updated_yn  := l_tcn_rec.tmt_streams_updated_yn ;
      END IF;

      IF (x_tcn_rec.accrual_activity  = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.accrual_activity  := l_tcn_rec.accrual_activity ;
      END IF;

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
    IF (x_tcn_rec.tmt_split_asset_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.tmt_split_asset_yn   := l_tcn_rec.tmt_split_asset_yn;
    END IF;
    IF (x_tcn_rec.tmt_generic_flag1_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.tmt_generic_flag1_yn   := l_tcn_rec.tmt_generic_flag1_yn;
    END IF;
    IF (x_tcn_rec.tmt_generic_flag2_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.tmt_generic_flag2_yn   := l_tcn_rec.tmt_generic_flag2_yn;
    END IF;
    IF (x_tcn_rec.tmt_generic_flag3_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.tmt_generic_flag3_yn   := l_tcn_rec.tmt_generic_flag3_yn;
    END IF;
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
    IF (x_tcn_rec.currency_conversion_type   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.currency_conversion_type   := l_tcn_rec.currency_conversion_type;
    END IF;
	IF (x_tcn_rec.currency_conversion_rate   = Okc_Api.G_MISS_NUM) THEN
      x_tcn_rec.currency_conversion_rate   := l_tcn_rec.currency_conversion_rate;
    END IF;
	IF (x_tcn_rec.currency_conversion_date   = Okc_Api.G_MISS_DATE) THEN
      x_tcn_rec.currency_conversion_date   := l_tcn_rec.currency_conversion_date;
    END IF;
--Added by Keerthi 04-SEP-2003
    IF (x_tcn_rec.chr_id   = Okc_Api.G_MISS_NUM) THEN
      x_tcn_rec.chr_id   := l_tcn_rec.chr_id;
    END IF;
--Added by Keerthi for Bug No 3195713
    IF (x_tcn_rec.source_trx_id   = Okc_Api.G_MISS_NUM) THEN
      x_tcn_rec.source_trx_id   := l_tcn_rec.source_trx_id;
    END IF;

    IF (x_tcn_rec.source_trx_type   = Okc_Api.G_MISS_CHAR) THEN
      x_tcn_rec.source_trx_type   := l_tcn_rec.source_trx_type;
    END IF;

    IF (x_tcn_rec.canceled_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.canceled_date := l_tcn_rec.canceled_date;
      END IF;

       IF (x_tcn_rec.legal_entity_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.legal_entity_id := l_tcn_rec.legal_entity_id;
      END IF;

    --Added by dpsingh for SLA Uptake (Bug 5707866)
       IF (x_tcn_rec.accrual_reversal_date = Okl_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.accrual_reversal_date := l_tcn_rec.accrual_reversal_date;
      END IF;

   -- Added by DJANASWA for SLA project
       IF (x_tcn_rec.accounting_reversal_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.accounting_reversal_yn := l_tcn_rec.accounting_reversal_yn;
      END IF;
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
       IF (x_tcn_rec.product_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.product_name := l_tcn_rec.product_name;
      END IF;

       IF (x_tcn_rec.book_classification_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.book_classification_code := l_tcn_rec.book_classification_code;
      END IF;

       IF (x_tcn_rec.tax_owner_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tax_owner_code := l_tcn_rec.tax_owner_code;
      END IF;

      IF (x_tcn_rec.tmt_status_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.tmt_status_code := l_tcn_rec.tmt_status_code;
      END IF;
      IF (x_tcn_rec.representation_name = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.representation_name := l_tcn_rec.representation_name;
      END IF;
      IF (x_tcn_rec.representation_code = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.representation_code := l_tcn_rec.representation_code;
      END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
      IF (x_tcn_rec.UPGRADE_STATUS_FLAG = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.UPGRADE_STATUS_FLAG := l_tcn_rec.UPGRADE_STATUS_FLAG;
      END IF;
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
      IF (x_tcn_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.TRANSACTION_DATE := l_tcn_rec.TRANSACTION_DATE;
      END IF;
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
      IF (x_tcn_rec.primary_rep_trx_id = Okl_Api.G_MISS_NUM)
      THEN
        x_tcn_rec.primary_rep_trx_id := l_tcn_rec.primary_rep_trx_id;
      END IF;
      IF (x_tcn_rec.REPRESENTATION_TYPE = Okl_Api.G_MISS_CHAR)
      THEN
        x_tcn_rec.REPRESENTATION_TYPE := l_tcn_rec.REPRESENTATION_TYPE;
      END IF;
-- Added by sosharma for Income Account recon- report 01-Nov-2008
       IF (x_tcn_rec.TRANSACTION_REVERSAL_DATE = Okl_Api.G_MISS_DATE)
      THEN
        x_tcn_rec.TRANSACTION_REVERSAL_DATE := l_tcn_rec.TRANSACTION_REVERSAL_DATE;
      END IF;

    RETURN(l_return_status);

    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_TRX_CONTRACTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_tcn_rec IN  tcn_rec_type,
      x_tcn_rec OUT NOCOPY tcn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tcn_rec := p_tcn_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tcn_rec,                         -- IN
      l_tcn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tcn_rec, l_def_tcn_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_TRX_CONTRACTS
    SET KHR_ID_NEW = l_def_tcn_rec.khr_id_new,
        PVN_ID = l_def_tcn_rec.pvn_id,
        PDT_ID = l_def_tcn_rec.pdt_id,
        RBR_CODE = l_def_tcn_rec.rbr_code,
        RPY_CODE = l_def_tcn_rec.rpy_code,
        RVN_CODE = l_def_tcn_rec.rvn_code,
        TRN_CODE = l_def_tcn_rec.trn_code,
        QTE_ID = l_def_tcn_rec.qte_id,
        AES_ID = l_def_tcn_rec.aes_id,
        CODE_COMBINATION_ID = l_def_tcn_rec.code_combination_id,
        TCN_TYPE = l_def_tcn_rec.tcn_type,
        RJN_CODE = l_def_tcn_rec.RJN_CODE,
        PARTY_REL_ID1_OLD = l_def_tcn_rec.PARTY_REL_ID1_OLD,
        PARTY_REL_ID2_OLD = l_def_tcn_rec.PARTY_REL_ID2_OLD,
        PARTY_REL_ID1_NEW = l_def_tcn_rec.PARTY_REL_ID1_NEW,
        PARTY_REL_ID2_NEW = l_def_tcn_rec.PARTY_REL_ID2_NEW,
        COMPLETE_TRANSFER_YN = l_def_tcn_rec.COMPLETE_TRANSFER_YN,
        OBJECT_VERSION_NUMBER = l_def_tcn_rec.object_version_number,
        CREATED_BY = l_def_tcn_rec.created_by,
        CREATION_DATE = l_def_tcn_rec.creation_date,
        LAST_UPDATED_BY = l_def_tcn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tcn_rec.last_update_date,
        DATE_ACCRUAL = l_def_tcn_rec.date_accrual,
        ACCRUAL_STATUS_YN = l_def_tcn_rec.accrual_status_yn,
        UPDATE_STATUS_YN = l_def_tcn_rec.update_status_yn,
        ORG_ID = l_def_tcn_rec.org_id,
        KHR_ID = l_def_tcn_rec.khr_id,
        TAX_DEDUCTIBLE_LOCAL = l_def_tcn_rec.tax_deductible_local,
        tax_deductible_corporate = l_def_tcn_rec.tax_deductible_corporate,
        AMOUNT = l_def_tcn_rec.amount,
        REQUEST_ID = l_def_tcn_rec.request_id,
        CURRENCY_CODE = l_def_tcn_rec.currency_code,
        PROGRAM_APPLICATION_ID = l_def_tcn_rec.program_application_id,
        KHR_ID_OLD = l_def_tcn_rec.khr_id_old,
        PROGRAM_ID = l_def_tcn_rec.program_id,
        PROGRAM_update_DATE = l_def_tcn_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_tcn_rec.attribute_category,
        ATTRIBUTE1 = l_def_tcn_rec.attribute1,
        ATTRIBUTE2 = l_def_tcn_rec.attribute2,
        ATTRIBUTE3 = l_def_tcn_rec.attribute3,
        ATTRIBUTE4 = l_def_tcn_rec.attribute4,
        ATTRIBUTE5 = l_def_tcn_rec.attribute5,
        ATTRIBUTE6 = l_def_tcn_rec.attribute6,
        ATTRIBUTE7 = l_def_tcn_rec.attribute7,
        ATTRIBUTE8 = l_def_tcn_rec.attribute8,
        ATTRIBUTE9 = l_def_tcn_rec.attribute9,
        ATTRIBUTE10 = l_def_tcn_rec.attribute10,
        ATTRIBUTE11 = l_def_tcn_rec.attribute11,
        ATTRIBUTE12 = l_def_tcn_rec.attribute12,
        ATTRIBUTE13 = l_def_tcn_rec.attribute13,
        ATTRIBUTE14 = l_def_tcn_rec.attribute14,
        ATTRIBUTE15 = l_def_tcn_rec.attribute15,
        LAST_UPDATE_LOGIN = l_def_tcn_rec.last_update_login,
	TRY_ID = l_def_tcn_rec.try_id,
	TSU_CODE = l_def_tcn_rec.tsu_code,
	SET_OF_BOOKS_ID = l_def_tcn_rec.set_of_books_id,
	DESCRIPTION = l_def_tcn_rec.description,
	DATE_TRANSACTION_OCCURRED = l_def_tcn_rec.date_transaction_occurred,
        TRX_NUMBER                = l_def_tcn_rec.trx_number,
        TMT_EVERGREEN_YN          = l_def_tcn_rec.tmt_evergreen_yn,
        TMT_CLOSE_BALANCES_YN     = l_def_tcn_rec.tmt_close_balances_yn,
        TMT_ACCOUNTING_ENTRIES_YN = l_def_tcn_rec.tmt_accounting_entries_yn,
        TMT_CANCEL_INSURANCE_YN   = l_def_tcn_rec.tmt_cancel_insurance_yn,
        TMT_ASSET_DISPOSITION_YN  = l_def_tcn_rec.tmt_asset_disposition_yn,
        TMT_AMORTIZATION_YN       = l_def_tcn_rec.tmt_amortization_yn,
        TMT_ASSET_RETURN_YN       = l_def_tcn_rec.tmt_asset_return_yn,
        TMT_CONTRACT_UPDATED_YN   = l_def_tcn_rec.tmt_contract_updated_yn,
        TMT_RECYCLE_YN            = l_def_tcn_rec.tmt_recycle_yn,
        TMT_VALIDATED_YN          = l_def_tcn_rec.tmt_validated_yn,
        TMT_STREAMS_UPDATED_YN    = l_def_tcn_rec.tmt_streams_updated_yn,
        accrual_activity	  = l_def_tcn_rec.accrual_activity,
-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
	tmt_split_asset_yn	  = l_def_tcn_rec.tmt_split_asset_yn,
	tmt_generic_flag1_yn	  = l_def_tcn_rec.tmt_generic_flag1_yn,
	tmt_generic_flag2_yn      = l_def_tcn_rec.tmt_generic_flag2_yn,
	tmt_generic_flag3_yn      = l_def_tcn_rec.tmt_generic_flag3_yn,
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
   	CURRENCY_CONVERSION_TYPE	  = l_def_tcn_rec.currency_conversion_type,
	CURRENCY_CONVERSION_RATE	  = l_def_tcn_rec.currency_conversion_rate,
	CURRENCY_CONVERSION_DATE	  = l_def_tcn_rec.currency_conversion_date,
-- Added by Keerthi 04-SEP-2003
        CHR_ID				  = l_def_tcn_rec.chr_id ,
-- Added by Keerthi for Bug No 3195713
    SOURCE_TRX_ID             = l_def_tcn_rec.source_trx_id,
    SOURCE_TRX_TYPE           = l_def_tcn_rec.source_trx_type,
-- Added by kmotepal
    CANCELED_DATE             = l_def_tcn_rec.canceled_date,
    --Added by dpsingh for LE Uptake
    LEGAL_ENTITY_ID            = l_def_tcn_rec.legal_entity_id,
    --Added by dpsingh for SLA Uptake (Bug 5707866)
    ACCRUAL_REVERSAL_DATE = l_def_tcn_rec.accrual_reversal_date,
    -- Added by DJANASWA for SLA project
    ACCOUNTING_REVERSAL_YN = l_def_tcn_rec.accounting_reversal_yn,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    PRODUCT_NAME = l_def_tcn_rec.product_name,
    BOOK_CLASSIFICATION_CODE = l_def_tcn_rec.book_classification_code,
    TAX_OWNER_CODE = l_def_tcn_rec.tax_owner_code,
    TMT_STATUS_CODE = l_def_tcn_rec.tmt_status_code,
    REPRESENTATION_NAME = l_def_tcn_rec.representation_name,
    REPRESENTATION_CODE = l_def_tcn_rec.representation_code,
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    UPGRADE_STATUS_FLAG = l_def_tcn_rec.UPGRADE_STATUS_FLAG,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
    TRANSACTION_DATE = l_def_tcn_rec.transaction_date,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
    primary_rep_trx_id = l_def_tcn_rec.primary_rep_trx_id,
    REPRESENTATION_TYPE = l_def_tcn_rec.REPRESENTATION_TYPE,
-- Added by sosharma for Income Account recon- report 01-Nov-2008
    TRANSACTION_REVERSAL_DATE  = l_def_tcn_rec.TRANSACTION_REVERSAL_DATE
    WHERE ID = l_def_tcn_rec.id;

    x_tcn_rec := l_def_tcn_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_TRX_CONTRACTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type,
    x_tcnv_rec                     OUT NOCOPY tcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcnv_rec                     tcnv_rec_type := p_tcnv_rec;
    l_def_tcnv_rec                 tcnv_rec_type;
    l_tcn_rec                      tcn_rec_type;
    lx_tcn_rec                     tcn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tcnv_rec	IN tcnv_rec_type
    ) RETURN tcnv_rec_type IS
      l_tcnv_rec	tcnv_rec_type := p_tcnv_rec;
    BEGIN
      l_tcnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tcnv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_tcnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_tcnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tcnv_rec	IN tcnv_rec_type,
      x_tcnv_rec	OUT NOCOPY tcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_tcnv_rec                     tcnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_tcnv_rec := p_tcnv_rec;
      -- Get current database values
      l_tcnv_rec := get_rec(p_tcnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tcnv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.id := l_tcnv_rec.id;
      END IF;
      IF (x_tcnv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.object_version_number := l_tcnv_rec.object_version_number;
      END IF;
      IF (x_tcnv_rec.rbr_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.rbr_code := l_tcnv_rec.rbr_code;
      END IF;
      IF (x_tcnv_rec.rpy_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.rpy_code := l_tcnv_rec.rpy_code;
      END IF;
      IF (x_tcnv_rec.rvn_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.rvn_code := l_tcnv_rec.rvn_code;
      END IF;
      IF (x_tcnv_rec.trn_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.trn_code := l_tcnv_rec.trn_code;
      END IF;
      IF (x_tcnv_rec.khr_id_new = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.khr_id_new := l_tcnv_rec.khr_id_new;
      END IF;
      IF (x_tcnv_rec.pvn_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.pvn_id := l_tcnv_rec.pvn_id;
      END IF;
      IF (x_tcnv_rec.pdt_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.pdt_id := l_tcnv_rec.pdt_id;
      END IF;
      IF (x_tcnv_rec.qte_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.qte_id := l_tcnv_rec.qte_id;
      END IF;
      IF (x_tcnv_rec.aes_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.aes_id := l_tcnv_rec.aes_id;
      END IF;
      IF (x_tcnv_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.code_combination_id := l_tcnv_rec.code_combination_id;
      END IF;
      IF (x_tcnv_rec.tax_deductible_local = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.tax_deductible_local := l_tcnv_rec.tax_deductible_local;
      END IF;
      IF (x_tcnv_rec.tax_deductible_corporate = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.tax_deductible_corporate := l_tcnv_rec.tax_deductible_corporate;
      END IF;
      IF (x_tcnv_rec.date_accrual = Okc_Api.G_MISS_DATE)
      THEN
        x_tcnv_rec.date_accrual := l_tcnv_rec.date_accrual;
      END IF;
      IF (x_tcnv_rec.accrual_status_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.accrual_status_yn := l_tcnv_rec.accrual_status_yn;
      END IF;
      IF (x_tcnv_rec.update_status_yn = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.update_status_yn := l_tcnv_rec.update_status_yn;
      END IF;
      IF (x_tcnv_rec.amount = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.amount := l_tcnv_rec.amount;
      END IF;
      IF (x_tcnv_rec.currency_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.currency_code := l_tcnv_rec.currency_code;
      END IF;
      IF (x_tcnv_rec.attribute_category = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute_category := l_tcnv_rec.attribute_category;
      END IF;
      IF (x_tcnv_rec.attribute1 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute1 := l_tcnv_rec.attribute1;
      END IF;
      IF (x_tcnv_rec.attribute2 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute2 := l_tcnv_rec.attribute2;
      END IF;
      IF (x_tcnv_rec.attribute3 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute3 := l_tcnv_rec.attribute3;
      END IF;
      IF (x_tcnv_rec.attribute4 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute4 := l_tcnv_rec.attribute4;
      END IF;
      IF (x_tcnv_rec.attribute5 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute5 := l_tcnv_rec.attribute5;
      END IF;
      IF (x_tcnv_rec.attribute6 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute6 := l_tcnv_rec.attribute6;
      END IF;
      IF (x_tcnv_rec.attribute7 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute7 := l_tcnv_rec.attribute7;
      END IF;
      IF (x_tcnv_rec.attribute8 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute8 := l_tcnv_rec.attribute8;
      END IF;
      IF (x_tcnv_rec.attribute9 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute9 := l_tcnv_rec.attribute9;
      END IF;
      IF (x_tcnv_rec.attribute10 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute10 := l_tcnv_rec.attribute10;
      END IF;
      IF (x_tcnv_rec.attribute11 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute11 := l_tcnv_rec.attribute11;
      END IF;
      IF (x_tcnv_rec.attribute12 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute12 := l_tcnv_rec.attribute12;
      END IF;
      IF (x_tcnv_rec.attribute13 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute13 := l_tcnv_rec.attribute13;
      END IF;
      IF (x_tcnv_rec.attribute14 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute14 := l_tcnv_rec.attribute14;
      END IF;
      IF (x_tcnv_rec.attribute15 = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.attribute15 := l_tcnv_rec.attribute15;
      END IF;
      IF (x_tcnv_rec.tcn_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.tcn_type := l_tcnv_rec.tcn_type;
      END IF;

      IF (x_tcnv_rec.rjn_code = Okc_Api.G_MISS_CHAR) THEN
         x_tcnv_rec.rjn_code := l_tcnv_rec.rjn_code;
      END IF;

      IF (x_tcnv_rec.party_rel_id1_old = Okc_Api.G_MISS_NUM) THEN
         x_tcnv_rec.party_rel_id1_old := l_tcnv_rec.party_rel_id1_old;
      END IF;

      IF (x_tcnv_rec.party_rel_id2_old = Okc_Api.G_MISS_CHAR) THEN
        x_tcnv_rec.party_rel_id2_old := l_tcnv_rec.party_rel_id2_old;
      END IF;

      IF (x_tcnv_rec.party_rel_id1_new = Okc_Api.G_MISS_NUM) THEN
        x_tcnv_rec.party_rel_id1_new := l_tcnv_rec.party_rel_id1_new;
      END IF;

      IF (x_tcnv_rec.party_rel_id2_new = Okc_Api.G_MISS_CHAR) THEN
        x_tcnv_rec.party_rel_id2_new := l_tcnv_rec.party_rel_id2_new;
      END IF;

      IF (x_tcnv_rec.complete_transfer_yn = Okc_Api.G_MISS_CHAR) THEN
        x_tcnv_rec.complete_transfer_yn := l_tcnv_rec.complete_transfer_yn;
      END IF;

      IF (x_tcnv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.org_id := l_tcnv_rec.org_id;
      END IF;
      IF (x_tcnv_rec.khr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.khr_id := l_tcnv_rec.khr_id;
      END IF;
      IF (x_tcnv_rec.request_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.request_id := l_tcnv_rec.request_id;
      END IF;
      IF (x_tcnv_rec.program_application_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.program_application_id := l_tcnv_rec.program_application_id;
      END IF;
      IF (x_tcnv_rec.khr_id_old = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.khr_id_old := l_tcnv_rec.khr_id_old;
      END IF;
      IF (x_tcnv_rec.program_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.program_id := l_tcnv_rec.program_id;
      END IF;
      IF (x_tcnv_rec.program_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcnv_rec.program_update_date := l_tcnv_rec.program_update_date;
      END IF;
      IF (x_tcnv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.created_by := l_tcnv_rec.created_by;
      END IF;
      IF (x_tcnv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcnv_rec.creation_date := l_tcnv_rec.creation_date;
      END IF;
      IF (x_tcnv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.last_updated_by := l_tcnv_rec.last_updated_by;
      END IF;
      IF (x_tcnv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_tcnv_rec.last_update_date := l_tcnv_rec.last_update_date;
      END IF;
      IF (x_tcnv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.last_update_login := l_tcnv_rec.last_update_login;
      END IF;

	  IF (x_tcnv_rec.try_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.try_id := l_tcnv_rec.try_id;
      END IF;
	  IF (x_tcnv_rec.tsu_code = Okc_Api.G_MISS_CHAR)
	  THEN
        x_tcnv_rec.tsu_code := l_tcnv_rec.tsu_code;
      END IF;
	  IF (x_tcnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_tcnv_rec.set_of_books_id := l_tcnv_rec.set_of_books_id;
      END IF;
	  IF (x_tcnv_rec.description = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.description := l_tcnv_rec.description;
      END IF;
	  IF (x_tcnv_rec.date_transaction_occurred = Okc_Api.G_MISS_DATE)
      THEN
        x_tcnv_rec.date_transaction_occurred := l_tcnv_rec.date_transaction_occurred;
      END IF;

      IF (x_tcnv_rec.trx_number = Okc_Api.G_MISS_CHAR)
      THEN
        x_tcnv_rec.trx_number := l_tcnv_rec.trx_number;
      END IF;

      IF (x_tcnv_rec.tmt_evergreen_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_evergreen_yn  := l_tcnv_rec.tmt_evergreen_yn;
      END IF;

      IF (x_tcnv_rec.tmt_close_balances_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_close_balances_yn  := l_tcnv_rec.tmt_close_balances_yn;
      END IF;

      IF (x_tcnv_rec.tmt_accounting_entries_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_accounting_entries_yn  := l_tcnv_rec.tmt_accounting_entries_yn;
      END IF;

      IF (x_tcnv_rec.tmt_cancel_insurance_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_cancel_insurance_yn  :=  l_tcnv_rec.tmt_cancel_insurance_yn;
      END IF;

      IF (x_tcnv_rec.tmt_asset_disposition_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_asset_disposition_yn  := l_tcnv_rec.tmt_asset_disposition_yn;
      END IF;

      IF (x_tcnv_rec.tmt_amortization_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_amortization_yn  :=  l_tcnv_rec.tmt_amortization_yn;
      END IF;

      IF (x_tcnv_rec.tmt_asset_return_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_asset_return_yn  :=  l_tcnv_rec.tmt_asset_return_yn;
      END IF;

      IF (x_tcnv_rec.tmt_contract_updated_yn  = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_contract_updated_yn  :=  l_tcnv_rec.tmt_contract_updated_yn;
      END IF;

      IF (x_tcnv_rec.tmt_recycle_yn   = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_recycle_yn   :=  l_tcnv_rec.tmt_recycle_yn;
      END IF;

      IF (x_tcnv_rec.tmt_validated_yn   = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_validated_yn   :=  l_tcnv_rec.tmt_validated_yn;
      END IF;

      IF (x_tcnv_rec.tmt_streams_updated_yn   = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.tmt_streams_updated_yn   := l_tcnv_rec.tmt_streams_updated_yn;
      END IF;

      IF (x_tcnv_rec.accrual_activity   = Okc_Api.G_MISS_CHAR) THEN
          x_tcnv_rec.accrual_activity   := l_tcnv_rec.accrual_activity;
      END IF;

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517
    IF (x_tcnv_rec.tmt_split_asset_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tmt_split_asset_yn   := l_tcnv_rec.tmt_split_asset_yn;
    END IF;
    IF (x_tcnv_rec.tmt_generic_flag1_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tmt_generic_flag1_yn   := l_tcnv_rec.tmt_generic_flag1_yn;
    END IF;
    IF (x_tcnv_rec.tmt_generic_flag2_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tmt_generic_flag2_yn   := l_tcnv_rec.tmt_generic_flag2_yn;
    END IF;
    IF (x_tcnv_rec.tmt_generic_flag3_yn   = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tmt_generic_flag3_yn   := l_tcnv_rec.tmt_generic_flag3_yn;
    END IF;
-- Added by HKPATEL 14-NOV-2002.  Multi-Currency Changes
    IF (x_tcnv_rec.currency_conversion_type   = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.currency_conversion_type  := l_tcnv_rec.currency_conversion_type;
    END IF;
    IF (x_tcnv_rec.currency_conversion_rate   = Okc_Api.G_MISS_NUM) THEN
      x_tcnv_rec.currency_conversion_rate  := l_tcnv_rec.currency_conversion_rate;
    END IF;
    IF (x_tcnv_rec.currency_conversion_date   = Okc_Api.G_MISS_DATE) THEN
      x_tcnv_rec.currency_conversion_date  := l_tcnv_rec.currency_conversion_date;
    END IF;
-- Added be Keerthi 04-SEP-2003
    IF (x_tcnv_rec.chr_id   = Okc_Api.G_MISS_NUM) THEN
      x_tcnv_rec.chr_id  := l_tcnv_rec.chr_id;
    END IF;
-- Added be Keerthi for Bug No 3195713
    IF (x_tcnv_rec.source_trx_id  = Okc_Api.G_MISS_NUM) THEN
      x_tcnv_rec.source_trx_id  := l_tcnv_rec.source_trx_id;
    END IF;

    IF (x_tcnv_rec.source_trx_type  = Okc_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.source_trx_type  := l_tcnv_rec.source_trx_type;
    END IF;

    IF (x_tcnv_rec.canceled_date   = Okc_Api.G_MISS_DATE) THEN
      x_tcnv_rec.canceled_date  := l_tcnv_rec.canceled_date;
    END IF;

    --Added by dpsingh for LE Uptake
    IF (x_tcnv_rec.legal_entity_id   = Okl_Api.G_MISS_NUM) THEN
      x_tcnv_rec.legal_entity_id  := l_tcnv_rec.legal_entity_id;
    END IF;

    --Added by dpsingh for SLA Uptake (Bug 5707866)
    IF (x_tcnv_rec.accrual_reversal_date   = Okl_Api.G_MISS_DATE) THEN
      x_tcnv_rec.accrual_reversal_date  := l_tcnv_rec.accrual_reversal_date;
    END IF;

-- Added by DJANASWA for SLA project
    IF (x_tcnv_rec.accounting_reversal_yn = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.accounting_reversal_yn := l_tcnv_rec.accounting_reversal_yn;
    END IF;

-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
    IF (x_tcnv_rec.product_name = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.product_name := l_tcnv_rec.product_name;
    END IF;

    IF (x_tcnv_rec.book_classification_code = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.book_classification_code := l_tcnv_rec.book_classification_code;
    END IF;

    IF (x_tcnv_rec.tax_owner_code = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tax_owner_code := l_tcnv_rec.tax_owner_code;
    END IF;

    IF (x_tcnv_rec.tmt_status_code = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.tmt_status_code := l_tcnv_rec.tmt_status_code;
    END IF;

    IF (x_tcnv_rec.representation_name = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.representation_name := l_tcnv_rec.representation_name;
    END IF;

    IF (x_tcnv_rec.representation_code = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.representation_code := l_tcnv_rec.representation_code;
    END IF;
-- Added by nikshah for SLA project (Bug 5707866) 16-Apr-2007
    IF (x_tcnv_rec.UPGRADE_STATUS_FLAG = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.UPGRADE_STATUS_FLAG := l_tcnv_rec.UPGRADE_STATUS_FLAG;
    END IF;
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
    IF (x_tcnv_rec.TRANSACTION_DATE = Okl_Api.G_MISS_DATE) THEN
      x_tcnv_rec.TRANSACTION_DATE := SYSDATE;
    END IF;
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
    IF (x_tcnv_rec.primary_rep_trx_id = Okl_Api.G_MISS_NUM) THEN
      x_tcnv_rec.primary_rep_trx_id := l_tcnv_rec.primary_rep_trx_id;
    END IF;
    IF (x_tcnv_rec.REPRESENTATION_TYPE = Okl_Api.G_MISS_CHAR) THEN
      x_tcnv_rec.REPRESENTATION_TYPE := l_tcnv_rec.REPRESENTATION_TYPE;
    END IF;
-- Added by sosharma for Income Account recon- report 01-Nov-2008
    IF (x_tcnv_rec.TRANSACTION_REVERSAL_DATE = Okl_Api.G_MISS_DATE) THEN
      x_tcnv_rec.TRANSACTION_REVERSAL_DATE := l_tcnv_rec.TRANSACTION_REVERSAL_DATE;
    END IF;

    RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_TRX_CONTRACTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_tcnv_rec IN  tcnv_rec_type,
      x_tcnv_rec OUT NOCOPY tcnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_request_id 	NUMBER 	:= Fnd_Global.CONC_REQUEST_ID;
	l_prog_app_id 	NUMBER 	:= Fnd_Global.PROG_APPL_ID;
	l_program_id 	NUMBER 	:= Fnd_Global.CONC_PROGRAM_ID;
    BEGIN
      x_tcnv_rec := p_tcnv_rec;


     SELECT  NVL(DECODE(l_request_id, -1, NULL, l_request_id) ,p_tcnv_rec.REQUEST_ID)
    ,NVL(DECODE(l_prog_app_id, -1, NULL, l_prog_app_id) ,p_tcnv_rec.PROGRAM_APPLICATION_ID)
    ,NVL(DECODE(l_program_id, -1, NULL, l_program_id)  ,p_tcnv_rec.PROGRAM_ID)
    ,DECODE(DECODE(l_request_id, -1, NULL, SYSDATE) ,NULL, p_tcnv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
        INTO x_tcnv_rec.REQUEST_ID
    ,x_tcnv_rec.PROGRAM_APPLICATION_ID
    ,x_tcnv_rec.PROGRAM_ID
    ,x_tcnv_rec.PROGRAM_UPDATE_DATE
    FROM DUAL;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tcnv_rec,                        -- IN
      l_tcnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tcnv_rec, l_def_tcnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_tcnv_rec := fill_who_columns(l_def_tcnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tcnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tcnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tcnv_rec, l_tcn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcn_rec,
      lx_tcn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tcn_rec, l_def_tcnv_rec);
    x_tcnv_rec := l_def_tcnv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:TCNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type,
    x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i),
          x_tcnv_rec                     => x_tcnv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- delete_row for:OKL_TRX_CONTRACTS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcn_rec                      IN tcn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTRACTS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcn_rec                      tcn_rec_type:= p_tcn_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_CONTRACTS
     WHERE ID = l_tcn_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_TRX_CONTRACTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_tcnv_rec                     tcnv_rec_type := p_tcnv_rec;
    l_tcn_rec                      tcn_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tcnv_rec, l_tcn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tcn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:TCNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status		     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i));

        -- store the highest degree of error
	  IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
	  END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;
	  -- return overall status
	  x_return_status := l_overall_status;

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Tcn_Pvt;

/
