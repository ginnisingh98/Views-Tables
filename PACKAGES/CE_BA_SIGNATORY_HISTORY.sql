--------------------------------------------------------
--  DDL for Package CE_BA_SIGNATORY_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BA_SIGNATORY_HISTORY" AUTHID CURRENT_USER as
/* $Header: cebasighiss.pls 120.0 2005/03/31 14:06:01 svali noship $ */
   --
   -- Package
   --   ce_ba_signatory_history
   -- Purpose
   --   To contain validation and insertion routines for ce_ba_signatory_history
   -- History
   --   04-Dec-2004   Sahik Vali   Created
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

   --
   -- Procedure
   --  Insert_Row
   -- Purpose
   --   Inserts a row into ce_ba_signatory_history
   -- History
   --   14-DEC-2004  Shaik Vali Created
   -- Arguments
   -- all the columns of the table ce_ba_signatory_history
   -- Example
   --   ce_ba_signatory_history.Insert_Row(....;
   -- Notes
   --
   PROCEDURE Insert_Row( X_rowid	IN OUT NOCOPY VARCHAR2,
				 X_Signatory_Id     IN OUT NOCOPY NUMBER,
				 X_Signatory_History_id	IN OUT NOCOPY NUMBER,
				 X_Approver_person_id		NUMBER,
				 X_Action					VARCHAR2,
				 X_Current_record_flag		VARCHAR2,
                         X_Last_Updated_By          NUMBER,
                         X_Last_Update_Date         DATE,
                         X_Last_Update_Login        NUMBER,
                         X_Created_By               NUMBER,
                         X_Creation_Date            DATE,
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
END CE_BA_SIGNATORY_HISTORY;

 

/
