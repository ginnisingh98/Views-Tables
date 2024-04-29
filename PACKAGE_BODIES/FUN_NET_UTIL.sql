--------------------------------------------------------
--  DDL for Package Body FUN_NET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_UTIL" AS
/* $Header: funntutb.pls 120.1 2005/12/23 14:10:24 asrivats noship $ */

    PROCEDURE Log_Unexpected_Msg(p_full_path IN VARCHAR2) IS
    BEGIN
        FND_MESSAGE.SET_NAME('FUN','FUN_LOGGING_USER_ERROR');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_MESSAGE.SET_NAME('FUN','FUN_LOGGING_UNEXP_ERROR');
     		FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
     		FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
     		FND_LOG.MESSAGE (FND_LOG.LEVEL_UNEXPECTED,p_full_path, TRUE);
        END IF;
    END Log_Unexpected_Msg;


    PROCEDURE Log_Msg(p_level               IN NUMBER,
			             p_full_path            IN VARCHAR2,
			             p_remove_from_stack    IN BOOLEAN) IS
    BEGIN
        IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.message(p_level,p_full_path,p_remove_from_stack);
        END IF;
    END Log_Msg;


    PROCEDURE Log_String(p_level      IN NUMBER,
                             p_full_path  IN VARCHAR2,
                             p_string     IN VARCHAR2) IS
    BEGIN
        IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(p_level,p_full_path,p_string);
        END IF;
    END Log_String;

-- ============================FND LOG END ==================================
FUNCTION ROUND_CURRENCY
          (P_Amount         IN NUMBER
          ,P_Currency_Code  IN VARCHAR2)
RETURN NUMBER
IS
  l_rounded_amount  number;
BEGIN

  SELECT  decode(FC.minimum_accountable_unit,
            null, round(P_Amount, FC.precision),
                  round(P_Amount/FC.minimum_accountable_unit) *
                               FC.minimum_accountable_unit)
  INTO    l_rounded_amount
  FROM    fnd_currencies FC
  WHERE  FC.currency_code = P_Currency_Code;

  RETURN(l_rounded_amount);

EXCEPTION

  WHEN NO_DATA_FOUND THEN

  RETURN(null);

END ROUND_CURRENCY;
END FUN_NET_UTIL;

/
