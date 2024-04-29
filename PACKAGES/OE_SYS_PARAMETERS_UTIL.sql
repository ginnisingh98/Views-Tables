--------------------------------------------------------
--  DDL for Package OE_SYS_PARAMETERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SYS_PARAMETERS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUSPMS.pls 120.1 2006/03/29 16:48:30 spooruli noship $ */

FUNCTION Get_Value(p_value_set_id IN NUMBER,
                   p_value_code   IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE Get_Value_from_Table(p_table_r  IN fnd_vset.table_r,
                               p_code     IN VARCHAR2,
			       x_value    OUT NOCOPY VARCHAR2);

FUNCTION Get_num_date_from_canonical(p_format_type  IN  VARCHAR2,
                                     p_value_code   IN  VARCHAR2)
RETURN VARCHAR2;

END Oe_Sys_Parameters_Util;

/
