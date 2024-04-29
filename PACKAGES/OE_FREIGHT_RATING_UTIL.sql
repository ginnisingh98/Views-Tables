--------------------------------------------------------
--  DDL for Package OE_FREIGHT_RATING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FREIGHT_RATING_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUFRRS.pls 120.0.12010000.2 2008/08/04 15:03:00 amallik ship $ */

G_FTE_INSTALLED   VARCHAR2(1) := NULL;

Type List_Line_Type_Code_Rec_Type is Record
(
      list_line_type_code                   Varchar2(30)
);

TYPE List_Line_Type_Code_Tbl_Type IS TABLE OF List_Line_Type_Code_Rec_Type
    INDEX BY BINARY_INTEGER;

g_list_line_type_code_rec       List_Line_Type_Code_Rec_Type;
g_list_line_type_code_tbl       List_Line_Type_Code_Tbl_Type;

FUNCTION IS_FREIGHT_RATING_AVAILABLE RETURN BOOLEAN;

FUNCTION Get_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2;

FUNCTION Get_List_Line_Type_Code
(   p_key	IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Estimated_Cost_Amount
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2;

PROCEDURE Create_Dummy_Adjustment(p_header_id in number);

-- Added as part of Bug 6955343
FUNCTION Get_Estimated_Cost_Amount_Ns
 (   p_cost_type_code                IN  VARCHAR2
 )RETURN VARCHAR2;

END OE_FREIGHT_RATING_UTIL;

/
