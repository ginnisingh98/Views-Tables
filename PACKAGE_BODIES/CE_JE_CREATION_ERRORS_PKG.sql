--------------------------------------------------------
--  DDL for Package Body CE_JE_CREATION_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_JE_CREATION_ERRORS_PKG" as
/* $Header: cejecerb.pls 120.0 2005/04/11 19:38:04 bhchung noship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2,
			   X_created_by		NUMBER,
			   X_creation_date 	DATE,
			   X_last_update_date	DATE,
			   X_last_updated_by	NUMBER,
			   X_last_update_login	NUMBER,
			   X_request_id		NUMBER) IS
   BEGIN
     INSERT INTO ce_je_messages(
	      application_short_name,
 	      statement_header_id,
              statement_line_id,
              message_name,
	      created_by,
	      creation_date,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      request_id)
              VALUES (
	      'CE',
 	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      X_created_by,
	      X_creation_date,
	      X_last_update_date,
	      X_last_updated_by,
	      X_last_update_login,
	      X_request_id);
  END Insert_Row;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2,
			   X_request_id			NUMBER,
		       X_application_short_name	 VARCHAR2) IS
   BEGIN
     INSERT INTO ce_je_messages(
	      application_short_name,
              statement_header_id,
              statement_line_id,
              message_name,
	      request_id,
              creation_date,
              created_by)
              VALUES (
	      X_application_short_name,
	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      X_request_id,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row(X_statement_header_id    NUMBER,
		       X_statement_line_id      NUMBER) IS
  BEGIN
    DELETE FROM ce_je_messages
    WHERE nvl(statement_line_id,999999)  = nvl(X_statement_line_id,999999)
    AND   statement_header_id = X_statement_header_id;
  END Delete_Row;

END CE_JE_CREATION_ERRORS_PKG;

/
