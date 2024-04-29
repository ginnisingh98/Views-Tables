--------------------------------------------------------
--  DDL for Package CE_BA_SIGNATORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BA_SIGNATORIES_PKG" AUTHID CURRENT_USER as
/* $Header: cebasigs.pls 120.0 2005/03/31 14:05:34 svali noship $ */
   --
   -- Package
   --   ce_ba_signatories_pkg
   -- Purpose
   --   To contain validation and insertion routines for ce_ba_signatories
   -- History
   --   04-Dec-2004   Sahik Vali   Created
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

   --
   -- Procedure
   --  Insert_Row
   -- Purpose
   --   Inserts a row into ce_ba_signatories
   -- History
   --   14-DEC-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_ba_signatories
   -- Example
   --   ce_ba_signatories_pkg.Insert_Row(....;
   -- Notes
   --
   PROCEDURE Insert_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Person_Id     	NUMBER,
				 X_Single_limit_amount	NUMBER,
		         X_Joint_limit_amount	NUMBER,
				 X_Signer_group		VARCHAR2,
				 X_Other_limits		VARCHAR2,
				 X_Start_date		DATE,
				 X_End_date		DATE,
				 X_Status		VARCHAR2,
				 X_Approval_type		VARCHAR2,
				 X_requester_id		NUMBER,
				 X_deleted_flag		VARCHAR2,
                         X_Last_Updated_By                NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Update_Login              NUMBER,
                         X_Created_By                     NUMBER,
                         X_Creation_Date                  DATE,
				 X_Attribute_category		VARCHAR2,
				 X_Attribute1		VARCHAR2,
				 X_Attribute2		VARCHAR2,
				 X_Attribute3		VARCHAR2,
				 X_Attribute4		VARCHAR2,
				 X_Attribute5		VARCHAR2,
				 X_Attribute6		VARCHAR2,
				 X_Attribute7		VARCHAR2,
				 X_Attribute8		VARCHAR2,
				 X_Attribute9		VARCHAR2,
				 X_Attribute10		VARCHAR2,
				 X_Attribute11		VARCHAR2,
				 X_Attribute12		VARCHAR2,
				 X_Attribute13		VARCHAR2,
				 X_Attribute14		VARCHAR2,
				 X_Attribute15		VARCHAR2
                      );
   --
   -- Procedure
   --  Lock_Row
   -- Purpose
   --   Locks a row into ce_ba_signatories
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_ba_signatories
   -- Example
   --   ce_ba_signatories_pkg.Lock_Row(....;
   -- Notes
   --
  PROCEDURE Lock_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Person_Id     	NUMBER,
				 X_Single_limit_amount	NUMBER,
		         X_Joint_limit_amount	NUMBER,
				 X_Signer_group		VARCHAR2,
				 X_Other_limits		VARCHAR2,
				 X_Start_date		DATE,
				 X_End_date		DATE,
				 X_Status		VARCHAR2,
				 X_Approval_type		VARCHAR2,
				 X_Attribute_category		VARCHAR2,
				 X_Attribute1		VARCHAR2,
				 X_Attribute2		VARCHAR2,
				 X_Attribute3		VARCHAR2,
				 X_Attribute4		VARCHAR2,
				 X_Attribute5		VARCHAR2,
				 X_Attribute6		VARCHAR2,
				 X_Attribute7		VARCHAR2,
				 X_Attribute8		VARCHAR2,
				 X_Attribute9		VARCHAR2,
				 X_Attribute10		VARCHAR2,
				 X_Attribute11		VARCHAR2,
				 X_Attribute12		VARCHAR2,
				 X_Attribute13		VARCHAR2,
				 X_Attribute14		VARCHAR2,
				 X_Attribute15		VARCHAR2
                      );
   --
   -- Procedure
   --  Update_Row
   -- Purpose
   --   Updates a row into ce_ba_signatories
   -- History
   --   15-Dec-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_ba_signatories
   -- Example
   --   ce_ba_signatories.Update_Row(....;
   -- Notes
   --
  PROCEDURE Update_Row( X_Rowid                   IN OUT NOCOPY VARCHAR2,
                         X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Bank_Account_Id                NUMBER,
                         X_Person_Id     	NUMBER,
				 X_Single_limit_amount	NUMBER,
		         X_Joint_limit_amount	NUMBER,
				 X_Signer_group		VARCHAR2,
				 X_Other_limits		VARCHAR2,
				 X_Start_date		DATE,
				 X_End_date		DATE,
				 X_Status		VARCHAR2,
				 X_Approval_type		VARCHAR2,
				 X_requester_id	NUMBER,
                         X_Last_Updated_By                NUMBER,
                         X_Last_Update_Date               DATE,
                         X_Last_Update_Login              NUMBER,
				 X_Attribute_category		VARCHAR2,
				 X_Attribute1		VARCHAR2,
				 X_Attribute2		VARCHAR2,
				 X_Attribute3		VARCHAR2,
				 X_Attribute4		VARCHAR2,
				 X_Attribute5		VARCHAR2,
				 X_Attribute6		VARCHAR2,
				 X_Attribute7		VARCHAR2,
				 X_Attribute8		VARCHAR2,
				 X_Attribute9		VARCHAR2,
				 X_Attribute10		VARCHAR2,
				 X_Attribute11		VARCHAR2,
				 X_Attribute12		VARCHAR2,
				 X_Attribute13		VARCHAR2,
				 X_Attribute14		VARCHAR2,
				 X_Attribute15		VARCHAR2
                      );

   -- Procedure
   --  Delete_Row
   -- Purpose
   --   Deletes a row from ce_je_mappings
   -- History
   --   08-Sept-2004  Shaik Vali Created
   -- Arguments
   --    x_rowid         Rowid of a row
   -- Example
   --   ce_je_mappings_pkg.delete_row();
   -- Notes
   --
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END CE_BA_SIGNATORIES_PKG;

 

/
