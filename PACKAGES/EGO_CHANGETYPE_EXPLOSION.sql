--------------------------------------------------------
--  DDL for Package EGO_CHANGETYPE_EXPLOSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CHANGETYPE_EXPLOSION" AUTHID CURRENT_USER as

TYPE NUM_ID_ARRAY IS VARRAY(9999) OF NUMBER;
PROCEDURE explodeTemplates (
	p_change_id	 IN NUMBER,
	p_change_type_id IN NUMBER,
	p_user_id        IN NUMBER,
	p_login_id       IN NUMBER,
	p_prog_appid     IN NUMBER,
	p_prog_id        IN NUMBER,
	p_req_id         IN NUMBER,
	p_err_text	 IN OUT NOCOPY VARCHAR2
	);
END EGO_CHANGETYPE_EXPLOSION;

 

/
