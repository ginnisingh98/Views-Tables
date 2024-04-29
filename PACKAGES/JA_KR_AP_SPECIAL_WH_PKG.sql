--------------------------------------------------------
--  DDL for Package JA_KR_AP_SPECIAL_WH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_KR_AP_SPECIAL_WH_PKG" AUTHID CURRENT_USER AS
/* $Header: jakrpwhs.pls 115.3 2002/11/12 22:13:15 thwon ship $ */

/**************************************************************************
 *                                                                        *
 * Name       : rounding_units                                            *
 * Purpose    : This function returns rounded amount to the down unit     *
 *                                                                        *
 **************************************************************************/

FUNCTION rounding_units
                (P_Withheld_Amount      IN     Number,
                 P_Calling_Sequence     IN     Varchar2)
                 RETURN NUMBER;

/**************************************************************************
 *                                                                        *
 * Name       : Minimum_Withheld_Amt                                      *
 * Purpose    : This function returns the value store in GDF 8            *
 *                                                                        *
 **************************************************************************/

FUNCTION Minimum_Withheld_Amt
                (P_Tax_Name             IN     Varchar2,
                 P_Calling_Sequence     IN     Varchar2)
                 RETURN NUMBER;


PROCEDURE Ja_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 );

END JA_KR_AP_SPECIAL_WH_PKG;

 

/
