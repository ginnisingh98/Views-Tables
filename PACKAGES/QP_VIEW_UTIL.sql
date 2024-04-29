--------------------------------------------------------
--  DDL for Package QP_VIEW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_VIEW_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXVVUTS.pls 120.1 2005/06/16 02:08:57 appldev  $ */

 FUNCTION Get_Entity_Id( p_list_line_id IN NUMBER
				   ) RETURN VARCHAR2;

 FUNCTION Get_Entity_Value( p_list_line_id IN NUMBER
				      ) RETURN VARCHAR2;

 FUNCTION Are_There_Breaks( p_list_line_id IN NUMBER
				      ) RETURN VARCHAR2;

FUNCTION Get_Price_List_Attribute RETURN VARCHAR2;
FUNCTION Get_Price_List_Context RETURN VARCHAR2;

FUNCTION Get_Parent_Discount_Line_Id( p_list_line_id IN NUMBER
				                ) RETURN NUMBER;

FUNCTION Get_Attribute_Code(p_context IN VARCHAR2,
					   p_attribute_name IN VARCHAR2
				        ) RETURN VARCHAR2;

  PROCEDURE Get_Context_Attributes( p_entity_id              NUMBER,
							 x_context           OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
							 x_attribute         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
							 x_product_flag      OUT NOCOPY /* file.sql.39 change */  BOOLEAN,
							 x_qualifier_flag    OUT NOCOPY /* file.sql.39 change */  BOOLEAN);

 END QP_VIEW_UTIL;

 

/
