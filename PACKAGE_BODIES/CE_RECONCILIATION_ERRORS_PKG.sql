--------------------------------------------------------
--  DDL for Package Body CE_RECONCILIATION_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_RECONCILIATION_ERRORS_PKG" as
/* $Header: cerecerb.pls 120.0.12010000.2 2009/11/10 03:13:21 csutaria ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.0.12010000.2 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2) IS
   BEGIN
     INSERT INTO CE_RECONCILIATION_ERRORS(
	      application_short_name,
 	      statement_header_id,
              statement_line_id,
              message_name,
              creation_date,
              created_by)
              VALUES (
	      'CE',
 	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2,
		       X_application_short_name	 VARCHAR2) IS
   BEGIN
     INSERT INTO CE_RECONCILIATION_ERRORS(
	      application_short_name,
              statement_header_id,
              statement_line_id,
              message_name,
              creation_date,
              created_by)
              VALUES (
	      X_application_short_name,
	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1));
  END Insert_Row;

  PROCEDURE Delete_Row(X_statement_header_id    NUMBER,
		       X_statement_line_id      NUMBER) IS
  BEGIN
    If x_statement_line_id is null Then -- Bug 9098954

    DELETE FROM CE_RECONCILIATION_ERRORS
    WHERE  statement_header_id = X_statement_header_id;
  Else
    DELETE FROM CE_RECONCILIATION_ERRORS
    WHERE  statement_header_id = X_statement_header_id
    And    statement_line_id = X_statement_line_id ;
  End If ;
  END Delete_Row;

END CE_RECONCILIATION_ERRORS_PKG;

/
