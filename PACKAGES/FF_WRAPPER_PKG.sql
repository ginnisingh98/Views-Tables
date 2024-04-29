--------------------------------------------------------
--  DDL for Package FF_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_WRAPPER_PKG" AUTHID CURRENT_USER as
/*  $Header: ffwrppkg.pkh 115.1 2003/11/26 06:54:05 arashid noship $ */
type t_date   is table of date           index by binary_integer;
type t_number is table of number         index by binary_integer;
type t_text   is table of varchar2(255)  index by binary_integer;
--
-- Globals for formula call when the wrapper package has not
-- been generated.
--
g_d      t_date;
g_n      t_number;
g_t      t_text;
g_i      t_number;
g_ffercd number;
g_fferln number;
g_ffermt varchar2(255);
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
);
end ff_wrapper_pkg;

 

/
