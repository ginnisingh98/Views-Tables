--------------------------------------------------------
--  DDL for Package POR_REDIRECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_REDIRECT" AUTHID CURRENT_USER AS
/* $Header: PORRDIRS.pls 115.6 2003/10/18 00:31:50 bluk ship $*/

PROCEDURE REQSERVER(x_source varchar2 default null,
                    x_menuFunction varchar2 default null,
                    x_responsibilityID varchar2 default null,
                    x_object varchar2 default null,
                    x_doc_id number default null,
                    x_org_id number default null,
                    x_requester_id number default null,
                    x_exp_receipt_date varchar2 default null,
                    x_param varchar2 default null);

PROCEDURE process_navigator_redirect;

END POR_REDIRECT;

 

/
