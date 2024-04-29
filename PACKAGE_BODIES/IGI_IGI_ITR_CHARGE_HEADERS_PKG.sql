--------------------------------------------------------
--  DDL for Package Body IGI_IGI_ITR_CHARGE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_ITR_CHARGE_HEADERS_PKG" as
-- $Header: igiitrab.pls 120.5.12000000.1 2007/09/12 10:30:18 mbremkum ship $
--


  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_It_Header_Id                   IN OUT NOCOPY NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_It_Period_Name                 VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Submit_Flag                    VARCHAR2,
                       X_It_Originator_Id               VARCHAR2,
                       X_It_Category                    VARCHAR2,
                       X_It_Source                      VARCHAR2,
                       X_Gl_Date                        DATE,
                       X_Submit_Date                    DATE,
                       X_Currency_Code                  VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Encumbrance_Type_Id            NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_itr_charge_headers
                 WHERE it_header_id = X_It_Header_Id;
      CURSOR C2 IS SELECT IGI_IGI_itr_charge_headers_s.nextval FROM sys.dual;
   BEGIN
      if (X_It_Header_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_It_Header_Id;
        CLOSE C2;
      end if;

       INSERT INTO IGI_itr_charge_headers(
              it_header_id,
              set_of_books_id,
              name,
              description,
              it_period_name,
              entered_dr,
              entered_cr,
              submit_flag,
              it_originator_id,
              it_category,
              it_source,
              gl_date,
              submit_date,
              currency_code,
              code_combination_id,
              encumbrance_type_id,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by
             ) VALUES (
              X_It_Header_Id,
              X_Set_Of_Books_Id,
              X_Name,
              X_Description,
              X_It_Period_Name,
              X_Entered_Dr,
              X_Entered_Cr,
              X_Submit_Flag,
              X_It_Originator_Id,
              X_It_Category,
              X_It_Source,
              X_Gl_Date,
              X_Submit_Date,
              X_Currency_Code,
              X_Code_Combination_Id,
              X_Encumbrance_Type_Id,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Last_Update_Date,
              X_Last_Updated_By
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_It_Header_Id                     NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Name                             VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_It_Period_Name                   VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Submit_Flag                      VARCHAR2,
                     X_It_Originator_Id                 VARCHAR2,
                     X_It_Category                      VARCHAR2,
                     X_It_Source                        VARCHAR2,
                     X_Gl_Date                          DATE,
                     X_Submit_Date                      DATE,
                     X_Currency_Code                    VARCHAR2,
                     X_Code_Combination_Id              NUMBER,
                     X_Encumbrance_Type_Id              NUMBER
  ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_itr_charge_headers
        WHERE  rowid = X_Rowid
        FOR UPDATE of It_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrab.IGI_IGI_ITR_CHARGE_HEADERS_PKG.lock_row.msg1', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Recinfo.it_header_id =  X_It_Header_Id)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.name =  X_Name)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (Recinfo.it_period_name =  X_It_Period_Name)
           AND (   (Recinfo.entered_dr =  X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr =  X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (Recinfo.submit_flag =  X_Submit_Flag)
           AND (Recinfo.it_originator_id =  X_It_Originator_Id)
           AND (Recinfo.it_category =  X_It_Category)
           AND (Recinfo.it_source =  X_It_Source)
           AND (Recinfo.gl_date =  X_Gl_Date)
           AND (   (Recinfo.submit_date =  X_Submit_Date)
                OR (    (Recinfo.submit_date IS NULL)
                    AND (X_Submit_Date IS NULL)))
           AND (Recinfo.currency_code =  X_Currency_Code)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (Recinfo.encumbrance_type_id =  X_Encumbrance_Type_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrab.IGI_IGI_ITR_CHARGE_HEADERS_PKG.lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Name                           VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_It_Period_Name                 VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Submit_Flag                    VARCHAR2,
                       X_It_Originator_Id               VARCHAR2,
                       X_It_Category                    VARCHAR2,
                       X_It_Source                      VARCHAR2,
                       X_Gl_Date                        DATE,
                       X_Submit_Date                    DATE,
                       X_Currency_Code                  VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Encumbrance_Type_Id            NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
  BEGIN
    UPDATE IGI_itr_charge_headers
    SET
       it_header_id                    =     X_It_Header_Id,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       name                            =     X_Name,
       description                     =     X_Description,
       it_period_name                  =     X_It_Period_Name,
       entered_dr                      =     X_Entered_Dr,
       entered_cr                      =     X_Entered_Cr,
       submit_flag                     =     X_Submit_Flag,
       it_originator_id                =     X_It_Originator_Id,
       it_category                     =     X_It_Category,
       it_source                       =     X_It_Source,
       gl_date                         =     X_Gl_Date,
       submit_date                     =     X_Submit_Date,
       currency_code                   =     X_Currency_Code,
       code_combination_id             =     X_Code_Combination_Id,
       encumbrance_type_id             =     X_Encumbrance_Type_Id,
       last_update_login               =     X_Last_Update_Login,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_itr_charge_headers
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_IGI_ITR_CHARGE_HEADERS_PKG;

/
