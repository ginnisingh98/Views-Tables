--------------------------------------------------------
--  DDL for Package BOMPCFGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCFGI" AUTHID CURRENT_USER as
/* $Header: BOMCFGIS.pls 115.2 2002/07/01 18:16:36 ssawant ship $ */
function user_item_number (
	model_line_id           in     number
        )
return varchar2;

PRAGMA RESTRICT_REFERENCES(user_item_number, WNDS);
end BOMPCFGI;


 

/
