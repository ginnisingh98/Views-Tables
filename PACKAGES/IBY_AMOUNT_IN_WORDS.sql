--------------------------------------------------------
--  DDL for Package IBY_AMOUNT_IN_WORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_AMOUNT_IN_WORDS" AUTHID CURRENT_USER AS
/* $Header: ibyamtws.pls 120.0.12010000.3 2009/01/06 07:03:11 bkjain ship $ */


  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_AMOUNT_IN_WORDS';


  -- This function will return the text version of an amount.
  -- It is usually needed for paper payment formats such as checks.
  -- Current implementation is a wrapper of the various word amount conversion
  -- modules in 11i AP and Global Financials. Many of these modules are
  -- obseleted in R12; their code are copied and repackaged in this package.
  --
  -- The API uses the country code or currency code to switch to the 11i
  -- modules. For example if the country code is ES, the API will call the logic
  -- of 11i JEES_NTW. For this reason callers should pass in the currency code
  -- and country code whenever possible. The API will try to find a global
  -- country specific conversion module first; if not found the API
  -- will use the AP logic in APXPBFOR.rdf for the conversion. The AP logic
  -- uses userenv('LANG') to get the translated amount phrases from AP_lookup_codes.
  --
  -- The currency code is also used to look up the amount unit and subunit words
  -- and unit ratios in AP logic.
  --
  -- Parameters:
  -- p_amount: the amount to be converted to text
  -- p_currency_code: the currency of the amount
  -- p_precision: required for some cases such as JEES_NTW
  -- p_country_code: used for cases where a global country specific conversion
  --                 module was used, e.g., JEES_NTW
  FUNCTION Get_Amount_In_Words(p_amount IN NUMBER,
                               p_currency_code IN VARCHAR2 := NULL,
                               p_precision IN NUMBER := NULL,
                               p_country_code IN VARCHAR2 := NULL)
  RETURN VARCHAR2;

FUNCTION amount_words_portugese(valor NUMBER) RETURN VARCHAR2;
PROCEDURE amount_words_portgse_milhares(valor NUMBER, b4 NUMBER, b5 NUMBER, b6 NUMBER, b7 NUMBER, b8 NUMBER, b9 NUMBER, l7 OUT NOCOPY VARCHAR2,
l8 OUT NOCOPY VARCHAR2, l9 OUT NOCOPY VARCHAR2, l10 OUT NOCOPY VARCHAR2, l11 OUT NOCOPY VARCHAR2, l12 OUT NOCOPY VARCHAR2, virgula_mi OUT NOCOPY VARCHAR2);
PROCEDURE amount_words_portgse_centos(valor NUMBER, b7 NUMBER, b8 NUMBER, b9 NUMBER, b10 NUMBER, b11 NUMBER, b12 NUMBER, l13 OUT NOCOPY VARCHAR2,
l14 OUT NOCOPY VARCHAR2, l15 OUT NOCOPY VARCHAR2, l16 OUT NOCOPY VARCHAR2, l17 OUT NOCOPY VARCHAR2, l18 OUT NOCOPY VARCHAR2, virgula_mil OUT NOCOPY VARCHAR2);
PROCEDURE amount_words_portgse_dezena(valor IN NUMBER,   b10 IN NUMBER,   b11 IN NUMBER,   b12 IN NUMBER,   l19 OUT NOCOPY VARCHAR2,   l20 OUT NOCOPY VARCHAR2,
l21 OUT NOCOPY VARCHAR2,   l22 OUT NOCOPY VARCHAR2,   l23 OUT NOCOPY VARCHAR2,   l24 OUT NOCOPY VARCHAR2,   virgula_cr OUT NOCOPY VARCHAR2);
PROCEDURE amount_words_portgse_centavos(valor IN NUMBER,   b13 IN NUMBER,   b14 IN NUMBER,   l25 OUT NOCOPY VARCHAR2,   l26 OUT NOCOPY VARCHAR2,   l27 OUT NOCOPY VARCHAR2,   l28 OUT NOCOPY VARCHAR2,   l29 OUT NOCOPY VARCHAR2);
END IBY_AMOUNT_IN_WORDS;



/
