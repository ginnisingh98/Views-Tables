--------------------------------------------------------
--  DDL for Package PON_GEOGRAPHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_GEOGRAPHY_PKG" AUTHID CURRENT_USER as
/*$Header: PONGEOS.pls 120.0 2005/06/01 16:46:37 appldev noship $ */

type refCurTyp is Ref Cursor;

PROCEDURE get_all_territories(
  p_theLanguage IN fnd_territories_tl.LANGUAGE%TYPE,
  x_territories OUT NOCOPY refCurTyp,
  x_STATUS OUT NOCOPY VARCHAR2,
  x_exception_msg OUT NOCOPY VARCHAR2
				  );

END PON_GEOGRAPHY_PKG;

 

/
