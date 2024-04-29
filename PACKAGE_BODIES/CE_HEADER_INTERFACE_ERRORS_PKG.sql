--------------------------------------------------------
--  DDL for Package Body CE_HEADER_INTERFACE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_HEADER_INTERFACE_ERRORS_PKG" as
/* $Header: cehinteb.pls 120.0 2002/08/24 02:36:36 appldev noship $ */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row( X_statement_number	 VARCHAR2,
		       X_bank_account_num	 VARCHAR2,
		       X_message_name	         VARCHAR2) IS
   BEGIN
     INSERT INTO CE_HEADER_INTERFACE_ERRORS(
	      application_short_name,
              statement_number,
              bank_account_num,
              message_name,
              creation_date,
              created_by)
              VALUES ('CE',
              NVL(X_statement_number,'NONE'),
              NVL(X_bank_account_num,'NONE'),
              NVL(X_message_name,'NONE'),
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Insert_Row( X_statement_number	 VARCHAR2,
		       X_bank_account_num	 VARCHAR2,
		       X_message_name	         VARCHAR2,
		       x_application_short_name  VARCHAR2) IS
   BEGIN
     INSERT INTO CE_HEADER_INTERFACE_ERRORS(
	      application_short_name,
              statement_number,
              bank_account_num,
              message_name,
              creation_date,
              created_by)
              VALUES (NVL(X_application_short_name,'NONE'),
              NVL(X_statement_number,'NONE'),
              NVL(X_bank_account_num,'NONE'),
              NVL(X_message_name,'NONE'),
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row(X_statement_number VARCHAR2,
		       X_bank_account_num VARCHAR2) IS
  BEGIN
    DELETE FROM CE_HEADER_INTERFACE_ERRORS
    WHERE statement_number  = X_statement_number AND
	  ((bank_account_num  = X_bank_account_num) OR
	   (bank_account_num = 'NONE'));
  END Delete_Row;

END CE_HEADER_INTERFACE_ERRORS_PKG;

/
