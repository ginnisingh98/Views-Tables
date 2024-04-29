--------------------------------------------------------
--  DDL for Package Body PN_NOTE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_NOTE_DETAILS_PKG" As
/* $Header: PNTNOTDB.pls 120.1 2005/08/05 06:28:07 appldev ship $ */
-------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
-------------------------------------------------------------------
PROCEDURE INSERT_ROW
	(
		 X_ROWID 				in out NOCOPY 	VARCHAR2
		,X_NOTE_DETAIL_ID 		in out NOCOPY 	NUMBER
		,X_NOTE_HEADER_ID 		in 		NUMBER
		,X_TEXT 				in 		VARCHAR2
		,X_CREATION_DATE 		in 		DATE
		,X_CREATED_BY 			in 		NUMBER
		,X_LAST_UPDATE_DATE 	in 		DATE
		,X_LAST_UPDATED_BY 		in 		NUMBER
		,X_LAST_UPDATE_LOGIN 	in 		NUMBER
	)
IS
	cursor C is
		select 	ROWID
		from 	PN_NOTE_DETAILS
		where 	NOTE_DETAIL_ID = X_NOTE_DETAIL_ID
			and LANGUAGE = userenv('LANG');
BEGIN
	IF (X_NOTE_DETAIL_ID IS NULL) THEN
		select	PN_NOTE_DETAILS_S.nextval
		into	X_NOTE_DETAIL_ID
		from	dual;
	END IF;

	insert into PN_NOTE_DETAILS
		(
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			CREATED_BY,
			CREATION_DATE,
			TEXT,
			NOTE_DETAIL_ID,
			NOTE_HEADER_ID,
			LANGUAGE,
			SOURCE_LANG
		)
		select
				X_LAST_UPDATED_BY,
				X_LAST_UPDATE_DATE,
				X_LAST_UPDATE_LOGIN,
				X_CREATED_BY,
				X_CREATION_DATE,
				X_TEXT,
				X_NOTE_DETAIL_ID,
				X_NOTE_HEADER_ID,
				L.LANGUAGE_CODE,
				userenv('LANG')
		from 	FND_LANGUAGES L
		where 	L.INSTALLED_FLAG in ('I', 'B')
			and not exists
					(
						select 	NULL
						from 	PN_NOTE_DETAILS T
						where 	T.NOTE_DETAIL_ID = X_NOTE_DETAIL_ID
							and T.LANGUAGE = L.LANGUAGE_CODE
					);

	open c;
	fetch c into X_ROWID;
	if (c%notfound) then
		close c;
		raise no_data_found;
	end if;
	close c;

END INSERT_ROW;

-------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
-------------------------------------------------------------------
PROCEDURE LOCK_ROW
	(
		 X_NOTE_DETAIL_ID 		in NUMBER
		,X_NOTE_HEADER_ID 		in NUMBER
		,X_TEXT					in VARCHAR2
	)
IS

	CURSOR C1 IS
		select  *
		from 	PN_NOTE_DETAILS
		where 	NOTE_DETAIL_ID = X_NOTE_DETAIL_ID
			and LANGUAGE = userenv('LANG')
		for update of NOTE_DETAIL_ID nowait;

	tlinfo c1%rowtype;

BEGIN
	open c1;
	fetch c1 into tlinfo;
	if (c1%notfound) then
		close c1;
		return;
	end if;
	close c1;

	if (    (tlinfo.TEXT = X_TEXT)
		AND (tlinfo.NOTE_HEADER_ID = X_NOTE_HEADER_ID)
		) then
		null;
	else
		fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
	end if;

	return;
END LOCK_ROW;

-------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
-------------------------------------------------------------------
PROCEDURE UPDATE_ROW
	(
		 X_NOTE_DETAIL_ID 		in NUMBER
		,X_TEXT 				in VARCHAR2
		,X_LAST_UPDATE_DATE 	in DATE
		,X_LAST_UPDATED_BY 		in NUMBER
		,X_LAST_UPDATE_LOGIN 	in NUMBER
	)
IS
BEGIN
	update PN_NOTE_DETAILS
		set 	 TEXT 				= X_TEXT
				,LAST_UPDATE_DATE 	= X_LAST_UPDATE_DATE
				,LAST_UPDATED_BY 	= X_LAST_UPDATED_BY
				,LAST_UPDATE_LOGIN 	= X_LAST_UPDATE_LOGIN
				,SOURCE_LANG 		= userenv('LANG')
		where 	NOTE_DETAIL_ID 		= X_NOTE_DETAIL_ID
			and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

	if (sql%notfound) then
		raise no_data_found;
	end if;
END UPDATE_ROW;

-------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
-------------------------------------------------------------------
PROCEDURE DELETE_ROW
	(
		X_NOTE_DETAIL_ID in NUMBER
	)
IS
BEGIN
	delete from PN_NOTE_DETAILS
		where NOTE_DETAIL_ID = X_NOTE_DETAIL_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;

END DELETE_ROW;

-------------------------------------------------------------------
-- PROCEDURE : ADD_LANGUAGE
-------------------------------------------------------------------
PROCEDURE ADD_LANGUAGE
IS
BEGIN
	update PN_NOTE_DETAILS T
		set ( TEXT) = (
			select 	B.TEXT
			from 	PN_NOTE_DETAILS B
			where 	B.NOTE_DETAIL_ID 	= T.NOTE_DETAIL_ID
				and B.LANGUAGE = T.SOURCE_LANG
						)
		where 	( 	T.NOTE_DETAIL_ID,
					T.LANGUAGE
				) IN
				(
					select 	SUBT.NOTE_DETAIL_ID,
							SUBT.LANGUAGE
					from 	PN_NOTE_DETAILS SUBB,
							PN_NOTE_DETAILS SUBT
					where 	SUBB.NOTE_DETAIL_ID = SUBT.NOTE_DETAIL_ID
						and SUBB.LANGUAGE = SUBT.SOURCE_LANG
						and (SUBB.TEXT <> SUBT.TEXT)
				);

	insert into PN_NOTE_DETAILS
		(
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			CREATED_BY,
			CREATION_DATE,
			TEXT,
			NOTE_DETAIL_ID,
			NOTE_HEADER_ID,
			LANGUAGE,
			SOURCE_LANG
		)
		select 	B.LAST_UPDATED_BY,
				B.LAST_UPDATE_DATE,
				B.LAST_UPDATE_LOGIN,
				B.CREATED_BY,
				B.CREATION_DATE,
				B.TEXT,
				B.NOTE_DETAIL_ID,
				B.NOTE_HEADER_ID,
				L.LANGUAGE_CODE,
				B.SOURCE_LANG
		from 	PN_NOTE_DETAILS B,
				FND_LANGUAGES L
		where 	L.INSTALLED_FLAG in ('I', 'B')
			and B.LANGUAGE = userenv('LANG')
			and not exists
				(
					select 	NULL
					from 	PN_NOTE_DETAILS T
					where 	T.NOTE_DETAIL_ID = B.NOTE_DETAIL_ID
						and T.LANGUAGE 		 = L.LANGUAGE_CODE
				);
END ADD_LANGUAGE;

END PN_NOTE_DETAILS_PKG;

/
