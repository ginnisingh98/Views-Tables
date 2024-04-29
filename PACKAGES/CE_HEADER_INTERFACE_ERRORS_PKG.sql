--------------------------------------------------------
--  DDL for Package CE_HEADER_INTERFACE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_HEADER_INTERFACE_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: cehintes.pls 120.0 2002/08/24 02:36:39 appldev noship $ */
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;
  PROCEDURE Insert_Row(X_statement_number               VARCHAR2,
                       X_bank_account_num		VARCHAR2,
                       X_message_name			VARCHAR2);
  PROCEDURE Insert_Row(X_statement_number               VARCHAR2,
                       X_bank_account_num		VARCHAR2,
                       X_message_name			VARCHAR2,
                       X_application_short_name		VARCHAR2);

  PROCEDURE Delete_Row(X_statement_number VARCHAR2,
		       X_bank_account_num VARCHAR2);

END CE_HEADER_INTERFACE_ERRORS_PKG;

 

/
