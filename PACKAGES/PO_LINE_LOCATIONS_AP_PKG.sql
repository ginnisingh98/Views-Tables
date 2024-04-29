--------------------------------------------------------
--  DDL for Package PO_LINE_LOCATIONS_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_LOCATIONS_AP_PKG" AUTHID CURRENT_USER AS
/* $Header: POLNLOCS.pls 120.0.12010000.1 2008/09/18 12:22:11 appldev noship $ */

    FUNCTION get_last_receipt(l_line_location_id IN NUMBER) RETURN DATE;
    FUNCTION get_requestors(l_line_location_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_num_distributions(l_line_location_id IN NUMBER) RETURN NUMBER;

--    PRAGMA RESTRICT_REFERENCES(get_last_receipt, WNDS, WNPS, RNPS);
--    PRAGMA RESTRICT_REFERENCES(get_requestors, WNDS, WNPS);

/* removed (GK) RNPS for package to compile, need to investigate */

--    PRAGMA RESTRICT_REFERENCES(get_num_distributions, WNDS, WNPS, RNPS);

END PO_LINE_LOCATIONS_AP_PKG;

/
