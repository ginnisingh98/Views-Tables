--------------------------------------------------------
--  DDL for Package Body PSP_AUTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_AUTO_PKG" AS
--$Header: PSPAUTHB.pls 115.8 2002/11/19 12:00:33 ddubey psp2376993.sql $
/****************************************************************************************************
History:-

  Subha Ramachandran      03/Feb/2000      Chnages for Multi-org Implementation


******************************************************************************************************/

PROCEDURE Insert_Accounts_Row  (X_Rowid		 IN OUT NOCOPY  VARCHAR2,
				X_Acct_Id			 NUMBER,
				X_Acct_Type			 VARCHAR2,
                                X_Period_Type            VARCHAR2,
				X_Acct_Seq_Num		 NUMBER,
				X_Expenditure_Type	 VARCHAR2,
				X_Segment_num            NUMBER,
				X_Natural_Account        VARCHAR2,
				X_Start_Date_Active	 DATE,
				X_End_Date_Active		 DATE     ,
                                X_Set_of_Books_Id     NUMBER,
                                X_Business_Group_Id   NUMBER
				) IS
      CURSOR C IS
      SELECT ROWID
      FROM   PSP_AUTO_ACCTS
      WHERE  acct_id = 	X_Acct_Id;
BEGIN
	INSERT INTO psp_auto_accts
		(
		acct_id,
		acct_type,
                period_type,
		expenditure_type,
		segment_num,
		natural_account,
		start_date_active,
		end_date_active,
		acct_seq_num,
                set_of_books_id,
                business_group_id,
	      last_update_date,
		last_updated_by,
	      last_update_login,
		created_by,
		creation_date
		)
		VALUES
		(
		X_Acct_Id,
		X_Acct_Type,
                X_Period_Type,
		X_Expenditure_Type,
		X_Segment_num,
		X_Natural_Account,
		X_Start_Date_Active,
		X_End_Date_Active,
		X_Acct_Seq_Num,
                X_Set_of_Books_Id,
                X_Business_Group_Id,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id,
		fnd_global.user_id,
		sysdate
		);
	OPEN C;
	FETCH C INTO X_Rowid;
	if (C%NOTFOUND) then
 	    CLOSE C;
            RAISE NO_DATA_FOUND;
        end if;
       CLOSE C;
END Insert_Accounts_Row;
--================================================================================
--================================================================================
PROCEDURE Lock_Accounts_Row    (X_Rowid		VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Acct_Type			VARCHAR2,
			        X_Period_Type           VARCHAR2,
				X_Acct_Seq_Num		NUMBER,
				X_Expenditure_Type	VARCHAR2,
				X_Segment_num            NUMBER,
				X_Natural_Account       VARCHAR2,
				X_Start_Date_Active	DATE,
				X_End_Date_Active		DATE,
                                X_Set_of_Books_Id      NUMBER,
                                X_Business_Group_Id    NUMBER
				) IS
	CURSOR C IS
	SELECT *
 	FROM psp_auto_accts
   	WHERE ROWID = X_Rowid
   	FOR UPDATE OF Acct_Id NOWAIT;
	Recinfo C%ROWTYPE;
BEGIN
 	OPEN C;
	FETCH C INTO Recinfo;
	if (C%NOTFOUND) then
	    CLOSE C;
	    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	    APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
  	--  check that mandatory columns match values in form
      	  	(Recinfo.Acct_Id = X_Acct_Id)
                AND (Recinfo.Start_Date_Active = X_Start_Date_Active)
        	AND (Recinfo.Acct_Seq_Num = X_Acct_Seq_Num)
                AND (Recinfo.Period_Type = X_Period_Type)
  	--  check that non-mandatory columns match values in form
           AND ((Recinfo.Expenditure_Type = X_Expenditure_Type)
            	 OR ((Recinfo.Expenditure_Type  IS NULL)
                   AND (X_Expenditure_Type IS NULL)))
	     AND ((Recinfo.Natural_Account = X_Natural_Account)
            	 OR ((Recinfo.Natural_Account  IS NULL)
                   AND (X_Natural_Account IS NULL)))
           AND ((Recinfo.End_Date_Active = X_End_Date_Active)
            	 OR ((Recinfo.End_Date_Active IS NULL)
                   AND (X_End_Date_Active IS NULL)))
   	   ) then
	return;
	else
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.Raise_Exception;
      end if;
END Lock_Accounts_Row;
PROCEDURE Update_Accounts_Row  (X_Rowid		 VARCHAR2,
				X_Acct_Id			 NUMBER,
				X_Acct_Type			 VARCHAR2,
                                X_Period_Type            VARCHAR2,
				X_Acct_Seq_Num		 NUMBER,
				X_Expenditure_Type	 VARCHAR2,
				X_Segment_num            NUMBER,
				X_Natural_Account        VARCHAR2,
				X_Start_Date_Active	 DATE,
				X_End_Date_Active		 DATE ,
                                X_Set_of_Books_Id        NUMBER,
                                X_Business_Group_Id      NUMBER
				) IS
