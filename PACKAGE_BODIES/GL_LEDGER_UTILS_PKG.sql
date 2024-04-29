--------------------------------------------------------
--  DDL for Package Body GL_LEDGER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_LEDGER_UTILS_PKG" AS
/* $Header: gluldgub.pls 120.4 2005/01/05 18:06:58 djogg noship $ */


  --
  -- PUBLIC FUNCTIONS
  --
  -- *********************************************************************

  PROCEDURE Find_Ledger(X_Ledger_Short_Name   VARCHAR2,
                        X_Ledger_Id           OUT NOCOPY NUMBER,
                        X_Ledger_Currency     OUT NOCOPY VARCHAR2,
                        X_Translated_Flag     OUT NOCOPY VARCHAR2) IS
    CURSOR c_ledger IS
      SELECT ledger_id, decode(object_type_code, 'S', NULL, currency_code), 'N'
      FROM   GL_LEDGERS
      WHERE  short_name = X_Ledger_Short_Name;

    CURSOR c_ledger_relationship IS
      SELECT target_ledger_id, target_currency_code,
             decode(relationship_type_code, 'BALANCE', 'Y', 'N')
      FROM   GL_LEDGER_RELATIONSHIPS
      WHERE  target_ledger_short_name = X_Ledger_Short_Name;
  BEGIN
    OPEN c_ledger;
    FETCH c_ledger INTO X_Ledger_Id, X_Ledger_Currency, X_Translated_Flag;
    IF (c_ledger%FOUND) THEN
      CLOSE c_ledger;
      RETURN;
    END IF;
    CLOSE c_ledger;

    -- Or it could be a translated ALC.
    OPEN c_ledger_relationship;
    FETCH c_ledger_relationship INTO X_Ledger_Id, X_Ledger_Currency,
                                     X_Translated_Flag;
    CLOSE c_ledger_relationship;
  END Find_Ledger;

  -- *********************************************************************

  PROCEDURE Find_Ledger_Short_Name(X_Ledger_Id           NUMBER,
                                   X_Ledger_Currency     VARCHAR2,
                                   X_Ledger_Short_Name   OUT NOCOPY VARCHAR2,
                                   X_Translated_Flag     OUT NOCOPY VARCHAR2) IS
    CURSOR c_ledger IS
      SELECT short_name, 'N'
      FROM   GL_LEDGERS
      WHERE  ledger_id = X_Ledger_Id
      AND    (   object_type_code = 'S'
              OR decode(X_Ledger_Currency, Null, 'Y', currency_code) =
                                           nvl(X_Ledger_Currency, 'Y') );

    CURSOR c_ledger_relationship IS
      SELECT target_ledger_short_name,
             decode(relationship_type_code, 'BALANCE', 'Y', 'N')
      FROM   GL_LEDGER_RELATIONSHIPS
      WHERE  target_ledger_id = X_Ledger_Id
      AND    target_currency_code = X_Ledger_Currency
      AND    application_id = 101;
  BEGIN
    OPEN c_ledger;
    FETCH c_ledger INTO X_Ledger_Short_Name, X_Translated_Flag;
    IF (c_ledger%FOUND) THEN
      CLOSE c_ledger;
      RETURN;
    END IF;
    CLOSE c_ledger;

    -- Or it could be a translated ALC.
    OPEN c_ledger_relationship;
    FETCH c_ledger_relationship INTO X_Ledger_Short_Name, X_Translated_Flag;
    CLOSE c_ledger_relationship;

  END Find_Ledger_Short_Name;

  -- *********************************************************************

  FUNCTION Get_Ledger_Id_Of_Short_Name(X_Ledger_Short_Name VARCHAR2)
    RETURN NUMBER
  IS
    ledger_id    NUMBER;
    ledger_curr  VARCHAR2(15);
    trans_flag   VARCHAR2(1);
  BEGIN
    Find_Ledger(X_Ledger_Short_Name, ledger_id, ledger_curr, trans_flag);
    RETURN ledger_id;
  END Get_Ledger_Id_Of_Short_Name;

  -- *********************************************************************

  FUNCTION Get_Default_Ledger_Currency(X_Ledger_Short_Name VARCHAR2)
    RETURN VARCHAR2
  IS
    CURSOR c_ledger IS
      SELECT target_currency_code
      FROM   GL_LEDGER_RELATIONSHIPS
      WHERE  target_ledger_short_name = X_Ledger_Short_Name;

    CURSOR c_ledger_set IS
      SELECT currency_code
      FROM   GL_LEDGERS
      WHERE  ledger_id = (select default_ledger_id
                          from   GL_ACCESS_SETS
                          where  access_set_id =
                                 (select implicit_access_set_id
                                  from   GL_LEDGERS
                                  where  short_name = X_Ledger_Short_Name));
    default_currency   VARCHAR2(30);
  BEGIN
    OPEN c_ledger;
    FETCH c_ledger INTO default_currency;
    IF (c_ledger%FOUND) THEN
      CLOSE c_ledger;
      RETURN default_currency;
    END IF;
    CLOSE c_ledger;

    -- Or it could be a ledger set.
    OPEN c_ledger_set;
    FETCH c_ledger_set INTO default_currency;
    CLOSE c_ledger_set;

    RETURN default_currency;
  END Get_Default_Ledger_Currency;

  -- *********************************************************************

  PROCEDURE Get_First_Ledger_Id_From_Set(
     X_Ledger_Set_Id            IN NUMBER,
     X_Ledger_Currency          IN VARCHAR2,
     X_Ledger_Id                OUT NOCOPY NUMBER,
     X_Errbuf                   OUT NOCOPY varchar2)
  IS
    CURSOR LedgerID(p_ledger_set_id number, p_ledger_currency varchar2) IS
      SELECT TARGET_LEDGER_ID
      FROM GL_LEDGER_SET_ASSIGNMENTS ASG,
           GL_LEDGER_RELATIONSHIPS LR
      WHERE ASG.LEDGER_SET_ID = P_LEDGER_SET_ID
      AND LR.TARGET_LEDGER_ID = ASG.LEDGER_ID
      AND LR.SOURCE_LEDGER_ID = ASG.LEDGER_ID
      AND LR.TARGET_CURRENCY_CODE = P_LEDGER_CURRENCY;
    l_ledger_id     number:= -1;
  BEGIN
    X_Ledger_Id := -1;

    OPEN LedgerID(X_Ledger_Set_Id, X_Ledger_Currency);
    LOOP
      FETCH LedgerID INTO l_ledger_id;
      EXIT WHEN LedgerID%NOTFOUND;
      X_Ledger_Id := l_ledger_id;
      IF X_Ledger_Id <> -1 THEN     --found the first ledger ID in a ledger set
        EXIT;
      END IF;

    END LOOP;
    CLOSE LedgerID;

    --the input ledger set id is actually a ledger id, not a ledger set id
    IF (l_ledger_id = -1) OR (X_Ledger_Id = -1) THEN
      X_Ledger_Id := X_Ledger_Set_Id;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_Errbuf := SQLERRM;
    WHEN OTHERS THEN
      X_Errbuf := SQLERRM;

  END Get_First_Ledger_Id_From_Set;

  -- *********************************************************************

END GL_LEDGER_UTILS_PKG;

/
