--------------------------------------------------------
--  DDL for Package CE_FC_EXT_VIEWS_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_FC_EXT_VIEWS_TABLE_PKG" AUTHID CURRENT_USER AS
/* $Header: cefexvws.pls 120.1 2002/11/12 21:23:03 bhchung ship $ */

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION body_revision RETURN VARCHAR2;

  FUNCTION spec_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row(	X_Rowid			IN OUT NOCOPY	VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER);

  PROCEDURE Update_Row(	X_Rowid				VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER);

  PROCEDURE Delete_Row( X_rowid				VARCHAR2);

  PROCEDURE Lock_Row  (	X_Rowid				VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER);

  PROCEDURE Check_Unique(X_external_source_type		VARCHAR2,
			 X_rowid			VARCHAR2);

END CE_FC_EXT_VIEWS_TABLE_PKG;

 

/
