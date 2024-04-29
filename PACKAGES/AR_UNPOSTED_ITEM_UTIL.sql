--------------------------------------------------------
--  DDL for Package AR_UNPOSTED_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_UNPOSTED_ITEM_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARCBUPTS.pls 120.0 2006/07/25 22:00:12 hyu noship $ */


PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                              p_precision     OUT NOCOPY NUMBER,
                              p_mau           OUT NOCOPY NUMBER );



FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER;


FUNCTION CurrRound( p_amount        IN NUMBER,
                    p_currency_code IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;



PROCEDURE Set_Buckets(
      p_header_acctd_amt   IN     NUMBER        ,
      p_base_currency      IN     fnd_currencies.currency_code%TYPE,
      p_exchange_rate      IN     NUMBER        ,
      p_base_precision     IN     NUMBER        ,
      p_base_min_acc_unit  IN     NUMBER        ,
      p_tax_amt            IN     NUMBER        ,
      p_charges_amt        IN     NUMBER        ,
      p_line_amt           IN     NUMBER        ,
      p_freight_amt        IN     NUMBER        ,
      p_tax_acctd_amt      IN OUT NOCOPY NUMBER        ,
      p_charges_acctd_amt  IN OUT NOCOPY NUMBER        ,
      p_line_acctd_amt     IN OUT NOCOPY NUMBER        ,
      p_freight_acctd_amt  IN OUT NOCOPY NUMBER         );



END;

 

/
