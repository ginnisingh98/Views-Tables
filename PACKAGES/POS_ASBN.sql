--------------------------------------------------------
--  DDL for Package POS_ASBN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASBN" AUTHID CURRENT_USER AS
/* $Header: POSASBNS.pls 115.0 99/08/20 11:07:08 porting sh $ */

  g_language    VARCHAR2(5);
  g_script_name VARCHAR2(240);
  g_org_id      NUMBER;
  g_user_id     NUMBER;
  g_session_id  NUMBER;
  g_responsibility_id NUMBER;
  g_flag        VARCHAR2(1);

  TYPE t_text_table is table of varchar2(240) index by binary_integer;
  g_dummy t_text_table;

  FUNCTION set_session_info RETURN BOOLEAN;
  FUNCTION get_result_value(p_index in number, p_col in number) return varchar2;

  FUNCTION item_halign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_valign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_name(l_index in number) RETURN VARCHAR2;
  FUNCTION item_code(l_index in number) RETURN VARCHAR2;
  FUNCTION item_style(l_index in number) RETURN VARCHAR2;
  FUNCTION item_displayed(l_index in number) RETURN BOOLEAN;
  FUNCTION item_updateable(l_index in number) RETURN BOOLEAN;
  FUNCTION item_lov(l_index in number) RETURN VARCHAR2;
  FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2;
  FUNCTION item_size (l_index in number) RETURN VARCHAR2;

  PROCEDURE Build_Buttons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2);

  PROCEDURE ASBN_Details;
  PROCEDURE edit_header;
  PROCEDURE paint_edit_header;
  PROCEDURE UPDATE_HEADER (pos_invoice_number         IN VARCHAR2 DEFAULT null,
                           pos_invoice_date           IN VARCHAR2 DEFAULT null,
                           pos_freight_amount         IN VARCHAR2 DEFAULT null
                         );

END POS_ASBN;

 

/
