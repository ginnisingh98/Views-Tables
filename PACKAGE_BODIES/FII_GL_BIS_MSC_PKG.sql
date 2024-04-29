--------------------------------------------------------
--  DDL for Package Body FII_GL_BIS_MSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_BIS_MSC_PKG" AS
/* $Header: FIIGLBSB.pls 120.1 2005/09/27 14:41:16 sgautam noship $ */
-- PUBLIC FUNCTIONS
--

  FUNCTION get_description_sql(
                          p_coa_id  IN NUMBER,
                          p_column_name IN VARCHAR2,
                          p_seg_val     IN VARCHAR2) RETURN VARCHAR2 IS
      l_segment_num   NUMBER(3);
      l_desc_sql      VARCHAR2(500);
  BEGIN
     /* Retrieve the segment number for the chart of account id
         and  segment name combination */
     SELECT segment_num
     INTO   l_segment_num
     FROM   FND_ID_FLEX_SEGMENTS
     WHERE  application_id = 101
     AND    id_flex_code = 'GL#'
     AND    id_flex_num = p_coa_id
     AND    application_column_name = p_column_name;

     /* No Exception Raised  so far. That means segment number exists
        for this chart of account id and segment name combination
        So  Calling GL_FLEXFIELDS_PKG.get_description_sql to get
          the description */
     l_desc_sql := GL_FLEXFIELDS_PKG.get_description_sql(
                                                   p_coa_id,
                                                   l_segment_num,
                                                   p_seg_val);
     return(l_desc_sql);
   EXCEPTION
      /* Segment Number doesn't exist for this chart of account id and
         segment name  */
      WHEN no_data_found THEN
          return(NULL);
   END get_description_sql;

END FII_GL_BIS_MSC_PKG;

/
