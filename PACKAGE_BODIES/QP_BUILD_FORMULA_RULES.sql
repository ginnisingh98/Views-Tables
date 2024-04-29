--------------------------------------------------------
--  DDL for Package Body QP_BUILD_FORMULA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BUILD_FORMULA_RULES" AS
/* $Header: QPXVBSFB.pls 115.0 18-MAY-11 11:11:11 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      QP_BUILD_FORMULA_RULES_TMP
--  
--  DESCRIPTION
--  
--      Body of package QP_BUILD_FORMULA_RULES_TMP
--  
--  NOTES
--  
--  HISTORY
--  
--  18-MAY-11 Created
--  
 
--  Global constant holding the package name
 
 
PROCEDURE Get_Formula_Values
(    p_Formula                      IN VARCHAR2
,    p_Operand_Tbl                  IN QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type
,    p_procedure_type               IN VARCHAR2
,    x_formula_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_return_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
 
l_oper   QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type; 
 
BEGIN
  BEGIN
    NULL;
 
l_oper(1):=TO_NUMBER(TO_CHAR(p_Operand_Tbl(1)));
 
    IF p_Formula = 
  ''
     || '1'
     THEN
      IF p_procedure_type != 'S' THEN
 
        x_formula_value := l_oper(1);
        x_return_status := 'S';
      ELSE
        x_return_status := 'T';
      END IF;
      RETURN;
    END IF;
 
 
l_oper(2):=TO_NUMBER(TO_CHAR(p_Operand_Tbl(2)));
 
    IF p_Formula = 
  ''
     || '1/2'
     THEN
      IF p_procedure_type != 'S' THEN
 
        x_formula_value := l_oper(1)/l_oper(2);
        x_return_status := 'S';
      ELSE
        x_return_status := 'T';
      END IF;
      RETURN;
    END IF;
 
 
 
    IF p_Formula = 
  ''
     || '1 / 2'
     THEN
      IF p_procedure_type != 'S' THEN
 
        x_formula_value := l_oper(1) / l_oper(2);
        x_return_status := 'S';
      ELSE
        x_return_status := 'T';
      END IF;
      RETURN;
    END IF;
 
 
 
    IF p_Formula = 
  ''
     || '1*2'
     THEN
      IF p_procedure_type != 'S' THEN
 
        x_formula_value := l_oper(1)*l_oper(2);
        x_return_status := 'S';
      ELSE
        x_return_status := 'T';
      END IF;
      RETURN;
    END IF;
 
l_oper(0):=TO_NUMBER(TO_CHAR(p_Operand_Tbl(0)));
 
 
 
l_oper(3):=TO_NUMBER(TO_CHAR(p_Operand_Tbl(3)));
 
    IF p_Formula = 
  ''
     || 'Greatest(0,1-nvl(2,3))'
     THEN
      IF p_procedure_type != 'S' THEN
 
        x_formula_value := Greatest(l_oper(0),l_oper(1)-nvl(l_oper(2),l_oper(3)));
        x_return_status := 'S';
      ELSE
        x_return_status := 'T';
      END IF;
      RETURN;
    END IF;
 
    x_return_status := 'F';
 
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
  END;
END Get_Formula_Values;
 
END QP_BUILD_FORMULA_RULES;

/
