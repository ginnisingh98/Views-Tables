--------------------------------------------------------
--  DDL for Package PO_COMMODITIES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMMODITIES_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: POXCMUTS.pls 115.0 2003/06/05 22:29:50 jazhang noship $ */

FUNCTION is_commodity_code_unique(
  p_comm_id IN NUMBER
, p_comm_code IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_commodity_name_unique(
  p_comm_id IN NUMBER
, p_comm_name IN VARCHAR2
) RETURN VARCHAR2;

END PO_COMMODITIES_UTIL_PKG;

 

/
