--------------------------------------------------------
--  DDL for Package OKL_LIKE_KIND_EXCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LIKE_KIND_EXCHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLKXS.pls 115.2 2002/07/12 19:29:11 sgiyer noship $ */

  TYPE rep_asset_rec_type IS RECORD (
       REP_ASSET_ID                  NUMBER,
       REP_ASSET_NUMBER              VARCHAR2(2000),
       BOOK_TYPE_CODE                VARCHAR2(2000),
       ASSET_CATEGORY_ID             NUMBER,
       ORIGINAL_COST                 NUMBER,
       CURRENT_COST                  NUMBER,
       DATE_PLACED_IN_SERVICE        DATE,
       DEPRN_METHOD                  VARCHAR2(2000),
       LIFE_IN_MONTHS                NUMBER);

  TYPE req_asset_rec_type IS RECORD (
  	   REQ_ASSET_ID                   NUMBER,
       REQ_ASSET_NUMBER               VARCHAR2(2000),
       BOOK_TYPE_CODE                 VARCHAR2(2000),
       ASSET_CATEGORY_ID              NUMBER,
       ORIGINAL_COST                  NUMBER,
       DATE_RETIRED                   DATE,
       PROCEEDS_OF_SALE               NUMBER,
       GAIN_LOSS_AMOUNT               NUMBER,
       BALANCE_SALE_PROCEEDS          NUMBER,
       BALANCE_GAIN_LOSS              NUMBER,
	   MATCH_AMOUNT                   NUMBER);

  TYPE asset_details_rec_type IS RECORD (
  	   ASSET_ID                       OKL_LIKE_KIND_EXCHANGE_V.ASSET_ID%TYPE,
	   ASSET_NUMBER                   OKL_LIKE_KIND_EXCHANGE_V.ASSET_NUMBER%TYPE,
	   BOOK_TYPE_CODE                 OKL_LIKE_KIND_EXCHANGE_V.BOOK_TYPE_CODE%TYPE,
	   BOOK_CLASS                     OKL_LIKE_KIND_EXCHANGE_V.BOOK_CLASS%TYPE,
       ORG_ID                         OKL_LIKE_KIND_EXCHANGE_V.ORG_ID%TYPE,
	   SET_OF_BOOKS_ID                OKL_LIKE_KIND_EXCHANGE_V.SET_OF_BOOKS_ID%TYPE,
	   DATE_PLACED_IN_SERVICE         OKL_LIKE_KIND_EXCHANGE_V.DATE_PLACED_IN_SERVICE%TYPE,
	   DESCRIPTION                    OKL_LIKE_KIND_EXCHANGE_V.DESCRIPTION%TYPE,
	   TAG_NUMBER                     OKL_LIKE_KIND_EXCHANGE_V.TAG_NUMBER%TYPE,
	   SERIAL_NUMBER                  OKL_LIKE_KIND_EXCHANGE_V.SERIAL_NUMBER%TYPE,
	   ASSET_KEY_CCID                 OKL_LIKE_KIND_EXCHANGE_V.ASSET_KEY_CCID%TYPE,
	   PARENT_ASSET_ID                OKL_LIKE_KIND_EXCHANGE_V.PARENT_ASSET_ID%TYPE,
	   MANUFACTURER_NAME              OKL_LIKE_KIND_EXCHANGE_V.MANUFACTURER_NAME%TYPE,
	   MODEL_NUMBER                   OKL_LIKE_KIND_EXCHANGE_V.MODEL_NUMBER%TYPE,
	   LEASE_ID                       OKL_LIKE_KIND_EXCHANGE_V.LEASE_ID%TYPE,
	   IN_USE_FLAG                    OKL_LIKE_KIND_EXCHANGE_V.IN_USE_FLAG%TYPE,
	   INVENTORIAL                    OKL_LIKE_KIND_EXCHANGE_V.INVENTORIAL%TYPE,
	   PROPERTY_TYPE_CODE             OKL_LIKE_KIND_EXCHANGE_V.PROPERTY_TYPE_CODE%TYPE,
	   PROPERTY_1245_1250_CODE        OKL_LIKE_KIND_EXCHANGE_V.PROPERTY_1245_1250_CODE%TYPE,
	   OWNED_LEASED                   OKL_LIKE_KIND_EXCHANGE_V.OWNED_LEASED%TYPE,
	   NEW_USED                       OKL_LIKE_KIND_EXCHANGE_V.NEW_USED%TYPE,
	   CURRENT_UNITS                  OKL_LIKE_KIND_EXCHANGE_V.CURRENT_UNITS%TYPE,
	   ASSET_TYPE                     OKL_LIKE_KIND_EXCHANGE_V.ASSET_TYPE%TYPE,
	   ASSET_CATEGORY_ID              OKL_LIKE_KIND_EXCHANGE_V.ASSET_CATEGORY_ID%TYPE,
	   DEPRN_METHOD_CODE              OKL_LIKE_KIND_EXCHANGE_V.DEPRN_METHOD_CODE%TYPE,
	   LIFE_IN_MONTHS                 OKL_LIKE_KIND_EXCHANGE_V.LIFE_IN_MONTHS%TYPE,
	   COST                           OKL_LIKE_KIND_EXCHANGE_V.COST%TYPE,
	   ADJUSTED_COST                  OKL_LIKE_KIND_EXCHANGE_V.ADJUSTED_COST%TYPE,
	   ORIGINAL_COST                  OKL_LIKE_KIND_EXCHANGE_V.ORIGINAL_COST%TYPE,
	   RECOVERABLE_COST               OKL_LIKE_KIND_EXCHANGE_V.RECOVERABLE_COST%TYPE,
	   SALVAGE_VALUE                  OKL_LIKE_KIND_EXCHANGE_V.SALVAGE_VALUE%TYPE,
	   PERCENT_SALVAGE_VALUE          OKL_LIKE_KIND_EXCHANGE_V.PERCENT_SALVAGE_VALUE%TYPE,
	   PRORATE_CONVENTION_CODE        OKL_LIKE_KIND_EXCHANGE_V.PRORATE_CONVENTION_CODE%TYPE,
	   DEPRECIATE_FLAG                OKL_LIKE_KIND_EXCHANGE_V.DEPRECIATE_FLAG%TYPE,
	   ITC_AMOUNT_ID                  OKL_LIKE_KIND_EXCHANGE_V.ITC_AMOUNT_ID%TYPE,
	   BASIC_RATE                     OKL_LIKE_KIND_EXCHANGE_V.BASIC_RATE%TYPE,
	   ADJUSTED_RATE                  OKL_LIKE_KIND_EXCHANGE_V.ADJUSTED_RATE%TYPE,
	   BONUS_RULE                     OKL_LIKE_KIND_EXCHANGE_V.BONUS_RULE%TYPE,
	   CEILING_NAME                   OKL_LIKE_KIND_EXCHANGE_V.CEILING_NAME%TYPE,
	   PRODUCTION_CAPACITY            OKL_LIKE_KIND_EXCHANGE_V.PRODUCTION_CAPACITY%TYPE,
	   UNIT_OF_MEASURE                OKL_LIKE_KIND_EXCHANGE_V.UNIT_OF_MEASURE%TYPE,
	   REVAL_CEILING                  OKL_LIKE_KIND_EXCHANGE_V.REVAL_CEILING%TYPE,
	   UNREVALUED_COST                OKL_LIKE_KIND_EXCHANGE_V.UNREVALUED_COST%TYPE,
	   SHORT_FISCAL_YEAR_FLAG         OKL_LIKE_KIND_EXCHANGE_V.SHORT_FISCAL_YEAR_FLAG%TYPE,
	   CONVERSION_DATE                OKL_LIKE_KIND_EXCHANGE_V.CONVERSION_DATE%TYPE,
	   ORIGINAL_DEPRN_START_DATE      OKL_LIKE_KIND_EXCHANGE_V.ORIGINAL_DEPRN_START_DATE%TYPE,
	   GROUP_ASSET_ID                 OKL_LIKE_KIND_EXCHANGE_V.GROUP_ASSET_ID%TYPE,
	   COST_RETIRED                   OKL_LIKE_KIND_EXCHANGE_V.COST_RETIRED%TYPE,
	   UNITS_RETIRED                  OKL_LIKE_KIND_EXCHANGE_V.UNITS%TYPE,
	   NBV_RETIRED                    OKL_LIKE_KIND_EXCHANGE_V.NBV_RETIRED%TYPE,
	   GAIN_LOSS_AMOUNT               OKL_LIKE_KIND_EXCHANGE_V.GAIN_LOSS_AMOUNT%TYPE,
	   PROCEEDS_OF_SALE               OKL_LIKE_KIND_EXCHANGE_V.PROCEEDS_OF_SALE%TYPE,
	   DATE_RETIRED                   OKL_LIKE_KIND_EXCHANGE_V.DATE_RETIRED%TYPE,
	   KLE_ID                         OKL_LIKE_KIND_EXCHANGE_V.KLE_ID%TYPE);

  TYPE rep_asset_tbl_type IS TABLE OF rep_asset_rec_type INDEX BY BINARY_INTEGER;
  TYPE req_asset_tbl_type IS TABLE OF req_asset_rec_type INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------