BEGIN
	UPDATE psp_auto_accts
	SET	Acct_Id	      = X_Acct_Id,
		Acct_Type         = X_Acct_Type,
                Period_Type       = X_Period_Type,
		Acct_Seq_Num	= X_Acct_Seq_Num,
		Expenditure_Type  = X_Expenditure_Type,
		Segment_num       = X_Segment_num,
		Natural_Account   = X_Natural_Account,

		Start_Date_Active = X_Start_Date_Active,
		End_Date_Active   = X_End_Date_Active,
                Set_of_books_id  = X_Set_of_Books_Id,
                Business_Group_Id = X_Business_group_id,
		Last_Update_Date  = sysdate,
		Last_Updated_By	= fnd_global.user_id,
		Last_Update_Login = fnd_global.login_id
      	WHERE  	ROWID = X_Rowid;
	if (SQL%NOTFOUND) then
  	   Raise NO_DATA_FOUND;
	end if;
END Update_Accounts_Row;

PROCEDURE Delete_Accounts_Row  (X_Rowid			VARCHAR2,
			           	  X_Acct_Id		NUMBER) IS

v_Dummy varchar2(1);

cursor expressions_c is
   select null from psp_auto_params
   where acct_id = X_Acct_Id;

cursor rules_c is
   select null from psp_auto_rules
   where acct_id = X_Acct_Id;


BEGIN
	-- Delete the detail records
      open expressions_c;
      fetch expressions_c into v_Dummy;
      if (expressions_c%FOUND) then
	DELETE FROM psp_auto_params
	WHERE  Acct_Id = X_Acct_Id;
	if (SQL%NOTFOUND) then
         close expressions_c;
  	   Raise NO_DATA_FOUND;
	end if;
      close expressions_c;
      end if;

      -- Delete the detail records (rules)
      open rules_c;
      fetch rules_c into v_Dummy;
      if (rules_c%FOUND) then
	DELETE FROM psp_auto_rules
	WHERE  Acct_Id = X_Acct_Id;
	if (SQL%NOTFOUND) then
         close rules_c;
  	   Raise NO_DATA_FOUND;
	end if;
      close rules_c;
      end if;


	-- Delete the master record
	DELETE FROM psp_auto_accts
	WHERE ROWID = X_Rowid;
	if (SQL%NOTFOUND) then
  	   Raise NO_DATA_FOUND;
	end if;
End Delete_Accounts_Row;


PROCEDURE Insert_Expressions_Row (X_Rowid			IN OUT NOCOPY  VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value			VARCHAR2
				) IS
	CURSOR C IS
	SELECT ROWID
        FROM   psp_auto_params
        WHERE  Acct_Id = 	X_Acct_Id
	AND Param_line_num = X_Param_Line_Num;
BEGIN
	INSERT INTO psp_auto_params
		(
		Acct_Id,
		Param_Line_Num,
		Lookup_Id,
		Operand,
		User_Value,
		Last_Update_Date,
		Last_Updated_By,
		Last_Update_Login,
		Created_By,
		Creation_Date
		)
		VALUES
		(
		X_Acct_Id,
		X_Param_Line_Num,
		X_Lookup_Id,
		X_Operand,
		X_User_Value,
		sysdate,
		fnd_global.user_id,
		fnd_global.login_id,
		fnd_global.user_id,
		sysdate
		);
	OPEN C;
	FETCH C INTO X_Rowid;
	if (C%NOTFOUND) then
 	    CLOSE C;
            RAISE NO_DATA_FOUND;
        end if;
       CLOSE C;
END Insert_Expressions_Row;
PROCEDURE Lock_Expressions_Row (X_Rowid				VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value			VARCHAR2
				) IS
	CURSOR C IS
	SELECT *
 	FROM psp_auto_params
   	WHERE ROWID = X_Rowid
   	FOR UPDATE OF Acct_Id NOWAIT;
	Recinfo C%ROWTYPE;
BEGIN
 	OPEN C;
	FETCH C INTO Recinfo;
	if (C%NOTFOUND) then
	    CLOSE C;
	    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	    APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C;
	if (
  	--  check that mandatory columns match values in form
      	  	(Recinfo.Acct_Id = X_Acct_Id)
                AND (Recinfo.Param_Line_Num = X_Param_Line_Num)
        	AND (Recinfo.Lookup_Id = X_Lookup_Id)
		AND (Recinfo.Operand = X_Operand)
  	--  check that non-mandatory columns match values in form
           AND ((Recinfo.User_Value = X_User_Value)
            	 OR ((Recinfo.User_Value  IS NULL)
                   AND (X_User_Value IS NULL)))
   	   ) then
	return;
	else
            FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
            APP_EXCEPTION.Raise_Exception;
      end if;
END Lock_Expressions_Row;
PROCEDURE Update_Expressions_Row (X_Rowid			VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value			VARCHAR2
				) IS
BEGIN
	UPDATE psp_auto_params
	SET	Acct_Id	          = 	X_Acct_Id,
		Param_Line_Num    =	X_Param_Line_Num,
		Lookup_Id	  =	X_Lookup_Id,
		Operand		  = 	X_Operand,
		User_Value	  = 	X_User_Value,
		Last_Update_Date = sysdate,
		Last_Updated_By  = fnd_global.user_id,
		Last_Update_Login = fnd_global.login_id
      	WHERE  	ROWID = X_Rowid;
	if (SQL%NOTFOUND) then
  	   Raise NO_DATA_FOUND;
	end if;
END Update_Expressions_Row;
PROCEDURE Delete_Expressions_Row  (X_Rowid			VARCHAR2) IS
BEGIN
	-- Delete the detail records
	DELETE FROM psp_auto_params
	WHERE ROWID = X_Rowid;
	if (SQL%NOTFOUND) then
  	   Raise NO_DATA_FOUND;
	end if;
End Delete_Expressions_Row;
END psp_auto_pkg;

/
