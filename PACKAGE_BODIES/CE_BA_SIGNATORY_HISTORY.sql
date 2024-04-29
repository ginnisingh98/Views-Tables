--------------------------------------------------------
--  DDL for Package Body CE_BA_SIGNATORY_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BA_SIGNATORY_HISTORY" as
/* $Header: cebasighisb.pls 120.0 2005/03/31 14:06:36 svali noship $ */
--
-- Package
--  ce_ba_signatory_history
-- Purpose
--   To contain validation and insertion routines for ce_ba_signatory_history
-- History
--   15-dec-2004   Shaik Vali           Created

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;


  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into ce_ba_signatory_history
  -- History
  --   15-Dec-2004  Shaik Vali           Created
  -- Arguments
  -- all the columns of the table CE_BA_SIGNATORY_HISTORY
  -- Example
  --   CE_BA_SIGNATORY_HISTORY.Insert_Row(....;
  -- Notes
  --

PROCEDURE Insert_Row( 	 X_rowid	IN OUT NOCOPY VARCHAR2,
				 X_Signatory_Id     IN OUT NOCOPY NUMBER,
                         X_Signatory_History_Id   IN OUT NOCOPY NUMBER,
				 X_Approver_Person_Id		NUMBER,
				 X_Action			VARCHAR2,
				 X_current_record_flag		VARCHAR2,
                         X_Last_Updated_By          NUMBER,
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
  ) IS
    CURSOR C IS SELECT rowid FROM CE_BA_SIGNATORY_HIST_H
                 WHERE signatory_history_id = X_signatory_history_id;

  CURSOR C2 IS SELECT ce_ba_signatory_hist_h_s.nextval FROM sys.dual;
   --
   BEGIN
     --   cep_standard.debug('open c2 ');

       OPEN C2;
       FETCH C2 INTO X_Signatory_history_id;
       CLOSE C2;
       --

       INSERT INTO CE_BA_SIGNATORY_HIST_H(
	      signatory_id,
	      signatory_history_id,
	      approver_person_id,
	      action,
	      current_record_flag,
   	      Last_Updated_By,
              Last_Update_Date,
              Last_Update_Login,
              Created_By,
              Creation_Date,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             ) VALUES (
              X_Signatory_Id,
	      X_signatory_history_id,
	      X_approver_person_id,
	      X_action,
	      X_current_record_flag,
              X_Last_Updated_By ,
              X_Last_Update_Date,
              X_Last_Update_Login,
              X_Created_By   ,
              X_Creation_Date,
	      X_Attribute_category,
 		X_Attribute1,
		X_Attribute2,
		X_Attribute3,
		X_Attribute4,
		X_Attribute5,
		X_Attribute6,
		X_Attribute7,
		X_Attribute8,
		X_Attribute9,
		X_Attribute10,
		X_Attribute11,
		X_Attribute12,
		X_Attribute13,
		X_Attribute14,
		X_Attribute15
             );
    --
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

END CE_BA_SIGNATORY_HISTORY;

/
