--------------------------------------------------------
--  DDL for Package ZX_PRD_OPTIONS_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PRD_OPTIONS_MIGRATE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxprdoptmigpkgs.pls 120.4 2005/09/22 09:30:37 asengupt ship $ */

PROCEDURE MIGRATE_PRODUCT_OPTIONS(x_return_status OUT NOCOPY VARCHAR2);

FUNCTION get_location_tax (
 p_org_id          IN NUMBER,
 p_set_of_books_id IN NUMBER
)RETURN VARCHAR2;
  -- PRAGMA RESTRICT_REFERENCES(get_location_tax, WNDS);

END ZX_PRD_OPTIONS_MIGRATE_PKG;

 

/
