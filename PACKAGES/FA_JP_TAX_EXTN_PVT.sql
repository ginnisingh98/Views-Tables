--------------------------------------------------------
--  DDL for Package FA_JP_TAX_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_JP_TAX_EXTN_PVT" AUTHID CURRENT_USER
/* $Header: FAVJPEXTS.pls 120.2.12010000.1 2009/07/21 12:37:42 glchen noship $   */
AS

  TYPE tp_whatif IS RECORD
		(REQUEST_ID              NUMBER,
		  BOOK_TYPE_CODE          VARCHAR2(15),
		  ASSET_ID                NUMBER,
		  ASSET_NUMBER            VARCHAR2(15),
		  DESCRIPTION             VARCHAR2(80),
		  TAG_NUMBER              VARCHAR2(15),
		  SERIAL_NUMBER           VARCHAR2(35),
		  PERIOD_NAME             VARCHAR2(15),
		  period_counter		  NUMBER,
		  FISCAL_YEAR             NUMBER(4),
		  EXPENSE_ACCT            VARCHAR2(500),
		  LOCATION                VARCHAR2(500),
		  UNITS                   NUMBER,
		  EMPLOYEE_NAME           VARCHAR2(240),
		  EMPLOYEE_NUMBER         VARCHAR2(30),
		  ASSET_KEY               VARCHAR2(500),
		  CURRENT_COST            NUMBER,
		  CURRENT_PRORATE_CONV    VARCHAR2(15),
		  CURRENT_METHOD          VARCHAR2(15),
		  CURRENT_LIFE            NUMBER,
		  CURRENT_BASIC_RATE      NUMBER,
		  CURRENT_ADJUSTED_RATE   NUMBER,
		  CURRENT_SALVAGE_VALUE   NUMBER,
		  DEPRECIATION            NUMBER,
		  NEW_DEPRECIATION        NUMBER,
		  CREATED_BY              NUMBER,
		  CREATION_DATE           DATE,
		  LAST_UPDATE_DATE        DATE,
		  LAST_UPDATED_BY         NUMBER,
		  LAST_UPDATE_LOGIN       NUMBER,
		  DATE_PLACED_IN_SERVICE  DATE,
		  CATEGORY                VARCHAR2(500),
		  ACCUMULATED_DEPRN       NUMBER,
		  BONUS_DEPRECIATION      NUMBER,
		  NEW_BONUS_DEPRECIATION  NUMBER,
		  CURRENT_BONUS_RULE      VARCHAR2(30),
		  PERIOD_NUM              NUMBER(9),
		  CURRENCY_CODE           VARCHAR2(15)
		);
  TYPE tp_whatitf IS TABLE OF tp_whatif
      INDEX BY BINARY_INTEGER;

 lt_whatitf      		tp_whatitf;

 PROCEDURE deprn_main (  x_errbuf                     OUT NOCOPY VARCHAR2
                        ,x_retcode                    OUT NOCOPY NUMBER
                        ,p_request_id                 IN  NUMBER
                        ,p_book_type_code             IN  fa_books.book_type_code%TYPE
                        ,p_first_begin_period         IN  VARCHAR2
                        ,p_number_of_periods          IN  NUMBER
                        ,p_start_period               IN  VARCHAR2
                        ,p_checkbox_check             IN  VARCHAR2
                        ,p_full_rsrv_checkbox         IN  VARCHAR2
						,p_asset_id					  IN  NUMBER
                        );

 PROCEDURE calc_jp250db (X_request_id NUMBER,
										   X_asset_id NUMBER,
										   X_book VARCHAR2,
										   X_method VARCHAR2,
										   X_cost NUMBER,
										   x_cur_cost NUMBER,
										   X_life NUMBER,
										   X_rate_in_use	NUMBER,
										   X_deprn_lmt	NUMBER,
										   X_start_prd VARCHAR2,
										   X_dtin_serv VARCHAR2,
										   X_num_per NUMBER);

 FUNCTION chk_period(X_period VARCHAR2, X_book_type VARCHAR2)
	RETURN NUMBER;

 FUNCTION ret_counter (X_book_typ VARCHAR2, X_periodname VARCHAR2)
		RETURN VARCHAR2;

END FA_JP_TAX_EXTN_PVT;

/
