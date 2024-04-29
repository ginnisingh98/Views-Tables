--------------------------------------------------------
--  DDL for Package ICX_JAVASCRIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_JAVASCRIPT" AUTHID CURRENT_USER as
/* $Header: ICXJSS.pls 120.1 2005/10/07 13:29:16 gjimenez noship $ */

--
  procedure open_script( version varchar2 default '1.1' );
  procedure close_script;
--
  procedure open_noscript;
  procedure close_noscript;
--
  procedure move_list_element;
  procedure copy_to_list;
  procedure copy_all;
  procedure delete_list_element;
  procedure select_all;
  procedure unselect_all;
  procedure clear_list;
  procedure append_to_list;
  procedure delete_from_list;
--
  procedure swap;
  procedure move_element_up;
  procedure move_element_down;
  procedure move_element_top;
  procedure move_element_bottom;
  procedure delete_blank_row;

  /**
   This procedure renders the JavaScript source code function
   that calls the main help and displays it in a new "pop-up"
   browser window.
   */
  procedure show_main_help;

  /**
   This procedure renders the JavaScript source code function
   that calls the context sensitive help and displays it in a
   new "pop-up" browser window.
   */
  procedure show_context_sens_help;

end icx_javascript;

 

/
