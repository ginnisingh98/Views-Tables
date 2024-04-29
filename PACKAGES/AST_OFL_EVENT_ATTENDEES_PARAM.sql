--------------------------------------------------------
--  DDL for Package AST_OFL_EVENT_ATTENDEES_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_OFL_EVENT_ATTENDEES_PARAM" AUTHID CURRENT_USER AS
 /* $Header: astrteps.pls 115.4 2002/02/06 10:44:41 pkm ship   $ */

procedure event_attendees_paramform;
procedure header;
procedure popup_window (p_event_code in varchar2 default null,
                        p_submit in varchar2 default null,
                        p_selected_event_code in varchar2 default null);
procedure high_popup_window (p_event_code in varchar2 default null,
                        p_submit in varchar2 default null,
                        p_selected_event_code in varchar2 default null);
procedure footer;

END;

 

/
