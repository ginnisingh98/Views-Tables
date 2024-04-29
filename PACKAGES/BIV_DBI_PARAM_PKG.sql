--------------------------------------------------------
--  DDL for Package BIV_DBI_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIV_DBI_PARAM_PKG" AUTHID CURRENT_USER as
/* $Header: bivsrvrpars.pls 115.0 2003/10/06 02:30:49 kreardon noship $ */

function get_params( p_region_code varchar2 default null )
  return varchar2;

function get_def_time_per
  return varchar2;

function get_def_time_comp
  return varchar2;

end biv_dbi_param_pkg;

 

/
