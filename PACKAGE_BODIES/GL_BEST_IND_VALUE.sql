--------------------------------------------------------
--  DDL for Package Body GL_BEST_IND_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BEST_IND_VALUE" AS
/* $Header: glubindb.pls 120.7 2005/12/27 21:33:34 vtreiger ship $ */
--  -------------------------------------------------
--  Functions
--  -------------------------------------------------

   FUNCTION find_ind_value
      (p_segment_num    IN NUMBER)
   RETURN VARCHAR2
   IS
      l_segment_str    VARCHAR2(3);
      l_full_segm_str  VARCHAR2(11);
      l_ind_name       VARCHAR2(30);
      l_col_name       VARCHAR2(40);
      l_ind_value      VARCHAR2(30);
      l_table_owner    VARCHAR2(20);
      l_schema         VARCHAR2(30);
      l_status         VARCHAR2(1);
      l_industry       VARCHAR2(1);
      l_rval           BOOLEAN;

--     cursor tbl_owner is
--       select upper(tab.owner)
--       from all_tables tab
--       where tab.table_name = 'GL_CODE_COMBINATIONS'
--       and owner = l_schema;

     cursor ind_col_name is
       select c.index_name ind_name, substr(c.column_name,1,40) col_name
       from all_ind_columns c
       where
         c.table_name = 'GL_CODE_COMBINATIONS' and
         c.table_owner = l_table_owner and
         c.column_position = 1
       order by col_name ASC;

   BEGIN
--  --- Get variables values ---

     l_segment_str := TO_CHAR(p_segment_num);
     l_segment_str := RTRIM(LTRIM(l_segment_str));
     l_full_segm_str := 'SEGMENT' || l_segment_str;
     l_ind_value := '';
     l_table_owner := '';

--  --- Find table owner ---
     l_rval := fnd_installation.get_app_info(
                                  'SQLGL', l_status, l_industry, l_schema);

--     OPEN tbl_owner;
--     FETCH tbl_owner INTO l_table_owner;
--     CLOSE tbl_owner;

     l_table_owner := l_schema;

--  --- Loop cursor to find index name ---
     OPEN ind_col_name;

     LOOP
       FETCH ind_col_name INTO l_ind_name, l_col_name;
       EXIT WHEN ind_col_name%NOTFOUND;

       IF (l_col_name = l_full_segm_str) THEN
         l_ind_value := l_ind_name;
         EXIT;
       END IF;
     END LOOP;

     CLOSE ind_col_name;
     RETURN(l_ind_value);

   END find_ind_value;

END gl_best_ind_value;

/
