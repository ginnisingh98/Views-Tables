--------------------------------------------------------
--  DDL for Package OKL_ST_CODE_CONVERSIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ST_CODE_CONVERSIONS" AUTHID CURRENT_USER AS
/* $Header: OKLRSCCS.pls 120.7.12010000.2 2009/01/19 12:56:52 rgooty ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_ST_CODE_CONVERSIONS';


  G_MISS_NUM				  CONSTANT NUMBER   	:=  OKL_API.G_MISS_NUM;
  G_MISS_CHAR				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_MISS_CHAR;
  G_MISS_DATE				  CONSTANT DATE   	:=  OKL_API.G_MISS_DATE;
  G_TRUE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_TRUE;
  G_FALSE				  CONSTANT VARCHAR2(1)	:=  OKL_API.G_FALSE;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_HALT_PROCESSING 		EXCEPTION;
  G_EXCEPTION_ERROR			EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR		EXCEPTION;

  G_DEFAULT_DATE_FORMAT	CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';
   G_EXPENSE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_EXPENSE;
   G_INCOME		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_INCOME;
   G_ADVANCE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ADVANCE;
   G_ARREARS		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_ARREARS;
   G_FND_YES		CONSTANT VARCHAR2(1)  := Okl_Create_Streams_Pvt.G_FND_YES;
   G_FND_NO		CONSTANT VARCHAR2(1)  := Okl_Create_Streams_Pvt.G_FND_NO;
   G_CSM_TRUE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_CSM_TRUE;
   G_CSM_FALSE		CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_CSM_FALSE;

   G_LOCK_AMOUNT  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_LOCK_AMOUNT;
   G_LOCK_RATE         CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_LOCK_RATE;
   G_LOCK_BOTH         CONSTANT VARCHAR2(10) :=Okl_Create_Streams_Pvt. G_LOCK_BOTH;
   G_MODE_LESSOR  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_LESSOR;
   G_MODE_LENDER  CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_LENDER;
   G_MODE_BOTH        CONSTANT VARCHAR2(10) := Okl_Create_Streams_Pvt.G_MODE_BOTH;
   G_SFE_LEVEL_PAYMENT	CONSTANT VARCHAR2(7) :=  Okl_Create_Streams_Pvt.G_SFE_LEVEL_PAYMENT;
   G_SFE_LEVEL_INTEREST CONSTANT VARCHAR2(8) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_INTEREST;
   G_SFE_LEVEL_PRINCIPAL CONSTANT VARCHAR2(9) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_PRINCIPAL;
   G_SFE_LEVEL_FUNDING CONSTANT VARCHAR2(7) := Okl_Create_Streams_Pvt.G_SFE_LEVEL_FUNDING;
   --Added by kthiruva on 12-Sep-2005 for Variable Rate Project
   --Bug -Start of Changes
   G_BALANCE_RATE              CONSTANT VARCHAR2(20) := Okl_Create_Streams_Pvt.G_BALANCE_RATE;
   G_BALANCE_PAYMENT           CONSTANT VARCHAR2(20) := Okl_Create_Streams_Pvt.G_BALANCE_PAYMENT;
   G_BALANCE_TERM              CONSTANT VARCHAR2(20) := Okl_Create_Streams_Pvt.G_BALANCE_TERM;
   G_BALANCE_FUNDING           CONSTANT VARCHAR2(20) := Okl_Create_Streams_Pvt.G_BALANCE_FUNDING;
   --Bug - End of Changes


  ---------------------------------------------------------------------------
  -- PRCODURE  CONVERT_DATE
  ---------------------------------------------------------------------------
  PROCEDURE CONVERT_DATE(p_date            IN     DATE,
                         p_date_format     IN     VARCHAR2,
                         x_char_date       OUT NOCOPY    VARCHAR2);

  PROCEDURE TRANSLATE_COUNTRY(p_country IN VARCHAR2,
                              x_country OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_IRS_TAX_TREATMENT(p_irs_tax_treatment IN VARCHAR2,
                                        x_irs_tax_treatment OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_FASB_TREATMENT(p_fasb_treatment IN VARCHAR2,
					p_rvi_yn IN VARCHAR2,
                                        x_fasb_treatment OUT NOCOPY VARCHAR2);

  --Added by dkagrawa on 6-Oct-2005 .Introducing overloaded method
  --Bug 4654549 - Start of Changes
  PROCEDURE TRANSLATE_FASB_TREATMENT(p_fasb_treatment IN VARCHAR2,
                                     x_fasb_treatment OUT NOCOPY VARCHAR2);
  --Bug 4654549 - End of Changes

  PROCEDURE TRANSLATE_PURCHASE_OPTION(p_purchase_option IN VARCHAR2,
                                      x_purchase_option OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_DEPRECIATION_METHOD(p_depreciation_method IN VARCHAR2,
                                          x_depreciation_method OUT NOCOPY VARCHAR2,
					  p_term IN NUMBER,
   				          x_term OUT NOCOPY VARCHAR2,
					  p_salvage IN NUMBER,
					  x_salvage OUT NOCOPY NUMBER,
					  p_adr_convention IN VARCHAR2,
					  x_adr_convention OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_DEPRE_ADRCONVENTION(p_depreciation_adrconvention IN VARCHAR2,
                                                 x_depreciation_adrconvention OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_YN(p_yn IN VARCHAR2,
                         x_yn OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_PERIODICITY(p_periodicity IN VARCHAR2,
                                  x_periodicity OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_STRUCTURE(p_structure IN VARCHAR2,
                                  x_structure OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_sfe_type IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2,
	                          x_stream_type_desc OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_sfe_type IN VARCHAR2,
								  p_sil_type IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2,
	                              x_stream_type_desc OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_ADVANCE_ARREARS(p_advance_arrears IN VARCHAR2,
                                      x_advance_arrears OUT NOCOPY VARCHAR2);


  PROCEDURE TRANSLATE_INCOME_EXPENSE(p_income_expense IN VARCHAR2,
                                     x_income_expense OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_PERCENTAGE(p_percentage IN NUMBER,
                                 x_ratio      OUT NOCOPY VARCHAR2);

  PROCEDURE REVERSE_TRANSLATE_STREAM_TYPE(p_stream_type_name IN VARCHAR2,
                                  p_stream_type_desc IN VARCHAR2,
                                  x_stream_type_name OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_LOCK_LEVEL_STEP(p_lock_level_step IN VARCHAR2,
                                      x_lock_amount OUT NOCOPY VARCHAR2,
                                      x_lock_rate OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_MODE(p_mode IN VARCHAR2,
                           x_mode OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_FEE_LEVEL_TYPE(p_fee_level_type IN VARCHAR2,
                                     x_fee_level_type OUT NOCOPY VARCHAR2);

  PROCEDURE REVERSE_TRANSLATE_YN(p_yn IN VARCHAR2,
                                 x_yn OUT NOCOPY VARCHAR2);

  PROCEDURE REVERSE_TRANSLATE_PERIODICITY(p_periodicity IN VARCHAR2,
                                  x_periodicity OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_NEPA(p_nominal_yn IN VARCHAR2,
                           p_pre_tax_yn IN VARCHAR2,
                           x_nepa OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_LOCK_LEVEL_LNSTEP(p_level_type IN VARCHAR2,
                                         p_lock_level_step IN VARCHAR2,
					 x_lock_amount OUT NOCOPY VARCHAR2,
                                         x_lock_rate OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_SIY_TYPE(p_siy_type IN VARCHAR2,
                                     x_siy_type OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_GUARANTEE_TYPE(p_guarantee_type IN VARCHAR2,
                                     x_guarantee_type OUT NOCOPY VARCHAR2);

  PROCEDURE TRANSLATE_STATISTIC_INDEX(p_target_type IN VARCHAR2,
                                      p_statistic_index IN VARCHAR2,
                                      x_statistic_index OUT NOCOPY VARCHAR2);

  --new procedure added to determine mode.

  PROCEDURE GET_MODE(p_transaction_number IN NUMBER,
                     x_mode OUT NOCOPY VARCHAR2);


 --New Procedure Added to FundingAndRate.

 PROCEDURE SET_FUNDINGANDRATE (p_transaction_number In NUMBER,
                               p_fee_index In NUMBER,
  		               x_FundingAndRate out NOCOPY VARCHAR2);

  --Added by kthiruva on 12-Sep-2005 for Variable Rate Project
  --Bug 4615187 -Start of Changes
  PROCEDURE GET_BALANCE_METHOD(p_transaction_number IN NUMBER,
                               x_balance_method OUT NOCOPY VARCHAR2);

  PROCEDURE CONVERT_DATE_RESTRUCT(p_date            IN     DATE,
                         p_date_format     IN     VARCHAR2,
                         p_type            IN     VARCHAR2,
                         p_periodicity     IN     VARCHAR2,
                         x_char_date       OUT NOCOPY    VARCHAR2);
  --Bug 4615187  - End of Changes

 -- gboomina BUG#4036384 procedure to set the description for fee with purpose
 --code as RVI
    PROCEDURE SET_RVI_FEE_DESCRIPTION(p_kle_id IN NUMBER,
                                      p_description IN VARCHAR2,
                                      x_description OUT NOCOPY VARCHAR2);
  --Added by kthiruva on 11-Nov-2005 for the VR Build
  --Bug 4726209 - Start of Changes
  PROCEDURE REVERSE_TRANSLATE_ADV_OR_ARR (p_yn IN VARCHAR2,
                                          x_yn OUT NOCOPY VARCHAR2);
  --Bug 4726209 - End of Changes

  --Added by kthiruva on 19-Apr-2006 to determine if a Paydown has been made on a contract
  --Bug 5161075 - Start of Changes
  PROCEDURE IS_PPD_AVAILABLE(p_trx_number IN NUMBER,
                             x_yn OUT NOCOPY VARCHAR2);
  --Bug 5161075 - End of Changes

  --Added by rbanerje on 03-Oct-2008 to return the decimal separator in the number format
  --Bug 6085025 - Start of Changes
  PROCEDURE get_decimal_separator( x_seperator OUT NOCOPY VARCHAR2 );
  --Bug 6085025 - End of Changes

END Okl_St_Code_Conversions;

/
