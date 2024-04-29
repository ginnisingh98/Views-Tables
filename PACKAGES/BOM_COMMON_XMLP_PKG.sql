--------------------------------------------------------
--  DDL for Package BOM_COMMON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMMON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMCOMMONS.pls 120.0 2007/12/28 09:42:07 dwkrishn noship $ */
  -- Author  : DWKRISHN
  -- Created : 6/26/2006 5:03:44 PM
  -- Purpose :

  -- Public type declarations

  -- Public function and procedure declarations
  function get_precision(qty_precision number)return varchar2 ;

end bom_common_xmlp_pkg;

/
