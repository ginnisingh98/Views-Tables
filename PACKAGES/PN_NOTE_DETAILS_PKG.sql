--------------------------------------------------------
--  DDL for Package PN_NOTE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_NOTE_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNTNOTDS.pls 120.1 2005/08/05 06:29:40 appldev ship $ */
---------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
---------------------------------------------------------------
procedure INSERT_ROW
	(
		X_ROWID 				in out NOCOPY  VARCHAR2,
		X_NOTE_DETAIL_ID 		in out NOCOPY	NUMBER,
		X_NOTE_HEADER_ID 		in		NUMBER,
		X_TEXT 					in 		VARCHAR2,
		X_CREATION_DATE 		in 		DATE,
		X_CREATED_BY 			in 		NUMBER,
		X_LAST_UPDATE_DATE 		in 		DATE,
		X_LAST_UPDATED_BY 		in 		NUMBER,
		X_LAST_UPDATE_LOGIN 	in 		NUMBER
	);

---------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
---------------------------------------------------------------
procedure LOCK_ROW
	(
		X_NOTE_DETAIL_ID 		in 		NUMBER,
		X_NOTE_HEADER_ID 		in 		NUMBER,
		X_TEXT 					in 		VARCHAR2
	);

---------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
---------------------------------------------------------------
procedure UPDATE_ROW
	(
		X_NOTE_DETAIL_ID 		in 		NUMBER,
		X_TEXT 					in 		VARCHAR2,
		X_LAST_UPDATE_DATE 		in 		DATE,
		X_LAST_UPDATED_BY 		in 		NUMBER,
		X_LAST_UPDATE_LOGIN 	in 		NUMBER
	);

---------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
---------------------------------------------------------------
procedure DELETE_ROW
	(
		X_NOTE_DETAIL_ID 		in 		NUMBER
	);

---------------------------------------------------------------
-- PROCEDURE : ADD_LANGUAGE
---------------------------------------------------------------
procedure ADD_LANGUAGE;

END PN_NOTE_DETAILS_PKG;

 

/
