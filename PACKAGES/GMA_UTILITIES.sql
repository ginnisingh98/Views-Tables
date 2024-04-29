--------------------------------------------------------
--  DDL for Package GMA_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: GMAUTILS.pls 115.3 2003/02/03 16:55:46 appldev noship $ *

/*=====================================================================+
 | PROCEDURE
 |   DO_SQL
 |
 | PURPOSE
 |   Executes a dynamic SQL statement
 |
 | ARGUMENTS
 |   p_sql_stmt   String holding sql statement.  May be up to 8K long.
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  PROCEDURE DO_SQL(p_sql_stmt in varchar2);

END GMA_UTILITIES;

 

/
