--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_VIEW_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_VIEW_CURRENCY" AS
/* $Header: hriovcrn.pkb 120.1 2006/10/09 15:24:14 jtitmas noship $ */

/******************************************************************************/
/* Function to convert an amount from one currency to another, given a        */
/* specified conversion rate type                                             */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_rate_type        IN VARCHAR2)
            RETURN NUMBER IS

BEGIN

  RETURN hri_bpl_currency.convert_currency_amount
           (p_from_currency => p_from_currency,
            p_to_currency => p_to_currency,
            p_conversion_date => p_conversion_date,
            p_amount => p_amount,
            p_rate_type => p_rate_type);

EXCEPTION WHEN OTHERS THEN
  RETURN to_number(null);

END convert_currency_amount;

FUNCTION convert_to_primary_crnc(p_from_currency     IN VARCHAR2
                                ,p_amount            IN NUMBER)
            RETURN NUMBER IS

BEGIN

  RETURN hri_bpl_currency.convert_to_primary_crnc
          (p_from_currency => p_from_currency,
           p_amount => p_amount);

EXCEPTION WHEN OTHERS THEN

  RETURN 0;

END convert_to_primary_crnc;

FUNCTION convert_to_secondary_crnc(p_from_currency     IN VARCHAR2
                                  ,p_amount            IN NUMBER)
            RETURN NUMBER IS

BEGIN

  RETURN hri_bpl_currency.convert_to_secondary_crnc
          (p_from_currency => p_from_currency,
           p_amount => p_amount);

EXCEPTION WHEN OTHERS THEN

  RETURN 0;

END convert_to_secondary_crnc;

END hri_oltp_view_currency;

/
