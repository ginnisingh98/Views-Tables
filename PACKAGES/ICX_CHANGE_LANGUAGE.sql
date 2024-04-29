--------------------------------------------------------
--  DDL for Package ICX_CHANGE_LANGUAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CHANGE_LANGUAGE" AUTHID CURRENT_USER as
/* $Header: ICXCLANS.pls 120.0 2005/10/07 12:13:16 gjimenez noship $ */

  procedure show_languages;
  procedure show_languages_local(p_message_flag in varchar2 default 'Y');

  procedure set_new_language(v_language IN varchar2);

end ICX_CHANGE_LANGUAGE;

 

/
