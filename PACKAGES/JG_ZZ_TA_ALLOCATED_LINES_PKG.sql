--------------------------------------------------------
--  DDL for Package JG_ZZ_TA_ALLOCATED_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_TA_ALLOCATED_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzalls.pls 120.1 2006/02/21 15:22:16 farishol ship $ */
PROCEDURE Insert_Row(X_rowid		IN OUT NOCOPY VARCHAR2
		,X_je_batch_id			NUMBER
		,X_je_header_id			NUMBER
		,X_je_line_num			NUMBER
		,X_creation_date		DATE
		,X_created_by			NUMBER
		,X_last_updated_by		NUMBER
		,X_last_update_date		DATE
		,X_last_update_login		NUMBER
		,X_request_id			NUMBER
		,X_program_application_id	NUMBER
		,X_program_id			NUMBER
		,X_program_update_date		DATE);
PROCEDURE Delete_Row( X_Rowid		VARCHAR2 );
END JG_ZZ_TA_ALLOCATED_LINES_PKG;

 

/
