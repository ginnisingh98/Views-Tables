--------------------------------------------------------
--  DDL for Package PE_GET_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_GET_VAL_PKG" AUTHID CURRENT_USER as
/* $Header: pepyppgr.pkh 120.2 2005/12/01 01:02:37 ggnanagu noship $ */
FUNCTION get_grade_value (
      p_grade_id      NUMBER,
      p_rate_id       NUMBER,
      p_change_date   DATE,
      p_which_value   VARCHAR2
)
RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_grade_value, WNDS);
END pe_get_val_pkg;

 

/
