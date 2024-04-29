--------------------------------------------------------
--  DDL for Package GMF_GL_GET_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_BALANCES" AUTHID CURRENT_USER AS
/* $Header: gmfbalns.pls 120.2 2005/09/20 12:25:29 rseshadr noship $ */

/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 Start**/

  TYPE gmf_segment_values_tbl IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

/** Anand thiyagarajan GL Expense Allocation Enhancement 26-04-2004 End**/

  PROCEDURE proc_gl_get_balances(
    in_set_of_books      in out NOCOPY number,
    in_chart_of_accounts in out NOCOPY number,
    in_period_year       in out NOCOPY number,
    in_period_num        in out NOCOPY number,
    in_account_type      in out NOCOPY varchar2, /* (A)sset/(L)iability...... */
    in_currency_code     in out NOCOPY varchar2,
    start_segments       in     varchar2,     /* Segments 1-30 */
    to_segments          in out NOCOPY varchar2, /* Segments 1-30 */
    in_actual_flag       in out NOCOPY varchar2, /* (A)ctual/(B)udget/(E)ncumerance */
    in_ytd_ptd           in     number,   /* 0=PTD, 1=YTD */
    amount                  out NOCOPY number,
    segment_delimiter       out NOCOPY varchar2,
    row_to_fetch         in out NOCOPY number,
    error_status            out NOCOPY number);

    PROCEDURE initialize(
	in_set_of_books_id	IN NUMBER
    );

END GMF_GL_GET_BALANCES;

 

/
