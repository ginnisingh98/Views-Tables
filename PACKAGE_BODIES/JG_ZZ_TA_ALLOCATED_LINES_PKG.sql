--------------------------------------------------------
--  DDL for Package Body JG_ZZ_TA_ALLOCATED_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_TA_ALLOCATED_LINES_PKG" AS
/* $Header: jgzzallb.pls 120.1 2006/02/21 15:16:24 farishol ship $ */
--
-- PUBLIC FUNCTIONS
--
PROCEDURE Insert_Row(    X_rowid                IN OUT NOCOPY VARCHAR2
                        ,X_je_batch_id                  NUMBER
                        ,X_je_header_id                 NUMBER
                        ,X_je_line_num                  NUMBER
                        ,X_creation_date                DATE
                        ,X_created_by                   NUMBER
                        ,X_last_updated_by              NUMBER
                        ,X_last_update_date             DATE
                        ,X_last_update_login            NUMBER
                        ,X_request_id                   NUMBER
                        ,X_program_application_id       NUMBER
                        ,X_program_id                   NUMBER
                        ,X_program_update_date          DATE) IS
	CURSOR C IS 	SELECT rowid
			FROM JG_ZZ_TA_ALLOCATED_LINES
			WHERE X_je_batch_id  = je_batch_id 	AND
			      X_je_header_id = je_header_id 	AND
			      X_je_line_num  = je_line_num;
	BEGIN
		INSERT INTO JG_ZZ_TA_ALLOCATED_LINES
			(je_batch_id
                        ,je_header_id
                        ,je_line_num
                        ,creation_date
                        ,created_by
                        ,last_updated_by
                        ,last_update_date
                        ,last_update_login
                        ,request_id
                        ,program_application_id
                        ,program_id
                        ,program_update_date)
                  VALUES
			(X_je_batch_id
                        ,X_je_header_id
                        ,X_je_line_num
                        ,X_creation_date
                        ,X_created_by
                        ,X_last_updated_by
                        ,X_last_update_date
                        ,X_last_update_login
                        ,X_request_id
                        ,X_program_application_id
                        ,X_program_id
                        ,X_program_update_date);
	OPEN C;
	FETCH C INTO X_rowid;
	IF (C%NOTFOUND) THEN
	  CLOSE C;
	  raise NO_DATA_FOUND;
	END IF;
	CLOSE C;
END insert_row;

PROCEDURE Delete_Row(	X_rowid VARCHAR2	) IS
	BEGIN
	  DELETE FROM JG_ZZ_TA_ALLOCATED_LINES
	WHERE ROWID = X_rowid;
	IF (SQL%NOTFOUND) THEN
	  RAISE NO_DATA_FOUND;
	END IF;
END Delete_Row;

END JG_ZZ_TA_ALLOCATED_LINES_PKG;

/
