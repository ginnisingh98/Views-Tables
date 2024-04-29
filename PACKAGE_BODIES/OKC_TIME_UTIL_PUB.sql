--------------------------------------------------------
--  DDL for Package Body OKC_TIME_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_UTIL_PUB" AS
/* $Header: OKCPTULB.pls 120.0 2005/05/25 19:31:23 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
----------------------------------------------------------------------------
-- The following procedure derives the most suitable period and duration based
-- on a start and end date.
----------------------------------------------------------------------------
  PROCEDURE get_duration(
    p_start_date in date,
    p_end_date in date,
    x_duration out nocopy number,
    x_timeunit out nocopy varchar2,
    x_return_status out nocopy varchar2) is
  begin
    OKC_TIME_UTIL_PVT.get_duration(
      p_start_date,
      p_end_date,
      x_duration,
      x_timeunit,
      x_return_status);
  END get_duration;

----------------------------------------------------------------------------
-- The following function returns the end date based on a start,duration and
-- period.
----------------------------------------------------------------------------
  FUNCTION get_enddate(
    p_start_date in date,
    p_timeunit varchar2,
    p_duration number)
  return date is
  l_date date;
  begin
    l_date := OKC_TIME_UTIL_PVT.get_enddate(
              p_start_date,
              p_timeunit ,
              p_duration );
    return l_date;
  END get_enddate;

  function get_app_id
  return NUMBER
  IS
  l_num   number;
  BEGIN
    l_num := OKC_TIME_UTIL_PVT.get_app_id;
    return l_num;
  END;

-- /striping/
  function get_app_id(rule_code in varchar2)
  return NUMBER
  IS
  l_num   number;
  BEGIN
   l_num := OKC_TIME_UTIL_PVT.get_app_id(rule_code);
   return l_num;
  END;

  function get_rule_df_name
  return varchar2
  IS
   l_return_string  varchar2(400);
  BEGIN
   l_return_string := OKC_TIME_UTIL_PVT.get_rule_df_name;
   return l_return_string;
  END;

-- /striping/
  function get_rule_df_name(rule_code in varchar2)
  return varchar2
  IS
   l_return_string  varchar2(400);
  BEGIN
   l_return_string := OKC_TIME_UTIL_PVT.get_rule_df_name(rule_code);
   return l_return_string;
  END;

  function get_rule_defs_using_vs(
    p_app_id IN NUMBER,
    p_dff_name IN VARCHAR2,
    p_fvs_name IN VARCHAR2)
  return varchar2
  IS
    l_return_string  varchar2(400);
  BEGIN
   l_return_string := OKC_TIME_UTIL_PVT.get_rule_defs_using_vs(
    p_app_id ,
    p_dff_name ,
    p_fvs_name );
   return l_return_string;
  end;

  PROCEDURE get_dff_column_values (
    p_app_id      IN NUMBER,
    p_dff_name    IN VARCHAR2,
    p_rdf_code    IN VARCHAR2,
    p_fvs_name    IN VARCHAR2,
    p_rule_id     IN NUMBER,
    p_col_vals    OUT NOCOPY t_col_vals,
    p_no_of_cols  OUT NOCOPY NUMBER
  )
  IS
  BEGIN
    OKC_TIME_UTIL_PVT.get_dff_column_values (
      p_app_id,
      p_dff_name,
      p_rdf_code,
      p_fvs_name,
      p_rule_id,
      p_col_vals,
      p_no_of_cols);
  end;

  function get_tve_ids (
    p_app_id IN NUMBER,
    p_dff_name IN VARCHAR2,
    p_rdf_code IN VARCHAR2,
    p_fvs_name IN VARCHAR2,
    p_rule_id IN NUMBER)
  return varchar2
  is
    l_return_string  varchar2(400);
  begin
   l_return_string := OKC_TIME_UTIL_PVT.get_tve_ids(
    p_app_id ,
    p_dff_name,
    p_rdf_code,
    p_fvs_name,
    p_rule_id);
    return l_return_string;
  end;

END OKC_TIME_UTIL_PUB;

/
