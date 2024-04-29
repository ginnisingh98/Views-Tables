--------------------------------------------------------
--  DDL for Package FEM_BI_DIMENSION_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BI_DIMENSION_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_bi_dim_utils.pls 120.1 2008/02/20 06:55:06 jcliving noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
  G_MODULE               constant varchar2(80) := 'fem.plsql.fem_bi_dimension_utils_pkg';
  G_PACKAGE_NAME         constant varchar2(30) := 'FEM_BI_DIMENSION_UTILS_PKG';
  G_FEM                  constant varchar2(3)  := 'FEM';

  type cal_periods_cursor is ref cursor return fem_cal_periods_b%rowtype;

---------------------------------------------
-- Declare public procedures and functions --
---------------------------------------------

/*===========================================================================+
 | PROCEDURE
 |   Run_Transformation
 |
 | DESCRIPTION
 |   Runs Attribute Transformation for all supported dimensions
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   x_errbuf                   Standard Concurrent Program parameter
 |   x_retcode                  Standard Concurrent Program parameter
 |   p_dimension_varchar_label  Dimension Varchar Label
 |   p_seed_db_link             Seed DB Link (INTERNAL USE ONLY)
 +===========================================================================*/

PROCEDURE Run_Transformation (
  x_errbuf                        out nocopy varchar2
  ,x_retcode                      out nocopy varchar2
  ,p_dimension_varchar_label      in varchar2
  ,p_seed_db_link                 in varchar2 := null
);


/*===========================================================================+
 | PROCEDURE
 |   Get_Pago_Cal_Period_ID
 |
 | DESCRIPTION
 |   Returns the prior Calendar Period ID for the given Calendar Period.
 |
 |   The returned Calendar Period will have the same Calendar, Dimension Group,
 |   and Adjustment Period Flag value.
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   p_cal_period_id            Calendar Period Id
 +===========================================================================*/

FUNCTION Get_Pago_Cal_Period_ID (
  p_cal_period_id                 in number
) RETURN number;


/*===========================================================================+
 | PROCEDURE
 |   Get_Yago_Cal_Period_ID
 |
 | DESCRIPTION
 |   Returns the prior year Calendar Period ID for the given Calendar Period.
 |
 |   The returned Calendar Period will have the same Calendar and Dimension
 |   Group.  As Adjusment Periods can have overlapping date ranges, only
 |   non adjustment periods are processed and returned.
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   p_cal_period_id            Calendar Period Id
 +===========================================================================*/

FUNCTION Get_Yago_Cal_Period_ID (
  p_cal_period_id                 in number
) RETURN number;


/*===========================================================================+
 | FOR INTERNAL USE ONLY.
 +===========================================================================*/

PROCEDURE Run_Seed_Transformation (
  p_dimension_varchar_label       in varchar2
  ,p_seed_db_link                 in varchar2
  ,x_completion_status            out nocopy varchar2
);

END FEM_BI_DIMENSION_UTILS_PKG;

/
