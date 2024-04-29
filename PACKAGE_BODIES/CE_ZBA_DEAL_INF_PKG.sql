--------------------------------------------------------
--  DDL for Package Body CE_ZBA_DEAL_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_ZBA_DEAL_INF_PKG" as
/* $Header: cezdinfb.pls 120.1 2005/07/25 23:04:38 sspoonen noship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_deal_type               VARCHAR2,
                       X_deal_num                NUMBER,
	               X_transaction_num         NUMBER,
		       X_cashpool_id		 NUMBER,
		       X_cashflows_created_flag	 VARCHAR2,
	               X_offset_deal_num         NUMBER,
	               X_offset_transaction_num  NUMBER) IS
   BEGIN
     INSERT INTO CE_ZBA_DEAL_MESSAGES(
	      application_short_name,
 	      statement_header_id,
              statement_line_id,
              creation_date,
              created_by,
              deal_type,
              deal_num,
	      transaction_num,
	      cashpool_id,
	      cashflows_created_flag,
	      offset_deal_num,
	      offset_transaction_num,
	      deal_status_flag)
              VALUES (
	      'CE',
 	      X_statement_header_id,
              X_statement_line_id,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1),
              X_deal_type,
              X_deal_num,
	      X_transaction_num,
	      X_cashpool_id,
	      X_cashflows_created_flag,
	      X_offset_deal_num,
	      X_offset_transaction_num,
	      'Y');
  END Insert_Row;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2) IS
   BEGIN
     INSERT INTO CE_ZBA_DEAL_MESSAGES(
	      application_short_name,
              statement_header_id,
              statement_line_id,
              message_name,
              creation_date,
              created_by,
              deal_status_flag)
              VALUES (
	      'CE',
	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1),
              'N');
  END Insert_Row;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_message_name	         VARCHAR2,
		       X_application_short_name	 VARCHAR2) IS
   BEGIN
     INSERT INTO CE_ZBA_DEAL_MESSAGES(
	      application_short_name,
              statement_header_id,
              statement_line_id,
              message_name,
              creation_date,
              created_by,
              deal_status_flag)
              VALUES (
	      X_application_short_name,
	      X_statement_header_id,
              X_statement_line_id,
              X_message_name,
	      sysdate,
	      NVL(FND_GLOBAL.user_id,-1),
              'N');
  END Insert_Row;

  PROCEDURE Delete_Row(X_statement_header_id    NUMBER,
		       X_statement_line_id      NUMBER) IS
  BEGIN
    IF X_statement_line_id IS NULL THEN
      DELETE FROM CE_ZBA_DEAL_MESSAGES
      WHERE statement_header_id = X_statement_header_id;
    ELSE
      DELETE FROM CE_ZBA_DEAL_MESSAGES
      WHERE statement_line_id = X_statement_line_id;
    END IF;
  END Delete_Row;

END CE_ZBA_DEAL_INF_PKG;

/
