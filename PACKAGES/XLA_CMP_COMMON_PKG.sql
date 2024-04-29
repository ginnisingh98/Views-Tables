--------------------------------------------------------
--  DDL for Package XLA_CMP_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_COMMON_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpcom.pkh 120.0 2004/06/02 11:42:18 aquaglia ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_cmp_common_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    Oracle Subledger Accounting Compiler Common Code                   |
|                                                                       |
| HISTORY                                                               |
|    30-JAN-04 A.Quaglia      Created                                   |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


G_COMPILE_STATUS_CODE_ERROR      CONSTANT    VARCHAR2(1) := 'E';
G_COMPILE_STATUS_CODE_UNCOMP     CONSTANT    VARCHAR2(1) := 'N';
G_COMPILE_STATUS_CODE_RUNNING    CONSTANT    VARCHAR2(1) := 'R';
G_COMPILE_STATUS_CODE_COMPILED   CONSTANT    VARCHAR2(1) := 'Y';
G_COMPILE_STATUS_CODE_DELETE     CONSTANT    VARCHAR2(1) := 'D';


TYPE lt_application_info IS RECORD
                   (
                     application_id         PLS_INTEGER
                    ,application_name       VARCHAR2(2000) --240 in the table
                    ,application_short_name VARCHAR2(50)
                    ,application_hash_id    VARCHAR2(5)
                    ,oracle_username        VARCHAR2(30)
                    ,product_abbreviation   VARCHAR2(4)
                    ,apps_account           VARCHAR2(30)
                   );


FUNCTION get_application_info
                  ( p_application_id       IN            NUMBER
                   ,p_application_info     OUT NOCOPY    lt_application_info
                  )
RETURN BOOLEAN
;

FUNCTION get_user_name
                  ( p_user_id          IN            NUMBER
                   ,p_user_name        OUT NOCOPY    VARCHAR2
                  )
RETURN BOOLEAN
;

PROCEDURE clob_to_varchar2s
                    (
                      p_clob          IN  CLOB
                     ,p_varchar2s     OUT NOCOPY DBMS_SQL.VARCHAR2S
                    );

PROCEDURE varchar2s_to_clob
                    (
                      p_varchar2s     IN         DBMS_SQL.VARCHAR2S
                     ,x_clob          OUT NOCOPY CLOB
                    );

PROCEDURE dump_text
                    (
                      p_text          IN  VARCHAR2
                    );

PROCEDURE dump_text
                    (
                      p_text          IN  DBMS_SQL.VARCHAR2S
                    );

PROCEDURE dump_text
                    (
                      p_text          IN  CLOB
                    );

FUNCTION bool_to_char(p_boolean IN BOOLEAN)
RETURN VARCHAR2;

FUNCTION replace_token
                    (
                      p_original_text    IN  CLOB
                     ,p_token            IN  VARCHAR2
                     ,p_replacement_text IN  CLOB
                    )
RETURN CLOB;

END xla_cmp_common_pkg;
 

/
