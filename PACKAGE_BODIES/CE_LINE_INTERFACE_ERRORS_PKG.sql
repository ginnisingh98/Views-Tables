--------------------------------------------------------
--  DDL for Package Body CE_LINE_INTERFACE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_LINE_INTERFACE_ERRORS_PKG" as
/* $Header: celinteb.pls 120.1 2002/11/12 21:19:49 bhchung ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
  		       X_statement_number	 VARCHAR2,
		       X_bank_account_num	 VARCHAR2,
		       X_line_number		 NUMBER,
		       X_message_name	         VARCHAR2) IS
   BEGIN
     INSERT INTO CE_LINE_INTERFACE_ERRORS(
	      application_short_name,
              statement_number,
              bank_account_num,
	      line_number,
              message_name,
              creation_date,
              created_by)
              VALUES (
	      'CE',
              X_statement_number,
              X_bank_account_num,
	      X_line_number,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
  		       X_statement_number	 VARCHAR2,
		       X_bank_account_num	 VARCHAR2,
		       X_line_number		 NUMBER,
		       X_message_name	         VARCHAR2,
		       X_application_short_name  VARCHAR2) IS
   BEGIN
     INSERT INTO CE_LINE_INTERFACE_ERRORS(
	      application_short_name,
              statement_number,
              bank_account_num,
	      line_number,
              message_name,
              creation_date,
              created_by)
              VALUES (
	      X_application_short_name,
              X_statement_number,
              X_bank_account_num,
	      X_line_number,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row(X_statement_number VARCHAR2,
		       X_bank_account_num VARCHAR2,
		       X_line_number	  NUMBER) IS
  BEGIN
    IF (X_line_number IS NOT NULL) THEN
      DELETE FROM CE_LINE_INTERFACE_ERRORS
      WHERE statement_number  = X_statement_number AND
	    bank_account_num  = X_bank_account_num AND
	    line_number	      = X_line_number;
    ELSE
      DELETE FROM CE_LINE_INTERFACE_ERRORS
      WHERE statement_number  = X_statement_number AND
	    bank_account_num  = X_bank_account_num;
    END IF;
  END Delete_Row;

END CE_LINE_INTERFACE_ERRORS_PKG;

/
