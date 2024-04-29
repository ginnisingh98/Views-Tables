--------------------------------------------------------
--  DDL for Package GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: glijiins.pls 120.7 2005/05/05 01:11:20 kvora ship $ */
--
-- Package
--   gl_interface_pkg
-- Purpose
--   To contain validation and insertion routines for gl_interface
-- History
--   03-30-94  	D. J. Ogg	Created

  --
  -- Procedure
  --   Get_Ledger_Column_Name
  -- Purpose
  --   Gets the name of the ledger column to be used
  -- History
  --   14-OCT-2002   D. J. Ogg		Created
  -- Arguments
  --   Itable			Interface Table Name
  --
  FUNCTION Get_Ledger_Column_Name(
		 Itable				VARCHAR2,
                 Resp_Id                        NUMBER,
                 Resp_Appl_Id                   NUMBER ) RETURN VARCHAR2;

  --
  -- Procedure
  --   Get_Ledger_Id
  -- Purpose
  --   Gets the ledger id from an interface table
  -- History
  --   14-OCT-2002   D. J. Ogg		Created
  -- Arguments
  --   Itable			Interface Table Name
  --   Ledger_Column_Name       Column that stores ledger_id
  --   X_Rowid                  Row id to get id from
  --
  FUNCTION Get_Ledger_Id(
		 Itable				VARCHAR2,
                 Ledger_Column_Name             VARCHAR2,
                 X_Rowid                        VARCHAR2) RETURN NUMBER;

  --
  -- Procedure
  --   Insert_Budget_Transfer_Row
  -- Purpose
  --   Inserts two new rows in gl_interface for the budget transfer
  -- History
  --   03-30-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The place to store the Row ID of the
  --                                from row
  --   X_To_Rowid		    The place to store the Row ID of the
  --                                to row
  --   X_Status			    The status of the new rows
  --   X_Ledger_Id		    The ledger ID of the new rows
  --   X_User_Je_Source_Name	    The source of the new rows (Transfer)
  --   X_Group_Id		    The group ID of the new rows
  --   X_User_Je_Category_Name	    The category of the new rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the new rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the new rows
  --   X_Period_Name                The period of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr	    The Credit amount transfered from the from
  --   X_To_Entered_Dr	    	The Debit amount transfered to the to
  --   X_To_Entered_Cr	    	The Credit amount transfered to the to
  --   X_Date_Created		    The date on which the new rows were
  --			  	    created
  --   X_Created_By		    The user id of the person who created the
  --				    new rows
  --
  PROCEDURE Insert_Budget_Transfer_Row(
		     X_From_Rowid                   IN OUT NOCOPY VARCHAR2,
		     X_To_Rowid                     IN OUT NOCOPY VARCHAR2,
		     X_Status				   VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Group_Id                            NUMBER,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
                     X_To_Entered_Dr                       NUMBER,
                     X_To_Entered_Cr                       NUMBER,
                     X_Date_Created                        DATE,
                     X_Created_By                          NUMBER);

  --
  -- Procedure
  --   Update_Budget_Transfer_Row
  -- Purpose
  --   Updates the two rows in gl_interface that correspond to a single
  --   budget transfer.
  -- History
  --   03-30-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --   X_Status			    The status of the rows
  --   X_Ledger_Id		    The ledger ID of the rows
  --   X_User_Je_Source_Name	    The source of the rows (Transfer)
  --   X_Group_Id		    The group ID of the rows
  --   X_User_Je_Category_Name	    The category of the rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the rows
  --   X_Period_Name                The period of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr	    The Credit amount transfered from the from
  --   X_To_Entered_Dr		    The Debit amount transfered to the to
  --   X_To_Entered_Cr		    The Credit amount transfered to the to
  --   X_Date_Created		    The date on which the rows were
  --			  	    created
  --   X_Created_By		    The user id of the person who created the
  --				    rows
  --
  PROCEDURE Update_Budget_Transfer_Row(
		     X_From_Rowid                   	   VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status				   VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Group_Id                            NUMBER,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
		     X_To_Entered_Dr			   NUMBER,
		     X_To_Entered_Cr			   NUMBER);

  --
  -- Procedure
  --   Lock_Budget_Transfer_Row
  -- Purpose
  --   Locks the two rows in gl_interface that correspond to a single
  --   budget transfer.
  -- History
  --   03-30-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --   X_Status			    The status of the new rows
  --   X_Ledger_Id		    The ledger ID of the rows
  --   X_User_Je_Source_Name	    The source of the rows (Transfer)
  --   X_Group_Id		    The group ID of the rows
  --   X_User_Je_Category_Name	    The category of the rows (Budget)
  --   X_Budget_Version_Id	    The budget containing the transfered amts
  --   X_Je_Batch_Name		    The batch name of the rows
  --   X_Currency_Code		    The currency of the transfered amts
  --   X_From_Code_Combination_Id   The code combination of the from row
  --   X_To_Code_Combination_Id     The code combination of the to row
  --   X_Combination_Number	    The ID indicating the group of transfers
  --                                containing the row
  --   X_Period_Name                The period of the transfer
  --   X_From_Entered_Dr	    The Debit amount transfered from the from
  --   X_From_Entered_Cr            The Credit amount transfered from the from
  --   X_To_Entered_Dr		    The Debit amount transfered from the from
  --   X_To_Entered_Cr		    The Credit amount transfered from the from
  --
  PROCEDURE Lock_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2,
		     X_Status				   VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_User_Je_Source_Name                 VARCHAR2,
                     X_Group_Id                            NUMBER,
                     X_User_Je_Category_Name               VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
		     X_Je_Batch_Name			   VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_From_Code_Combination_Id            NUMBER,
                     X_To_Code_Combination_Id              NUMBER,
                     X_Combination_Number		   NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_From_Entered_Dr                     NUMBER,
                     X_From_Entered_Cr                     NUMBER,
		     X_To_Entered_Dr			   NUMBER,
		     X_To_Entered_Cr			   NUMBER);

  --
  -- Procedure
  --   Delete_Budget_Transfer_Row
  -- Purpose
  --   Deletes the two rows from gl_interface that correspond to a single
  --   budget transfer.
  -- History
  --   03-30-94   D. J. Ogg		Created
  -- Arguments
  --   X_From_Rowid		    The Row ID of the from row
  --   X_To_Rowid		    The Row ID of the to row
  --
  PROCEDURE Delete_Budget_Transfer_Row(
		     X_From_Rowid                          VARCHAR2,
		     X_To_Rowid                            VARCHAR2);

  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Deletes all of the journal import rows with this source,
  --   group id, and batch id.
  -- History
  --   06-08-94   D. J. Ogg		Created
  -- Arguments
  --   x_ledger_id              Gives the ledger ID
  --   x_user_je_source_name    The translated source name
  --   x_group_id		The group id to check
  --   x_je_batch_id            The batch id to delete
  -- Example
  --   gl_interface_pkg.delete_rows(2, 'Transfer', 5);
  PROCEDURE delete_rows(x_ledger_id           NUMBER,
                        x_user_je_source_name VARCHAR2,
			x_group_id            NUMBER DEFAULT NULL,
		        x_je_batch_id         NUMBER DEFAULT NULL);

  --
  -- Procedure
  --   exists_data
  -- Purpose
  --   Returns TRUE if there are rows in gl_interface with this
  --   ledger id, user source name, and group id
  -- History
  --   06-08-94   D. J. Ogg		Created
  -- Arguments
  --   x_ledger_id              Gives the ledger ID
  --   x_user_je_source_name    The translated source name
  --   x_group_id		The group id to check
  -- Example
  --   if (gl_interface_pkg.exists_data(2, 'Transfer', 5)) then
  FUNCTION exists_data(x_ledger_id           NUMBER,
                       x_user_je_source_name VARCHAR2,
		       x_group_id            NUMBER DEFAULT NULL)
    RETURN BOOLEAN;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_ACCOUNTING_DATE in DATE,
  X_CURRENCY_CODE in VARCHAR2,
  X_DATE_CREATED in DATE,
  X_CREATED_BY in NUMBER,
  X_ACTUAL_FLAG in VARCHAR2,
  X_USER_JE_CATEGORY_NAME in VARCHAR2,
  X_USER_JE_SOURCE_NAME in VARCHAR2,
  X_CURRENCY_CONVERSION_DATE in DATE,
  X_ENCUMBRANCE_TYPE_ID in NUMBER,
  X_BUDGET_VERSION_ID in NUMBER,
  X_USER_CURRENCY_CONV_TYPE in VARCHAR2,
  X_CURRENCY_CONVERSION_RATE in NUMBER,
  X_AVERAGE_JOURNAL_FLAG in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_SEGMENT8 in VARCHAR2,
  X_SEGMENT9 in VARCHAR2,
  X_SEGMENT10 in VARCHAR2,
  X_SEGMENT11 in VARCHAR2,
  X_SEGMENT12 in VARCHAR2,
  X_SEGMENT13 in VARCHAR2,
  X_SEGMENT14 in VARCHAR2,
  X_SEGMENT15 in VARCHAR2,
  X_SEGMENT16 in VARCHAR2,
  X_SEGMENT17 in VARCHAR2,
  X_SEGMENT18 in VARCHAR2,
  X_SEGMENT19 in VARCHAR2,
  X_SEGMENT20 in VARCHAR2,
  X_SEGMENT21 in VARCHAR2,
  X_SEGMENT22 in VARCHAR2,
  X_SEGMENT23 in VARCHAR2,
  X_SEGMENT24 in VARCHAR2,
  X_SEGMENT25 in VARCHAR2,
  X_SEGMENT26 in VARCHAR2,
  X_SEGMENT27 in VARCHAR2,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_ENTERED_DR in NUMBER,
  X_ENTERED_CR in NUMBER,
  X_ACCOUNTED_DR in NUMBER,
  X_ACCOUNTED_CR in NUMBER,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in VARCHAR2,
  X_REFERENCE3 in VARCHAR2,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  X_REFERENCE6 in VARCHAR2,
  X_REFERENCE7 in VARCHAR2,
  X_REFERENCE8 in VARCHAR2,
  X_REFERENCE9 in VARCHAR2,
  X_REFERENCE10 in VARCHAR2,
  X_REFERENCE11 in VARCHAR2,
  X_REFERENCE12 in VARCHAR2,
  X_REFERENCE13 in VARCHAR2,
  X_REFERENCE14 in VARCHAR2,
  X_REFERENCE15 in VARCHAR2,
  X_REFERENCE16 in VARCHAR2,
  X_REFERENCE17 in VARCHAR2,
  X_REFERENCE18 in VARCHAR2,
  X_REFERENCE19 in VARCHAR2,
  X_REFERENCE20 in VARCHAR2,
  X_REFERENCE21 in VARCHAR2,
  X_REFERENCE22 in VARCHAR2,
  X_REFERENCE23 in VARCHAR2,
  X_REFERENCE24 in VARCHAR2,
  X_REFERENCE25 in VARCHAR2,
  X_REFERENCE26 in VARCHAR2,
  X_REFERENCE27 in VARCHAR2,
  X_REFERENCE28 in VARCHAR2,
  X_REFERENCE29 in VARCHAR2,
  X_REFERENCE30 in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_CODE_COMBINATION_ID in NUMBER,
  X_STAT_AMOUNT in NUMBER,
  X_GROUP_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_VALUE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_CONTEXT2 in VARCHAR2,
  X_INVOICE_DATE in DATE,
  X_TAX_CODE in VARCHAR2,
  X_INVOICE_IDENTIFIER in VARCHAR2,
  X_INVOICE_AMOUNT in NUMBER,
  X_CONTEXT3 in VARCHAR2,
  X_USSGL_TRANSACTION_CODE in VARCHAR2,
  X_JGZZ_RECON_REF in VARCHAR2,
  X_ORIGINATING_BAL_SEG_VALUE in VARCHAR2,
  X_GL_SL_LINK_ID in NUMBER,
  X_GL_SL_LINK_TABLE in VARCHAR2
);

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_ACCOUNTING_DATE in DATE,
  X_CURRENCY_CODE in VARCHAR2,
  X_DATE_CREATED in DATE,
  X_CREATED_BY in NUMBER,
  X_ACTUAL_FLAG in VARCHAR2,
  X_USER_JE_CATEGORY_NAME in VARCHAR2,
  X_USER_JE_SOURCE_NAME in VARCHAR2,
  X_CURRENCY_CONVERSION_DATE in DATE,
  X_ENCUMBRANCE_TYPE_ID in NUMBER,
  X_BUDGET_VERSION_ID in NUMBER,
  X_USER_CURRENCY_CONV_TYPE in VARCHAR2,
  X_CURRENCY_CONVERSION_RATE in NUMBER,
  X_AVERAGE_JOURNAL_FLAG in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_SEGMENT8 in VARCHAR2,
  X_SEGMENT9 in VARCHAR2,
  X_SEGMENT10 in VARCHAR2,
  X_SEGMENT11 in VARCHAR2,
  X_SEGMENT12 in VARCHAR2,
  X_SEGMENT13 in VARCHAR2,
  X_SEGMENT14 in VARCHAR2,
  X_SEGMENT15 in VARCHAR2,
  X_SEGMENT16 in VARCHAR2,
  X_SEGMENT17 in VARCHAR2,
  X_SEGMENT18 in VARCHAR2,
  X_SEGMENT19 in VARCHAR2,
  X_SEGMENT20 in VARCHAR2,
  X_SEGMENT21 in VARCHAR2,
  X_SEGMENT22 in VARCHAR2,
  X_SEGMENT23 in VARCHAR2,
  X_SEGMENT24 in VARCHAR2,
  X_SEGMENT25 in VARCHAR2,
  X_SEGMENT26 in VARCHAR2,
  X_SEGMENT27 in VARCHAR2,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_ENTERED_DR in NUMBER,
  X_ENTERED_CR in NUMBER,
  X_ACCOUNTED_DR in NUMBER,
  X_ACCOUNTED_CR in NUMBER,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in VARCHAR2,
  X_REFERENCE3 in VARCHAR2,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  X_REFERENCE6 in VARCHAR2,
  X_REFERENCE7 in VARCHAR2,
  X_REFERENCE8 in VARCHAR2,
  X_REFERENCE9 in VARCHAR2,
  X_REFERENCE10 in VARCHAR2,
  X_REFERENCE11 in VARCHAR2,
  X_REFERENCE12 in VARCHAR2,
  X_REFERENCE13 in VARCHAR2,
  X_REFERENCE14 in VARCHAR2,
  X_REFERENCE15 in VARCHAR2,
  X_REFERENCE16 in VARCHAR2,
  X_REFERENCE17 in VARCHAR2,
  X_REFERENCE18 in VARCHAR2,
  X_REFERENCE19 in VARCHAR2,
  X_REFERENCE20 in VARCHAR2,
  X_REFERENCE21 in VARCHAR2,
  X_REFERENCE22 in VARCHAR2,
  X_REFERENCE23 in VARCHAR2,
  X_REFERENCE24 in VARCHAR2,
  X_REFERENCE25 in VARCHAR2,
  X_REFERENCE26 in VARCHAR2,
  X_REFERENCE27 in VARCHAR2,
  X_REFERENCE28 in VARCHAR2,
  X_REFERENCE29 in VARCHAR2,
  X_REFERENCE30 in VARCHAR2,
  X_PERIOD_NAME in VARCHAR2,
  X_CODE_COMBINATION_ID in NUMBER,
  X_STAT_AMOUNT in NUMBER,
  X_GROUP_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_ID in NUMBER,
  X_SUBLEDGER_DOC_SEQUENCE_VALUE in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_CONTEXT2 in VARCHAR2,
  X_INVOICE_DATE in DATE,
  X_TAX_CODE in VARCHAR2,
  X_INVOICE_IDENTIFIER in VARCHAR2,
  X_INVOICE_AMOUNT in NUMBER,
  X_CONTEXT3 in VARCHAR2,
  X_USSGL_TRANSACTION_CODE in VARCHAR2,
  X_JGZZ_RECON_REF in VARCHAR2,
  X_ORIGINATING_BAL_SEG_VALUE in VARCHAR2,
  X_GL_SL_LINK_ID in NUMBER,
  X_GL_SL_LINK_TABLE in VARCHAR2
);

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  X_ITABLE in VARCHAR2
);

END gl_interface_pkg;

 

/
