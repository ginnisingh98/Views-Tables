--------------------------------------------------------
--  DDL for Package CN_TBLSPC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TBLSPC_PKG" AUTHID CURRENT_USER as
/* $Header: cntbspcs.pls 115.4 2003/01/30 03:28:09 achung noship $ */

--| ----------------------------------------------------------------------+
--|   Function Name :  get_tablespace
--| ----------------------------------------------------------------------+
FUNCTION get_tablespace RETURN varchar2;

--| ----------------------------------------------------------------------+
--|   Function Name :  get_index_tablespace
--| ----------------------------------------------------------------------+
FUNCTION get_index_tablespace RETURN varchar2;

END cn_tblspc_pkg;

 

/
