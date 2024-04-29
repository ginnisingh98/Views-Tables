--------------------------------------------------------
--  DDL for Package OKC_TIME_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TIME_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPTULS.pls 120.0 2005/05/26 09:51:21 appldev noship $ */
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'SQLcode';
  G_DATE_ERROR                 CONSTANT varchar2(200) := 'Start Date > End Date';
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_TIME_UTIL_PUB';
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

----------------------------------------------------------------------------
-- The following procedure derives the most suitable period and duration based
-- on a start and end date.
----------------------------------------------------------------------------

  PROCEDURE get_duration(
    p_start_date in date,
    p_end_date in date,
    x_duration out nocopy number,
    x_timeunit  out nocopy varchar2,
    x_return_status out nocopy varchar2);

----------------------------------------------------------------------------
-- The following function returns the end date based on a start,duration and
-- period.
----------------------------------------------------------------------------
  FUNCTION get_enddate(
    p_start_date in date,
    p_timeunit varchar2,
    p_duration number)
  return date ;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- The following section deals with handling of tve related rules
----------------------------------------------------------------------------

  SUBTYPE col_val_rec is OKC_TIME_UTIL_PVT.col_val_rec;
  SUBTYPE t_col_vals is OKC_TIME_UTIL_PVT.t_col_vals;

  FUNCTION get_app_id
    return NUMBER;

-- /striping/
  FUNCTION get_app_id(rule_code in varchar2)
    return NUMBER;

  FUNCTION get_rule_df_name
    return varchar2;

-- /striping/
  FUNCTION get_rule_df_name(rule_code in varchar2)
    return varchar2;

  FUNCTION get_rule_defs_using_vs(
    p_app_id IN NUMBER,
    p_dff_name IN VARCHAR2,
    p_fvs_name IN VARCHAR2)
    return varchar2;

  PROCEDURE get_dff_column_values (
    p_app_id      IN NUMBER,
    p_dff_name    IN VARCHAR2,
    p_rdf_code    IN VARCHAR2,
    p_fvs_name    IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_col_vals    OUT NOCOPY t_col_vals,
    p_no_of_cols  OUT NOCOPY NUMBER
    );

  FUNCTION get_tve_ids (
    p_app_id IN NUMBER,
    p_dff_name IN VARCHAR2,
    p_rdf_code IN VARCHAR2,
    p_fvs_name IN VARCHAR2,
    p_rule_id IN NUMBER)
    return varchar2;

END OKC_TIME_UTIL_PUB;

 

/
