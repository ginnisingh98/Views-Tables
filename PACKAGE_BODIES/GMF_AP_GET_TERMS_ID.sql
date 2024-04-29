--------------------------------------------------------
--  DDL for Package Body GMF_AP_GET_TERMS_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AP_GET_TERMS_ID" AS
/* $Header: gmftrmib.pls 115.0 99/07/16 04:25:16 porting shi $ */
CURSOR get_terms_id (termscode varchar2, termsid number) IS
		SELECT  	distinct name, term_id
		FROM		ap_terms
		WHERE   	name like  termscode and
				term_id = nvl( termsid, term_id);
PROCEDURE ap_get_terms_id( terms_code in out varchar2,
		terms_id in out number,
                row_to_fetch in out number,
		statuscode out number) IS
Begin
	IF NOT get_terms_id%ISOPEN then
		OPEN get_terms_id(terms_code, terms_id);
	END IF;
	FETCH get_terms_id INTO terms_code, terms_id;
	IF get_terms_id%NOTFOUND THEN
		CLOSE get_terms_id;
		statuscode := 100;
	END IF;
	IF row_to_fetch = 1 and get_terms_id%ISOPEN then
		CLOSE get_terms_id;
	END IF;
	EXCEPTION
		WHEN OTHERS THEN
			statuscode := SQLCODE;
End;
END GMF_AP_GET_TERMS_ID;

/
