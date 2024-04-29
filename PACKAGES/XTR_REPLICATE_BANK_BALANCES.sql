--------------------------------------------------------
--  DDL for Package XTR_REPLICATE_BANK_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_REPLICATE_BANK_BALANCES" AUTHID CURRENT_USER AS
/* |  $Header: xtrbbals.pls 120.4 2005/07/25 09:53:52 eaggarwa noship $ | */
--
-- To replicate the data from CE tables to xtr_bank_balances table
--
--
-- Purpose: This package will insert/delete/update the bank balances
--  from CE tables to the xtr_bank_balances table.

-- replicate_bank_account is the main procedure through which the
-- insert/delete/update procedures will be called.
--
--  -- MODIFICATION HISTORY
-- Person             Date                Comments
-- Eakta Aggarwal    19-May-2005           Created
-- ---------          ------          ----------------------------------


   PROCEDURE REPLICATE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%rowtype,
       p_action_flag IN varchar2,
       x_return_status   	OUT NOCOPY  VARCHAR2,
       x_msg_count			OUT NOCOPY 	NUMBER,
       x_msg_data			OUT NOCOPY 	VARCHAR2);

  PROCEDURE REPLICATE_BANK_BALANCE
     ( p_ce_bank_account_balance_id	IN	XTR_BANK_BALANCES.ce_bank_account_balance_id%TYPE,
       p_company_code	IN	XTR_BANK_BALANCES.company_code%TYPE,
       p_account_number	IN	XTR_BANK_BALANCES.account_number%TYPE,
       p_balance_date	IN	XTR_BANK_BALANCES.balance_date%TYPE,
       p_ledger_balance	IN	CE_BANK_ACCT_BALANCES.ledger_balance%TYPE,
       p_available_balance	IN	CE_BANK_ACCT_BALANCES.available_balance%TYPE,
       p_interest_calculated_balance	IN	CE_BANK_ACCT_BALANCES.value_dated_balance%TYPE,
       p_one_day_float	IN	XTR_BANK_BALANCES.one_day_float%TYPE,
       p_two_day_float	IN	XTR_BANK_BALANCES.two_day_float%TYPE,
       p_action_flag IN varchar2,
       x_return_status   	OUT NOCOPY  VARCHAR2,
       x_msg_count			OUT NOCOPY 	NUMBER,
       x_msg_data			OUT NOCOPY 	VARCHAR2);


   PROCEDURE INSERT_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%rowtype,
       x_return_status   	 In	OUT NOCOPY  	VARCHAR2
       );

   PROCEDURE UPDATE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%rowtype,
       x_return_status   	 IN	OUT NOCOPY  	VARCHAR2
       );

   PROCEDURE DELETE_BANK_BALANCE
     ( p_balance_rec IN xtr_bank_balances%rowtype,
       x_return_status       IN OUT NOCOPY  	VARCHAR2
      );


   PROCEDURE VALIDATE_BANK_BALANCE
     ( p_company_code IN xtr_bank_balances.company_code%TYPE,
       p_account_number IN xtr_bank_balances.account_number%TYPE,
       p_balance_date IN xtr_bank_balances.balance_date%TYPE,
       p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null,
       p_interest_calc_balance IN NUMBER,
       p_available_balance in NUMBER,
       p_action_flag IN VARCHAR2,
       x_return_status   		OUT NOCOPY  	VARCHAR2
      );

  PROCEDURE VALIDATE_BANK_BALANCE
     ( p_company_code IN xtr_bank_balances.company_code%TYPE,
       p_account_number IN xtr_bank_balances.account_number%TYPE,
       p_balance_date IN xtr_bank_balances.balance_date%TYPE,
       p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null,
       p_interest_calc_balance IN NUMBER,
       p_available_balance in NUMBER,
       p_action_flag IN VARCHAR2,
       x_return_status   		OUT NOCOPY  	VARCHAR2,
       x_msg_count			OUT NOCOPY 	NUMBER,
       x_msg_data			OUT NOCOPY 	VARCHAR2);

   PROCEDURE LOG_ERR_MSG
      ( p_error_code    IN  VARCHAR2,
        p_field_name    IN  VARCHAR2 default null,
        p_balance_date  IN  xtr_bank_balances.balance_date%type  DEFAULT NULL
       );

   FUNCTION   CHK_REVAL ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                        , p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null
                        , p_balance_cflow IN xtr_bank_balances.balance_cflow%TYPE
                        , p_action_flag IN VARCHAR2
                        , p_val_type IN VARCHAR2 )
                        RETURN VARCHAR2;


  FUNCTION CHK_ACCRUAL ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                        , p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null
                        , p_interest_calc_balance IN NUMBER
                        , p_action_flag IN VARCHAR2
                        , p_val_type IN VARCHAR2)
                        RETURN VARCHAR2;

