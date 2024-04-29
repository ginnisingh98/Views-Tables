--------------------------------------------------------
--  DDL for Package BOMPLDCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPLDCI" AUTHID CURRENT_USER as
/* $Header: BOMLDCIS.pls 115.1 99/09/16 16:00:45 porting ship $ */

function get_validation_org ( opunit in number,
                              site_level_org_id in number)
return integer;

PRAGMA restrict_references( get_validation_org, WNDS);
function bmldite_load_item
(       org_id         in      number,
	ci_delimiter   in out  VARCHAR2,
        l_item_type        in   VARCHAR2,
        error_message  out     VARCHAR2,
        message_name   out     VARCHAR2,
        table_name     out     VARCHAR2)
return integer;
end BOMPLDCI;

 

/
