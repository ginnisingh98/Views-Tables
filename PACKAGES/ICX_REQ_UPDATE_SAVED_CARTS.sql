--------------------------------------------------------
--  DDL for Package ICX_REQ_UPDATE_SAVED_CARTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_UPDATE_SAVED_CARTS" AUTHID CURRENT_USER as
/* $Header: ICXRQUPS.pls 115.1 99/07/17 03:23:46 porting ship $ */

procedure cartSearch;
procedure displaySavedCarts(a_1 in varchar2 default null,
                            c_1 in varchar2 default null,
                            i_1 in varchar2 default null,
                            a_2 in varchar2 default null,
                            c_2 in varchar2 default null,
                            i_2 in varchar2 default null,
                            a_3 in varchar2 default null,
                            c_3 in varchar2 default null,
                            i_3 in varchar2 default null,
                            a_4 in varchar2 default null,
                            c_4 in varchar2 default null,
                            i_4 in varchar2 default null,
                            a_5 in varchar2 default null,
                            c_5 in varchar2 default null,
                            i_5 in varchar2 default null,
                            p_start_row in number default 1,
                            p_end_row in number default null,
                            p_where in varchar2 default null );
procedure deleteSavedCarts(condensed_params in number default null);

end ICX_REQ_UPDATE_SAVED_CARTS;

 

/
