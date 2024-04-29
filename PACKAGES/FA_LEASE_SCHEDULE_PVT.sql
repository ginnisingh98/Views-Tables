--------------------------------------------------------
--  DDL for Package FA_LEASE_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LEASE_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVLSCS.pls 120.2.12010000.2 2009/07/19 11:26:09 glchen ship $ */
--
-- API name             : FA_LEASE_SCHEDULE_PVT
-- Type	                : Public
-- Pre-reqs             : None.
-- Function/Procedure   : These Functions/Procedures will be used to support
--                        public API's
--
	----------------------------------------------------
	-- CHECK FOR PAYMENT SCHEDULE NAME
	----------------------------------------------------
	FUNCTION CHECK_PAYMENT_SCHEDULE (
  	 P_PAYMENT_SCHEDULE_NAME    IN     FA_LEASE_SCHEDULES.PAYMENT_SCHEDULE_NAME%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	----------------------------------------------------
	-- CHECK FOR CURRENCY CODE
	----------------------------------------------------
	FUNCTION CHECK_CURRENCY_CODE(
   	P_CURRENCY_CODE			IN     FA_LEASE_SCHEDULES.CURRENCY_CODE%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;

	----------------------------------------------------
	-- CHECK FOR LEASE FREQUENCY
	----------------------------------------------------
	FUNCTION CHECK_LEASE_FREQUENCY(
   	P_FREQUENCY 			IN     FA_LEASE_SCHEDULES.FREQUENCY%TYPE
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null
	) RETURN BOOLEAN;


	----------------------------------------------------
	-- CHECK FOR START DATE
	----------------------------------------------------
	FUNCTION CHECK_START_DATE (
   	P_LEASE_PAYMENTS_TBL 		IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE,
   	P_LEASE_INCEPTION_DATE 		IN 	 DATE,
   	P_MONTHS_PER_PERIOD		IN	 NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	----------------------------------------------------
	-- CHECK FOR PAYMENT AMOUNT
	----------------------------------------------------
	FUNCTION   CHECK_PAYMENT_AMOUNT(
	P_LEASE_PAYMENTS_TBL 		IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	----------------------------------------------------
	-- CHECK FOR NUMBER OF PAYMENTS
	----------------------------------------------------
	FUNCTION   CHECK_NO_OF_PAYMENTS (
	P_LEASE_PAYMENTS_TBL 		IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	----------------------------------------------------
	-- CHECK FOR LEASE PAYMENT TYPE
	----------------------------------------------------
	FUNCTION   CHECK_PERIODS (
	P_LEASE_PAYMENTS_TBL 		IN     FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

	----------------------------------------------------
	-- CALCULATE END DATE
	----------------------------------------------------
	FUNCTION CALC_END_DATE (
	P_NUMBER_OF_PAYMENTS 		IN 	NUMBER,
	P_MONTHS_PER_PERIOD 		IN 	NUMBER,
	P_START_DATE 			IN 	DATE
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN DATE;

	----------------------------------------------------
	-- VALIDATE SCHEDULE ID
	----------------------------------------------------
	FUNCTION VALIDATE_SCHEDULE_ID (
	P_PAYMENT_SCHEDULE_ID 		IN 	NUMBER,
	X_MONTHS_PER_PERIOD 		OUT NOCOPY NUMBER,
	X_CURRENCY_PRECISION 		OUT NOCOPY NUMBER,
	X_PERIODS_PER_YEAR 		OUT NOCOPY NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  RETURN BOOLEAN;

	----------------------------------------------------
	-- CALCULATE INTEREST
	----------------------------------------------------
	FUNCTION CALCULATE_INTEREST (
	P_PRINCIPAL 			IN 	NUMBER,
	P_RATE_PER_PERIOD 		IN 	NUMBER,
	P_NUM_PERIODS 			IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO MINIMUM OF TWO NUMBERS
	----------------------------------------------------
	FUNCTION AMINIMUM2(
	P_X 				IN 	NUMBER,
	P_Y 				IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO MINIMUM OF THREE NUMBERS
	----------------------------------------------------
	FUNCTION AMINIMUM3(
	P_X 				IN 	NUMBER,
	P_Y 				IN 	NUMBER,
	P_Z 				IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO LUMP SUM CALCULATIONS
	----------------------------------------------------
	FUNCTION LUMP_SUM(
	P_PAYMENT_AMOUNT 		IN 	NUMBER,
	P_NUMBER_PAYMENTS 		IN 	NUMBER,
	P_INTEREST_RATE 		IN 	NUMBER,
	P_CURRENCY_PRECISION  		IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO ORDINARY ANNUITY CALCULATIONS
	----------------------------------------------------
	FUNCTION ORDINARY_ANNUITY(
	P_PAYMENT_AMOUNT		IN 	NUMBER,
	P_NUMBER_PAYMENTS			IN 	NUMBER,
        P_INTEREST_RATE			IN 	NUMBER,
	P_CURRENCY_PRECISION  		IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO ANNUITY DUE CALCULATIONS
	----------------------------------------------------
	FUNCTION ANNUITY_DUE(
	P_PAYMENT_AMOUNT	 	IN 	NUMBER,
	P_NUMBER_PAYMENTS		IN 	NUMBER,
	P_INTEREST_RATE			IN 	NUMBER,
	P_CURRENCY_PRECISION  		IN 	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN NUMBER;

	----------------------------------------------------
	-- DO PRESENT VALUE CALCULATIONS
	----------------------------------------------------
	PROCEDURE PRESENT_VALUE_CALC(
	P_PAYMENT_SCHEDULE_ID 		IN 	NUMBER,
	P_MONTHS_PER_PERIOD 		IN 	NUMBER,
	P_INTEREST_PER_PERIOD 		IN 	NUMBER,
	P_CURRENCY_PRECISION 		IN 	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

	----------------------------------------------------
	-- VALIDATE PAYMENT DETAILS
	----------------------------------------------------
      	FUNCTION VALIDATE_PAYMENTS (
   	PX_LEASE_SCHEDULES_REC     	IN OUT NOCOPY FA_API_TYPES.LEASE_SCHEDULES_REC_TYPE,
   	P_LEASE_PAYMENTS_TBL       	IN      FA_API_TYPES.LEASE_PAYMENTS_TBL_TYPE,
	P_MONTHS_PER_PERIOD		   OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
	RETURN BOOLEAN;

	----------------------------------------------------
	-- AMORTIZE CALCULATIONS
	----------------------------------------------------
      	FUNCTION AMORTIZE(
	P_PAYMENT_SCHEDULE_ID    	IN 	NUMBER,
	P_TRANS_REC		      	IN      FA_API_TYPES.TRANS_REC_TYPE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
	RETURN BOOLEAN;
END FA_LEASE_SCHEDULE_PVT;

/
