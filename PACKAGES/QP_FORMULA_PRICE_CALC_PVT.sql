--------------------------------------------------------
--  DDL for Package QP_FORMULA_PRICE_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_FORMULA_PRICE_CALC_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCALS.pls 120.1.12010000.1 2008/07/28 11:58:18 appldev ship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		    CONSTANT  VARCHAR2(30) := 'QP_FORMULA_PRICE_CALC_PVT';

TYPE req_line_attrs_rec IS RECORD (
  line_index       NUMBER,
  attribute_type   VARCHAR2(30),
  context          VARCHAR2(30),
  attribute        VARCHAR2(30),
  value            VARCHAR2(240) );

TYPE req_line_attrs_tbl IS TABLE OF req_line_attrs_rec
  INDEX BY BINARY_INTEGER;

TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE Step_Number_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/* Wrapper for Get_Custom_Price, to be called by Java Formula Engine */
FUNCTION Java_Custom_Price(p_price_formula_id      IN NUMBER,
                           p_list_price            IN NUMBER,
                           p_price_effective_date  IN DATE,
                           p_line_index            IN NUMBER,
                           p_request_id            IN NUMBER)
RETURN NUMBER;

/*Public Function to parse a formula even before substituting each step number
  with its calculated value*/
PROCEDURE Parse_Formula (p_formula       IN  VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2);

/*Public Function to Evaluate a formula and calculate the result*/
FUNCTION  Calculate (p_price_formula_id     IN  NUMBER,
                     p_list_price           IN  NUMBER,
		     p_price_effective_date IN  DATE,
		     --p_req_line_attrs_tbl   IN  REQ_LINE_ATTRS_TBL,
                     p_line_index           IN  NUMBER,
                     p_list_line_type_code  IN  VARCHAR2,
                     --Added parameters p_line_index and p_list_line_type_code
                     --and commented out the parameter p_req_line_attrs_tbl.
                     --POSCO performance-related
		     x_return_status        OUT NOCOPY VARCHAR2,
                     p_modifier_value       IN  NUMBER default NULL) --mkarya for bug 1906545
RETURN NUMBER;

PROCEDURE  Set_Message (p_price_formula_id     IN NUMBER,
                        p_formula_name         IN VARCHAR2,
                        p_null_step_number_tbl IN STEP_NUMBER_TBL_TYPE);

/* Wrapper function for JDBC call to Get_Formula_Values */
PROCEDURE Java_Get_Formula_Values(p_formula          IN VARCHAR2,
                                  p_operands_str     IN VARCHAR2,
                                  p_procedure_type   IN VARCHAR2,
                                  x_formula_value    OUT NOCOPY /* file.sql.39 change */ NUMBER,
                                  x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END QP_FORMULA_PRICE_CALC_PVT;

/
