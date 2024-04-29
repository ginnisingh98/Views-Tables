--------------------------------------------------------
--  DDL for Package Body IGI_AR_SYS_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_AR_SYS_OPT_PKG" as
-- $Header: igirsopb.pls 120.4.12000000.2 2007/10/25 06:24:54 mbremkum ship $

   l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   l_path        VARCHAR2(50)  :=      'IGI.PLSQL.igirsopb.IGI_AR_SYS_OPT_PKG.';


     /*Added Insert Row for R12 Uptake bug No 5905216*/

     PROCEDURE Insert_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2,
--	  X_Dunning_Receivables_Trx_Id  NUMBER,
          X_Last_Updated_By             NUMBER,
          X_Last_Update_Date            DATE,
          X_Last_Update_Login           NUMBER,
	  X_Created_By			VARCHAR2,
	  X_Creation_Date		DATE,
	  X_Org_Id			NUMBER

    ) IS

	l_login_id NUMBER;
	l_created_by NUMBER;
	l_updated_by NUMBER;

    BEGIN

	l_login_id := FND_GLOBAL.LOGIN_ID;
	l_created_by := FND_GLOBAL.USER_ID;
	l_updated_by := FND_GLOBAL.USER_ID;

	insert into igi_ar_system_options_all
	(
	SET_OF_BOOKS_ID,
	RPI_HEADER_CONTEXT_CODE,
	RPI_HEADER_CHARGE_ID,
	RPI_HEADER_GENERATE_SEQ,
	RPI_LINE_CONTEXT_CODE,
	RPI_LINE_CHARGE_ID,
	RPI_LINE_GENERATE_SEQ,
	RPI_LINE_CHARGE_LINE_NUM,
	RPI_LINE_PRICE_BREAK_NUM,
	DUNNING_RECEIVABLES_TRX_ID,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ORG_ID
	)
	values
	(
	  X_Set_Of_Books_Id,
	  X_Rpi_Header_Context_Code,
	  X_Rpi_Header_Charge_Id,
	  X_Rpi_Header_Generate_Seq,
	  X_Rpi_Line_Context_Code,
	  X_Rpi_Line_Charge_Id,
	  X_Rpi_Line_Generate_Seq,
	  X_Rpi_Line_Charge_Line_Num,
	  X_Rpi_Line_Price_Break_Num,
	  NULL,				/*Inserting NULL as Dunning is obsolete*/
          l_updated_by,
          X_Last_Update_Date,
          l_login_id,
	  l_created_by,
	  X_Creation_Date,
	  X_Org_Id
	);

   END Insert_Row;


   PROCEDURE Update_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
--	  X_Arc_Auto_Gl_Import_Flag     VARCHAR2,	/*Commented for R12 Uptake Bug No 5905216*/
--	  X_Arc_Cash_Sob_Id		NUMBER,
--	  X_Arc_Unalloc_Rev_Ccid	NUMBER,
--        X_Dunning_Receivables_Trx_Id  NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2,
	  X_Last_Updated_By             NUMBER,
          X_Last_Update_Date            DATE,
          X_Last_Update_Login           NUMBER
--        X_Arc_Je_Source_Name          VARCHAR2
     ) IS
	BEGIN

	 UPDATE igi_ar_system_options_all
	 SET
	  Set_Of_Books_Id		= X_Set_Of_Books_Id,
--	  Arc_Auto_Gl_Import_Flag       = X_Arc_Auto_Gl_Import_Flag,	/*Commented for R12 Uptake bug No 5905216*/
--	  Arc_Cash_Sob_Id		= X_Arc_Cash_Sob_Id,
--	  Arc_Unalloc_Rev_Ccid		= X_Arc_Unalloc_Rev_Ccid,
--        Dunning_Receivables_Trx_id    = X_Dunning_Receivables_Trx_Id,
	  Rpi_Header_Context_Code	= X_Rpi_Header_Context_Code,
	  Rpi_Header_Charge_Id		= X_Rpi_Header_Charge_Id,
	  Rpi_Header_Generate_Seq 	= X_Rpi_Header_Generate_Seq,
	  Rpi_Line_Context_Code		= X_Rpi_Line_Context_Code,
	  Rpi_Line_Charge_Id   		= X_Rpi_Line_Charge_Id,
	  Rpi_Line_Generate_Seq		= X_Rpi_Line_Generate_Seq,
	  Rpi_Line_Charge_Line_Num	= X_Rpi_Line_Charge_Line_Num,
	  Rpi_Line_Price_Break_Num 	= X_Rpi_Line_Price_Break_Num,
          Last_Updated_By               = X_Last_Updated_By,
          Last_Update_Date              = X_Last_Update_Date,
          Last_Update_Login             = X_Last_Update_Login
