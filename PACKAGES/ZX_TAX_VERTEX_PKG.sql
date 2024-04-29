--------------------------------------------------------
--  DDL for Package ZX_TAX_VERTEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_VERTEX_PKG" AUTHID CURRENT_USER AS
/* $Header: zxvertexpkgs.pls 120.1 2006/04/07 00:16:54 svaze ship $ */
Function is_city_limit_valid(p_city_limit IN VARCHAR2) return boolean;
FUNCTION IS_GEOCODE_VALID(p_geocode IN VARCHAR2) return BOOLEAN;
FUNCTION INSTALLED return BOOLEAN;

End zx_tax_vertex_pkg;

 

/
