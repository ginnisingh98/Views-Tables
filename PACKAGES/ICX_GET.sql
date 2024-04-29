--------------------------------------------------------
--  DDL for Package ICX_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_GET" AUTHID CURRENT_USER as
/* $Header: ICXGETS.pls 115.2 2001/12/05 15:54:11 pkm ship     $ */

FUNCTION get_action_history_date (x_object_id IN NUMBER,
                                  x_object_type_code IN VARCHAR2,
                                  x_subtype_code IN VARCHAR2,
                                  x_action_code IN VARCHAR2)
                                  RETURN DATE;

pragma restrict_references (get_action_history_date,WNDS,RNPS,WNPS);

FUNCTION get_avail_item_count (x_vendor_id IN NUMBER,
                               x_category_id IN NUMBER)
                               RETURN NUMBER;

pragma restrict_references (get_avail_item_count,WNDS,RNPS,WNPS);

FUNCTION get_ord_item_count (x_vendor_id IN NUMBER,
                             x_type IN VARCHAR2,
                             x_category_id IN NUMBER)
                             RETURN NUMBER;

pragma restrict_references (get_ord_item_count,WNDS,RNPS,WNPS);

FUNCTION get_gl_account (x_cc_id IN NUMBER)
                         RETURN VARCHAR2;

pragma restrict_references (get_gl_account,WNDS,RNPS,WNPS);

FUNCTION get_gl_value (appl_id in number,
                       id_flex_code in varchar2,
                       id_flex_num in number,
                       cc_id in number,
                       gl_qualifier in varchar2)
                       return varchar2;

pragma restrict_references (get_gl_value,WNDS,WNPS);

FUNCTION  get_person_name (x_person_id IN  NUMBER) RETURN VARCHAR2;

pragma restrict_references (get_person_name,WNDS,WNPS);
end;

 

/
