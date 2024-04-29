--------------------------------------------------------
--  DDL for Package ONT_FREIGHT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_FREIGHT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUFDBS.pls 120.0 2005/06/01 22:46:40 appldev noship $ */

Procedure Freight_Debug(p_header_name  In Varchar2 default null,
                        p_list_line_id In Number   default null,
                        p_line_id      In Number);

END ONT_FREIGHT_UTIL;

 

/
