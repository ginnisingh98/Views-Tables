--------------------------------------------------------
--  DDL for Package QP_MASS_MAINTAIN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MASS_MAINTAIN_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXMMUTS.pls 120.1.12010000.1 2008/07/28 11:54:43 appldev ship $ */

--GLOBAL Constant holding the package name

  G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_MASS_MAINTAIN_UTIL';

  -- This Function returns 'N' if pte_code and source_system_code of passed list_header_id matches
  -- with the corresponding profile values else returns 'Y'
  -- Its confusing but has been done intentionally

  FUNCTION Check_SS_PTE_Codes_Match (p_list_header_id   IN NUMBER ) RETURN VARCHAR2;

  -- This function return the product description
  FUNCTION get_product_desc(p_product_attr_context  varchar2,
                            p_product_attr  varchar2,
                            p_product_attr_val varchar2) RETURN VARCHAR2;

  Function Get_Product_UOM_Code ( p_list_line_id IN NUMBER,
                                p_product_attr_context  IN VARCHAR2,
                                p_product_attr  IN VARCHAR2 ) return VARCHAR2;

  -- This procedure gets the select statement associated with context_code
  -- and segment_code and return it.
  PROCEDURE get_valueset_select(p_context_code IN  VARCHAR2,
                                p_segment_code IN  VARCHAR2,
                                x_select_stmt  OUT NOCOPY VARCHAR2,
                                p_segment_map_col IN VARCHAR2 DEFAULT NULL, -- sfiresto fix
                                p_pte IN VARCHAR2 DEFAULT NULL,  -- Hierarchical Categories
                                p_ss  IN VARCHAR2 DEFAULT NULL); -- Hierarchical Categories
END QP_MASS_MAINTAIN_UTIL;

/
