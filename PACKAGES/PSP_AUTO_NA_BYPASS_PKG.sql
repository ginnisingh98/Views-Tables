--------------------------------------------------------
--  DDL for Package PSP_AUTO_NA_BYPASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_AUTO_NA_BYPASS_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPAUTNS.pls 115.4 2002/11/19 11:11:17 ddubey psp2376993.sql $ */
	PROCEDURE insert_row
		(p_rowid		IN OUT NOCOPY VARCHAR2,
		p_natural_account	IN VARCHAR2,
		p_segment_num		IN NUMBER,
		p_business_group_id	IN NUMBER,
		p_set_of_books_id	IN NUMBER,
		p_mode			IN VARCHAR2 DEFAULT 'R');

	PROCEDURE lock_row
		(p_rowid		IN OUT NOCOPY VARCHAR2,
		p_natural_account	IN VARCHAR2);

	PROCEDURE update_row
		(p_rowid		IN OUT NOCOPY VARCHAR2,
		p_natural_account	IN VARCHAR2,
		p_segment_num		IN NUMBER,
		p_mode			IN VARCHAR2 DEFAULT 'R');
	PROCEDURE delete_row
		(p_rowid	IN OUT NOCOPY VARCHAR2 );

END psp_auto_na_bypass_pkg;

 

/
