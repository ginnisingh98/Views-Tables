--------------------------------------------------------
--  DDL for Package Body JA_KR_AP_SPECIAL_WH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_KR_AP_SPECIAL_WH_PKG" AS
/* $Header: jakrpwhb.pls 115.5 2002/11/12 22:13:24 thwon ship $ */


/**************************************************************************
 *                                                                        *
 * Name       : rounding_units                                            *
 * Purpose    : This function returns rounded amount to the down unit     *
 *                                                                        *
 **************************************************************************/

FUNCTION rounding_units
		(P_Withheld_Amount	IN   Number,
		 P_Calling_Sequence	IN   Varchar2) RETURN Number
IS
   -------------------------------
   -- Local Variables Definition
   -------------------------------
   Rounded Number;
   debug_info                     Varchar2(500);
   current_calling_sequence       Varchar2(2000);

BEGIN
   current_calling_sequence := 'JA_KR_AP_SPECIAL_WH_PKG.<- rounding_units ' ||
                                P_Calling_Sequence;
   rounded := nvl(P_Withheld_Amount,0) - (nvl(P_Withheld_Amount,0) mod 10);
   RETURN nvl(rounded,P_Withheld_Amount);

EXCEPTION
   WHEN others THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','JA_KR_AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      'P_Withheld_Amount1 = ' || to_char(P_Withheld_Amount));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END rounding_units;

/**************************************************************************
 *                                                                        *
 * Name       : Minimum_Withheld_Amt                                      *
 * Purpose    : This function returns the value stoted in Global          *
 *              Attribute13 from ap_tax_codes                              *
 *                                                                        *
 **************************************************************************/

FUNCTION Minimum_Withheld_Amt
                (P_Tax_Name             IN     Varchar2,
                 P_Calling_Sequence     IN     Varchar2) RETURN NUMBER
IS
   -------------------------------
   -- Local Variables Definition
   -------------------------------
   Min_Wh                         Number := 0;
   debug_info                     Varchar2(500);
   current_calling_sequence       Varchar2(2000);
   CURSOR C_Minimum IS
      SELECT to_number(global_attribute13) Minimum
        FROM AP_Tax_Codes
       WHERE name = P_Tax_Name;

BEGIN
   current_calling_sequence := 'JA_KR_AP_SPECIAL_WH_PKG.<- Minimum_Withheld_Amt ' ||
                                P_Calling_Sequence;
   FOR db_reg IN C_Minimum LOOP
       Min_Wh := nvl(db_reg.Minimum,0);
       RETURN (Min_Wh);
   END LOOP;
   RETURN (Min_Wh);

EXCEPTION
   WHEN others THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','JA_KR_AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      'P_Tax_Name = ' || P_Tax_Name);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Minimum_Withheld_Amt;


Procedure Ja_Special_Withheld_Amt
                (
                 P_Withheld_Amount        IN OUT NOCOPY Number
                ,P_Base_WT_amount         IN OUT NOCOPY Number
                ,P_CurrCode               IN Varchar2
                ,P_BaseCurrCode           IN Varchar2
                ,P_Invoice_exchange_rate  IN Number
                ,P_Tax_Name               IN Varchar2
                ,P_Calling_sequence       IN Varchar2
                 )

IS
   -------------------------------
   -- Local Variables Definition
   -------------------------------
   Rounded                     Number;
   Min_Wh                      Number := 0;
   debug_info                  Varchar2(500);
   current_calling_sequence    Varchar2(2000);

BEGIN

   current_calling_sequence := 'JA_KR_AP_SPECIAL_WH_PKG.<- Ja_Special_Withheld_Amt ' ||
                                P_Calling_Sequence;

   IF (P_CurrCode = P_BaseCurrCode) THEN

      P_Base_WT_Amount  := Rounding_Units
                             (P_Base_WT_Amount
                             ,P_calling_sequence);

      P_Withheld_Amount := Rounding_Units
                             (P_Withheld_Amount
                             ,P_calling_sequence);

   ELSE
      IF (P_Invoice_Exchange_Rate is null) THEN
        P_Base_WT_Amount := 0;
        P_Withheld_Amount := Rounding_Units
                                (P_Withheld_Amount
                                ,P_calling_sequence);
      ELSE
        P_Base_WT_Amount := Rounding_Units
                                (P_Base_WT_Amount
                                ,P_calling_sequence);
        P_Withheld_Amount := P_Base_Wt_Amount * P_Invoice_Exchange_Rate;
      END IF;
   END IF;

  /*****************************************************************
    Check for Minimum Withheld Amount
   *****************************************************************/
   Min_Wh := Minimum_Withheld_Amt(P_Tax_Name
                              ,P_calling_sequence);

   IF  Min_Wh > P_Base_WT_Amount THEN
       P_Base_WT_Amount  := 0;
       P_Withheld_Amount := 0;
   END IF;

EXCEPTION
   WHEN others THEN IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','JA_KR_AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS',
                      ' P_Withheld_Amount = ' || to_char(P_Withheld_Amount)||
                      ', P_Base_WT_Amount = ' || to_char(Min_Wh));
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END Ja_Special_Withheld_Amt;

END JA_KR_AP_SPECIAL_WH_PKG;

/
