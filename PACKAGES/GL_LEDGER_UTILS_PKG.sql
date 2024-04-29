--------------------------------------------------------
--  DDL for Package GL_LEDGER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_LEDGER_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: gluldgus.pls 120.2 2005/01/05 18:07:02 djogg noship $ */
--
-- Package
--   GL_LEDGER_UTILS_PKG
-- Purpose
--   To create GL_LEDGER_UTILS_PKG package.
-- History
--   05/20/01    T Cheng      Created.
--

  -- *********************************************************************
  -- The following procedures are designed to handle the ledger segment
  -- in the mirror chart of accounts, or can also be used in general to
  -- convert between ledger short name and ledger id/currency.

  --
  -- Procedure
  --   Find_Ledger
  -- Purpose
  --   Find the ledger by short name.
  -- History
  --   02/20/03   T Cheng      Created
  -- Arguments
  --   X_Ledger_Short_Name     ledger short name (unique)
  --   X_Ledger_Id             ledger id
  --   X_Ledger_Currency       ledger currency, NULL for ledger sets
  --   X_Translated_Flag       whether it is a translated ALC (Y/N)
  -- Example
  --   gl_ledger_utils_pkg.Find_Ledger('Vision Operations',
  --                                   ldg_id, ldg_cur, flag);
  -- Notes
  --   For ledger sets, X_Ledger_Currency will be null.
  --
  PROCEDURE Find_Ledger(X_Ledger_Short_Name   VARCHAR2,
                        X_Ledger_Id           OUT NOCOPY NUMBER,
                        X_Ledger_Currency     OUT NOCOPY VARCHAR2,
                        X_Translated_Flag     OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   Find_Ledger_Short_Name
  -- Purpose
  --   Find the ledger short name by id and currency.
  -- History
  --   02/27/03   T Cheng      Created
  -- Arguments
  --   X_Ledger_Id             ledger id
  --   X_Ledger_Currency       ledger currency, ignored if ledger sets
  --   X_Ledger_Short_Name     ledger short name
  --   X_Translated_Flag       whether it is a translated ALC (Y/N)
  -- Example
  --   gl_ledger_utils_pkg.Find_Ledger_Short_Name(1, 'USD', short_name, flag);
  -- Notes
  --   X_Ledger_Currency is ignored if it is a ledger set.
  --   For a ledger id that corresponds to a single ledger, if no ledger
  --   currency is passed in, the short name of the "base" ledger is returned.
  --
  PROCEDURE Find_Ledger_Short_Name(X_Ledger_Id           NUMBER,
                                   X_Ledger_Currency     VARCHAR2,
                                   X_Ledger_Short_Name   OUT NOCOPY VARCHAR2,
                                   X_Translated_Flag     OUT NOCOPY VARCHAR2);

  -- *********************************************************************
  -- The following functions are designed to get default values for
  -- report parameters.

  --
  -- Function
  --   Get_Ledger_Id_Of_Short_Name
  -- Purpose
  --   Given a ledger short name, returns the ledger id.
  -- History
  --   05/20/03   T Cheng      Created
  -- Arguments
  --   X_Ledger_Short_Name     ledger short name
  -- Example
  --   ledger_id := gl_ledger_utils_pkg.Get_Ledger_Id_Of_Short_Name('LSN');
  -- Notes
  --
  FUNCTION Get_Ledger_Id_Of_Short_Name(X_Ledger_Short_Name VARCHAR2)
    RETURN NUMBER;

  --
  -- Function
  --   Get_Default_Ledger_Currency
  -- Purpose
  --   If the ledger parameter is a single ledger (ledger, MRC ALC or
  --   translated ALC), return the ledger's currency. If it is a ledger set,
  --   return the currency of the default ledger if there is one, otherwise
  --   NULL.
  -- History
  --   05/20/03   T Cheng      Created
  -- Arguments
  --   X_Ledger_Short_Name     ledger short name
  -- Example
  --   curr := gl_ledger_utils_pkg.Get_Default_Ledger_Currency('LSN');
  -- Notes
  --
  FUNCTION Get_Default_Ledger_Currency(X_Ledger_Short_Name VARCHAR2)
    RETURN VARCHAR2;

  -- *********************************************************************

  --
  -- Procedure
  --   Get_First_Ledger_Id_From_Set
  -- Purpose
  -- Get the first ledger id from a ledger set. This ledger id will be
  -- used to get the first period name for all ledgers in this ledger set.
  -- The first period name will then be used to calculate the YTD amount.
  -- History
  --   06/02/03   K. Yung      Created
  -- Arguments
  --   X_Ledger_set_id     ledger set id
  --   X_ledger_currency   ledger currency
  --   X_ledger_id         returned first ledger id found in the ledger set
  --   X_errbuf            returned error message
  -- Example
  --   gl_ledger_utils_pkg.Get_First_Ledger_Id_From_Set(1394, 'USD', ledger_id,
  --                                                    errbuf);
  -- Notes
  --
procedure Get_First_Ledger_Id_From_Set(
                    X_Ledger_Set_Id    IN  number,
                    X_Ledger_Currency  IN  VARCHAR2,
                    X_Ledger_Id        OUT NOCOPY number,
                    X_Errbuf           OUT NOCOPY varchar2);

  -- *********************************************************************


END GL_LEDGER_UTILS_PKG;

 

/