-- Global Variables
------------------------------------------------------------------------------
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LIKE_KIND_EXCHANGE_PVT';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_NO_DATA_FOUND        CONSTANT VARCHAR2(200) := 'OKL_NOT_FOUND';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
 G_CONTRACT_NUMBER_TOKEN CONSTANT VARCHAR2(200) := 'CONTRACT_NUMBER';
 G_ADJ_TRX_TYPE_CODE        VARCHAR2(100) := 'ADJUSTMENT';
-------------------------------------------------------------------------------
--Global Messages
-------------------------------------------------------------------------------
G_FA_INVALID_BK_CAT        VARCHAR2(200) := 'OKL_LLA_FA_INVALID_BOOK_CAT';
G_FA_BOOK                  VARCHAR2(200) := 'FA_BOOK';
G_ASSET_CATEGORY           VARCHAR2(200) := 'FA_CATEGORY';
G_FA_TAX_CPY_NOT_ALLOWED   VARCHAR2(200) := 'OKL_LLA_FA_TAX_CPY_NOT_ALLOWED';
------------------------------------------------------------------------------
-- Global Exception
-------------------------------------------------------------------------------
G_EXCEPTION_HALT_VALIDATION EXCEPTION;
------------------------------------------------------------------------------

 -- Function to calculate total match amount
 FUNCTION GET_TOTAL_MATCH_AMT (p_asset_id IN NUMBER,
                                p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- Function to calculate balance sale proceeds
 FUNCTION GET_BALANCE_SALE_PROCEEDS (p_asset_id IN NUMBER,
                                    p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- Function to calculate deferred gain
 FUNCTION GET_DEFERRED_GAIN (p_asset_id IN VARCHAR2,
                            p_tax_book IN VARCHAR2) RETURN NUMBER;

 -- Procedure to create a like kind exchange transaction
 PROCEDURE CREATE_LIKE_KIND_EXCHANGE(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_corporate_book       IN  VARCHAR2
             ,p_tax_book             IN  VARCHAR2
             ,p_comments             IN  VARCHAR2
			 ,p_rep_asset_rec        IN  rep_asset_rec_type
             ,p_req_asset_tbl        IN  req_asset_tbl_type);


END OKL_LIKE_KIND_EXCHANGE_PVT;

 

/
