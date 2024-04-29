--------------------------------------------------------
--  DDL for Package Body PER_JP_SCHOOL_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_SCHOOL_LOOKUPS_PKG" as
/* $Header: pejpschl.pkb 115.6 99/07/18 13:59:12 porting ship $ */
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
			p_last_update_login	IN NUMBER)
	IS
		l_rowid	ROWID;
		CURSOR csr_school_rowid IS
			select	rowid
			from	per_jp_school_lookups
			where	school_id=p_school_id;
	BEGIN
		insert into per_jp_school_lookups(
			SCHOOL_ID,
			SCHOOL_NAME,
			SCHOOL_NAME_KANA,
			MAJOR,
			MAJOR_KANA,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN)
		values(	p_school_id,
			p_school_name,
			p_school_name_kana,
			p_major,
			p_major_kana,
			p_created_by,
			p_creation_date,
			p_last_updated_by,
			p_last_update_date,
			p_last_update_Login);

		open csr_school_rowid;
		fetch csr_school_rowid into l_rowid;
		close csr_school_rowid;

		p_rowid := rowidtochar(l_rowid);
	END;
--
	PROCEDURE lock_row(
			p_rowid			IN VARCHAR2,
			p_school_id		IN VARCHAR2,
			p_school_name		IN VARCHAR2,
			p_school_name_kana	IN VARCHAR2,
			p_major			IN VARCHAR2,
			p_major_kana		IN VARCHAR2)
	IS
		CURSOR csr_school IS
			select	*
			from	per_jp_school_lookups
			where	rowid=chartorowid(p_rowid)
			for update of school_id nowait;
		l_rec	csr_school%ROWTYPE;
	BEGIN
		open csr_school;
		fetch csr_school into l_rec;
		if csr_school%NOTFOUND then
			close csr_school;
			fnd_message.set_name('FND','FORM_RECORD_DELETED');
			fnd_message.raise_error;
		end if;
		close csr_school;

		if  (l_rec.school_id = p_school_id)
		and ((l_rec.school_name = p_school_name) or (l_rec.school_name is NULL and p_school_name is NULL))
		and ((l_rec.school_name_kana = p_school_name_kana) or (l_rec.school_name_kana is NULL and p_school_name_kana is NULL))
		and ((l_rec.major = p_major) or (l_rec.major is NULL and p_major is NULL))
		and ((l_rec.major_kana = p_major_kana) or (l_rec.major_kana is NULL and p_major_kana is NULL)) then
			NULL;
		else
			fnd_message.set_name('FND','FORM_RECORD_CHANGED');
			fnd_message.raise_error;
		end if;
	END;
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
			p_last_update_login	IN NUMBER)
	IS
	BEGIN
		update	per_jp_school_lookups
		set	school_id		= p_school_id,
			school_name		= p_school_name,
			school_name_kana	= p_school_name_kana,
			major			= p_major,
			major_kana		= p_major_kana,
			created_by		= p_created_by,
			creation_date		= p_creation_date,
			last_updated_by		= p_last_updated_by,
			last_update_date	= p_last_update_date,
			last_update_login	= p_last_update_login
		where	rowid=chartorowid(p_rowid);
	END;
end;

/