--        Arc_Je_Source_Name            = X_Arc_Je_Source_Name
	  WHERE rowid = X_Rowid;
	  if (SQL%NOTFOUND) then
	   raise NO_DATA_FOUND;
	  end if;
	END Update_Row;


  PROCEDURE Lock_Row(X_Rowid		VARCHAR2,
	  X_Set_Of_Books_Id		NUMBER,
--	  X_Arc_Auto_Gl_Import_Flag     VARCHAR2,	/*Commented for R12 Uptake bug No 5905216*/
--	  X_Arc_Cash_Sob_Id		NUMBER,
--	  X_Arc_Unalloc_Rev_Ccid	NUMBER,
--        X_Dunning_Receivables_Trx_Id  NUMBER,
	  X_Rpi_Header_Context_Code	VARCHAR2,
	  X_Rpi_Header_Charge_Id	VARCHAR2,
	  X_Rpi_Header_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Context_Code	VARCHAR2,
	  X_Rpi_Line_Charge_Id		VARCHAR2,
	  X_Rpi_Line_Generate_Seq	VARCHAR2,
	  X_Rpi_Line_Charge_Line_Num	VARCHAR2,
	  X_Rpi_Line_Price_Break_Num	VARCHAR2
--        X_Arc_Je_Source_Name          VARCHAR2
	 )  IS
	  CURSOR C IS
	    SELECT *
	    FROM igi_ar_system_options_all
	    WHERE rowid = X_Rowid
	    FOR UPDATE of Set_Of_Books_Id NOWAIT;
	  Recinfo C%ROWTYPE;
	BEGIN
	   OPEN C;
	   FETCH C INTO Recinfo;
	   if (C%NOTFOUND) then
	      CLOSE C;
	      FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	      IF ( l_excep_level >=  l_debug_level ) THEN
                FND_LOG.MESSAGE (l_excep_level,l_path || 'Lock_Row',FALSE);
              END IF;
              APP_EXCEPTION.Raise_Exception;
	   end if;
	   CLOSE C;

	   if (
				(Recinfo.Set_Of_Books_Id = X_Set_Of_Books_Id)
--		    AND	(	(Recinfo.Arc_Auto_Gl_Import_Flag = X_Arc_Auto_Gl_Import_Flag)
--			OR (	(Recinfo.Arc_Auto_Gl_Import_Flag IS NULL)
--			   AND	(X_Arc_Auto_Gl_Import_Flag IS NULL)))
--		    AND	(	(Recinfo.Arc_Cash_Sob_Id = X_Arc_Cash_Sob_Id)
--			OR (	(Recinfo.Arc_Cash_Sob_Id IS NULL)
--			   AND	(X_Arc_Cash_Sob_Id IS NULL)))
--		    AND (	(Recinfo.Arc_Unalloc_Rev_Ccid = X_Arc_Unalloc_Rev_Ccid)
--			OR (	(Recinfo.Arc_Unalloc_Rev_Ccid IS NULL)
--			   AND	(X_Arc_Unalloc_Rev_Ccid IS NULL)))
--		    AND  (	(Recinfo.Dunning_Receivables_Trx_Id = X_Dunning_Receivables_Trx_Id)
--			OR (	(Recinfo.Dunning_Receivables_Trx_Id IS NULL)
--			   AND	(X_Dunning_Receivables_Trx_Id IS NULL)))
		    AND (	(Recinfo.Rpi_Header_Context_Code = X_Rpi_Header_Context_Code)
			OR (	(Recinfo.Rpi_Header_Context_Code IS NULL)
			   AND	(X_Rpi_Header_Context_Code IS NULL)))
		    AND (	(Recinfo.Rpi_Header_Charge_Id = X_Rpi_Header_Charge_Id)
			OR (	(Recinfo.Rpi_Header_Charge_Id IS NULL)
			   AND	(X_Rpi_Header_Charge_Id IS NULL)))
		    AND (	(Recinfo.Rpi_Header_Generate_Seq = X_Rpi_Header_Generate_Seq)
			OR (	(Recinfo.Rpi_Header_Generate_Seq IS NULL)
			   AND	(X_Rpi_Header_Generate_Seq IS NULL)))
		    AND (	(Recinfo.Rpi_Line_Context_Code = X_Rpi_Line_Context_Code)
			OR (	(Recinfo.Rpi_Line_Context_Code IS NULL)
			   AND	(X_Rpi_Line_Context_Code IS NULL)))
		    AND (	(Recinfo.Rpi_Line_Charge_Id = X_Rpi_Line_Charge_Id)
			OR (	(Recinfo.Rpi_Line_Charge_Id IS NULL)
			   AND	(X_Rpi_Line_Charge_Id IS NULL)))
		    AND (	(Recinfo.Rpi_Line_Generate_Seq = X_Rpi_Line_Generate_Seq)
			OR (	(Recinfo.Rpi_Line_Generate_Seq IS NULL)
			   AND	(X_Rpi_Line_Generate_Seq IS NULL)))
		    AND (	(Recinfo.Rpi_Line_Charge_Line_Num = X_Rpi_Line_Charge_Line_Num)
			OR (	(Recinfo.Rpi_Line_Charge_Line_Num IS NULL)
			   AND	(X_Rpi_Line_Charge_Line_Num IS NULL)))
		    AND (	(Recinfo.Rpi_Line_Price_Break_Num = X_Rpi_Line_Price_Break_Num)
			OR (	(Recinfo.Rpi_Line_Price_Break_Num IS NULL)
			   AND	(X_Rpi_Line_Price_Break_Num IS NULL)))
--                  AND (	(Recinfo.Arc_Je_Source_Name = X_Arc_Je_Source_Name)
--	 		OR (	(Recinfo.Arc_Je_Source_Name IS NULL)
--			   AND	(X_Arc_Je_Source_Name IS NULL)))

		) then
		return;
		else


		  FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
		  IF ( l_excep_level >=  l_debug_level ) THEN
	                FND_LOG.MESSAGE (l_excep_level,l_path || 'Lock_Row',FALSE);
                  END IF;
		  APP_EXCEPTION.Raise_Exception;
		end if;

	END Lock_Row;

 END IGI_AR_SYS_OPT_PKG;

/
