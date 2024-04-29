--------------------------------------------------------
--  DDL for Package EDW_MISC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MISC_UTIL" AUTHID CURRENT_USER AS
/* $Header: EDWMISCS.pls 115.5 2002/12/05 22:15:57 arsantha ship $*/


Procedure globalNamesOff ;

FUNCTION formatNumber(p_input in number, sep in varchar2) return varchar2;
function get_item_default(l_db_link varchar2) return varchar2;
function get_itemorg_default(l_db_link varchar2) return varchar2;

end edw_misc_util;

 

/
