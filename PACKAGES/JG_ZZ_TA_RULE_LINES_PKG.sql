--------------------------------------------------------
--  DDL for Package JG_ZZ_TA_RULE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_TA_RULE_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztais.pls 120.1 2006/02/21 15:23:58 farishol ship $ */

PROCEDURE Insert_Row( 	 X_rowid		IN OUT NOCOPY VARCHAR2
			,X_rule_line_id		IN OUT NOCOPY NUMBER
			,X_account_range_id	      	NUMBER
			,X_natural_account		VARCHAR2
			,X_allocation_percent		NUMBER
			,X_offset_account		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );


PROCEDURE Update_Row( 	 X_rowid		      	VARCHAR2
			,X_rule_line_id		      	NUMBER
			,X_account_range_id	      	NUMBER
			,X_natural_account		VARCHAR2
			,X_allocation_percent		NUMBER
			,X_offset_account		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );

PROCEDURE Delete_Row( X_Rowid		VARCHAR2 );

PROCEDURE Lock_Row( 	 X_rowid		      	VARCHAR2
			,X_rule_line_id		       	NUMBER
			,X_account_range_id	      	NUMBER
			,X_natural_account		VARCHAR2
			,X_allocation_percent		NUMBER
			,X_offset_account		VARCHAR2
			,X_creation_date		DATE
			,X_created_by			NUMBER
			,X_last_updated_by		NUMBER
			,X_last_update_date		DATE
			,X_last_update_login		NUMBER
			,X_Context			VARCHAR2
			,X_attribute1			VARCHAR2
			,X_attribute2			VARCHAR2
			,X_attribute3			VARCHAR2
			,X_attribute4			VARCHAR2
			,X_attribute5			VARCHAR2
			,X_attribute6			VARCHAR2
			,X_attribute7			VARCHAR2
			,X_attribute8			VARCHAR2
			,X_attribute9			VARCHAR2
			,X_attribute10			VARCHAR2
			,X_attribute11			VARCHAR2
			,X_attribute12			VARCHAR2
			,X_attribute13			VARCHAR2
			,X_attribute14			VARCHAR2
			,X_attribute15			VARCHAR2 );

END JG_ZZ_TA_RULE_LINES_PKG;

 

/
