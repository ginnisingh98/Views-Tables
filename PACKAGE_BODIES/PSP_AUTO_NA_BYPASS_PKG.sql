--------------------------------------------------------
--  DDL for Package Body PSP_AUTO_NA_BYPASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_AUTO_NA_BYPASS_PKG" AS
/* $Header: PSPAUTNB.pls 115.5 2002/11/19 11:05:37 ddubey ship $ */
PROCEDURE insert_row
	(p_rowid		IN OUT NOCOPY	VARCHAR2,
	p_natural_account	IN	VARCHAR2,
	p_segment_num		IN	NUMBER,
	p_business_group_id	IN	NUMBER,
	p_set_of_books_id	IN	NUMBER,
	p_mode			IN	VARCHAR2	DEFAULT 'R') IS
CURSOR	row_id_cur IS
SELECT	rowid
FROM	psp_auto_na_bypass
WHERE	natural_account = p_natural_account
AND	segment_num = p_segment_num;

l_last_update_date	DATE;
l_last_updated_by	NUMBER;
l_last_update_login	NUMBER;

BEGIN
	l_last_update_date := SYSDATE;
	IF (p_mode = 'I') THEN
		l_last_updated_by := 1;
		l_last_update_login := 0;
	ELSIF (p_mode = 'R') THEN
		l_last_updated_by := fnd_global.user_id;
		IF l_last_updated_by IS NULL THEN
			l_last_updated_by := -1;
		END IF;
		l_last_update_login :=fnd_global.login_id;
		IF l_last_update_login IS null THEN
			l_last_update_login := -1;
		END IF;
	ELSE
		fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
		app_exception.raise_exception;
	END IF;
	INSERT INTO psp_auto_na_bypass
		(natural_account,	segment_num,		business_group_id,	set_of_books_id,
		creation_date,		created_by,		last_update_date,	last_updated_by,
		last_update_login)
	VALUES	(p_natural_account,	p_segment_num,		p_business_group_id,	p_set_of_books_id,
		l_last_update_date,	l_last_updated_by,	l_last_update_date,	l_last_updated_by,
		l_last_update_login);

	OPEN row_id_cur;
	FETCH row_id_cur INTO p_rowid;
	IF (row_id_cur%NOTFOUND) THEN
		CLOSE row_id_cur;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE row_id_cur;

END insert_row;

PROCEDURE lock_row
	(p_rowid		IN OUT NOCOPY	VARCHAR2,
	p_natural_account	IN	VARCHAR2) IS
CURSOR	natural_account_lock_cur IS
SELECT	*
FROM	psp_auto_na_bypass
WHERE	rowid = p_rowid
FOR UPDATE OF natural_account NOWAIT;

-- Becuase the primary key may be updated, so we lock the row
-- based on rowid instead of these 2 primary keys.
--		where NATURAL_ACCOUNT = P_NATURAL_ACCOUNT
--		and SEGMENT_NUM = P_SEGMENT_NUM

l_natural_account_lock_info natural_account_lock_cur%ROWTYPE;

BEGIN
	OPEN natural_account_lock_cur;
	FETCH natural_account_lock_cur INTO l_natural_account_lock_info;
	IF (natural_account_lock_cur%NOTFOUND) THEn
		fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
		CLOSE natural_account_lock_cur;
		RETURN;
	END IF;
	CLOSE natural_account_lock_cur;

	IF (l_natural_account_lock_info.natural_account = p_natural_account) THEN
		RETURN;
	ELSE
		fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
	END IF;
	RETURN;
END lock_row;

PROCEDURE update_row
	(p_rowid		IN OUT NOCOPY	VARCHAR2,
	p_natural_account	IN	VARCHAR2,
	p_segment_num		IN	NUMBER,
	p_mode			IN	VARCHAR2	DEFAULT 'R') IS
l_last_update_date	DATE;
l_last_updated_by	NUMBER;
l_last_update_login	NUMBER;

BEGIN
	l_last_update_date := SYSDATE;
	IF (p_mode = 'I') THEN
		l_last_updated_by := 1;
		l_last_update_login := 0;
	ELSIF (p_mode = 'R') THEN
		l_last_updated_by := fnd_global.user_id;
		IF (l_last_updated_by IS NULL) THEN
			l_last_updated_by := -1;
		END IF;
		l_last_update_login :=fnd_global.login_id;
		IF (l_last_update_login IS NULL) THEN
			l_last_update_login := -1;
		END IF;
	ELSE
		fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
		app_exception.raise_exception;
	END IF;

	UPDATE	psp_auto_na_bypass
	SET	natural_account = p_natural_account,
		segment_num = p_segment_num,
		last_update_date = l_last_update_date,
		last_updated_by = l_last_updated_by,
		last_update_login = l_last_update_login
	WHERE	rowid = p_rowid;
-- Becuase the primary key may be updated, so we update the row
-- based on rowid instead of these 2 primary keys.
--	where NATURAL_ACCOUNT = P_NATURAL_ACCOUNT
--	and SEGMENT_NUM = P_SEGMENT_NUM

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END update_row;


PROCEDURE delete_row
	(p_rowid	IN OUT NOCOPY	VARCHAR2) IS
BEGIN
	DELETE FROM psp_auto_na_bypass
	WHERE	rowid = p_rowid;

-- Becuase the primary key may be updated, so we lock the row
-- based on rowid instead of these 2 primary keys.
--	where NATURAL_ACCOUNT = P_NATURAL_ACCOUNT
--	and SEGMENT_NUM = P_SEGMENT_NUM;

	IF (SQL%NOTFOUND) THEN
		RAISE NO_DATA_FOUND;
	END IF;
END delete_row;

END psp_auto_na_bypass_pkg;

/
