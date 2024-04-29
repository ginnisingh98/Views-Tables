--------------------------------------------------------
--  DDL for Package PER_JP_SCHOOL_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_SCHOOL_LOOKUPS_PKG" AUTHID CURRENT_USER as
/* $Header: pejpschl.pkh 115.2 99/07/18 13:59:40 porting ship $ */
	PROCEDURE insert_row(
			p_rowid			OUT VARCHAR2,
			p_school_id		IN VARCHAR2,
			p_school_name		IN VARCHAR2,
			p_school_name_kana	IN VARCHAR2,
			p_major			IN VARCHAR2,
			p_major_kana		IN VARCHAR2,
			p_created_by		IN NUMBER,
			p_creation_date		IN DATE,
			p_last_updated_by	IN NUMBER,
			p_last_update_date	IN DATE,
			p_last_update_login	IN NUMBER);
--
	PROCEDURE lock_row(
			p_rowid			IN VARCHAR2,
			p_school_id		IN VARCHAR2,
			p_school_name		IN VARCHAR2,
			p_school_name_kana	IN VARCHAR2,
			p_major			IN VARCHAR2,
			p_major_kana		IN VARCHAR2);
--
	PROCEDURE update_row(
			p_rowid			IN VARCHAR2,
			p_school_id		IN VARCHAR2,
			p_school_name		IN VARCHAR2,
			p_school_name_kana	IN VARCHAR2,
			p_major			IN VARCHAR2,
			p_major_kana		IN VARCHAR2,
			p_created_by		IN NUMBER,
			p_creation_date		IN DATE,
			p_last_updated_by	IN NUMBER,
			p_last_update_date	IN DATE,
			p_last_update_login	IN NUMBER);
end;

 

/
