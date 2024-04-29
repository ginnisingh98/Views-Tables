--------------------------------------------------------
--  DDL for Package FF_WRAPPER_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_WRAPPER_MAIN_PKG" AUTHID CURRENT_USER as
/*  $Header: ffwrpmai.pkh 120.0 2005/05/27 23:25:53 appldev noship $ */
------------------------------------------------------------------------
-- ** WARNING :  DO NOT PUT ANY GLOBAL DATA IN THIS PACKAGE HEADER ** --
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Package state causes problems with package invalidation if the     --
-- formula wrapper is regenerated.                                    --
------------------------------------------------------------------------

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
end ff_wrapper_main_pkg;

 

/
