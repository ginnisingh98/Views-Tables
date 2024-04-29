--------------------------------------------------------
--  DDL for Package Body FND_BC4J_CLEANUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_BC4J_CLEANUP_PKG" AS
/* $Header: FNDBCCLB.pls 115.5 2002/10/18 17:23:10 aviswana ship $ */

PROCEDURE Delete_Transaction_Rows(p_older_than_date IN DATE) IS
    h_counter		NUMBER := 0;
    h_commit_level	NUMBER := 200;
    CURSOR select_cursor IS
	SELECT rowid FROM fnd_ps_txn
	WHERE creation_date < p_older_than_date;
BEGIN
    FOR rec IN select_cursor LOOP
 	DELETE FROM fnd_ps_txn
	WHERE rowid = rec.rowid;

	h_counter := h_counter + 1;
	IF (h_counter = h_commit_level) THEN
	    commit work;
	    h_counter := 0;
        END IF;
    END LOOP;

    IF (h_counter > 0) THEN
	commit work;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        rollback work;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ERRNO', to_char(sqlcode));
        fnd_message.set_token('REASON', sqlerrm);
        fnd_message.set_token('ROUTINE',
		'FND_BC4J_CLEANUP.Delete_Transaction_Rows');
        app_exception.raise_exception;
END Delete_Transaction_Rows;


PROCEDURE Delete_Control_Rows(p_older_than_date IN DATE) IS
    h_counter		NUMBER := 0;
    h_commit_level	NUMBER := 200;
    CURSOR select_cursor IS
	SELECT rowid FROM fnd_pcoll_control
	WHERE updatedate < p_older_than_date;
BEGIN
    FOR rec IN select_cursor LOOP
 	DELETE FROM fnd_pcoll_control
	WHERE rowid = rec.rowid;

	h_counter := h_counter + 1;
	IF (h_counter = h_commit_level) THEN
	    commit work;
	    h_counter := 0;
        END IF;
    END LOOP;

    IF (h_counter > 0) THEN
	commit work;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        rollback work;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ERRNO', to_char(sqlcode));
        fnd_message.set_token('REASON', sqlerrm);
        fnd_message.set_token('ROUTINE',
		'FND_BC4J_CLEANUP.Delete_Control_Rows');
        app_exception.raise_exception;
END Delete_Control_Rows;


end FND_BC4J_CLEANUP_PKG;

/
