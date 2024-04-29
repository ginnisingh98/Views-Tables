--------------------------------------------------------
--  DDL for Package QP_PARAM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PARAM_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPRMS.pls 120.2 2005/10/03 02:25:28 prarasto noship $ */

PROCEDURE get_valueset_select(p_valueset_id IN VARCHAR2,
                             x_select_stmt OUT NOCOPY VARCHAR2);

PROCEDURE Populate_Parameter_Values( p_parameter_id  IN NUMBER,
                                     p_seeded_value  IN VARCHAR2,
				     p_parameter_level IN VARCHAR2);

PROCEDURE Insert_Parameter_Values( p_level IN VARCHAR2,
				   p_level_name IN VARCHAR2);

PROCEDURE Delete_Parameter_Values( p_level IN VARCHAR2,
				   p_level_name IN VARCHAR2);

FUNCTION Get_Parameter_Value( p_level in varchar2,
                              p_level_name in varchar2 ,
                              p_parameter_code in varchar2)  RETURN VARCHAR2;

FUNCTION Is_Seed_User RETURN VARCHAR2;

END QP_Param_Util;

 

/
