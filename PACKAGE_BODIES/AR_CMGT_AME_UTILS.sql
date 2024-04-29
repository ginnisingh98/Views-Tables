--------------------------------------------------------
--  DDL for Package Body AR_CMGT_AME_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_AME_UTILS" as
 /* $Header: ARCMGAUB.pls 120.0 2005/08/24 21:11:24 bsarkar noship $  */

FUNCTION  get_credit_limit ( transactionIdIn    IN      NUMBER)
        return NUMBER AS
        l_credit_limit          NUMBER;
BEGIN
    SELECT recommendation_value2
    INTO   l_credit_limit
    FROM   ar_cmgt_cf_recommends
    WHERE  case_folder_id = transactionIdIn
    AND    credit_recommendation = 'CREDIT_LIMIT';

    return(l_credit_limit);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;

FUNCTION  get_txn_credit_limit ( transactionIdIn    IN      NUMBER)
        return NUMBER AS
        l_credit_limit          NUMBER;
BEGIN
    SELECT recommendation_value2
    INTO   l_credit_limit
    FROM   ar_cmgt_cf_recommends
    WHERE  case_folder_id = transactionIdIn
    AND    credit_recommendation = 'TXN_CREDIT_LIMIT';

    return(l_credit_limit);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;

FUNCTION  get_score ( transactionIdIn    IN      NUMBER)
        return NUMBER AS
        l_score          NUMBER;
BEGIN
    SELECT SUM(SCORE)
    INTO   l_score
    FROM   ar_cmgt_cf_dtls
    WHERE  case_folder_id = transactionIdIn;

    return(l_score);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;

FUNCTION  get_credit_classification ( transactionIdIn    IN      NUMBER)
        return VARCHAR2 AS
        l_credit_classification          VARCHAR2(30);
BEGIN
    SELECT recommendation_value1
    INTO   l_credit_classification
    FROM   ar_cmgt_cf_recommends
    WHERE  case_folder_id = transactionIdIn
    AND    credit_recommendation = 'CLASSIFICATION';

    return(l_credit_classification);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;


FUNCTION  get_credit_limit_currency ( transactionIdIn    IN      NUMBER)
        return VARCHAR2 AS
        l_credit_currency          ar_cmgt_case_folders.limit_currency%type;
BEGIN
    SELECT limit_currency
    INTO   l_credit_currency
    FROM   ar_cmgt_case_folders
    WHERE  case_folder_id = transactionIdIn;


    return(l_credit_currency);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;

FUNCTION  get_exchange_rate_type ( transactionIdIn    IN      NUMBER)
        return VARCHAR2 AS
        l_exchange_rate_type         ar_cmgt_case_folders.exchange_rate_type%type;
BEGIN
    SELECT exchange_rate_type
    INTO   l_exchange_rate_type
    FROM   ar_cmgt_case_folders
    WHERE  case_folder_id = transactionIdIn;

    return(l_exchange_rate_type);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return(null);
        WHEN OTHERS THEN
            return(null);

END;

FUNCTION  get_amount_requested ( transactionIdIn    IN      NUMBER)
        return NUMBER AS
        l_amount_requested         ar_cmgt_credit_requests.limit_amount%type;
BEGIN
    select nvl(a.limit_amount,a.trx_amount)
    into   l_amount_requested
    from ar_cmgt_credit_requests a,
         ar_cmgt_case_folders b
    WHERE b.case_folder_id = transactionIdIn
    AND   a.credit_request_id = b.credit_request_id
    AND   b.type = 'CASE';

    return(l_amount_requested);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            return (null);
        WHEN OTHERS THEN
            return(null);

END;

END ar_cmgt_ame_utils;

/
