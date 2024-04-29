--------------------------------------------------------
--  DDL for Package PON_FORMS_SECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_FORMS_SECTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: PONFMSCS.pls 120.1 2006/04/13 05:42:47 sdewan noship $ */

-------------------------------------------------------------------------------
--------------------------  PACKAGE BODY --------------------------------------
-------------------------------------------------------------------------------

PROCEDURE  insert_forms_sections(p_form_id       IN      NUMBER,
				p_name 		IN	VARCHAR2,
				p_description 	IN	VARCHAR2,
                                p_tip_text      IN      VARCHAR2,
				p_source_language 	IN	VARCHAR2,
				p_result	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT	NOCOPY	VARCHAR2);



PROCEDURE  update_forms_sections(p_forms_sections_id	IN	NUMBER,
				p_name 		IN	VARCHAR2,
				p_description 	IN	VARCHAR2,
                                p_tip_text      IN      VARCHAR2,
				p_language 	IN	VARCHAR2,
				p_result 	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT 	NOCOPY	VARCHAR2);

PROCEDURE  delete_forms_sections(p_form_id       IN      NUMBER,
				p_result	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT	NOCOPY	VARCHAR2);

PROCEDURE  add_language;

END PON_FORMS_SECTIONS_PVT;

 

/
