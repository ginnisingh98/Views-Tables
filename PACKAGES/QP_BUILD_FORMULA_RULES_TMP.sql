--------------------------------------------------------
--  DDL for Package QP_BUILD_FORMULA_RULES_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BUILD_FORMULA_RULES_TMP" AUTHID CURRENT_USER AS
/* $Header: QPXVBFTS.pls 120.1 2005/06/14 01:59:39 appldev  $ */

  PROCEDURE Get_Formula_Values
       (p_Formula                   in     VARCHAR2,
        p_Operand_Tbl               in     QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type,
        p_procedure_type            IN     VARCHAR2,
        x_formula_value             out NOCOPY /* file.sql.39 change */    NUMBER,
        x_return_status             out NOCOPY /* file.sql.39 change */    VARCHAR2);

END QP_BUILD_FORMULA_RULES_TMP;

 

/
