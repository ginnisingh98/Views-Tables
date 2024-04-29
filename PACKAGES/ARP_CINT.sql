--------------------------------------------------------
--  DDL for Package ARP_CINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CINT" AUTHID CURRENT_USER AS
/* $Header: ARPLCINS.pls 120.2 2005/10/30 04:24:23 appldev ship $ */

PROCEDURE up_cust_int      ( warning_text_in        in varchar2,
			     location_ccid_in       in number,
			     message_text_in        in varchar2,
			     interface_status_in    in varchar2,
			     rowid_in               in rowid );

PROCEDURE cint_gen_loc_ccid ( h_request_id        in number,
                              h_user_id           in number,
			      h_prog_appl_id      in number,
			      h_program_id        in number,
			      h_last_update_login in number,
			      h_application_id    in number,
			      h_language_id       in number );

END ARP_CINT;


 

/
