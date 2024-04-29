--------------------------------------------------------
--  DDL for Package INV_COMMON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COMMON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVCOMMONS.pls 120.0 2007/12/18 07:39:59 dwkrishn noship $ */

  function get_precision(qty_precision number)return varchar2 ;

end INV_COMMON_XMLP_PKG;

/
