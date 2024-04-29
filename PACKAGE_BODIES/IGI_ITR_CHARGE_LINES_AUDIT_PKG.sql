--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_LINES_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_LINES_AUDIT_PKG" as
-- $Header: igiitrqb.pls 120.5.12000000.1 2007/09/12 10:32:25 mbremkum ship $
--

  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE  Insert_Row(X_It_Service_Line_Id               IN OUT NOCOPY NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Failed_Funds_Lookup_Code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Reversal_Flag                    VARCHAR2,
                        X_Creation_Date                    DATE,
                        X_Created_By                       NUMBER,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  ) IS
/*
      CURSOR C  IS SELECT rowid
                   FROM   igi_itr_charge_lines_audit
                   WHERE  it_service_line_id = X_It_Service_Line_Id;
*/


    BEGIN


      INSERT INTO igi_itr_charge_lines_audit(
                          it_service_line_id,
                          it_header_id,
                          it_line_num,
                          set_of_books_id,
                          charge_center_id,
                          effective_date,
                          entered_dr,
                          entered_cr,
                          description,
                          status_flag,
                          posting_flag,
                          submit_date,
                          suggested_amount,
                          rejection_note,
                          receiving_code_combination_id,
                          creation_code_combination_id,
                          charge_service_id,
                          failed_funds_lookup_code,
                          encumbrance_flag,
                          encumbered_amount,
                          unencumbered_amount,
                          gl_encumbered_date,
                          gl_encumbered_period_name,
                          gl_cancelled_date,
                          prevent_encumbrance_flag,
                          je_header_id,
                          reversal_flag,
                          creation_date,
                          created_by,
                          last_update_login,
                          last_update_date,
                          last_updated_by
                          ) VALUES (
                          X_It_Service_Line_Id,
                          X_It_Header_Id,
                          X_It_Line_Num,
                          X_Set_Of_Books_Id,
                          X_Charge_Center_Id,
                          X_Effective_Date,
                          X_Entered_Dr,
                          X_Entered_Cr,
                          X_Description,
                          X_Status_Flag,
                          X_Posting_Flag,
                          X_Submit_Date,
                          X_Suggested_Amount,
                          X_Rejection_Note,
                          X_Receiving_Ccid,
                          X_Creation_Ccid,
                          X_Charge_Service_Id,
                          X_Failed_Funds_Lookup_Code,
                          X_Encumbrance_Flag,
                          X_Encumbered_Amount,
                          X_Unencumbered_Amount,
                          X_Gl_Encumbered_Date,
                          X_Gl_Encumbered_Period_Name,
                          X_Gl_Cancelled_Date,
                          X_Prevent_Encumbrance_Flag,
                          X_Je_Header_Id,
                          X_Reversal_Flag,
                          X_Creation_Date,
                          X_Created_By,
                          X_Last_Update_Login,
                          X_Last_Update_Date,
                          X_Last_Updated_By
                   );
