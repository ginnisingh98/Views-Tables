--------------------------------------------------------
--  DDL for Package Body AR_UNPOSTED_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_UNPOSTED_ITEM_UTIL" AS
/* $Header: ARCBUPTB.pls 120.0 2006/07/25 22:00:41 hyu noship $ */


--
-- Declaration of local specs and variables
--

TYPE CurrencyCodeType  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
TYPE PrecisionType     IS TABLE OF NUMBER(1)     INDEX BY BINARY_INTEGER;
TYPE MauType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
NextElement            BINARY_INTEGER := 0;
CurrencyCode           CurrencyCodeType;
Precision              PrecisionType;
Mau                    MauType;
g_cust_inv_rec         ra_customer_trx%ROWTYPE;



--
-- local body code
--

CURSOR CurrencyCursor( cp_currency_code VARCHAR2 ) IS
SELECT precision,
       minimum_accountable_unit
  FROM fnd_currencies
 WHERE currency_code = cp_currency_code;


PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                              p_precision     OUT NOCOPY NUMBER,
                              p_mau           OUT NOCOPY NUMBER ) IS
     i BINARY_INTEGER := 0;
BEGIN
   WHILE i < NextElement
   LOOP
        EXIT WHEN CurrencyCode(i) = p_currency_code;
        i := i + 1;
   END LOOP;
   IF i = NextElement   THEN
        OPEN CurrencyCursor( p_currency_code );
        DECLARE
            l_Precision NUMBER;
            l_Mau       NUMBER;
        BEGIN
            FETCH CurrencyCursor
            INTO    l_Precision,
                    l_Mau;
            IF CurrencyCursor%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
            END IF;
            Precision(i)    := l_Precision;
            Mau(i)          := l_Mau;
        END;
        CLOSE CurrencyCursor;
        CurrencyCode(i) := p_currency_code;
        NextElement     := i + 1;
    END IF;
    p_precision := Precision(i);
    p_mau       := Mau(i);
EXCEPTION
    WHEN OTHERS THEN
        IF CurrencyCursor%ISOPEN THEN
           CLOSE CurrencyCursor;
        END IF;
END;



FUNCTION functional_amount(amount        IN NUMBER,
                           currency_code IN VARCHAR2,
                           exchange_rate IN NUMBER,
                           precision     IN NUMBER,
                           min_acc_unit  IN NUMBER) RETURN NUMBER IS

    CURSOR curr_info (cc FND_CURRENCIES.CURRENCY_CODE%TYPE) IS
        SELECT PRECISION,
               MINIMUM_ACCOUNTABLE_UNIT,
               CURRENCY_CODE
        FROM   FND_CURRENCIES
        WHERE  CURRENCY_CODE = cc;
    curr       curr_info%ROWTYPE;
    loc_amount NUMBER;
    invalid_params EXCEPTION;

BEGIN

    IF (((currency_code IS NULL) AND
         (precision IS NULL) AND
         (min_acc_unit IS NULL)) OR
        (amount IS NULL) ) THEN
      BEGIN
         RAISE invalid_params;
      END;
    END IF;

    IF ((precision IS NULL) AND (min_acc_unit IS NULL)) THEN
      BEGIN
         OPEN curr_info(currency_code);
         FETCH curr_info INTO curr;
         CLOSE curr_info;

         IF (curr.currency_code IS NULL) THEN
              RAISE invalid_params;
         END IF;
      END;
    ELSE
      BEGIN
         curr.precision := precision;
         curr.minimum_accountable_unit := min_acc_unit;
      END;
    END IF;

    loc_amount := amount * NVL(exchange_rate, 1);

    IF (curr.minimum_accountable_unit IS NULL) THEN
       RETURN( ROUND(loc_amount, curr.precision));
    ELSE
       RETURN( ROUND((loc_amount / curr.minimum_accountable_unit)) *
               curr.minimum_accountable_unit);
    END IF;

EXCEPTION
     WHEN OTHERS THEN
         -- Bug 2191876
         IF curr_info%ISOPEN THEN
            CLOSE curr_info;
         END IF;

