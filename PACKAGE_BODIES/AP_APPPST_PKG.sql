--------------------------------------------------------
--  DDL for Package Body AP_APPPST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APPPST_PKG" AS
/* $Header: appstfxb.pls 120.3 2004/10/28 23:28:52 pjena noship $ */
                                                                         --
function Ap_Get_GL_Interface_Amount
                             (EnteredAmount IN NUMBER
                             ,BaseAmount    IN NUMBER
                             ,AccountType   IN VARCHAR2
                             ,ResultColumn  IN VARCHAR2)
return NUMBER
is
                                                                         --
  tmpForSwap      NUMBER;
  Entered_DR      NUMBER;
  Entered_CR      NUMBER;
  Accounted_DR    NUMBER;
  Accounted_CR    NUMBER;
                                                                         --
BEGIN
                                                                         --
-- In the following if-else-endif, construct, we are doing everything assuming
-- that we are operating on a Debit account.
                                                                         --
  if (  (SIGN(EnteredAmount) = -1) OR
        ((EnteredAmount = 0) AND (SIGN(NVL(BaseAmount, EnteredAmount)) = -1))
     ) then
                                                                         --
    -- Special cases (where a debit account should be credited)
                                                                         --
    Entered_DR   := NULL;
    Entered_CR   := 0 - EnteredAmount;
    Accounted_DR := NULL;
    Accounted_CR := 0 - NVL(BaseAmount, EnteredAmount);
                                                                         --
  else
                                                                         --
    -- Normal cases (where debit accounts should be debited)
                                                                         --
    Entered_DR   := EnteredAmount;
    Entered_CR   := NULL;
    Accounted_DR := NVL(BaseAmount, EnteredAmount);
    Accounted_CR := NULL;
                                                                         --
  end if;
                                                                         --
-- For Credit accounts, correct (swap) the entries because they
-- were created assuming Debit Accounts.
                                                                         --
  if (AccountType = 'CR') then
                                                                         --
    -- swap Entered_DR and Entered_CR
    tmpForSwap   := Entered_DR;
    Entered_Dr   := Entered_CR;
    Entered_CR   := tmpForSwap;
                                                                         --
    -- swap Accounted_DR and Accounted_CR
    tmpForSwap   := Accounted_DR;
    Accounted_Dr := Accounted_CR;
    Accounted_CR := tmpForSwap;
                                                                         --
  end if;
                                                                         --
  select decode(UPPER(ResultColumn), 'ENTERED_DR'  , Entered_DR
                                   , 'ENTERED_CR'  , Entered_CR
                                   , 'ACCOUNTED_DR', Accounted_DR
                                                   , Accounted_CR)
         into tmpForSwap from dual;
                                                                         --
  return tmpForSwap;
                                                                         --
END AP_Get_GL_Interface_Amount;
                                                                         --
                                                                         --
function Ap_apppst_Round_Currency
                         (P_Amount         IN number
                         ,P_Currency_Code  IN varchar2)
return number is
  l_rounded_amount  number;
begin
                                                                         --
  select  decode(FC.minimum_accountable_unit,
            null, round(P_Amount, FC.precision),
                  round(P_Amount/FC.minimum_accountable_unit) *
                               FC.minimum_accountable_unit)
  into    l_rounded_amount
  from    fnd_currencies FC
  where   FC.currency_code = P_Currency_Code;
                                                                         --
  return(l_rounded_amount);
                                                                         --
EXCEPTION

  WHEN NO_DATA_FOUND THEN

  return (null);
                                                                         --
end AP_APPPST_ROUND_CURRENCY;
                                                                         --

END AP_APPPST_PKG;

/
