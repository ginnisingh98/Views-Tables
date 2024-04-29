--------------------------------------------------------
--  DDL for Package WIP_COMMON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_COMMON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPCOMMONS.pls 120.1 2008/01/31 12:12:05 npannamp noship $ */

  function get_precision(qty_precision number)return varchar2 ;

end wip_common_xmlp_pkg;

/