FUNCTION CHK_ACCRUAL_ON_RENDER
                       ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return boolean;


FUNCTION CHK_REVAL_ON_RENDER
                       ( p_company_code IN xtr_bank_balances.company_code%TYPE
                        , p_account_number IN xtr_bank_balances.account_number%TYPE
                        , p_currency IN xtr_bank_accounts.currency%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return boolean;


FUNCTION CHK_ACCRUAL_ON_RENDER
                       (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return VARCHAR2;



FUNCTION CHK_REVAL_ON_RENDER
                       (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                        , p_balance_date IN xtr_bank_balances.balance_date%TYPE
                       )return VARCHAR2;




FUNCTION CHK_ROUNDING_CHANGE ( p_company_code IN xtr_bank_balances.company_code%TYPE,
                               p_account_number IN xtr_bank_balances.account_number%TYPE,
                               p_balance_date IN xtr_bank_balances.balance_date%TYPE) RETURN BOOLEAN ;

FUNCTION  CHK_ACCRUAL_INT (
              p_party_code xtr_bank_accounts.party_code%type
             ,p_account_number xtr_bank_accounts.account_number%type
              )RETURN varchar2;


FUNCTION CHK_INT_OVERRIDE (
            p_party_code xtr_bank_accounts.party_code%type
           ,p_account_number xtr_bank_accounts.account_number%type
           ,p_oldest_date DATE
           ) RETURN VARCHAR2;


PROCEDURE UPDATE_ROUNDING_DAYCOUNT
                   (p_ce_bank_account_id xtr_bank_accounts.ce_bank_account_id%TYPE
                    ,p_rounding_type  xtr_bank_accounts.rounding_type%TYPE
                    ,p_day_count_type xtr_bank_accounts.day_count_type%TYPE
                    ,x_return_status  OUT NOCOPY 	VARCHAR2
                    );


PROCEDURE UPDATE_BANK_ACCOUNT
     ( p_company_code IN xtr_bank_balances.company_code%TYPE,
       p_account_number IN xtr_bank_balances.account_number%TYPE,
       p_balance_date IN xtr_bank_balances.balance_date%TYPE,
       p_action_flag IN VARCHAR2,
       x_return_status   		OUT NOCOPY  	VARCHAR2
       );



FUNCTION CHK_INTEREST_SETTLED
        (  p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
           , p_balance_date IN xtr_bank_balances.balance_date%TYPE
        )return VARCHAR2;

PROCEDURE CHK_ACCRUAL_REVAL_WARNINGS
                   (p_ce_bank_account_id IN xtr_bank_accounts.ce_bank_account_id%TYPE
                    ,p_balance_date IN xtr_bank_balances.balance_date%TYPE
                    ,p_ce_bank_account_balance_id IN xtr_bank_balances.ce_bank_account_balance_id%TYPE default null
                    ,p_interest_calc_balance IN NUMBER
                    ,p_balance_cflow IN xtr_bank_balances.balance_cflow%TYPE
                    ,p_action_flag IN VARCHAR2
                    ,x_return_status  OUT NOCOPY 	VARCHAR2
                    ,x_msg_count  OUT NOCOPY 	NUMBER
                    ,x_msg_data	 OUT NOCOPY 	VARCHAR2 );

END XTR_REPLICATE_BANK_BALANCES; -- Package spec


 

/
