--------------------------------------------------------
--  DDL for Package AP_ACCOUNTING_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ACCOUNTING_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: apslauts.pls 115.3 2004/04/02 18:46:41 schitlap noship $ */

/*============================================================================
 |  FUNCTION - Get_PO_REVERSED_ENCUMB_AMOUNT
 |
 |  DESCRIPTION
 |      fetch the amount of PO encumbrance reversed against the given PO
 |      distribution from all invoices for a given date range in functional
 |      currency. Calculation includes PO encumbrance which are in GL only.
 |      In case Invoice encumbrance type is the same as PO encumbrance, we
 |      need to exclude the variance.
 |      it returns actual amount or 0 if there is po reversed encumbrance
 |      line existing, otherwise returns NULL.
 |
 |  PARAMETERS
 |      P_Po_distribution_id - po_distribution_id (in)
 |      P_Start_date - Start gl date (in)
 |      P_End_date - End gl date (in)
 |      P_Calling_Sequence - debug usage
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |      1. In case user changes the purchase order encumbrance
 |         type or Invoice encumbrance type after invoice is
 |         validated, this API might not return a valid value.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

 FUNCTION Get_PO_Reversed_Encumb_Amount(
              P_Po_Distribution_Id   IN            NUMBER,
              P_Start_gl_Date        IN            DATE,
              P_End_gl_Date          IN            DATE,
              P_Calling_Sequence     IN            VARCHAR2 DEFAULT NULL)

 RETURN NUMBER;

 PRAGMA RESTRICT_REFERENCES(Get_PO_Reversed_Encumb_Amount, WNDS, WNPS);

END AP_ACCOUNTING_UTILITIES_PKG;


 

/
