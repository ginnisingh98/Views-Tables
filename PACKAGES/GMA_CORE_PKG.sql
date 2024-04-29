--------------------------------------------------------
--  DDL for Package GMA_CORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_CORE_PKG" AUTHID CURRENT_USER AS
/* $Header: GMACORES.pls 115.4 2002/12/03 21:58:08 appldev ship $ */
FUNCTION get_date_constant  (
  V_constant VARCHAR2) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (get_date_constant,WNPS, WNDS);

FUNCTION get_date_constant_d  (
  V_constant VARCHAR2) RETURN DATE;
PRAGMA RESTRICT_REFERENCES (get_date_constant_d,WNPS, WNDS);
-- Bug #2626977 (JKB) Added new function above.

PROCEDURE check_product_installed (V_constant IN VARCHAR2,
				  V_status   OUT NOCOPY VARCHAR2);
END GMA_CORE_PKG;

 

/
