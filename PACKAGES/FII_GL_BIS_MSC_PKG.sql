--------------------------------------------------------
--  DDL for Package FII_GL_BIS_MSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_BIS_MSC_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLBSS.pls 120.1 2005/09/27 14:41:08 sgautam noship $ */
--
-- Function
--   get_description_sql
-- Purpose
--   wrapper function to call gl_flexfields_pkg.get_description_sql
--   to get segemnt vale description for glfv_gl_accounts_descr
-- History
--   Apr-25-2003    SGAUTAM      Created
-- Arguments
--   p_coa_id       Number       Chart of account id
--   p_column_name  Varchar2     Segment Name
--   p_seg_val      Varchar2     Segment Value
-- Returns
--   Segment value description (Varchar2)
-- Example
--   FII_GL_BIS_MSC_PKG.get_description_sql(101, 'SEGMENT10', SEGMENT10);
-- Notes
--

FUNCTION get_description_sql(
            p_coa_id      IN NUMBER,
            p_column_name IN VARCHAR2,
            p_seg_val     IN VARCHAR2) RETURN VARCHAR2;

END FII_GL_BIS_MSC_PKG;

 

/
