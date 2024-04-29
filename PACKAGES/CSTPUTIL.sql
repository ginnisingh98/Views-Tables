--------------------------------------------------------
--  DDL for Package CSTPUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPUTIL" AUTHID CURRENT_USER AS
/* $Header: CSTPUTIS.pls 120.1 2006/02/11 16:25:10 rthng noship $ */

-- PROCEDURE
--  CSTPUGCI		Return Currency Information
--
-- INPUT PARAMETERS
--  I_ORG_ID		Organization id
--
-- RETURN VALUES
--  O_ROUND_UNIT	Rounding Unit - extension of min acct unit, e.g.
--			ROUND(number/O_ROUND_UNIT)*O_ROUND_UNIT
--  O_PRECISION	Regular precision
--  O_EXT_PREC		Extended precision
--

PROCEDURE CSTPUGCI (
	 I_ORG_ID		IN	NUMBER,
	 O_ROUND_UNIT		OUT NOCOPY	NUMBER,
	 O_PRECISION		OUT NOCOPY	NUMBER,
	 O_EXT_PREC		OUT NOCOPY	NUMBER);

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
  procedure do_sql(p_sql_stmt in varchar2);
  Procedure execute_insert_CIT(
                             p_view_name IN varchar2,
                             p_cost_org_id IN NUMBER,
                             p_ct_id       IN NUMBER,
                             p_item_id     IN NUMBER,
                             p_app_col_name IN VARCHAR2,
                             p_flex        IN NUMBER);

END CSTPUTIL;

 

/
