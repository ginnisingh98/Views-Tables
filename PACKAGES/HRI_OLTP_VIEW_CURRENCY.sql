--------------------------------------------------------
--  DDL for Package HRI_OLTP_VIEW_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_VIEW_CURRENCY" AUTHID CURRENT_USER AS
/* $Header: hriovcrn.pkh 120.1 2006/10/09 15:24:47 jtitmas noship $ */

/******************************************************************************/
/* Function to convert an amount from one currency to another, given a        */
/* specified conversion rate type                                             */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_rate_type        IN VARCHAR2)
            RETURN NUMBER;

FUNCTION convert_to_primary_crnc(p_from_currency     IN VARCHAR2
                                ,p_amount            IN NUMBER)
            RETURN NUMBER;

FUNCTION convert_to_secondary_crnc(p_from_currency     IN VARCHAR2
                                  ,p_amount            IN NUMBER)
            RETURN NUMBER;

END hri_oltp_view_currency;

/
