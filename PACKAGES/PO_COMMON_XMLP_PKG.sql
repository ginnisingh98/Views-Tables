--------------------------------------------------------
--  DDL for Package PO_COMMON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMMON_XMLP_PKG" AUTHID CURRENT_USER as
/* $Header: POCOMMONS.pls 120.2 2008/01/03 11:12:27 dwkrishn noship $ */

  -- Author  : DWKRISHN
  -- Created : 6/26/2006 5:03:44 PM
  -- Purpose :

  -- Public type declarations

  -- Public function and procedure declarations
  function get_precision(qty_precision number)return varchar2 ;

end po_common_xmlp_pkg;


/
