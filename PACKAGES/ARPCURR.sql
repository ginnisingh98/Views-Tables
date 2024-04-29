--------------------------------------------------------
--  DDL for Package ARPCURR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARPCURR" AUTHID CURRENT_USER AS
/* $Header: ARPLCURS.pls 120.4.12010000.1 2008/07/24 16:50:09 appldev ship $ */

    FunctionalCurrency  fnd_currencies.currency_code%TYPE;
--
    FUNCTION CurrRound( p_amount IN NUMBER , p_currency_code IN VARCHAR2 := FunctionalCurrency ) RETURN NUMBER;
    FUNCTION ReconcileAcctdAmounts( p_ExchangeRate             IN NUMBER,
                                     p_ReconcileAmount          IN NUMBER,
                                     p_ReconcileAcctdAmount     IN NUMBER,
                                     p_ChildAmount              IN NUMBER,
                                     p_RunningTotalAmount       IN OUT NOCOPY NUMBER,
                                     p_RunningTotalAcctdAmount  IN OUT NOCOPY NUMBER ) RETURN NUMBER;


PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                              p_precision     OUT NOCOPY NUMBER,
                              p_mau           OUT NOCOPY NUMBER );
--


FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER ;


Function GetFunctCurr(p_set_of_books_id IN  Number) RETURN VARCHAR2;
--
Function GetConvType(p_conv_type IN  varchar2) RETURN VARCHAR2;
--

TYPE getrate_seg_type IS
     TABLE OF  varchar2(100)
     INDEX BY  BINARY_INTEGER;

TYPE getrate_id_type IS
    TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

pg_getrate_hash_seg_cache  getrate_seg_type;
pg_getrate_line_seg_cache getrate_seg_type;
pg_getrate_hash_id_cache  getrate_id_type;
pg_getrate_line_id_cache  getrate_id_type;

/* Bug 3810649 */
pg_init_seg_cache         getrate_seg_type;

tab_size                 NUMBER     := 0;

Function GetRate(p_from_curr_code IN varchar2,p_to_curr_code IN varchar2,p_conversion_date DATE,p_conversion_type IN varchar2) RETURN NUMBER;
--
Function RateExists(p_set_of_books_id IN NUMBER,p_from_curr_code IN varchar2,p_conversion_date DATE,p_conversion_type IN varchar2) RETURN VARCHAR2;
--
Function IsFixedRate(p_rec_curr_code IN varchar2,
                     p_funct_curr_code IN varchar2,
                     p_rec_conversion_date DATE,
                     p_trx_curr_code IN varchar2 Default NULL,
                     p_trx_conversion_date DATE  Default NULL) RETURN VARCHAR2;
--
PROCEDURE flush_cached_rates;

PROCEDURE init;

END arpcurr;

/
