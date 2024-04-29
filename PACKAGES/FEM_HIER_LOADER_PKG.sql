--------------------------------------------------------
--  DDL for Package FEM_HIER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_HIER_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: femhierldr_pkh.pls 120.0 2005/06/06 21:00:57 appldev noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------

  G_PKG_NAME             constant varchar2(30) := 'FEM_HIER_LOADER_PKG';
  G_FEM                  constant varchar2(3)  := 'FEM';
  G_BLOCK                constant varchar2(80) := G_FEM||'.PLSQL.'||G_PKG_NAME;

---------Exceptions---------------------
  e_loader_error                  exception;
  e_hierarchy_error               exception;


---------------------------------------------
--  Package Types
---------------------------------------------
  type cv_curs is ref cursor;
  type rowid_type is table of rowid index by binary_integer;
  type number_type is table of number index by binary_integer;
  type pct_type is table of number(3,2) index by binary_integer;
  type date_type is table of date index by binary_integer;
  type varchar2_std_type is table of varchar2(30) index by binary_integer;
  type varchar2_150_type is table of varchar2(150) index by binary_integer;
  type flag_type is table of varchar2(1) index by binary_integer;
  type lang_type is table of varchar2(4) index by binary_integer;
  type varchar2_1000_type is table of varchar2(1000) index by binary_integer;


/*===========================================================================+
 | PROCEDURE
 |              Main
 |
 | DESCRIPTION
 |              Main engine procedure for loading dimension hierarchies
 |              into FEM
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/

PROCEDURE Main (
  errbuf                        out nocopy varchar2
  ,retcode                      out nocopy varchar2
  ,p_object_definition_id       in number
  ,p_execution_mode             in varchar2
  ,p_dimension_varchar_label    in varchar2
  ,p_hierarchy_object_name      in varchar2
  ,p_hier_obj_def_display_name  in varchar2
);



END FEM_HIER_LOADER_PKG;

 

/
