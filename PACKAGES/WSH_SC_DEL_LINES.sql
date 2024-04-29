--------------------------------------------------------
--  DDL for Package WSH_SC_DEL_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_DEL_LINES" AUTHID CURRENT_USER as
/* $Header: WSHSCDLS.pls 115.0 99/07/16 08:20:32 porting ship $ */

Procedure update_shp_qty(del_id number, action_code varchar2);

Procedure update_unrel_lines(del_id number);

END WSH_SC_DEL_LINES;

 

/
