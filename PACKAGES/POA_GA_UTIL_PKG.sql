--------------------------------------------------------
--  DDL for Package POA_GA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_GA_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: poagautils.pls 115.2 2004/01/23 23:59:46 mangupta noship $ */

  FUNCTION is_enabled(p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE,
                      p_org_id IN PO_HEADERS_ALL.org_id%TYPE)
  RETURN VARCHAR2 parallel_enable;

  FUNCTION is_global_agreement(p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE)
  RETURN VARCHAR2 parallel_enable;

  FUNCTION get_ga_conversion_rate(p_from_currency_code IN VARCHAR2, p_to_currency_code IN VARCHAR2, p_rate_date IN DATE) RETURN NUMBER parallel_enable;

END POA_GA_UTIL_PKG;

 

/
