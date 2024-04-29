--------------------------------------------------------
--  DDL for Package POS_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_GET" AUTHID CURRENT_USER AS
/* $Header: POSGETUS.pls 120.0.12010000.2 2014/05/15 11:12:40 puppulur ship $ */

    FUNCTION  get_person_name (x_person_id IN  NUMBER) RETURN VARCHAR2;

    FUNCTION  get_person_name_cache(x_person_id IN  NUMBER) RETURN VARCHAR2;

    FUNCTION  item_flex_seg (
	              ri   in 	rowid)
             return varchar2;

    FUNCTION get_gl_account (x_cc_id IN NUMBER)
				 RETURN VARCHAR2;

    FUNCTION get_gl_value (appl_id in number,
			     id_flex_code in varchar2,
			     id_flex_num in number,
			     cc_id in number,
			     gl_qualifier in varchar2)
		           return varchar2 ;

    FUNCTION  get_item_config(x_item_id IN  NUMBER,
                              x_org_id IN NUMBER)
                             RETURN VARCHAR2;

    FUNCTION  get_item_number (x_item_id IN  NUMBER,
			       x_org_id IN NUMBER) RETURN VARCHAR2;

    FUNCTION pos_getstatus(p_closed_code VARCHAR2) RETURN VARCHAR2;

END POS_GET;

/
