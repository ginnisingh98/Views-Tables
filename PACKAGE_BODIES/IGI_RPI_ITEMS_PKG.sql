--------------------------------------------------------
--  DDL for Package Body IGI_RPI_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_ITEMS_PKG" AS
--- $Header: igiritmb.pls 120.3.12000000.1 2007/08/31 05:52:44 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE Insert_Row( X_Item_Id                     IN NUMBER
                    , X_Set_Of_Books_Id             IN NUMBER
                    , X_Item_Code                   IN VARCHAR2
                    , X_Price                       IN NUMBER
                    , X_Price_Effective_Date        IN DATE
                    , X_Unit_Of_Measure             IN VARCHAR2
                    , X_Start_Effective_Date        IN DATE
                    , X_Creation_Date               IN DATE
                    , X_Created_By                  IN NUMBER
                    , X_Last_Update_Date            IN DATE
                    , X_Last_Updated_By             IN NUMBER
                    , X_Last_Update_Login           IN NUMBER
                    , X_Revised_Price_Eff_Date      IN DATE
                    , X_Revised_Price               IN NUMBER
                    , X_Description                 IN VARCHAR2
                    , X_Vat_Tax_Id                  IN NUMBER
                    , X_Revenue_Code_Combination_Id IN NUMBER
                    , X_Inactive_Date               IN DATE
                    , X_Enabled_Flag                IN VARCHAR2
			/*MOAC IMpact Bug No 5905216*/
		    , X_Org_id			    IN NUMBER   )
IS
   l_Item_Id NUMBER;
   l_Row_ID  VARCHAR(30);

   CURSOR Cursor_Row_ID IS SELECT rowid
                           FROM   igi_rpi_items
                           WHERE  item_id = X_Item_Id;

   CURSOR Cursor_Item_id IS SELECT igi_rpi_items_s.nextval FROM sys.dual;

   BEGIN
      IF (X_Item_Id is NULL)
      THEN
         Open  Cursor_Item_id;
         Fetch Cursor_Item_id INTO l_Item_Id;

         IF (Cursor_Item_id%NOTFOUND)
         THEN
            Raise NO_DATA_FOUND;
         END IF;

         Close Cursor_Item_id;
      END IF;

    LOCK TABLE igi_rpi_items IN SHARE UPDATE MODE;
    IF (X_Item_Id is NOT NULL)
    THEN
    INSERT INTO igi_rpi_items( item_id
                               , set_of_books_id
                               , item_code
                               , price
                               , price_effective_date
                               , unit_of_measure
                               , start_effective_date
                               , creation_date
                               , created_by
                               , last_update_date
                               , last_updated_by
                               , last_update_login
                               , revised_price_eff_date
                               , revised_price
                               , description
                               , vat_tax_id
                               , revenue_code_combination_id
                               , inactive_date
                               , enabled_flag
			       , org_id
                               )
    VALUES (   X_Item_Id
             , X_Set_Of_Books_Id
             , X_Item_Code
             , X_Price
             , X_Price_Effective_Date
             , X_Unit_Of_Measure
             , X_Start_Effective_Date
             , X_Creation_Date
             , X_Created_By
             , X_Last_Update_Date
             , X_Last_Updated_By
             , X_Last_Update_Login
             , X_Revised_Price_Eff_Date
             , X_Revised_Price
             , X_Description
             , X_Vat_Tax_Id
             , X_Revenue_Code_Combination_Id
             , X_Inactive_Date
             , X_Enabled_Flag
	     , X_Org_Id
           );
    END IF;
    Open Cursor_Row_ID;
    Fetch Cursor_Row_ID INTO l_Row_ID;

    IF (Cursor_Row_ID%NOTFOUND)
    THEN
       Raise NO_DATA_FOUND;
    END IF;
    Close Cursor_Row_ID;

EXCEPTION
     WHEN NO_DATA_FOUND THEN RETURN;
     WHEN app_exceptions.application_exception THEN RAISE;
     WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'IGI_RPI_ITEMS_PKG.Insert_Row');
      -- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
          FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE', sqlcode);
          FND_MESSAGE.SET_TOKEN('MSG', sqlerrm);

          FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_rpi_items_pkg.insert_row.Msg1',TRUE);
      END IF;
      -- bug 3199481, end block
      RAISE;

END Insert_Row;


PROCEDURE Update_Row( X_Item_Id                     IN NUMBER
                    , X_Set_Of_Books_Id             IN NUMBER
                    , X_Item_Code                   IN VARCHAR2
                    , X_Price                       IN NUMBER
                    , X_Price_Effective_Date        IN DATE
                    , X_Unit_Of_Measure             IN VARCHAR2
                    , X_Start_Effective_Date        IN DATE
                    , X_Last_Update_Date            IN DATE
                    , X_Last_Updated_By             IN NUMBER
                    , X_Last_Update_Login           IN NUMBER
                    , X_Revised_Price_Eff_Date      IN DATE
                    , X_Revised_Price               IN NUMBER
                    , X_Description                 IN VARCHAR2
                    , X_Vat_Tax_Id                  IN NUMBER
                    , X_Revenue_Code_Combination_Id IN NUMBER
                    , X_Inactive_Date               IN DATE
                    , X_Enabled_Flag                IN VARCHAR2 )
IS
  BEGIN

    LOCK TABLE igi_rpi_items IN SHARE UPDATE MODE;

    UPDATE igi_rpi_items
    SET item_code                   = X_Item_Code
    ,   price                       = X_Price
    ,   price_effective_date        = X_Price_Effective_Date
    ,   unit_of_measure             = X_Unit_Of_Measure
    ,   start_effective_date        = X_Start_Effective_Date
    ,   last_update_date            = X_Last_Update_Date
    ,   last_updated_by             = X_Last_Updated_By
    ,   last_update_login           = X_Last_Update_Login
    ,   revised_price_eff_date      = X_Revised_Price_Eff_Date
    ,   revised_price               = X_Revised_Price
    ,   description                 = X_Description
    ,   vat_tax_id                  = X_Vat_Tax_Id
    ,   revenue_code_combination_id = X_Revenue_Code_Combination_Id
    ,   inactive_date               = X_Inactive_Date
    ,   enabled_flag                = X_Enabled_Flag
    WHERE Item_Id         = X_Item_Id
    AND   Set_Of_Books_Id = X_Set_Of_Books_Id;

EXCEPTION
     WHEN NO_DATA_FOUND THEN RETURN;
     WHEN app_exceptions.application_exception THEN RAISE;
     WHEN OTHERS THEN
       fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
       fnd_message.set_token('PROCEDURE',
                             'IGI_RPI_ITEMS_PKG.Update_Row');
       -- bug 3199481, start block
       IF (l_unexp_level >= l_debug_level) THEN
           FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE', sqlcode);
           FND_MESSAGE.SET_TOKEN('MSG', sqlerrm);

           FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_rpi_items_pkg.update_row.Msg1',TRUE);
       END IF;
       -- bug 3199481, end block
       RAISE;

END Update_Row;


PROCEDURE Delete_Row(X_Item_Id NUMBER)
IS
  BEGIN
    DELETE FROM igi_rpi_items
    WHERE Item_Id = X_Item_Id;

    IF (SQL%NOTFOUND)
    THEN
        Raise NO_DATA_FOUND;
    END IF;

END Delete_Row;

END IGI_RPI_ITEMS_PKG;

/
