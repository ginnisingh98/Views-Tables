--------------------------------------------------------
--  DDL for Package Body FF_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_WRAPPER_PKG" as
/*  $Header: ffwrppkg.pkb 120.0 2005/05/27 23:25:57 appldev noship $ */
--
procedure formula
(p_formula_name    in            varchar2
,p_ff_package_name in            varchar2
,p_d               in out nocopy ff_wrapper_pkg.t_date
,p_n               in out nocopy ff_wrapper_pkg.t_number
,p_t               in out nocopy ff_wrapper_pkg.t_text
,p_i               in out nocopy ff_wrapper_pkg.t_number
,p_fferln             out nocopy number
,p_ffercd          in out nocopy number
,p_ffermt             out nocopy varchar2
) is
begin
  --
  -- Dummy procedure.
  --
  null;
end formula;
end ff_wrapper_pkg;

/
