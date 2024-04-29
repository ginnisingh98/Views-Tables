--------------------------------------------------------
--  DDL for Package QP_FORMULA_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_FORMULA_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXPFORS.pls 120.1.12010000.1 2008/07/28 11:54:59 appldev ship $ */

  TYPE t_Operand_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_retcode       VARCHAR2(30);
  g_errbuf        VARCHAR2(240);

  PROCEDURE FORMULAS
  (err_buff                out NOCOPY /* file.sql.39 change */ VARCHAR2,
   retcode                 out NOCOPY /* file.sql.39 change */ NUMBER);


END QP_FORMULA_RULES_PVT;

/
