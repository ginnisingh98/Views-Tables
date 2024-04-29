--------------------------------------------------------
--  DDL for Package PER_ITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ITS_PKG" AUTHID CURRENT_USER as
/* $Header: peits01t.pkh 115.0 99/10/06 07:22:20 porting ship    $ */
--
----------------------------------------------------------------------
-- return_legislation_code
--
--    Returns the legislation_code for the business group of a responsibility.
--    (purity level allows remote call from sql statement)
--
FUNCTION RETURN_LEGISLATION_CODE(P_RESPONSIBILITY_ID IN NUMBER) RETURN VARCHAR2;
pragma restrict_references(RETURN_LEGISLATION_CODE, WNDS, RNPS, WNPS);
--
----------------------------------------------------------------------
--
END PER_ITS_PKG;

 

/
