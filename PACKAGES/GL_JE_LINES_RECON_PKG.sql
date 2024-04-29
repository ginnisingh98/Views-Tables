--------------------------------------------------------
--  DDL for Package GL_JE_LINES_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_LINES_RECON_PKG" AUTHID CURRENT_USER as
/* $Header: glirclns.pls 120.4 2005/05/05 01:19:16 kvora ship $ */

--
-- Package
--   GL_JE_LINES_RECON_PKG
-- Purpose
--   To implement various data checking needed for the
--   gl_je_lines_recon table
-- History
--   07-JUN-2004  D J Ogg          Created.
--

  --
  -- Procedure
  --   insert_rows_for_batch
  -- Purpose
  --   Inserts any missing reconciliation rows for a batch
  -- History
  --   09-JUN-2004  D. J. Ogg    Created
  -- Arguments
  --   X_Je_Batch_Id    The batch id for which rows should be added
  -- Example
  --   gl_je_lines_recon_pkg.insert_rows_for_batch(500);
  -- Notes
  --
  PROCEDURE insert_rows_for_batch(X_Je_Batch_Id  	NUMBER,
				  X_Last_Updated_By	NUMBER,
				  X_Last_Update_Login	NUMBER);

  --
  -- Procedure
  --   insert_rows_for_journal
  -- Purpose
  --   Inserts any missing reconciliation rows for a journal
  -- History
  --   09-JUN-2004  D. J. Ogg    Created
  -- Arguments
  --   X_Je_Header_Id    The header id for which rows should be added
  -- Example
  --   gl_je_lines_recon_pkg.insert_rows_for_journal(500);
  -- Notes
  --
  PROCEDURE insert_rows_for_journal(X_Je_Header_Id  	NUMBER,
				    X_Last_Updated_By	NUMBER,
				    X_Last_Update_Login	NUMBER);

  -- Procedure
  --   insert_rows_for_line
  -- Purpose
  --   Inserts any missing reconciliation rows for a journal line
  -- History
  --   09-JUN-2004  D. J. Ogg    Created
  -- Arguments
  --   X_Je_Header_Id    The header id for which rows should be added
  -- Example
  --   gl_je_lines_recon_pkg.insert_rows_for_line(500,1,1,2);
  -- Notes
  --
  PROCEDURE insert_rows_for_line(X_Je_Header_Id  	NUMBER,
				 X_Je_Line_Num		NUMBER,
				 X_Last_Updated_By	NUMBER,
				 X_Last_Update_Login	NUMBER);

  PROCEDURE Insert_Row(X_RowId            IN OUT NOCOPY VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Ledger_Id                      NUMBER,
		       X_Jgzz_Recon_Status		VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id			NUMBER,
		       X_Jgzz_Recon_Ref			VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Je_Header_Id                     NUMBER,
                     X_Je_Line_Num                      NUMBER,
                     X_Ledger_Id                        NUMBER,
		     X_Jgzz_Recon_Status	        VARCHAR2,
		     X_Jgzz_Recon_Date		        DATE,
		     X_Jgzz_Recon_Id		        NUMBER,
		     X_Jgzz_Recon_Ref		        VARCHAR2
                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Ledger_Id                      NUMBER,
		       X_Jgzz_Recon_Status	        VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id		        NUMBER,
		       X_Jgzz_Recon_Ref		        VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );


  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2);


  -- Procedure
  --   insert_gen_line_recon_lines
  -- Purpose
  --   Insert reconciliation rows for the generated lines in a
  --   primary journal being posted.
  --   This routine is designed to be only called by Posting.
  -- History
  --   14-FEB-2005  K Vora        Created
  -- Arguments
  --   x_je_header_id       The header to be used
  --   x_from_je_line_num   The line number from which to process
  --   x_last_updated_by
  --   x_last_update_login
  -- Example
  --   gl_je_lines_recon_pkg.insert_gen_line_recon_lines(123, 101, 1, 234);
  -- Notes
  --
  FUNCTION insert_gen_line_recon_lines( X_Je_Header_Id       NUMBER,
                                        X_From_Je_Line_Num   NUMBER,
                                        X_Last_Updated_By    NUMBER,
                                        X_Last_Update_Login  NUMBER )
  RETURN NUMBER;


  -- Procedure
  --   insert_alc_recon_lines
  -- Purpose
  --   Insert reconciliation rows for the ALC journals in the
  --   selected posting run.
  --   This routine is designed to be only called by Posting.
  -- History
  --   14-FEB-2005  K Vora        Created
  -- Arguments
  --   x_prun_id             The posting run id to be used
  --   x_last_updated_by
  --   x_last_update_login
  -- Example
  --   gl_je_lines_recon_pkg.insert_alc_recon_lines(123, 1, 234);
  -- Notes
  --
  FUNCTION insert_alc_recon_lines( X_Prun_Id            NUMBER,
                                   X_Last_Updated_By    NUMBER,
                                   X_Last_Update_Login  NUMBER )
  RETURN NUMBER;


  -- Procedure
  --   insert_sl_recon_lines
  -- Purpose
  --   Insert reconciliation rows for the SL journals in the
  --   selected posting run.
  --   This routine is designed to be only called by Posting.
  -- History
  --   14-FEB-2005  K Vora        Created
  -- Arguments
  --   x_prun_id             The posting run id to be used
  --   x_last_updated_by
  --   x_last_update_login
  -- Example
  --   gl_je_lines_recon_pkg.insert_sl_recon_lines(123, 1, 234);
  -- Notes
  --
  FUNCTION insert_sl_recon_lines( X_Prun_Id            NUMBER,
                                   X_Last_Updated_By    NUMBER,
                                   X_Last_Update_Login  NUMBER )
  RETURN NUMBER;


END GL_JE_LINES_RECON_PKG;

 

/
