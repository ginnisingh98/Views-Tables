--------------------------------------------------------
--  DDL for Package IEX_COLL_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_COLL_IND" AUTHID CURRENT_USER AS
/* $Header: iexvmtis.pls 120.0 2005/05/10 20:26:47 acaraujo noship $ */
--
--System parameter record can be modified based on info required
--
TYPE curr_rec_type IS RECORD (
     set_of_books_id   ar_system_parameters.set_of_books_id%TYPE           ,
     base_currency     gl_sets_of_books.currency_code%TYPE                 ,
     base_precision    fnd_currencies.precision%type                       ,
     base_min_acc_unit fnd_currencies.minimum_accountable_unit%type        ,
     past_year_from    DATE,
     past_year_to      DATE
  );

g_curr_rec curr_rec_type;

FUNCTION GET_WTD_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_WTD_DAYS_PAID(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_WTD_DAYS_TERMS(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_AVG_DAYS_LATE(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_CEI(p_party_id IN NUMBER,
                 p_cust_account_id IN NUMBER,
                 p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_TRUE_DSO(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_CONV_DSO(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_NSF_STOP_PMT_COUNT(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_NSF_STOP_PMT_AMOUNT(p_party_id IN NUMBER,
                     p_cust_account_id IN NUMBER,
                     p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_SALES(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_DEDUCTION(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION COMP_TOT_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER;

FUNCTION COMP_REM_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER;

FUNCTION COMP_CURR_REC(p_start_date IN DATE,
                      p_end_date   IN DATE,
                      p_party_id IN NUMBER,
                      p_cust_account_id IN NUMBER,
                      p_customer_site_use_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_APPS_TOTAL(p_payment_schedule_id IN NUMBER,
                        p_to_date IN DATE) RETURN NUMBER;

FUNCTION GET_ADJ_TOTAL(p_payment_schedule_id IN NUMBER,
                       p_to_date IN DATE) RETURN NUMBER;

FUNCTION GET_ADJ_FOR_TOT_REC(p_payment_schedule_id IN NUMBER,
                             p_to_date IN DATE) RETURN NUMBER;

FUNCTION GET_CREDIT_LIMIT(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_HIGH_CREDIT_YTD(p_party_id IN NUMBER,
                   p_cust_account_id IN NUMBER,
                   p_customer_site_use_id IN NUMBER) RETURN VARCHAR2;
END;

 

/
