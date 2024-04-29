--------------------------------------------------------
--  DDL for Package Body CE_SQLLDR_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_SQLLDR_ERRORS_PKG" AS
/* $Header: ceslerrb.pls 120.0 2002/08/24 02:37:45 appldev noship $ */
PROCEDURE Insert_Row(   X_statement_number	VARCHAR2,
			X_bank_account_num	VARCHAR2,
			X_rec_no		NUMBER,
			X_message_text	        VARCHAR2,
			X_status		VARCHAR2 DEFAULT 'W') IS
   BEGIN
     INSERT INTO CE_SQLLDR_ERRORS(
                statement_number,
		bank_account_num,
		rec_no,
		message_text,
		status,
		creation_date,
		created_by)
              VALUES (
		X_statement_number,
		X_bank_account_num,
		X_rec_no,
		X_message_text,
		X_status,
		sysdate,
		NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row IS
  BEGIN
    DELETE FROM CE_SQLLDR_ERRORS;
  END Delete_Row;


END CE_SQLLDR_ERRORS_PKG;

/
