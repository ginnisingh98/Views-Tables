--------------------------------------------------------
--  DDL for Package Body GL_AUTOREV_CRITERIA_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOREV_CRITERIA_SETS_PKG" AS
/* $Header: glistcsb.pls 120.2 2003/12/15 22:25:10 spala noship $ */

  --
  -- PUBLIC FUNCTIONS

-- ************************************************************************
--   Called by Journal Reversal Criteria Set form
-- ************************************************************************
  PROCEDURE insert_row(X_Criteria_Set_Id                NUMBER,
                       X_Criteria_Set_Name              VARCHAR2,
                       X_Criteria_Set_Desc              VARCHAR2,
		       X_Creation_Date                  DATE,
                       X_Last_Update_Date               DATE,
		       X_Created_By                     NUMBER,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       X_Context                        VARCHAR2,
	               X_Security_Flag                  VARCHAR2
                      )  IS


  BEGIN


     INSERT INTO gl_autorev_criteria_sets(
      			criteria_set_id,
       			criteria_set_name,
       			criteria_set_desc,
			creation_date,
       			last_update_date,
			created_by,
       			last_updated_by,
       			last_update_login,
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
       			attribute12 ,
       			attribute13,
       			attribute14 ,
       			attribute15 ,
       			context,
       			security_flag)
     		VALUES(x_Criteria_Set_id,
                       X_Criteria_Set_Name,
                       X_Criteria_Set_Desc,
		       X_Creation_Date,
                       X_Last_Update_Date,
		       X_Created_By,
                       X_Last_Updated_By,
                       X_Last_Update_Login,
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
                       X_Attribute15,
                       X_Context,
	               X_Security_Flag);

  	-- Insert Detail values also into GL_AUTOREVERS_OPTIONS

	    GL_AUTOREVERSE_OPTIONS_PKG.Insert_Criteria_Reversal_Cat(
		x_criteria_set_id   => X_Criteria_Set_id,
		x_created_by        => X_Created_By,
		x_last_updated_by   => X_Last_Updated_By,
		x_last_update_login => X_Last_Update_Login);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'Criteria_reversal_cat');
      RAISE;
  END insert_row;

-- ************************************************************************
--   Called by Journal Reversal Criteria Set form
-- ************************************************************************

 FUNCTION get_criteria_set_id RETURN NUMBER IS
   l_criteria_set_id 	NUMBER;

  BEGIN
       -- Fetch criteria_set_id from the sequence

     SELECT GL_AUTOREV_CRITERIA_SETS_S.Nextval INTO l_criteria_set_id
		FROM DUAL;

     -- Retrun new criteria_set_id;

     RETURN(l_criteria_set_id);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'get_criteria_set_id');
      RAISE;
  END get_criteria_set_id;

-- ************************************************************************
--   Called by Journal Reversal Criteria Set form
-- ************************************************************************

   Procedure Delete_row( X_Criteria_set_Id      NUMBER)  IS

	l_ledger_id 	NUMBER := 0;
   BEGIN
        DELETE FROM GL_AUTOREVERSE_OPTIONS G
        WHERE G.CRITERIA_SET_ID = x_criteria_set_id;

   EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE',
        'GL_AUTOREV_CRITERIA_SETS.Delete_Row');
         RAISE;
   END Delete_Row;

-- ************************************************************************
--   Called by Journal Reversal Criteria Set form
-- ************************************************************************

   FUNCTION Check_Ledger_Assign( X_Criteria_set_Id      NUMBER)
         Return Boolean   IS

	x_ledger_id 	NUMBER := 0;
   BEGIN
      SELECT 1 into x_ledger_id FROM DUAL
      WHERE EXISTS (SELECT ledger_id FROM GL_LEDGERS
                    where  criteria_set_id = x_criteria_set_id);

      If (x_ledger_id = 1) Then
        FND_MESSAGE.Set_name('SQLGL','GL_AR_LEDGER_CRITERIA_SET_ASSG');
        APP_EXCEPTION.RAISE_EXCEPTION;
        Return(False);
      END IF;
      Return (True);
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
      RAISE;

      When NO_DATA_FOUND THEN
	NULL;
        Return(True);
      WHEN OTHERS THEN
        fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
        fnd_message.set_token('PROCEDURE',
        'GL_AUTOREV_CRITERIA_SETS.Check_Ledger_Assign');
         RAISE;


   END Check_Ledger_Assign;

END GL_AUTOREV_CRITERIA_SETS_PKG;

/
