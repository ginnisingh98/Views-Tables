--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_LINES_PKG" as
-- $Header: igiitrtb.pls 120.5.12000000.1 2007/09/12 10:32:50 mbremkum ship $
--


  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE  Insert_Row(X_Rowid                            IN OUT NOCOPY VARCHAR2,
                        X_It_Service_Line_Id               IN OUT NOCOPY NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER,
                        X_Creation_Date                    DATE,
                        X_Created_By                       NUMBER,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  ) IS

      CURSOR C  IS SELECT rowid
                   FROM   igi_itr_charge_lines
                   WHERE  it_service_line_id = X_It_Service_Line_Id;

      CURSOR C2 IS SELECT igi_itr_charge_lines_s.nextval FROM sys.dual;

    BEGIN

      IF X_It_Service_Line_Id is null THEN
        OPEN C2;
        FETCH C2 INTO X_It_Service_Line_Id;
        CLOSE C2;
      END IF;


      INSERT INTO igi_itr_charge_lines(
                       it_service_line_id
                      ,it_header_id
                      ,it_line_num
                      ,set_of_books_id
                      ,receiving_code_combination_id
                      ,creation_code_combination_id
                      ,charge_center_id
                      ,charge_service_id
                      ,service_id
                      ,crea_cost_center
                      ,crea_conf_segment_value
                      ,recv_cost_center
                      ,recv_conf_segment_value
                      ,effective_date
                      ,entered_dr
                      ,entered_cr
                      ,description
                      ,status_flag
                      ,posting_flag
                      ,submit_date
                      ,suggested_amount
                      ,rejection_note
                      ,failed_funds_lookup_code
                      ,encumbrance_flag
                      ,encumbered_amount
                      ,unencumbered_amount
                      ,gl_encumbered_date
                      ,gl_encumbered_period_name
                      ,gl_cancelled_date
                      ,prevent_encumbrance_flag
                      ,je_header_id
                      ,receiver_id
                      ,charge_range_id
                      ,creation_date
                      ,created_by
                      ,last_update_login
                      ,last_update_date
                      ,last_updated_by
                       ) VALUES (
                       X_It_Service_Line_Id
                      ,X_It_Header_Id
                      ,X_It_Line_Num
                      ,X_Set_Of_Books_Id
                      ,X_Receiving_Ccid
                      ,X_Creation_Ccid
                      ,X_Charge_Center_Id
                      ,X_Charge_Service_Id
                      ,X_Service_Id
                      ,X_Crea_Cost_Center
                      ,X_Crea_Conf_Segment_Value
                      ,X_Recv_Cost_Center
                      ,X_Recv_Conf_Segment_Value
                      ,X_Effective_Date
                      ,X_Entered_Dr
                      ,X_Entered_Cr
                      ,X_Description
                      ,X_Status_Flag
                      ,X_Posting_Flag
                      ,X_Submit_Date
                      ,X_Suggested_Amount
                      ,X_Rejection_Note
                      ,X_Failed_Funds_Lookup_code
                      ,X_Encumbrance_Flag
                      ,X_Encumbered_Amount
                      ,X_Unencumbered_Amount
                      ,X_Gl_Encumbered_Date
                      ,X_Gl_Encumbered_Period_Name
                      ,X_Gl_Cancelled_Date
                      ,X_Prevent_Encumbrance_Flag
                      ,X_Je_Header_Id
                      ,X_Receiver_Id
                      ,X_Charge_Range_Id
                      ,X_Creation_Date
                      ,X_Created_By
                      ,X_Last_Update_Login
                      ,X_Last_Update_Date
                      ,X_Last_Updated_By
                    );

                  OPEN C;
                  FETCH C INTO X_Rowid;
                  IF (C%NOTFOUND) THEN
                     CLOSE C;
                     RAISE NO_DATA_FOUND;
                  END IF;
                  CLOSE C;

   END Insert_Row;


  PROCEDURE    Lock_Row(X_Rowid                            VARCHAR2,
                        X_It_Service_Line_Id               NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER
  ) IS


       CURSOR C IS
         SELECT *
         FROM   igi_itr_charge_lines
         WHERE  rowid = X_Rowid
         FOR UPDATE of it_service_line_id NOWAIT;

       Recinfo  C%ROWTYPE;


    BEGIN

      OPEN C;
      FETCH C INTO Recinfo;
      IF (C%NOTFOUND) THEN
        CLOSE C;
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrtb.IGI_ITR_CHARGE_LINES_PKG.lock_row.msg1', FALSE);
	END IF;
        app_exception.raise_exception;
      END IF;
      CLOSE C;
      IF (
               (Recinfo.it_service_line_id              = X_It_Service_Line_Id)
          AND  (Recinfo.it_header_id                    = X_It_Header_Id)
          AND  (Recinfo.it_line_num                     = X_It_Line_Num)
          AND  (   (Recinfo.set_of_books_id                 = X_Set_Of_Books_Id)
                OR (    (Recinfo.set_of_books_id IS NULL)
                    AND (X_Set_Of_Books_Id IS NULL)))
          AND  (Recinfo.receiving_code_combination_id   = X_Receiving_Ccid)
          AND  (Recinfo.creation_code_combination_id    = X_Creation_Ccid)
          AND  (Recinfo.charge_center_id                = X_Charge_Center_Id)
          AND  (Recinfo.charge_service_id               = X_Charge_Service_Id)
          AND  (   (Recinfo.service_id                      = X_Service_Id)
                OR (    (Recinfo.service_id IS NULL)
                    AND (X_Service_Id IS NULL)))
          AND  (   (Recinfo.crea_cost_center            = X_Crea_Cost_Center)
                OR (    (Recinfo.crea_cost_center IS NULL)
                    AND (X_Crea_Cost_Center IS NULL)))
          AND  (   (Recinfo.crea_conf_segment_value     = X_Crea_Conf_Segment_Value)
                OR (    (Recinfo.crea_conf_segment_value IS NULL)
                    AND (X_Crea_Conf_Segment_Value IS NULL)))
          AND  (   (Recinfo.recv_cost_center            = X_Recv_Cost_Center)
                OR (    (Recinfo.recv_cost_center IS NULL)
                    AND (X_Recv_Cost_Center IS NULL)))
          AND  (   (Recinfo.recv_conf_segment_value     = X_Recv_Conf_Segment_Value)
                OR  (   (Recinfo.recv_conf_segment_value IS NULL)
                     AND (X_Recv_Conf_Segment_Value IS NULL)))
          AND  (   (Recinfo.effective_date                  = X_Effective_Date)
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
                    AND (X_Description Is NULL)))
          AND  (   (Recinfo.status_flag                 = X_Status_Flag)
                OR (    (Recinfo.status_flag IS NULL)
                    AND (X_Status_Flag IS NULL)))
          AND  (   (Recinfo.posting_flag                = X_Posting_Flag)
                OR (    (Recinfo.posting_flag IS NULL)
                    AND (X_Posting_Flag IS NULL)))
          AND  (   (Recinfo.submit_date                 = X_Submit_Date)
                OR (    (Recinfo.submit_date IS NULL)
                    AND (X_Submit_Date IS NULL)))
          AND  (   (Recinfo.suggested_amount            = X_Suggested_Amount)
                OR (    (Recinfo.suggested_amount IS NULL)
                    AND (X_Suggested_Amount IS NULL)))
          AND  (   (Recinfo.rejection_note              = X_Rejection_Note)
                OR (    (Recinfo.rejection_note IS NULL)
                    AND (X_Rejection_Note IS NULL)))
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
          AND  (   (Recinfo.gl_encumbered_period_name    = X_Gl_Encumbered_Period_Name)
                OR (    (Recinfo.gl_encumbered_period_name IS NULL)
                    AND (X_Gl_Encumbered_Period_Name IS NULL)))
          AND  (   (Recinfo.gl_cancelled_date            = X_Gl_Cancelled_Date)
                OR (    (Recinfo.gl_cancelled_date IS NULL)
                    AND (X_Gl_Cancelled_Date IS NULL)))
          AND  (   (Recinfo.prevent_encumbrance_flag     = X_Prevent_Encumbrance_Flag)
                OR (    (Recinfo.prevent_encumbrance_flag IS NULL)
                    AND (X_Prevent_Encumbrance_Flag IS NULL)))
          AND  (   (Recinfo.je_header_id                     = X_Je_Header_Id)
                OR (    (Recinfo.je_header_id IS NULL)
                    AND (X_Je_Header_Id IS NULL)))
          AND  (   (Recinfo.receiver_id                      = X_Receiver_Id)
                OR (    (Recinfo.receiver_id IS NULL)
                    AND (X_Receiver_Id IS NULL)))
          AND  (   (Recinfo.charge_range_id                  = X_Charge_Range_Id)
                OR (    (Recinfo.charge_range_id IS NULL)
                    AND (X_Charge_Range_Id IS NULL)))
         )  THEN
              return;
            ELSE
              fnd_message.set_name('FND','FORM_RECORD_CHANGED');
	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrtb.IGI_ITR_CHARGE_LINES_PKG.lock_row.msg2', FALSE);
	END IF;
              APP_EXCEPTION.raise_exception;
            END IF;

    END Lock_Row;



  PROCEDURE  Update_Row(X_Rowid                            VARCHAR2,
                        X_It_Service_Line_Id               NUMBER,
                        X_It_Header_Id                     NUMBER,
                        X_It_Line_Num                      NUMBER,
                        X_Set_Of_Books_Id                  NUMBER,
                        X_Receiving_Ccid                   NUMBER,
                        X_Creation_Ccid                    NUMBER,
                        X_Charge_Center_Id                 NUMBER,
                        X_Charge_Service_Id                NUMBER,
                        X_Service_Id                       NUMBER,
                        X_Crea_Cost_Center                 VARCHAR2,
                        X_Crea_Conf_Segment_Value          VARCHAR2,
                        X_Recv_Cost_Center                 VARCHAR2,
                        X_Recv_Conf_Segment_Value          VARCHAR2,
                        X_Effective_Date                   DATE,
                        X_Entered_Dr                       NUMBER,
                        X_Entered_Cr                       NUMBER,
                        X_Description                      VARCHAR2,
                        X_Status_Flag                      VARCHAR2,
                        X_Posting_Flag                     VARCHAR2,
                        X_Submit_Date                      DATE,
                        X_Suggested_Amount                 NUMBER,
                        X_Rejection_Note                   VARCHAR2,
                        X_Failed_Funds_Lookup_code         VARCHAR2,
                        X_Encumbrance_Flag                 VARCHAR2,
                        X_Encumbered_Amount                NUMBER,
                        X_Unencumbered_Amount              NUMBER,
                        X_Gl_Encumbered_Date               DATE,
                        X_Gl_Encumbered_Period_Name        VARCHAR2,
                        X_Gl_Cancelled_Date                DATE,
                        X_Prevent_Encumbrance_Flag         VARCHAR2,
                        X_Je_Header_Id                     NUMBER,
                        X_Receiver_Id                      NUMBER,
                        X_Charge_Range_Id                  NUMBER,
                        X_Last_Update_Login                NUMBER,
                        X_Last_Update_Date                 DATE,
                        X_Last_Updated_By                  NUMBER
  ) IS
    BEGIN

      UPDATE igi_itr_charge_lines
      SET
              it_service_line_id                 = X_It_Service_Line_Id,
              it_header_id                       = X_It_Header_Id,
              it_line_num                        = X_It_Line_Num,
              set_of_books_id                    = X_Set_Of_Books_Id,
              receiving_code_combination_id      = X_Receiving_Ccid,
              creation_code_combination_id       = X_Creation_Ccid,
              charge_center_id                   = X_Charge_Center_Id,
              charge_service_id                  = X_Charge_Service_Id,
              service_id                         = X_Service_Id,
              crea_cost_center                   = X_Crea_Cost_Center,
              crea_conf_segment_value            = X_Crea_Conf_Segment_Value,
              recv_cost_center                   = X_Recv_Cost_Center,
              recv_conf_segment_value            = X_Recv_Conf_Segment_Value,
              effective_date                     = X_Effective_Date,
              entered_dr                         = X_Entered_Dr,
              entered_cr                         = X_Entered_Cr,
              description                        = X_Description,
              status_flag                        = X_Status_Flag,
              posting_flag                       = X_Posting_Flag,
              submit_date                        = X_Submit_Date,
              suggested_amount                   = X_Suggested_Amount,
              rejection_note                     = X_Rejection_Note,
              failed_funds_lookup_code           = X_Failed_Funds_Lookup_Code,
              encumbrance_flag                   = X_Encumbrance_Flag,
              encumbered_amount                  = X_Encumbered_Amount,
              unencumbered_amount                = X_Unencumbered_Amount,
              gl_encumbered_date                 = X_Gl_Encumbered_Date,
              gl_encumbered_period_name          = X_GL_Encumbered_Period_Name,
              gl_cancelled_date                  = X_Gl_Cancelled_Date,
              prevent_encumbrance_flag           = X_Prevent_Encumbrance_Flag,
              je_header_id                       = X_Je_Header_Id,
              receiver_id                        = X_Receiver_Id,
              charge_range_id                    = X_Charge_Range_Id,
              last_update_login                  = X_Last_Update_Login,
              last_update_date                   = X_Last_Update_Date,
              last_updated_by                    = X_Last_Updated_By
      WHERE rowid = X_Rowid;

      IF SQL%NOTFOUND THEN
        raise NO_DATA_FOUND;
      END IF;

  END Update_Row;



  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM igi_itr_charge_lines
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;



  PROCEDURE check_unique(x_rowid          VARCHAR2,
                         x_it_line_num    NUMBER,
                         x_it_header_id   NUMBER) IS

    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   igi_itr_charge_lines cl
      WHERE  cl.it_line_num = x_it_line_num
      AND    cl.it_header_id = x_it_header_id
      AND    (x_rowid IS NULL
              OR
              cl.rowid <> x_rowid);

    dummy   VARCHAR2(30);

  BEGIN

    OPEN c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name('IGI','IGI_ITR_DPL_LINE_NO');
	IF( l_error_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrtb.IGI_ITR_CHARGE_LINES_PKG.check_unique.msg3', FALSE);
	END IF;
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  END check_unique;


  -- OPSF(I) ITR  Bug 1764441  22-May-2001 S Brewer Start(1)
  -- This procedure is called from igi_itr_charge_headers_pkg.delete_row
  -- to delete all service lines before deleting the charge header
  PROCEDURE delete_lines(X_It_Header_Id NUMBER) IS
  BEGIN

    DELETE FROM igi_itr_charge_lines
    WHERE  it_header_id = X_It_Header_Id;


  END delete_lines;
  -- OPSF(I) ITR  Bug 1764441  22-May-2001 S Brewer End(1)


END IGI_ITR_CHARGE_LINES_PKG;

/
