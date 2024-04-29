--------------------------------------------------------
--  DDL for Package PSP_AUTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_AUTO_PKG" AUTHID CURRENT_USER AS
--$Header: PSPAUTHS.pls 115.8 2002/11/19 11:01:00 ddubey ship $
/**************************************************************************************************************
History:-

 Subha Ramachandran    03/Feb/2000     Changes for Multi-org Implementation

**************************************************************************************************************/


PROCEDURE Insert_Accounts_Row  (X_Rowid	      IN OUT NOCOPY  VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Acct_Type			VARCHAR2,
                                X_Period_Type           VARCHAR2,
				X_Acct_Seq_Num		NUMBER,
				X_Expenditure_Type	VARCHAR2,
				X_Segment_num           NUMBER,
				X_Natural_Account	      VARCHAR2,
				X_Start_Date_Active	DATE,
				X_End_Date_Active		DATE   ,
                                X_Set_of_Books_Id   number,
                                X_Business_Group_Id number

				);
PROCEDURE Lock_Accounts_Row    (X_Rowid		 VARCHAR2,
				X_Acct_Id			 NUMBER,
				X_Acct_Type			 VARCHAR2,
                                X_Period_Type            VARCHAR2,
				X_Acct_Seq_Num		 NUMBER,
				X_Expenditure_Type	 VARCHAR2,
				X_Segment_num            NUMBER,
				X_Natural_Account        VARCHAR2,
				X_Start_Date_Active	 DATE,
				X_End_date_Active		 DATE  ,
                                X_Set_of_Books_Id   number,
                                X_Business_Group_Id number
				);
PROCEDURE Update_Accounts_Row  (X_Rowid		VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Acct_Type			VARCHAR2,
                                X_Period_Type           VARCHAR2,
				X_Acct_Seq_Num		NUMBER,
				X_Expenditure_Type	VARCHAR2,
				X_Segment_num           NUMBER,
				X_Natural_Account	      VARCHAR2,
				X_Start_Date_Active	DATE,
				X_End_Date_Active		DATE   ,

                                X_Set_of_Books_Id   number,
                                X_Business_Group_Id number
				);
PROCEDURE Delete_Accounts_Row  (X_Rowid		VARCHAR2,
				X_Acct_Id			NUMBER
				);
PROCEDURE Insert_Expressions_Row (X_Rowid		IN OUT NOCOPY  VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value		VARCHAR2
				);
PROCEDURE Lock_Expressions_Row (X_Rowid		VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value		VARCHAR2
				);
PROCEDURE Update_Expressions_Row (X_Rowid		VARCHAR2,
				X_Acct_Id			NUMBER,
				X_Param_Line_Num		NUMBER,
				X_Lookup_Id			NUMBER,
				X_Operand			VARCHAR2,
				X_User_Value		VARCHAR2
				);
PROCEDURE Delete_Expressions_Row  (X_Rowid	VARCHAR2);
END psp_auto_pkg;

 

/