END functional_amount;







FUNCTION CurrRound( p_amount        IN NUMBER,
                    p_currency_code IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
    l_precision NUMBER(1);
    l_mau       NUMBER;
BEGIN
    GetCurrencyDetails( p_currency_code, l_precision, l_mau );
    IF l_mau IS NOT NULL
    THEN
         RETURN( ROUND( p_amount / l_mau) * l_mau );
    ELSE
         RETURN( ROUND( p_amount, l_precision ));
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;




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
      p_freight_acctd_amt  IN OUT NOCOPY NUMBER         ) IS

l_run_amt_tot         NUMBER;
l_run_acctd_amt_tot   NUMBER;
l_last_bucket         VARCHAR2(1);

/* Bug 2013601
 Variables to hold running total of amount, accounted amount and the
 total adjusted amount */
l_run_oth_amt_tot       NUMBER;
l_run_oth_acctd_amt_tot NUMBER;
l_amt_tot               NUMBER;
BEGIN

     l_run_amt_tot       := 0;
     l_run_acctd_amt_tot := 0;

     /* Bug 2013601
        Initialise the variables */
     l_run_oth_amt_tot := 0;
     l_run_oth_acctd_amt_tot := 0;
     l_amt_tot := p_tax_amt + p_charges_amt + p_line_amt + p_freight_amt ;

     l_run_amt_tot                 := l_run_amt_tot + p_tax_amt;
     p_tax_acctd_amt               := functional_amount(
                                          l_run_amt_tot,
                                          p_base_currency,
                                          p_exchange_rate,
                                          p_base_precision,
                                          p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot           := l_run_acctd_amt_tot + p_tax_acctd_amt;

     IF p_tax_acctd_amt <> 0 THEN
        l_last_bucket    := 'T';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_charges_amt;
     p_charges_acctd_amt          := functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_charges_acctd_amt;

     IF p_charges_acctd_amt <> 0 THEN
        l_last_bucket    := 'C';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_line_amt;
     p_line_acctd_amt             := functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_line_acctd_amt;

     IF p_line_acctd_amt <> 0 THEN
        l_last_bucket    := 'L';
     END IF;

     l_run_amt_tot                := l_run_amt_tot + p_freight_amt;
     p_freight_acctd_amt          := functional_amount(
                                         l_run_amt_tot,
                                         p_base_currency,
                                         p_exchange_rate,
                                         p_base_precision,
                                         p_base_min_acc_unit) - l_run_acctd_amt_tot;

     l_run_acctd_amt_tot          := l_run_acctd_amt_tot + p_freight_acctd_amt;

     IF p_freight_acctd_amt <> 0 THEN
        l_last_bucket    := 'F';
     END IF;


     IF l_last_bucket IS NULL THEN

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_tax_amt;
           p_tax_acctd_amt         := Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_tax_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_charges_amt;
           p_charges_acctd_amt     := Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot +p_charges_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_line_amt;
           p_line_acctd_amt        := Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_line_acctd_amt;

           l_run_oth_amt_tot       := l_run_oth_amt_tot + p_freight_amt;
           p_freight_acctd_amt     := Currround((l_run_oth_amt_tot/l_amt_tot)*
                                         p_header_acctd_amt,p_base_currency) -
                                         l_run_oth_acctd_amt_tot;
           l_run_oth_acctd_amt_tot := l_run_oth_acctd_amt_tot + p_freight_acctd_amt;


     ELSIF    l_last_bucket = 'T' THEN
           p_tax_acctd_amt     := p_tax_acctd_amt     - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'C' THEN
           p_charges_acctd_amt := p_charges_acctd_amt - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'L' THEN
           p_line_acctd_amt    := p_line_acctd_amt    - (l_run_acctd_amt_tot - p_header_acctd_amt);
     ELSIF l_last_bucket = 'F' THEN
           p_freight_acctd_amt := p_freight_acctd_amt - (l_run_acctd_amt_tot - p_header_acctd_amt);
     END IF;

EXCEPTION
  WHEN OTHERS THEN    RAISE;

END Set_Buckets;

END;

/
