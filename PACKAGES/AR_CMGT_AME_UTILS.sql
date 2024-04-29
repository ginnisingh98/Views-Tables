--------------------------------------------------------
--  DDL for Package AR_CMGT_AME_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_AME_UTILS" AUTHID CURRENT_USER as
 /* $Header: ARCMGAUS.pls 120.0 2005/08/24 21:11:09 bsarkar noship $  */

FUNCTION  get_credit_limit ( transactionIdIn    IN      NUMBER)
        return NUMBER;
FUNCTION  get_txn_credit_limit ( transactionIdIn    IN      NUMBER)
        return NUMBER;

FUNCTION  get_credit_limit_currency ( transactionIdIn    IN      NUMBER)
        return VARCHAR2;

FUNCTION  get_exchange_rate_type ( transactionIdIn    IN      NUMBER)
        return VARCHAR2;

FUNCTION get_credit_classification ( transactionIdIn    IN      NUMBER)
        return VARCHAR2;
FUNCTION get_score ( transactionIdIn    IN      NUMBER)
        return NUMBER;

FUNCTION  get_amount_requested ( transactionIdIn    IN      NUMBER)
        return NUMBER;

END ar_cmgt_ame_utils;

 

/
