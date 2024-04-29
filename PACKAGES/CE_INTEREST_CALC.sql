--------------------------------------------------------
--  DDL for Package CE_INTEREST_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_INTEREST_CALC" AUTHID CURRENT_USER AS
/* $Header: ceintcas.pls 120.2 2005/08/26 20:26:57 lkwan ship $ */

--l_DEBUG varchar2(1);

FUNCTION ROUNDUP(p_amount NUMBER,
		 p_round_factor NUMBER) RETURN NUMBER;

FUNCTION get_interest_rate( p_bank_account_id IN NUMBER,
				p_balance_date   IN DATE,
				p_balance_amount IN NUMBER,
				p_interest_rate  IN OUT NOCOPY NUMBER ) RETURN NUMBER;

PROCEDURE  delete_schedule_account( p_interest_schedule_id number,
				    p_bank_account_id 	   number,
 				    p_interest_acct_type   varchar2,
				    p_cashpool_id  	   number

					);

PROCEDURE  get_balance_info(    p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER);

PROCEDURE  get_balance_pool_info(    p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER);

PROCEDURE  get_interest_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER);

PROCEDURE  get_interest_pool_info(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number,
				p_row_count OUT NOCOPY  NUMBER);

PROCEDURE  set_end_date(  p_from_date 			date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number ,
				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
				);

PROCEDURE  set_int_rate(  	p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_interest_rate		number
			);

PROCEDURE  set_range_and_rate(  p_from_date 			date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number ,
				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
				);

PROCEDURE  calculate_interest(  p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
 				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number
				);

PROCEDURE  int_cal_detail_main( p_from_date 		date,
				p_to_date 		date,
				p_interest_schedule_id 	number,
				p_bank_account_id 	number,
				p_interest_acct_type 	varchar2,
				p_cashpool_id  		number);

PROCEDURE  int_cal_xtr( p_from_date 		IN	date,
			p_to_date  		IN	date,
			p_bank_account_id  	IN	number,
			p_interest_rate   	IN      NUMBER,
			p_interest_acct_type 	IN      varchar2,
			p_interest_amount	OUT NOCOPY number);

END CE_INTEREST_CALC;

 

/
