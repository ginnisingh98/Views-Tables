--------------------------------------------------------
--  DDL for Package POA_OLTP_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_OLTP_GENERIC_PKG" AUTHID CURRENT_USER AS
/* $Header: poagpkss.pls 115.3 2002/09/05 01:46:33 jhou noship $ */

FUNCTION get_approved_date_poh (p_creation_date IN DATE,
                                p_poh_id IN NUMBER) return DATE;
  PRAGMA RESTRICT_REFERENCES(get_approved_date_poh, WNDS);

  FUNCTION get_approved_date_por (p_creation_date IN DATE,
                                p_por_id IN NUMBER) return DATE;
  PRAGMA RESTRICT_REFERENCES(get_approved_date_por, WNDS);

  FUNCTION get_approved_date_pll (p_creation_date IN DATE,
                                p_line_location_id IN NUMBER) return DATE;
  PRAGMA RESTRICT_REFERENCES(get_approved_date_pll, WNDS);


END POA_OLTP_GENERIC_PKG;


 

/