/*****
                  OPEN C;
                  FETCH C INTO X_Rowid;
                  IF (C%NOTFOUND) THEN
                     CLOSE C;
                     RAISE NO_DATA_FOUND;
                  END IF;
                  CLOSE C;
****/

   END Insert_Row;


  PROCEDURE    Lock_Row(X_It_Service_Line_Id               IN OUT NOCOPY NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Failed_Funds_Lookup_Code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Reversal_Flag                    VARCHAR2
     ) IS



       CURSOR C IS
         SELECT *
         FROM   igi_itr_charge_lines_audit
         WHERE  it_service_line_id  = X_It_Service_Line_Id
         AND    reversal_flag = 'N'
         FOR UPDATE of it_service_line_id NOWAIT;

       Recinfo  C%ROWTYPE;


    BEGIN

      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrqb.IGI_ITR_CHARGE_LINES_AUDIT_PKG.lock_row.msg1', FALSE);
	END IF;
        app_exception.raise_exception;
      END IF;
      CLOSE C;

      IF (
               (   (Recinfo.it_service_line_id          = X_It_Service_Line_Id)
                OR (    (Recinfo.it_service_line_id IS NULL)
                    AND (X_It_Service_Line_Id IS NULL)))
          AND  (   (Recinfo.it_header_id                = X_It_Header_Id)
                OR (    (Recinfo.it_header_id IS NULL)
                    AND (X_It_Header_Id IS NULL)))
          AND  (   (Recinfo.it_line_num                 = X_It_Line_Num)
                OR (    (Recinfo.it_line_num IS NULL)
                    AND (X_It_Line_Num IS NULL)))
          AND  (   (Recinfo.set_of_books_id             = X_Set_Of_Books_Id)
                OR (    (Recinfo.set_of_books_id IS NULL)
                    AND (X_Set_Of_Books_Id IS NULL)))
          AND  (   (Recinfo.charge_center_id            = X_Charge_Center_Id)
                OR (    (Recinfo.charge_center_id IS NULL)
                    AND (X_Charge_Center_Id IS NULL)))
          AND  (   (Recinfo.effective_date              = X_Effective_Date)
                OR (    (Recinfo.effective_date IS NULL)
                    AND (X_Effective_Date IS NULL)))
          AND  (   (Recinfo.entered_dr                  = X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
          AND  (   (Recinfo.entered_cr                  = X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
          AND  (   (Recinfo.description                 = X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
          AND  (   (Recinfo.status_flag                 = X_Status_Flag)
                OR (    (Recinfo.status_flag IS NULL)
                    AND (X_Status_Flag IS NULL)))
          AND  (   (Recinfo.posting_flag                = X_Posting_Flag)
                OR (    (Recinfo.posting_flag IS NULL)
                    AND (X_Posting_Flag IS NULL)))
          AND  (   (Recinfo.Submit_Date                 = X_Submit_Date)
                OR (    (Recinfo.submit_date IS NULL)
                    AND (X_Submit_Date IS NULL)))
          AND  (   (Recinfo.Suggested_Amount            = X_Suggested_Amount)
                OR (    (Recinfo.suggested_amount IS NULL)
                    AND (X_Suggested_Amount IS NULL)))
          AND  (   (Recinfo.Rejection_Note              = X_Rejection_Note)
                OR (    (Recinfo.rejection_note IS NULL)
                    AND (X_Rejection_Note IS NULL)))
          AND  (   (Recinfo.receiving_code_combination_id   = X_Receiving_Ccid)
                OR (    (Recinfo.receiving_code_combination_id IS NULL)
                    AND (X_Receiving_Ccid IS NULL)))
          AND  (   (Recinfo.creation_code_combination_id    = X_Creation_Ccid)
                OR (    (Recinfo.creation_code_combination_id IS NULL)
                    AND (X_Creation_Ccid IS NULL)))
          AND  (   (Recinfo.charge_service_id           = X_Charge_Service_Id)
                OR (    (Recinfo.charge_service_id IS NULL)
                    AND (X_Charge_Service_Id IS NULL)))
          AND  (   (Recinfo.failed_funds_lookup_code    = X_Failed_Funds_Lookup_Code)
                OR (    (Recinfo.failed_funds_lookup_code IS NULL)
                    AND (X_Failed_Funds_Lookup_Code IS NULL)))
          AND  (   (Recinfo.encumbrance_flag            = X_Encumbrance_Flag)
                OR (    (Recinfo.encumbrance_flag IS NULL)
                    AND (X_Encumbrance_Flag IS NULL)))
          AND  (   (Recinfo.encumbered_amount           = X_Encumbered_Amount)
                OR (    (Recinfo.encumbered_amount IS NULL)
                    AND (X_Encumbered_Amount IS NULL)))
          AND  (   (Recinfo.unencumbered_amount         = X_Unencumbered_Amount)
                OR (    (Recinfo.unencumbered_amount IS NULL)
                    AND (X_Unencumbered_Amount IS NULL)))
          AND  (   (Recinfo.gl_encumbered_date          = X_Gl_Encumbered_Date)
                OR (    (Recinfo.gl_encumbered_date IS NULL)
                    AND (X_Gl_Encumbered_Date IS NULL)))
          AND  (   (Recinfo.gl_encumbered_period_name   = X_Gl_Encumbered_Period_Name)
                OR (    (Recinfo.gl_encumbered_period_name IS NULL)
                    AND (X_Gl_Encumbered_Period_Name IS NULL)))
          AND  (   (Recinfo.gl_cancelled_date           = X_Gl_Cancelled_Date)
                OR (    (Recinfo.gl_cancelled_date IS NULL)
                    AND (X_Gl_Cancelled_Date IS NULL)))
          AND  (   (Recinfo.prevent_encumbrance_flag    = X_Prevent_Encumbrance_Flag)
                OR (    (Recinfo.prevent_encumbrance_flag IS NULL)
                    AND (X_Prevent_Encumbrance_Flag IS NULL)))
          AND  (   (Recinfo.je_header_id                = X_Je_Header_Id)
                OR (    (Recinfo.je_header_id IS NULL)
                    AND (X_Je_Header_Id IS NULL)))
          AND  (   (Recinfo.reversal_flag                = X_Reversal_Flag)
                OR (    (Recinfo.reversal_flag IS NULL)
                    AND (X_Reversal_Flag IS NULL)))
         )  THEN
              return;
            ELSE
              fnd_message.set_name('FND','FORM_RECORD_CHANGED');
	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrqb.IGI_ITR_CHARGE_LINES_AUDIT_PKG.lock_row.msg2', FALSE);
	END IF;
              APP_EXCEPTION.raise_exception;
            END IF;

    END Lock_Row;





  PROCEDURE  Update_Row(X_It_Service_Line_Id               IN OUT NOCOPY NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Failed_Funds_Lookup_Code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Reversal_Flag                    VARCHAR2,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  ) IS
    BEGIN

      UPDATE igi_itr_charge_lines_audit
      SET
              it_service_line_id                = X_It_Service_Line_Id,
              it_header_id                       = X_It_Header_Id,
              it_line_num                        = X_It_Line_Num,
              set_of_books_id                    = X_Set_Of_Books_Id,
              charge_center_id                   = X_Charge_Center_Id,
              effective_date                     = X_Effective_Date,
              entered_dr                         = X_Entered_Dr,
              entered_cr                         = X_Entered_Cr,
              description                        = X_Description,
              status_flag                        = X_Status_Flag,
              posting_flag                       = X_Posting_Flag,
              submit_date                        = X_Submit_Date,
              suggested_amount                   = X_Suggested_Amount,
              rejection_note                     = X_Rejection_Note,
              receiving_code_combination_id      = X_Receiving_Ccid,
              creation_code_combination_id       = X_Creation_Ccid,
              charge_service_id                  = X_Charge_Service_Id,
              failed_funds_lookup_code           = X_Failed_Funds_Lookup_Code,
              encumbrance_flag                   = X_Encumbrance_Flag,
              encumbered_amount                  = X_Encumbered_Amount,
              unencumbered_amount                = X_Unencumbered_Amount,
              gl_encumbered_date                 = X_Gl_Encumbered_Date,
              gl_encumbered_period_name          = X_Gl_Encumbered_Period_Name,
              gl_cancelled_date                  = X_Gl_Cancelled_Date,
              prevent_encumbrance_flag           = X_Prevent_Encumbrance_Flag,
              je_header_id                       = X_Je_Header_Id,
              reversal_flag                      = X_Reversal_Flag,
              last_update_login                  = X_Last_Update_Login,
              last_update_date                   = X_Last_Update_Date,
              last_updated_by                    = X_Last_Updated_By
      WHERE it_service_line_id = X_It_Service_Line_Id
      AND   reversal_flag = 'N';

      IF SQL%NOTFOUND THEN
        raise NO_DATA_FOUND;
      END IF;

  END Update_Row;



END IGI_ITR_CHARGE_LINES_AUDIT_PKG;

/
