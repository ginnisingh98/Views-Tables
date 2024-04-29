--------------------------------------------------------
--  DDL for Package GL_JE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: glijelns.pls 120.12.12010000.2 2009/05/28 11:55:13 skotakar ship $ */

--
-- Package
--   GL_JE_LINES_PKG
-- Purpose
--   To implement various data checking needed for the
--   gl_je_lines table
-- History
--   01-18-94  D J Ogg          Created.
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the line number
  --   is unique within the header.
  -- History
  --   01-18-93  D. J. Ogg    Created
  -- Arguments
  --   header_id        The ID of the header
  --   line_num         The line number to check
  --   row_id 		The row ID
  -- Example
  --   gl_je_lines_pkg.check_unique(2002, 10, 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(header_id NUMBER, line_num NUMBER,
                         row_id VARCHAR2);

  --
  -- Procedure
  --   delete_lines
  -- Purpose
  --   Deletes all of the lines in a given header.
  -- History
  --   01-18-93  D. J. Ogg    Created
  -- Arguments
  --   header_id 	The ID of the header
  -- Example
  --   gl_je_lines_pkg.delete_lines(1002);
  -- Notes
  --
  PROCEDURE delete_lines(header_id	NUMBER);

  --
  -- Procedure
  --   update_lines
  -- Purpose
  --   Updates the conversion, effective date, and period information
  --   for all lines within a given header.  If you pass a currency
  --   conversion rate of -1, this routine will not update the currency
  --   conversion rate.
  -- History
  --   02-07-94  D. J. Ogg    Created
  -- Arguments
  --   header_id 	   The ID of the header
  --   x_period_name       The name of the new period
  --   x_effective_date    The new effective date
  --   conversion_denom_rate	   The denominator part of the conversion
  --				   rate (or -1)
  --   conversion_numer_rate 	   The numerator part of the conversion
  --				   rate (or -1)
  --   entered_currency    The entered currency for the line (only used
  --			   if the conversion rate is not -1)
  --   accounted_currency  The accounted currency for the line (only
  --			   used if the conversion rate is not -1)
  --   ignore_ignore_flag  If 'Y', indicates that the ignore_rate_flag
  --                       should be ignored.  Otherwise, indicates that
  --                       the ignore_rate_flag should be heeded.
  --   clear_stat	   If 'Y', indicates that the statistical amounts
  --			   should be cleared
  --   user_id		   The ID of the user doing the update
  --   login_id		   The Login ID of the user doing the update
  -- Example
  --   gl_je_lines_pkg.update_lines(1002, 'USD', 'JAN-91', '15-JAN-91',
  --                                1.2, 'N', 102, 0);
  -- Notes
  --
  PROCEDURE update_lines(header_id		NUMBER,
                         x_period_name     	VARCHAR2,
                         x_effective_date  	DATE,
		         conversion_denom_rate	NUMBER,
		         conversion_numer_rate	NUMBER,
			 entered_currency	VARCHAR2,
			 accounted_currency     VARCHAR2,
                         ignore_ignore_flag     VARCHAR2,
			 clear_stat		VARCHAR2,
		         user_id		NUMBER,
			 login_id		NUMBER);

  --
  -- Procedure
  --   calculate_totals
  -- Purpose
  --   Retotals the running totals for a header
  -- History
  --   01-24-94  D. J. Ogg    Created
  -- Arguments
  --   header_id 			The ID of the header
  --   running_total_dr			The running total of debits
  --   running_total_cr			The running total of credits
  --   running_total_accounted_dr	The running total of accounted debits
  --   running_total_accounted_cr	The running total of accounted credits
  -- Example
  --   gl_je_lines_pkg.calculate_totals(1002, run_dr, run_cr, run_accdr,
  --					run_acccr);
  -- Notes
  --
  PROCEDURE calculate_totals(	header_id				NUMBER,
				running_total_dr		IN OUT NOCOPY	NUMBER,
				running_total_cr		IN OUT NOCOPY	NUMBER,
				running_total_accounted_dr	IN OUT NOCOPY	NUMBER,
				running_total_accounted_cr	IN OUT NOCOPY	NUMBER
			    );

  --
  -- Procedure
  --   header_has_stat
  -- Purpose
  --   Returns true if the header contains STAT amounts and
  --   false otherwise
  -- History
  --   03-15-94  D. J. Ogg    Created
  -- Arguments
  --   header_id 			The ID of the header
  -- Example
  --   gl_je_lines_pkg.header_has_stat(1002);
  -- Notes
  --
  FUNCTION header_has_stat(header_id	NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   header_has_tax
  -- Purpose
  --   Returns true if the header contains taxable lines and
  --   false otherwise
  -- History
  --   11-20-96  D. J. Ogg    Created
  -- Arguments
  --   header_id 			The ID of the header
  -- Example
  --   gl_je_lines_pkg.header_has_tax(1002);
  -- Notes
  --
  FUNCTION header_has_tax(header_id	NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   populate_fields
  -- Purpose
  --   Gets all of the data necessary post-query
  -- History
  --   02-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id		Current ledger id
  --   x_org_id                 Current org id
  --   x_coa_id			Current chart of accounts id
  --   x_ccid			Current code combination id
  --   x_account_num		Natural Account value
  --   x_account_type		Account Type
  --   x_jgzz_recon_flag        Reconciliation Flag
  --   x_tax_enabled		Indicates whether or not to retrieve
  --				tax information
  --   x_taxable_account	Indicates whether the account is taxable
  --   x_tax_code		Tax code for the current line
  --   x_stat_enabled		Indicates whether or not to retrieve
  --				statistical amounts
  --   x_unit_of_measure	Unit of Measure
  --   x_tax_code_id		Tax code id
  --   x_tax_type_id		Type of tax code
  --   x_tax_code		Tax code associated with id
  -- Notes
  --
  PROCEDURE populate_fields(x_ledger_id				NUMBER,
			    x_org_id                            NUMBER,
			    x_coa_id				NUMBER,
			    x_ccid				NUMBER,
			    x_account_num		IN OUT NOCOPY	VARCHAR2,
			    x_account_type		IN OUT NOCOPY	VARCHAR2,
                            x_jgzz_recon_flag           IN OUT NOCOPY   VARCHAR2,
			    x_tax_enabled			VARCHAR2,
			    x_taxable_account		IN OUT NOCOPY  VARCHAR2,
			    x_stat_enabled			VARCHAR2,
			    x_unit_of_measure		IN OUT NOCOPY  VARCHAR2,
			    x_tax_code_id		        NUMBER,
			    x_tax_type_code			VARCHAR2,
			    x_tax_code			IN OUT NOCOPY  VARCHAR2);

  --
  -- Procedure
  --   init_acct_dependencies
  -- Purpose
  --   Gets all of the tax and stat data necessary when the natural
  --   account value is changed
  -- History
  --   05-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id		Current ledger id
  --   x_org_id                 Current org id
  --   x_coa_id			Current chart of accounts id
  --   x_ccid                   Code Combination Id (or -1)
  --   x_account_num		Natural Account value
  --   x_account_type		Account type of Natural Account value
  --   x_tax_enabled		Indicates whether or not to retrieve
  --				tax information
  --   x_taxable_account	Indicates whether the account is taxable
  --   x_get_default_tax_info	Indicates whether you should get the default
  --				tax information
  --   x_eff_date		Effective date to use for default tax info
  --   x_default_tax_type_code	Default tax type code
  --   x_default_tax_code	Default tax code
  --   x_default_tax_code_id	Default tax code id
  --   x_default_rounding_code	Default rounding rule code
  --   x_default_incl_tax_flag	Default includes tax flag
  --   x_stat_enabled		Indicates whether or not to retrieve
  --				statistical amounts
  --   x_unit_of_measure	Unit of Measure
  --   x_jgzz_recon_flag        Indicates whether or not to reconcile accounts
  -- Notes
  --
  PROCEDURE init_acct_dependencies(
			    x_ledger_id				NUMBER,
			    x_org_id                            NUMBER,
			    x_coa_id				NUMBER,
                            x_ccid                              NUMBER,
			    x_account_num			VARCHAR2,
			    x_account_type			VARCHAR2,
			    x_tax_enabled			VARCHAR2,
			    x_taxable_account		IN OUT NOCOPY  VARCHAR2,
			    x_get_default_tax_info		VARCHAR2,
			    x_eff_date				DATE,
			    x_default_tax_type_code	IN OUT NOCOPY  VARCHAR2,
			    x_default_tax_code		IN OUT NOCOPY  VARCHAR2,
			    x_default_tax_code_id	IN OUT NOCOPY  NUMBER,
			    x_default_rounding_code	IN OUT NOCOPY	VARCHAR2,
			    x_default_incl_tax_flag	IN OUT NOCOPY	VARCHAR2,
			    x_stat_enabled			VARCHAR2,
			    x_unit_of_measure		IN OUT NOCOPY  VARCHAR2,
			    x_jgzz_recon_flag           IN OUT NOCOPY  VARCHAR2);

  --
  -- Procedure
  --   get_tax_defaults
  -- Purpose
  --   Gets default values for rounding rule and includes tax
  -- History
  --   05-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id		Current ledger id
  --   x_org_id                 Current org id
  --   x_account_value		Natural Account value
  --   x_tax_type_code		Tax type code
  --   x_default_rounding_code	Default rounding rule code
  --   x_default_incl_tax_flag	Default includes tax flag
  -- Notes
  --
  PROCEDURE get_tax_defaults(x_ledger_id			NUMBER,
 		 	     x_org_id                           NUMBER,
			     x_account_value			VARCHAR2,
			     x_tax_type_code			VARCHAR2,
			     x_default_rounding_code	IN OUT NOCOPY	VARCHAR2,
			     x_default_incl_tax_flag	IN OUT NOCOPY	VARCHAR2);

  --
  -- Procedure
  --   default_tax_type
  -- Purpose
  --   Determines the default value for the tax type in the MJE form
  -- History
  --   02-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   output_type			I - Id, V - Value
  --   x_ledger_id			The current ledger
  --   x_org_id                         Current org id
  --   x_account_value			The natural account value for the
  --					current journal entry line.
  --   x_account_type			The account type for the
  --					current journal entry line.
  --   x_default_tax_type		Default tax type
  --   x_default_tax_type_code		Default tax type code
  -- Notes
  --
  FUNCTION default_tax_type(output_type			IN 	VARCHAR2,
			    x_ledger_id			IN 	NUMBER,
			    x_org_id                    IN      NUMBER,
			    x_account_value		IN 	VARCHAR2,
			    x_account_type		IN 	VARCHAR2)
    RETURN VARCHAR2;

  --
  -- Procedure
  --   default_tax_code
  -- Purpose
  --   Determines the default value for the tax code in the MJE form
  -- History
  --   02-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   output_type			I - Id, V - Value
  --   x_ledger_id			The current ledger
  --   x_org_id                         Current org id
  --   x_account_value			The natural account value for the
  --					current journal entry line.
  --   x_acct_type			The selected account type
  --   x_eff_date			The effective date of the current
  -- Notes
  --
  FUNCTION default_tax_code(output_type			IN VARCHAR2,
			    x_ledger_id			IN NUMBER,
                            x_org_id			IN NUMBER,
 			    x_account_value		IN VARCHAR2,
			    x_acct_type			IN VARCHAR2,
			    x_eff_date			IN DATE
                           ) RETURN VARCHAR2;

  --
  -- Procedure
  --   default_rounding_rule
  -- Purpose
  --   Determines the default value for the rounding_rule in the MJE form
  -- History
  --   02-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   output_type			I - Id, V - Value
  --   x_ledger_id			The current ledger
  --   x_org_id                         Current org id
  --   x_tax_type			The selected tax type
  -- Notes
  --
  FUNCTION default_rounding_rule(output_type			IN VARCHAR2,
				 x_ledger_id			IN NUMBER,
				 x_org_id			IN NUMBER,
 				 x_tax_type			IN VARCHAR2
                                ) RETURN VARCHAR2;

  --
  -- Procedure
  --   default_includes_tax
  -- Purpose
  --   Determines the default value for the amount includes tax flag
  --   in the MJE form
  -- History
  --   02-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   output_type			I - Id, V - Value
  --   x_ledger_id			The current ledger
  --   x_org_id                         Current org id
  --   x_account_value			The natural account value for the
  --					current journal entry line.
  --   x_tax_type			The selected tax type
  -- Notes
  --
  FUNCTION default_includes_tax(output_type			IN VARCHAR2,
				x_ledger_id			IN NUMBER,
			 	x_org_id			IN NUMBER,
			        x_account_value			IN VARCHAR2,
			        x_tax_type			IN VARCHAR2
                               ) RETURN VARCHAR2;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Je_Header_Id            IN OUT NOCOPY NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Status                         VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Accounted_Dr                   NUMBER,
                       X_Accounted_Cr                   NUMBER,
                       X_Description                    VARCHAR2,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Reference_3                    VARCHAR2,
                       X_Reference_4                    VARCHAR2,
                       X_Reference_5                    VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Context2                       VARCHAR2,
                       X_Invoice_Date                   DATE,
                       X_Tax_Code                       VARCHAR2,
                       X_Invoice_Identifier             VARCHAR2,
                       X_Invoice_Amount                 NUMBER,
                       X_No1                            VARCHAR2,
                       X_Stat_Amount                    NUMBER,
                       X_Ignore_Rate_Flag               VARCHAR2,
                       X_Context3                       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Subledger_Doc_Sequence_Id      NUMBER,
                       X_Context4                       VARCHAR2,
                       X_Subledger_Doc_Sequence_Value   NUMBER,
                       X_Reference_6                    VARCHAR2,
                       X_Reference_7                    VARCHAR2,
                       X_Reference_8                    VARCHAR2,
                       X_Reference_9                    VARCHAR2,
                       X_Reference_10                   VARCHAR2,
		       X_Recon_On_Flag			VARCHAR2,
		       X_Recon_Rowid	  IN OUT NOCOPY VARCHAR2,
		       X_Jgzz_Recon_Status		VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id			NUMBER,
		       X_Jgzz_Recon_Ref			VARCHAR2,
		       X_Taxable_Line_Flag		VARCHAR2,
		       X_Tax_Type_Code			VARCHAR2,
		       X_Tax_Code_Id			NUMBER,
		       X_Tax_Rounding_Rule_Code		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_Tax_Document_Identifier	VARCHAR2,
		       X_Tax_Document_Date		DATE,
		       X_Tax_Customer_Name		VARCHAR2,
		       X_Tax_Customer_Reference		VARCHAR2,
		       X_Tax_Registration_Number	VARCHAR2,
		       X_Tax_Line_Flag			VARCHAR2,
		       X_Tax_Group_Id			NUMBER,
                       X_Third_Party_Id		        VARCHAR2,
		       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2
                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Je_Header_Id                     NUMBER,
                     X_Je_Line_Num                      NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Effective_Date                   DATE,
                     X_Status                           VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Accounted_Dr                     NUMBER,
                     X_Accounted_Cr                     NUMBER,
                     X_Description                      VARCHAR2,
                     X_Reference_1                      VARCHAR2,
                     X_Reference_2                      VARCHAR2,
                     X_Reference_3                      VARCHAR2,
                     X_Reference_4                      VARCHAR2,
                     X_Reference_5                      VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Context2                         VARCHAR2,
                     X_Invoice_Date                     DATE,
                     X_Tax_Code                         VARCHAR2,
                     X_Invoice_Identifier               VARCHAR2,
                     X_Invoice_Amount                   NUMBER,
                     X_No1                              VARCHAR2,
                     X_Stat_Amount                      NUMBER,
                     X_Ignore_Rate_Flag                 VARCHAR2,
                     X_Context3                         VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Subledger_Doc_Sequence_Id        NUMBER,
                     X_Context4                         VARCHAR2,
                     X_Subledger_Doc_Sequence_Value     NUMBER,
                     X_Reference_6                      VARCHAR2,
                     X_Reference_7                      VARCHAR2,
                     X_Reference_8                      VARCHAR2,
                     X_Reference_9                      VARCHAR2,
                     X_Reference_10                     VARCHAR2,
		     X_Recon_Rowid			VARCHAR2,
		     X_Jgzz_Recon_Status		VARCHAR2,
		     X_Jgzz_Recon_Date			DATE,
		     X_Jgzz_Recon_Id			NUMBER,
		     X_Jgzz_Recon_Ref			VARCHAR2,
		     X_Taxable_Line_Flag		VARCHAR2,
		     X_Tax_Type_Code			VARCHAR2,
		     X_Tax_Code_Id			NUMBER,
		     X_Tax_Rounding_Rule_Code		VARCHAR2,
		     X_Amount_Includes_Tax_Flag		VARCHAR2,
		     X_Tax_Document_Identifier		VARCHAR2,
		     X_Tax_Document_Date		DATE,
		     X_Tax_Customer_Name		VARCHAR2,
		     X_Tax_Customer_Reference		VARCHAR2,
		     X_Tax_Registration_Number		VARCHAR2,
		     X_Tax_Line_Flag			VARCHAR2,
		     X_Tax_Group_Id			NUMBER,
                     X_Third_Party_Id		        VARCHAR2,
		     X_Global_Attribute1                VARCHAR2,
                     X_Global_Attribute2                VARCHAR2,
                     X_Global_Attribute3                VARCHAR2,
                     X_Global_Attribute4                VARCHAR2,
                     X_Global_Attribute5                VARCHAR2,
                     X_Global_Attribute6                VARCHAR2,
                     X_Global_Attribute7                VARCHAR2,
                     X_Global_Attribute8                VARCHAR2,
                     X_Global_Attribute9                VARCHAR2,
                     X_Global_Attribute10               VARCHAR2,
                     X_Global_Attribute_Category        VARCHAR2
                    );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Status                         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Accounted_Dr                   NUMBER,
                       X_Accounted_Cr                   NUMBER,
                       X_Description                    VARCHAR2,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Reference_3                    VARCHAR2,
                       X_Reference_4                    VARCHAR2,
                       X_Reference_5                    VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Context2                       VARCHAR2,
                       X_Invoice_Date                   DATE,
                       X_Tax_Code                       VARCHAR2,
                       X_Invoice_Identifier             VARCHAR2,
                       X_Invoice_Amount                 NUMBER,
                       X_No1                            VARCHAR2,
                       X_Stat_Amount                    NUMBER,
                       X_Ignore_Rate_Flag               VARCHAR2,
                       X_Context3                       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Subledger_Doc_Sequence_Id      NUMBER,
                       X_Context4                       VARCHAR2,
                       X_Subledger_Doc_Sequence_Value   NUMBER,
                       X_Reference_6                    VARCHAR2,
                       X_Reference_7                    VARCHAR2,
                       X_Reference_8                    VARCHAR2,
                       X_Reference_9                    VARCHAR2,
                       X_Reference_10                   VARCHAR2,
		       X_Recon_On_Flag			VARCHAR2,
		       X_Recon_Rowid 	  IN OUT NOCOPY VARCHAR2,
		       X_Jgzz_Recon_Status		VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id			NUMBER,
		       X_Jgzz_Recon_Ref			VARCHAR2,
		       X_Taxable_Line_Flag		VARCHAR2,
		       X_Tax_Type_Code			VARCHAR2,
		       X_Tax_Code_Id			NUMBER,
		       X_Tax_Rounding_Rule_Code		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_Tax_Document_Identifier	VARCHAR2,
		       X_Tax_Document_Date		DATE,
		       X_Tax_Customer_Name		VARCHAR2,
		       X_Tax_Customer_Reference		VARCHAR2,
		       X_Tax_Registration_Number	VARCHAR2,
		       X_Tax_Line_Flag			VARCHAR2,
		       X_Tax_Group_Id			NUMBER,
                       X_Third_Party_Id		        VARCHAR2,
		       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2
                      );


  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2,
                       X_Recon_Rowid			VARCHAR2);

END GL_JE_LINES_PKG;

/
