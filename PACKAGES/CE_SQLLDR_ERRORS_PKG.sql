--------------------------------------------------------
--  DDL for Package CE_SQLLDR_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_SQLLDR_ERRORS_PKG" AUTHID CURRENT_USER AS
/* $Header: ceslerrs.pls 120.0 2002/08/24 02:37:49 appldev noship $ */

  PROCEDURE Insert_Row( X_statement_number	VARCHAR2,
			X_bank_account_num	VARCHAR2,
			X_rec_no		NUMBER,
			X_message_text		VARCHAR2,
			X_status		VARCHAR2 DEFAULT 'W');

  PROCEDURE Delete_Row;

END CE_SQLLDR_ERRORS_PKG;
 

/
