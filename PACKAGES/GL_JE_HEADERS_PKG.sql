--------------------------------------------------------
--  DDL for Package GL_JE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: glijhrvs.pls 120.10.12010000.2 2009/05/28 12:00:35 skotakar ship $ */

--
-- Package
--   GL_JE_HEADERS_PKG
-- Purpose
--   To implement various data checking needed for the
--   gl_je_headers table
-- History
--   12-27-93  S. J. Mueller    Created
--   01-11-94  D J Ogg          Added routines check_unique, get_unique_id,
-- 				and default_reversal_period
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the header
  --   is unique within the batch.
  -- History
  --   01-11-93  D. J. Ogg    Created
  -- Arguments
  --   batch_id         The ID of the batch
  --   header_name 	The name of the header
  --   row_id 		The row ID
  -- Example
  --   gl_je_headers_pkg.check_unique(2002, 'Testing', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(batch_id NUMBER, header_name VARCHAR2,
                         row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique header id
  -- History
  --   12-30-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_je_headers_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   delete_headers
  -- Purpose
  --   Deletes all of the headers that belong to a given MassAllocation
  --   batch.
  -- History
  --   01-18-93  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the MassAllocation batch
  -- Example
  --   gl_je_headers_pkg.delete_headers(1002);
  -- Notes
  --
  PROCEDURE delete_headers(batch_id 	NUMBER);

  --
  -- Procedure
  --   change_effective_date
  -- Purpose
  --   Changes the effective date for all of the headers within the batch
  -- History
  --   30-MAY-1996	D J Ogg		Created
  -- Arguments
  --   batch_id			The ID of the batch
  --   new_effective_date	The new effective date
  -- Example
  --   gl_je_headers_pkg.change_effective_date(1002, '01-JAN-1992');
  -- Notes
  --
  PROCEDURE change_effective_date(batch_id 		NUMBER,
				  new_effective_date 	DATE);

  --
  -- Procedure
  --   calculate_totals
  -- Purpose
  --   Retotals the running totals for a batch
  -- History
  --   01-24-94  D. J. Ogg    Created
  -- Arguments
  --   batch_id 			The ID of the batch
  --   running_total_dr			The running total of debits
  --   running_total_cr			The running total of credits
  --   running_total_accounted_dr	The running total of accounted debits
  --   running_total_accounted_cr	The running total of accounted credits
  -- Example
  --   gl_je_lines_pkg.calculate_totals(1002, run_dr, run_cr, run_accdr,
  --					run_acccr);
  -- Notes
  --
  PROCEDURE calculate_totals(	batch_id				NUMBER,
				running_total_dr		IN OUT NOCOPY	NUMBER,
				running_total_cr		IN OUT NOCOPY	NUMBER,
				running_total_accounted_dr	IN OUT NOCOPY	NUMBER,
				running_total_accounted_cr	IN OUT NOCOPY	NUMBER
			    );

  --
  -- Procedure
  --   change_period
  -- Purpose
  --   Runs in two modes.  When called with no header ID, it
  --   converts all of the journals within the current
  --   batch to the new period.  When called with a header
  --   ID, it assumes the change period process failed
  --   due to a bad journal, and you have gotten the
  --   correct journal information from the customer.
  --   It processes the given journal, using the given
  --   conversion information, and all of the journals
  --   after that journal.  It assumes that all of the
  --   journals before that journal have already been
  --   processed.
  -- History
  --   02-07-94  D. J. Ogg    Created
  -- Arguments
  --   batch_id         The ID of the batch whose period has changed.
  --   period_name      The new period name of the batch
  --   effective_date   The new effective date of the batch
  --   user_id          The ID of the user who changed the period
  --   login_id         The Login ID of the user who changed the period
  --   header_id        If provided, the ID of a bad journal
  --   currency_code    If provided, the override currency code for the
  --                    erroneous journal
  --   conversion_date  If provided, the override conversion date for
  --                    the erroneous journal
  --   conversion_type  If provided, the override conversion type for
  --                    the erroneous journal
  --   conversion_rate  If provided, the override conversion rate for
  --                    the erroneous journal
  -- Returns
  --   The ID of the next bad header, if it finds one.
  -- Example
  --   hid := gl_je_headers.change_period(2, 'USD', 'Test batch', 'JAN-91',
  --                                      '15-JAN-91');
  -- Notes
  --
  FUNCTION change_period(batch_id        NUMBER,
                         period_name     VARCHAR2,
                         effective_date  DATE,
                         user_id         NUMBER,
                         login_id        NUMBER,
                         header_id       NUMBER     DEFAULT null,
                         currency_code   VARCHAR2   DEFAULT null,
                         conversion_date DATE       DEFAULT null,
                         conversion_type VARCHAR2   DEFAULT null,
                         conversion_rate NUMBER     DEFAULT null
                        ) RETURN NUMBER;

  --
  -- Procedure
  --   max_effective_date
  -- Purpose
  --   Returns the maximum effective date of an unreversed journal in
  --   this batch
  -- History
  --   16-FEB-96  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the batch whose journals are to be
  --                    checked.
  -- Example
  --   eff_date := gl_je_headers.max_effective_date(1002)
  -- Notes
  --
  FUNCTION max_effective_date(batch_id          NUMBER) RETURN DATE;

  --
  -- Procedure
  --   needs_tax
  -- Purpose
  --   Returns TRUE if some journal in the batch needs to be
  --   taxed and FALSE otherwise
  -- History
  --   16-FEB-96  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the batch whose journals are to be
  --                    checked.
  -- Example
  --   IF(gl_je_headers.needs_tax(1002)) THEN
  -- Notes
  --
  FUNCTION needs_tax(batch_id          NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   has_seqnum
  -- Purpose
  --   Returns TRUE if some journal in the batch has a sequence number
  --   and FALSE otherwise
  -- History
  --   15-SEP-96  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The ID of the batch whose journals are to be
  --                    checked.
  -- Example
  --   IF(gl_je_headers.has_seqnum(1002)) THEN
  -- Notes
  --
  FUNCTION has_seqnum(batch_id          NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   populate_fields
  -- Purpose
  --   Gets all of the data necessary post-query
  -- History
  --   29-NOV-94  D. J. Ogg    Created
  -- Arguments
  --   set_of_books_id		The set of books containing the journal
  --   je_source_name		Source name to find translation for
  --   user_je_source_name	Translation of source name
  --   frozen_source            Are we allowed to change batches from this
  --                            source?
  --   je_category_name		Category name to find translation for
  --   user_je_category_name	Translation of category name
  --   reversal_option_code	S - Switch Dr/Cr, C - Change Sign
  --   period_name		Period name to get year, number, start and
  --				end date for
  --   start_date		Start date of period
  --   end_date			End date of period
  --   period_year		Year of period
  --   period_num		Number of period
  --   currency_conversion_type	Conversion type to find translation for
  --   user_currency_conv_type	Translation of conversion type
  --   budget_version_id	Id of budget to get name of
  --   budget_name		Name of budget
  --   encumbrance_type_id	Id of encumbrance to get name of
  --   encumbrance_type		Name of encumbrance
  --   accrual_rev_period_name  Reversal Period name to get year, number,
  --                            start and end date for
  --   accrual_rev_start_date	Start date of reversal period
  --   accrual_rev_end_date	End date of reversal period
  --   posting_acct_seq_version_id Posting sequence version information
  --   posting_acct_seq_name	Posting sequence name
  --   close_acct_seq_version_id Posting sequence version information
  --   close_acct_seq_name	Posting sequence name
  --   error_name		Resulting error, if any
  -- Notes
  --
  PROCEDURE populate_fields(ledger_id				NUMBER,
                            ledger_name			IN OUT NOCOPY  VARCHAR2,
			    je_source_name		      	VARCHAR2,
			    user_je_source_name		IN OUT NOCOPY  VARCHAR2,
                            frozen_source_flag		IN OUT NOCOPY	VARCHAR2,
			    je_category_name			VARCHAR2,
			    user_je_category_name	IN OUT NOCOPY  VARCHAR2,
			    period_name				VARCHAR2,
			    start_date			IN OUT NOCOPY  DATE,
			    end_date			IN OUT NOCOPY  DATE,
			    period_year			IN OUT NOCOPY	NUMBER,
			    period_num			IN OUT NOCOPY 	NUMBER,
			    currency_conversion_type		VARCHAR2,
			    user_currency_conv_type	IN OUT NOCOPY	VARCHAR2,
			    budget_version_id			NUMBER,
			    budget_name			IN OUT NOCOPY  VARCHAR2,
			    encumbrance_type_id			NUMBER,
			    encumbrance_type		IN OUT NOCOPY  VARCHAR2,
			    accrual_rev_period_name		VARCHAR2,
			    accrual_rev_start_date	IN OUT NOCOPY  DATE,
			    accrual_rev_end_date	IN OUT NOCOPY  DATE,
			    posting_acct_seq_version_id		NUMBER,
			    posting_acct_seq_name	IN OUT NOCOPY  VARCHAR2,
			    close_acct_seq_version_id		NUMBER,
			    close_acct_seq_name	IN OUT NOCOPY  VARCHAR2,
			    error_name			IN OUT NOCOPY  VARCHAR2);

PROCEDURE Insert_Row(X_Rowid                                IN OUT NOCOPY VARCHAR2,
                     X_Je_Header_Id                         IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Je_Category                          VARCHAR2,
                     X_Je_Source                            VARCHAR2,
                     X_Period_Name                          VARCHAR2,
                     X_Name                                 VARCHAR2,
                     X_Currency_Code                        VARCHAR2,
                     X_Status                               VARCHAR2,
                     X_Date_Created                         DATE,
                     X_Accrual_Rev_Flag                     VARCHAR2,
                     X_Multi_Bal_Seg_Flag                   VARCHAR2,
                     X_Actual_Flag                          VARCHAR2,
                     X_Default_Effective_Date               DATE,
                     X_Conversion_Flag                      VARCHAR2,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Budget_Version_Id                    NUMBER,
                     X_Balanced_Je_Flag                     VARCHAR2,
                     X_Balancing_Segment_Value              VARCHAR2,
                     X_Je_Batch_Id                          IN OUT NOCOPY NUMBER,
                     X_From_Recurring_Header_Id             NUMBER,
                     X_Unique_Date                          VARCHAR2,
                     X_Earliest_Postable_Date               DATE,
                     X_Posted_Date                          DATE,
                     X_Accrual_Rev_Effective_Date           DATE,
                     X_Accrual_Rev_Period_Name              VARCHAR2,
                     X_Accrual_Rev_Status                   VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id             NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag         VARCHAR2,
                     X_Description                          VARCHAR2,
		     X_Tax_Status_Code			    VARCHAR2,
                     X_Control_Total                        NUMBER,
                     X_Running_Total_Dr                     NUMBER,
                     X_Running_Total_Cr                     NUMBER,
                     X_Running_Total_Accounted_Dr           NUMBER,
                     X_Running_Total_Accounted_Cr           NUMBER,
                     X_Currency_Conversion_Rate             NUMBER,
                     X_Currency_Conversion_Type             VARCHAR2,
                     X_Currency_Conversion_Date             DATE,
                     X_External_Reference                   VARCHAR2,
		     X_Originating_Bal_Seg_Value            VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Context                              VARCHAR2,
		     X_Global_Attribute1                    VARCHAR2,
		     X_Global_Attribute2                    VARCHAR2,
		     X_Global_Attribute3                    VARCHAR2,
		     X_Global_Attribute4                    VARCHAR2,
		     X_Global_Attribute5                    VARCHAR2,
		     X_Global_Attribute6                    VARCHAR2,
		     X_Global_Attribute7                    VARCHAR2,
		     X_Global_Attribute8                    VARCHAR2,
		     X_Global_Attribute9                    VARCHAR2,
		     X_Global_Attribute10                   VARCHAR2,
		     X_Global_Attribute_Category            VARCHAR2,
                     X_Ussgl_Transaction_Code               VARCHAR2,
                     X_Context2                             VARCHAR2,
                     X_Doc_Sequence_Id                      NUMBER,
                     X_Doc_Sequence_Value                   NUMBER,
		     X_Header_Mode			    VARCHAR2,
		     X_Batch_Row_Id			    IN OUT NOCOPY VARCHAR2,
		     X_Batch_Name			    VARCHAR2,
                     X_Chart_of_Accounts_ID		    NUMBER,
		     X_Period_Set_Name		            VARCHAR2,
		     X_Accounted_Period_Type		    VARCHAR2,
		     X_Batch_Status			    VARCHAR2,
		     X_Status_Verified			    VARCHAR2,
		     X_Batch_Default_Effective_Date	    DATE,
		     X_Batch_Posted_Date		    DATE,
		     X_Batch_Date_Created		    DATE,
		     X_Budgetary_Control_Status		    VARCHAR2,
		     X_Approval_Status_Code                 VARCHAR2,
		     X_Batch_Control_Total		    IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	            IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	            IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag                 VARCHAR2,
		     X_Org_Id                               NUMBER,
		     X_Posting_Run_Id			    NUMBER,
		     X_Request_Id			    NUMBER,
		     X_Packet_Id			    NUMBER,
		     X_Unreservation_Packet_Id		    NUMBER,
		     X_Jgzz_Recon_Context                   VARCHAR2,
                     X_Jgzz_Recon_Ref                       VARCHAR2,
                     X_Reference_Date                       DATE
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Header_Id                           NUMBER,
                   X_Ledger_Id                              NUMBER,
                   X_Je_Category                            VARCHAR2,
                   X_Je_Source                              VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Name                                   VARCHAR2,
                   X_Currency_Code                          VARCHAR2,
                   X_Status                                 VARCHAR2,
                   X_Date_Created                           DATE,
                   X_Accrual_Rev_Flag                       VARCHAR2,
                   X_Multi_Bal_Seg_Flag                     VARCHAR2,
                   X_Actual_Flag                            VARCHAR2,
                   X_Default_Effective_Date                 DATE,
                   X_Conversion_Flag                        VARCHAR2,
                   X_Encumbrance_Type_Id                    NUMBER,
                   X_Budget_Version_Id                      NUMBER,
                   X_Balanced_Je_Flag                       VARCHAR2,
                   X_Balancing_Segment_Value                VARCHAR2,
                   X_Je_Batch_Id                            NUMBER,
                   X_From_Recurring_Header_Id               NUMBER,
                   X_Unique_Date                            VARCHAR2,
                   X_Earliest_Postable_Date                 DATE,
                   X_Posted_Date                            DATE,
                   X_Accrual_Rev_Effective_Date             DATE,
                   X_Accrual_Rev_Period_Name                VARCHAR2,
                   X_Accrual_Rev_Status                     VARCHAR2,
                   X_Accrual_Rev_Je_Header_Id               NUMBER,
                   X_Accrual_Rev_Change_Sign_Flag           VARCHAR2,
                   X_Description                            VARCHAR2,
		   X_Tax_Status_Code		    	    VARCHAR2,
                   X_Control_Total                          NUMBER,
                   X_Running_Total_Dr                       NUMBER,
                   X_Running_Total_Cr                       NUMBER,
                   X_Running_Total_Accounted_Dr             NUMBER,
                   X_Running_Total_Accounted_Cr             NUMBER,
                   X_Currency_Conversion_Rate               NUMBER,
                   X_Currency_Conversion_Type               VARCHAR2,
                   X_Currency_Conversion_Date               DATE,
                   X_External_Reference                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Context                                VARCHAR2,
                   X_Ussgl_Transaction_Code                 VARCHAR2,
                   X_Context2                               VARCHAR2,
                   X_Doc_Sequence_Id                        NUMBER,
                   X_Doc_Sequence_Value                     NUMBER
                   );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Header_Id                           NUMBER,
                   X_Ledger_Id                              NUMBER,
                   X_Je_Category                            VARCHAR2,
                   X_Je_Source                              VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Name                                   VARCHAR2,
                   X_Currency_Code                          VARCHAR2,
                   X_Status                                 VARCHAR2,
                   X_Date_Created                           DATE,
                   X_Accrual_Rev_Flag                       VARCHAR2,
                   X_Multi_Bal_Seg_Flag                     VARCHAR2,
                   X_Actual_Flag                            VARCHAR2,
                   X_Default_Effective_Date                 DATE,
                   X_Conversion_Flag                        VARCHAR2,
                   X_Encumbrance_Type_Id                    NUMBER,
                   X_Budget_Version_Id                      NUMBER,
                   X_Balanced_Je_Flag                       VARCHAR2,
                   X_Balancing_Segment_Value                VARCHAR2,
                   X_Je_Batch_Id                            NUMBER,
                   X_From_Recurring_Header_Id               NUMBER,
                   X_Unique_Date                            VARCHAR2,
                   X_Earliest_Postable_Date                 DATE,
                   X_Posted_Date                            DATE,
                   X_Accrual_Rev_Effective_Date             DATE,
                   X_Accrual_Rev_Period_Name                VARCHAR2,
                   X_Accrual_Rev_Status                     VARCHAR2,
                   X_Accrual_Rev_Je_Header_Id               NUMBER,
                   X_Accrual_Rev_Change_Sign_Flag           VARCHAR2,
                   X_Description                            VARCHAR2,
		   X_Tax_Status_Code		    	    VARCHAR2,
                   X_Control_Total                          NUMBER,
                   X_Running_Total_Dr                       NUMBER,
                   X_Running_Total_Cr                       NUMBER,
                   X_Running_Total_Accounted_Dr             NUMBER,
                   X_Running_Total_Accounted_Cr             NUMBER,
                   X_Currency_Conversion_Rate               NUMBER,
                   X_Currency_Conversion_Type               VARCHAR2,
                   X_Currency_Conversion_Date               DATE,
                   X_External_Reference                     VARCHAR2,
		   X_Originating_Bal_Seg_Value              VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Context                                VARCHAR2,
		   X_Global_Attribute1                      VARCHAR2,
		   X_Global_Attribute2                      VARCHAR2,
		   X_Global_Attribute3                      VARCHAR2,
		   X_Global_Attribute4                      VARCHAR2,
		   X_Global_Attribute5                      VARCHAR2,
		   X_Global_Attribute6                      VARCHAR2,
		   X_Global_Attribute7                      VARCHAR2,
		   X_Global_Attribute8                      VARCHAR2,
		   X_Global_Attribute9                      VARCHAR2,
		   X_Global_Attribute10                     VARCHAR2,
		   X_Global_Attribute_Category              VARCHAR2,
                   X_Ussgl_Transaction_Code                 VARCHAR2,
                   X_Context2                               VARCHAR2,
                   X_Doc_Sequence_Id                        NUMBER,
                   X_Doc_Sequence_Value                     NUMBER,
		   X_Header_Mode			    VARCHAR2,
		   X_Batch_Row_Id			    VARCHAR2,
		   X_Batch_Name			    	    VARCHAR2,
                   X_Chart_of_Accounts_ID		    NUMBER,
		   X_Period_Set_Name		            VARCHAR2,
		   X_Accounted_Period_Type		    VARCHAR2,
		   X_Batch_Status			    VARCHAR2,
		   X_Status_Verified			    VARCHAR2,
		   X_Batch_Default_Effective_Date	    DATE,
		   X_Batch_Posted_Date		    	    DATE,
		   X_Batch_Date_Created		    	    DATE,
		   X_Budgetary_Control_Status		    VARCHAR2,
		   X_Approval_Status_Code                   VARCHAR2,
		   X_Batch_Control_Total		    NUMBER,
		   X_Batch_Running_Total_Dr	            NUMBER,
		   X_Batch_Running_Total_Cr	            NUMBER,
                   X_Average_Journal_Flag                   VARCHAR2,
		   X_Posting_Run_Id			    NUMBER,
		   X_Request_Id			    	    NUMBER,
		   X_Packet_Id			    	    NUMBER,
		   X_Unreservation_Packet_Id		    NUMBER,
		   X_Verify_Request_Completed		    VARCHAR2,
		   X_Jgzz_Recon_Context                     VARCHAR2,
                   X_Jgzz_Recon_Ref                         VARCHAR2,
                   X_Reference_Date                         DATE
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Header_Id                        NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Category                         VARCHAR2,
                     X_Je_Source                           VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Date_Created                        DATE,
                     X_Accrual_Rev_Flag                    VARCHAR2,
                     X_Multi_Bal_Seg_Flag                  VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Conversion_Flag                     VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Balanced_Je_Flag                    VARCHAR2,
                     X_Balancing_Segment_Value             VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_From_Recurring_Header_Id            NUMBER,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Accrual_Rev_Effective_Date          DATE,
                     X_Accrual_Rev_Period_Name             VARCHAR2,
                     X_Accrual_Rev_Status                  VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id            NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag        VARCHAR2,
                     X_Description                         VARCHAR2,
 		     X_Tax_Status_Code			   VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Currency_Conversion_Rate            NUMBER,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Currency_Conversion_Date            DATE,
                     X_External_Reference                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Doc_Sequence_Id                     NUMBER,
                     X_Doc_Sequence_Value                  NUMBER);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Header_Id                        NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Category                         VARCHAR2,
                     X_Je_Source                           VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Date_Created                        DATE,
                     X_Accrual_Rev_Flag                    VARCHAR2,
                     X_Multi_Bal_Seg_Flag                  VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Conversion_Flag                     VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Balanced_Je_Flag                    VARCHAR2,
                     X_Balancing_Segment_Value             VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_From_Recurring_Header_Id            NUMBER,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Accrual_Rev_Effective_Date          DATE,
                     X_Accrual_Rev_Period_Name             VARCHAR2,
                     X_Accrual_Rev_Status                  VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id            NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag        VARCHAR2,
                     X_Description                         VARCHAR2,
		     X_Tax_Status_Code			   VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Currency_Conversion_Rate            NUMBER,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Currency_Conversion_Date            DATE,
                     X_External_Reference                  VARCHAR2,
		     X_Originating_Bal_Seg_Value           VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
		     X_Global_Attribute1                    VARCHAR2,
		     X_Global_Attribute2                    VARCHAR2,
		     X_Global_Attribute3                    VARCHAR2,
		     X_Global_Attribute4                    VARCHAR2,
		     X_Global_Attribute5                    VARCHAR2,
		     X_Global_Attribute6                    VARCHAR2,
		     X_Global_Attribute7                    VARCHAR2,
		     X_Global_Attribute8                    VARCHAR2,
		     X_Global_Attribute9                    VARCHAR2,
		     X_Global_Attribute10                   VARCHAR2,
		     X_Global_Attribute_Category            VARCHAR2,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Doc_Sequence_Id                     NUMBER,
                     X_Doc_Sequence_Value                  NUMBER,
                     X_Effective_Date_Changed		   VARCHAR2,
		     X_Header_Mode			   VARCHAR2,
		     X_Batch_Row_Id			   VARCHAR2,
		     X_Batch_Name			   VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
		     X_Batch_Status			   VARCHAR2,
		     X_Status_Verified			   VARCHAR2,
		     X_Batch_Default_Effective_Date	   DATE,
		     X_Batch_Posted_Date		   DATE,
		     X_Batch_Date_Created		   DATE,
		     X_Budgetary_Control_Status		   VARCHAR2,
		     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
		     X_Batch_Control_Total		   IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	           IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	           IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag		   VARCHAR2,
		     X_Posting_Run_Id			   NUMBER,
		     X_Request_Id			   NUMBER,
		     X_Packet_Id			   NUMBER,
		     X_Unreservation_Packet_Id		   NUMBER,
		     Update_Effective_Date_Flag		   VARCHAR2,
		     Update_Approval_Stat_Flag		   VARCHAR2,
	  	     X_Jgzz_Recon_Context                  VARCHAR2,
                     X_Jgzz_Recon_Ref                      VARCHAR2,
                     X_Reference_Date                      DATE
                     );

PROCEDURE Delete_Row(X_Rowid 				   VARCHAR2,
		     X_Je_Header_Id 			   NUMBER,
		     X_Header_Mode 			   VARCHAR2,
		     X_Batch_Row_Id			   VARCHAR2,
		     X_Je_Batch_Id			   NUMBER,
		     X_Ledger_Id			   NUMBER,
		     X_Actual_Flag			   VARCHAR2,
		     X_Period_Name			   VARCHAR2,
		     X_Batch_Name			   VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
		     X_Batch_Status			   VARCHAR2,
		     X_Status_Verified			   VARCHAR2,
		     X_Batch_Default_Effective_Date	   DATE,
		     X_Batch_Posted_Date		   DATE,
		     X_Batch_Date_Created		   DATE,
		     X_Budgetary_Control_Status		   VARCHAR2,
		     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
		     X_Batch_Control_Total		   IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	           IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	           IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag		   VARCHAR2,
		     X_Posting_Run_Id			   NUMBER,
		     X_Request_Id			   NUMBER,
		     X_Packet_Id			   NUMBER,
		     X_Unreservation_Packet_Id		   NUMBER,
		     X_Last_Updated_By			   NUMBER,
		     X_Last_Update_Login		   NUMBER);

END GL_JE_HEADERS_PKG;

/
