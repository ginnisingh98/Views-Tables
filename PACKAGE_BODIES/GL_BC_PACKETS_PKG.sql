--------------------------------------------------------
--  DDL for Package Body GL_BC_PACKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_PACKETS_PKG" AS
/* $Header: glibcpab.pls 120.6 2005/07/29 16:58:18 djogg ship $ */

--
-- PRIVATE FUNCTIONS
--
PROCEDURE Lock_Budget_Transfer_Row(
		   X_Rowid                            	   VARCHAR2,
		   X_Status_Code			   VARCHAR2,
		   X_Packet_Id				   NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Je_Source_Name                        VARCHAR2,
                   X_Je_Category_Name                      VARCHAR2,
		   X_Code_Combination_Id		   NUMBER,
		   X_Period_Name			   VARCHAR2,
	   	   X_Period_Year			   NUMBER,
		   X_Period_Num				   NUMBER,
	 	   X_Quarter_Num			   NUMBER,
                   X_Currency_Code                         VARCHAR2,
		   X_Budget_Version_Id			   NUMBER,
                   X_Entered_Dr                            NUMBER,
                   X_Entered_Cr                            NUMBER,
		   X_Je_Batch_Name			   VARCHAR2,
		   X_Combination_Number			   NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_BC_PACKETS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Packet_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN

  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  if (
          (   (Recinfo.status_code = X_Status_Code)
           OR (    (Recinfo.status_code IS NULL)
               AND (X_Status_Code IS NULL)))
      AND (   (Recinfo.packet_id = X_Packet_Id)
           OR (    (Recinfo.packet_id IS NULL)
               AND (X_Packet_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.je_source_name = X_Je_Source_Name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_Je_Source_Name IS NULL)))
      AND (   (Recinfo.je_category_name = X_Je_Category_Name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_Category_Name IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (Recinfo.actual_flag = 'B')
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.period_year = X_Period_Year)
           OR (    (Recinfo.period_year IS NULL)
               AND (X_Period_Year IS NULL)))
      AND (   (Recinfo.period_num = X_Period_Num)
           OR (    (Recinfo.period_num IS NULL)
               AND (X_Period_Num IS NULL)))
      AND (   (Recinfo.quarter_num = X_Quarter_Num)
           OR (    (Recinfo.quarter_num IS NULL)
               AND (X_Quarter_Num IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.entered_dr = X_Entered_Dr)
           OR (    (Recinfo.entered_dr IS NULL)
               AND (X_Entered_Dr IS NULL)))
      AND (   (Recinfo.entered_cr = X_Entered_Cr)
           OR (    (Recinfo.entered_cr IS NULL)
               AND (X_Entered_Cr IS NULL)))
      AND (   (Recinfo.reference1 = X_Combination_Number)
           OR (    (Recinfo.reference1 IS NULL)
               AND (X_Combination_Number IS NULL)))
      AND (   (Recinfo.je_batch_name = X_Je_Batch_Name)
           OR (    (Recinfo.je_batch_name IS NULL)
               AND (X_Je_Batch_Name IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Budget_Transfer_Row;


--
-- PUBLIC FUNCTIONS
--

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_bc_packets_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_BC_PACKETS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_bc_packets_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  FUNCTION insert_je_packet(batch_id NUMBER,
			    lgr_id NUMBER,
                            mode_code VARCHAR2,
                            user_id NUMBER,
                            x_session_id NUMBER,
                            x_serial_id NUMBER) RETURN NUMBER IS
    new_packet_id NUMBER;
    insert_mode	  VARCHAR2(1);
  BEGIN
    -- Get the packet id
    new_packet_id := gl_bc_packets_pkg.get_unique_id;

    -- Set the funds check mode
    IF (mode_code = 'R') THEN
      insert_mode := 'P';
    ELSE
      insert_mode := 'C';
    END IF;

    -- Insert the data into gl_je_packets
    INSERT INTO gl_bc_packets
      (packet_id, ledger_id, je_source_name,
       je_category_name, code_combination_id, actual_flag,
       period_name, period_year, period_num, quarter_num,
       currency_code, status_code,
       last_update_date, last_updated_by,
       budget_version_id, encumbrance_type_id,
       entered_dr, entered_cr, accounted_dr, accounted_cr,
       ussgl_transaction_code, je_batch_id, je_header_id, je_line_num,
       application_id, session_id, serial_id)
    SELECT new_packet_id, jeh.ledger_id, jeh.je_source,
           jeh.je_category, jel.code_combination_id, jeb.actual_flag,
           per.period_name, per.period_year, per.period_num, per.quarter_num,
           jeh.currency_code, insert_mode,
           sysdate, user_id,
           jeh.budget_version_id, jeh.encumbrance_type_id,
           jel.entered_dr, jel.entered_cr, jel.accounted_dr,jel.accounted_cr,
           jel.ussgl_transaction_code, jeh.je_batch_id, jeh.je_header_id,
           jel.je_line_num, 101, x_session_id, x_serial_id
    FROM gl_je_batches jeb, gl_period_statuses per, gl_je_headers jeh,
         gl_je_lines jel
    WHERE jeb.je_batch_id = batch_id
    AND   per.application_id = 101
    AND   per.ledger_id = jeh.ledger_id
    AND   per.period_name = jeb.default_period_name
    AND   jeh.je_batch_id = jeb.je_batch_id
    AND   jeh.ledger_id = lgr_id
    AND   jel.je_header_id = jeh.je_header_id;

    RETURN (new_packet_id);
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_bc_packets_pkg.insert_je_packet');
      RAISE;
  END insert_je_packet;

  FUNCTION exists_packet(xpacket_id NUMBER) RETURN BOOLEAN IS
    CURSOR check_for_pkt IS
      SELECT 'Has packet'
      FROM dual
      WHERE EXISTS (SELECT 'Has packet'
                    FROM gl_bc_packets
                    WHERE packet_id = xpacket_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN check_for_pkt;
    FETCH check_for_pkt INTO dummy;

    IF check_for_pkt%FOUND THEN
      CLOSE check_for_pkt;
      return(TRUE);
    ELSE
      CLOSE check_for_pkt;
      return(FALSE);
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_bc_packets_pkg.exists_packet');
      RAISE;
  END exists_packet;

  FUNCTION get_ledger_id(xpacket_id NUMBER) RETURN NUMBER IS
    CURSOR get_lgr_id IS
      SELECT ledger_id
      FROM gl_bc_packets
      WHERE packet_id = xpacket_id;
    lgr_id NUMBER;
  BEGIN
    OPEN get_lgr_id;
    FETCH get_lgr_id INTO lgr_id;

    IF get_lgr_id%FOUND THEN
      CLOSE get_lgr_id;
      return(lgr_id);
    ELSE
      CLOSE get_lgr_id;
      Raise NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_bc_packets_pkg.get_ledger_id');
      RAISE;
  END get_ledger_id;

  PROCEDURE Insert_Budget_Transfer_Row(
		     X_From_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_To_Rowid                     IN OUT NOCOPY VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
		     X_To_Entered_Dr			   NUMBER,
		     X_To_Entered_Cr			   NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Session_Id                          NUMBER,
                     X_Serial_Id                           NUMBER) IS
   CURSOR C (ccid IN NUMBER, unique_value IN VARCHAR2) IS
                 SELECT rowid FROM GL_BC_PACKETS
                 WHERE packet_id           = X_Packet_Id
		 AND   ledger_id           = X_Ledger_Id
		 AND   reference2          = unique_value
                 AND   code_combination_id = ccid
                 AND   reference1          = to_char(X_Combination_Number)
                 AND   period_name         = X_Period_Name;
BEGIN

  -- Insert the From line
  INSERT INTO GL_BC_PACKETS(
	  status_code,
	  packet_id,
          ledger_id,
          je_source_name,
          je_category_name,
	  code_combination_id,
          actual_flag,
          period_name,
	  period_year,
	  period_num,
	  quarter_num,
	  currency_code,
	  last_update_date,
	  last_updated_by,
	  budget_version_id,
          entered_dr,
          entered_cr,
	  accounted_dr,
	  accounted_cr,
	  je_batch_name,
          application_id,
          session_id,
          serial_id,
	  reference1,
          reference2
         ) VALUES (
          X_Status_Code,
	  X_Packet_Id,
          X_Ledger_Id,
          X_Je_Source_Name,
          X_Je_Category_Name,
          X_From_Code_Combination_Id,
	  'B',
          X_Period_Name,
	  X_Period_Year,
	  X_Period_Num,
	  X_Quarter_Num,
          X_Currency_Code,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Budget_Version_Id,
          X_From_Entered_Dr,
          X_From_Entered_Cr,
	  X_From_Entered_Dr,
	  X_From_Entered_Cr,
          X_Je_Batch_Name,
          101,
          X_Session_Id,
          X_Serial_Id,
          X_Combination_Number,
          'New Budget Transfer Row');

  OPEN C(X_From_Code_Combination_Id, 'New Budget Transfer Row');
  FETCH C INTO X_From_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- Insert the to line, switching the Cr and Dr
  INSERT INTO GL_BC_PACKETS(
	  status_code,
	  packet_id,
          ledger_id,
          je_source_name,
          je_category_name,
	  code_combination_id,
          actual_flag,
          period_name,
	  period_year,
	  period_num,
	  quarter_num,
	  currency_code,
	  last_update_date,
	  last_updated_by,
	  budget_version_id,
          entered_dr,
          entered_cr,
	  accounted_dr,
	  accounted_cr,
	  je_batch_name,
          application_id,
          session_id,
          serial_id,
	  reference1,
          reference2
         ) VALUES (
          X_Status_Code,
	  X_Packet_Id,
          X_Ledger_Id,
          X_Je_Source_Name,
          X_Je_Category_Name,
          X_To_Code_Combination_Id,
	  'B',
          X_Period_Name,
	  X_Period_Year,
	  X_Period_Num,
	  X_Quarter_Num,
          X_Currency_Code,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Budget_Version_Id,
          X_To_Entered_Dr,
          X_To_Entered_Cr,
	  X_To_Entered_Dr,
	  X_To_Entered_Cr,
          X_Je_Batch_Name,
          101,
          X_Session_Id,
          X_Serial_Id,
          X_Combination_Number,
          X_From_RowId);

  OPEN C(X_To_Code_Combination_Id, X_From_RowId);
  FETCH C INTO X_To_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;


  -- Change the from reference2 to the to rowid.
  UPDATE GL_BC_PACKETS
  SET    reference2          = X_To_RowId
  WHERE  packet_id           = X_Packet_Id
  AND    ledger_id           = X_Ledger_Id
  AND    reference2          = 'New Budget Transfer Row'
  AND    code_combination_id = X_From_Code_Combination_Id
  AND    reference1          = to_char(X_Combination_Number)
  AND    period_name         = X_Period_Name;

END Insert_Budget_Transfer_Row;

PROCEDURE Update_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
		     X_To_Entered_Dr			   NUMBER,
		     X_To_Entered_Cr			   NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER) IS
BEGIN
  UPDATE GL_BC_PACKETS
  SET
    status_code           = X_Status_Code,
    packet_id		  = X_Packet_Id,
    ledger_id             = X_Ledger_Id,
    je_source_name        = X_Je_Source_Name,
    je_category_name      = X_Je_Category_Name,
    code_combination_id   = decode(rowid,
                                   X_From_Rowid, X_From_Code_Combination_Id,
				   X_To_Rowid, X_To_Code_Combination_Id),
    actual_flag           = 'B',
    period_name           = X_Period_Name,
    period_year		  = X_Period_Year,
    period_num		  = X_Period_Num,
    quarter_num		  = X_Quarter_Num,
    currency_code         = X_Currency_Code,
    last_update_date	  = X_Last_Update_Date,
    last_updated_by	  = X_Last_Updated_By,
    budget_version_id     = X_Budget_Version_Id,
    entered_dr            = decode(rowid,
				   X_From_Rowid, X_From_Entered_Dr,
				   X_To_Rowid, X_To_Entered_Dr),
    entered_cr            = decode(rowid,
				   X_From_Rowid, X_From_Entered_Cr,
				   X_To_Rowid, X_To_Entered_Cr),
    accounted_dr          = decode(rowid,
				   X_From_Rowid, X_From_Entered_Dr,
				   X_To_Rowid, X_To_Entered_Dr),
    accounted_cr          = decode(rowid,
				   X_From_Rowid, X_From_Entered_Cr,
				   X_To_Rowid, X_To_Entered_Cr),
    je_batch_name         = X_Je_Batch_Name,
    reference1            = X_Combination_Number
  WHERE rowid IN (X_From_Rowid, X_To_RowId);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Budget_Transfer_Row;

PROCEDURE Lock_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status_Code			   VARCHAR2,
                     X_Packet_Id                           NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
		     X_Period_Year			   NUMBER,
		     X_Period_Num			   NUMBER,
		     X_Quarter_Num			   NUMBER,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
		     X_To_Entered_Dr			   NUMBER,
		     X_To_Entered_Cr			   NUMBER) IS
BEGIN

  -- Lock the from row
  GL_BC_PACKETS_PKG.Lock_Budget_Transfer_Row(
          X_Rowid                => X_From_RowId,
	  X_Status_Code		 => X_Status_Code,
	  X_Packet_Id		 => X_Packet_Id,
          X_Ledger_Id            => X_Ledger_Id,
          X_Je_Source_Name       => X_Je_Source_Name,
          X_Je_Category_Name     => X_Je_Category_Name,
          X_Code_Combination_Id  => X_From_Code_Combination_Id,
          X_Period_Name          => X_Period_Name,
	  X_Period_Year		 => X_Period_Year,
	  X_Period_Num		 => X_Period_Num,
	  X_Quarter_Num		 => X_Quarter_Num,
          X_Currency_Code        => X_Currency_Code,
          X_Budget_Version_Id    => X_Budget_Version_Id,
          X_Entered_Dr           => X_From_Entered_Dr,
          X_Entered_Cr           => X_From_Entered_Cr,
          X_Combination_Number   => X_Combination_Number,
          X_Je_Batch_Name        => X_Je_Batch_Name
  );

  -- Lock the to row
  GL_BC_PACKETS_PKG.Lock_Budget_Transfer_Row(
          X_Rowid                => X_To_RowId,
	  X_Status_Code		 => X_Status_Code,
	  X_Packet_Id		 => X_Packet_Id,
          X_Ledger_Id            => X_Ledger_Id,
          X_Je_Source_Name       => X_Je_Source_Name,
          X_Je_Category_Name     => X_Je_Category_Name,
          X_Code_Combination_Id  => X_To_Code_Combination_Id,
          X_Period_Name          => X_Period_Name,
	  X_Period_Year		 => X_Period_Year,
	  X_Period_Num		 => X_Period_Num,
	  X_Quarter_Num		 => X_Quarter_Num,
          X_Currency_Code        => X_Currency_Code,
          X_Budget_Version_Id    => X_Budget_Version_Id,
          X_Entered_Dr           => X_To_Entered_Dr,
          X_Entered_Cr           => X_To_Entered_Cr,
          X_Combination_Number   => X_Combination_Number,
          X_Je_Batch_Name        => X_Je_Batch_Name
  );

END Lock_Budget_Transfer_Row;

PROCEDURE Delete_Budget_Transfer_Row(X_From_Rowid VARCHAR2,
                                     X_To_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_BC_PACKETS
  WHERE  rowid IN (X_From_Rowid, X_To_Rowid);

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Budget_Transfer_Row;

  PROCEDURE Delete_Packet(Packet_Id      NUMBER,
			  Reference1     NUMBER DEFAULT NULL) IS
  BEGIN
    DELETE gl_bc_packets
    WHERE packet_id = Delete_Packet.packet_id
    AND   status_code IN ('P', 'C')
    AND   nvl(reference1,'XZYXZ')
            = nvl(Delete_Packet.reference1, nvl(reference1, 'XZYXZ'));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
  END Delete_Packet;

  FUNCTION copy_packet(packet_id NUMBER,
                       mode_code VARCHAR2,
                       user_id NUMBER,
                       x_session_id NUMBER,
                       x_serial_id NUMBER) RETURN NUMBER IS
    new_packet_id NUMBER;
    insert_mode	  VARCHAR2(1);
  BEGIN
    -- Get the packet id
    new_packet_id := gl_bc_packets_pkg.get_unique_id;

    -- Set the funds check mode
    IF (mode_code = 'R') THEN
      insert_mode := 'P';
    ELSE
      insert_mode := 'C';
    END IF;

    -- Insert the data into gl_je_packets
    INSERT INTO gl_bc_packets
      (packet_id, ledger_id, je_source_name,
       je_category_name, code_combination_id, actual_flag,
       period_name, period_year, period_num, quarter_num,
       currency_code, status_code,
       last_update_date, last_updated_by, budget_version_id,
       entered_dr, entered_cr, accounted_dr, accounted_cr,
       ussgl_transaction_code, je_batch_name,
       application_id, session_id, serial_id)
    SELECT new_packet_id, bc.ledger_id, bc.je_source_name,
           bc.je_category_name, bc.code_combination_id, bc.actual_flag,
           bc.period_name, bc.period_year, bc.period_num, bc.quarter_num,
           bc.currency_code, insert_mode,
           sysdate, user_id, bc.budget_version_id,
           bc.entered_dr, bc.entered_cr, bc.accounted_dr, bc.accounted_cr,
           bc.ussgl_transaction_code, bc.je_batch_name,
           101, x_session_id, x_serial_id
    FROM gl_bc_packets bc
    WHERE bc.packet_id = copy_packet.packet_id;

    RETURN (new_packet_id);
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_bc_packets_pkg.copy_packet');
      RAISE;
  END copy_packet;

  FUNCTION view_bc_results_setup(packet_id NUMBER,
                                 ledger_id NUMBER) RETURN NUMBER IS
    seq_id  NUMBER;
    errbuf  VARCHAR2(80);
    retcode VARCHAR2(80);
  BEGIN
    DELETE FROM PSA_BC_REPORT_EVENTS_GT;
    INSERT INTO PSA_BC_REPORT_EVENTS_GT(packet_id) VALUES (packet_id);

    SELECT PSA_BC_XML_REPORT_S.nextval
    INTO seq_id
    FROM dual;

    PSA_BC_XML_REPORT_PUB.Create_BC_Transaction_Report(
      errbuf => errbuf,
      retcode => retcode,
      p_ledger_id => ledger_id,
      p_application_id => 101,
      p_packet_event_flag => 'P',
      p_sequence_id => seq_id);

    RETURN(seq_id);
  END view_bc_results_setup;

END gl_bc_packets_pkg;

/
