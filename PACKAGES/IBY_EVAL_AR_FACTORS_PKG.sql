--------------------------------------------------------
--  DDL for Package IBY_EVAL_AR_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EVAL_AR_FACTORS_PKG" AUTHID CURRENT_USER AS
/*$Header: ibyevars.pls 115.4 2002/11/18 22:26:43 jleybovi ship $*/

/*
** Procedure: eval_TrxnCreditLimit
** Purpose: Evaluates the risk associated with Transaction Credit
**          Limit risk factor.
**          The transaction amount will be passed into this routine
**          along with the account number. Compare the
**          transaction credit limit set for this account with the
**          transaction amount and return the risk score.
*/

procedure eval_TrxnCreditLimit(i_acctnumber in varchar2,
                          i_amount in number,
                          i_currency_code in varchar2,
                          i_payeeid in varchar2,
                          o_risk_score out nocopy number);

/*
** Procedure: eval_OverallCreditLimit
** Purpose: Evaluates the risk associated with Overall Credit Limit risk factor.
**          The  accountnumber will be passed into this routine
**          Based on the account number get the associated Overall Credit Limit
**          and compare it with the overall balance .
**          Overall Balance is the amount due remaining for all the open
**          transactions of that account
*/

Procedure eval_OverallCreditLimit(i_accountnumber in varchar2,
                                  i_amount in number,
                                  i_currency_code in varchar2,
                                  i_payeeid in varchar2,
                       		  o_risk_score out nocopy number);



/*
** Procedure: eval_CreditRatingCode
** Purpose: Evaluates the risk associated with CreditRating Code risk factor.
**          The accountnumber will be passed into this routine
**          Based on the account number get the associated creditrating code
**          and compare the creditrating code with the creditratingcode mapping
**          stored in iby_mappings and return the appropriate risk score.
*/

Procedure eval_CreditRatingCode(i_accountnumber in varchar2,
                       i_payeeid in varchar2,
                       o_risk_score out nocopy number);

/*
** Procedure: eval_RiskCode
** Purpose: Evaluates the risk associated with Risk Code risk factor.
**          The  ccountnumber will be passed into this routine
**          Based on the account number get the associated risk code
**          and compare the riskcode with the riskcode mapping
**          stored in iby_mappings and return the appropriate risk score.
*/

procedure eval_RiskCode(i_accountnumber in varchar2,
                       i_payeeid in varchar2,
                       o_risk_score out nocopy number);
end iby_eval_ar_factors_pkg;

 

/
