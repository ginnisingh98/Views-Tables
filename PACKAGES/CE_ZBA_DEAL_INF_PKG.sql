--------------------------------------------------------
--  DDL for Package CE_ZBA_DEAL_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_ZBA_DEAL_INF_PKG" AUTHID CURRENT_USER as
/* $Header: cezdinfs.pls 120.1 2005/07/25 23:04:27 sspoonen noship $ */

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row(X_statement_header_id     NUMBER,
		       X_statement_line_id	 NUMBER,
		       X_deal_type               VARCHAR2,
                       X_deal_num                NUMBER,
	               X_transaction_num         NUMBER,
		       X_cashpool_id		 NUMBER,
		       X_cashflows_created_flag	 VARCHAR2,
	               X_offset_deal_num         NUMBER,
	               X_offset_transaction_num  NUMBER);

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id            	NUMBER,
                       X_message_name			VARCHAR2);

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id		NUMBER,
                       X_message_name			VARCHAR2,
                       X_application_short_name		VARCHAR2);

  PROCEDURE Delete_Row( X_statement_header_id 		NUMBER,
			X_statement_line_id   		NUMBER);

END CE_ZBA_DEAL_INF_PKG;

 

/
