--------------------------------------------------------
--  DDL for Package ZX_TAX_TAXWARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_TAXWARE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxtaxwarepkgs.pls 120.1 2006/04/07 00:20:57 svaze ship $ */

/*-----------------------------------------------------------------------*/
/* Public Exceptions                                                     */
/*-----------------------------------------------------------------------*/
TAXWARE_NOT_INSTALLED   EXCEPTION;            -- Bug 5139634

Function is_city_limit_valid(p_city_limit IN VARCHAR2) return boolean;
FUNCTION IS_GEOCODE_VALID(p_geocode IN VARCHAR2) return BOOLEAN;
FUNCTION INSTALLED return BOOLEAN;            -- Bug 5139634

End zx_tax_taxware_pkg;

 

/
