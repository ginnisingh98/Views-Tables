--------------------------------------------------------
--  DDL for Package Body PON_GEOGRAPHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_GEOGRAPHY_PKG" as
/*$Header: PONGEOB.pls 120.0 2005/06/01 15:28:31 appldev noship $ */

PROCEDURE get_all_territories(
  p_theLanguage IN fnd_territories_tl.LANGUAGE%TYPE,
  x_territories OUT NOCOPY refCurTyp,
  x_STATUS OUT NOCOPY VARCHAR2,
  x_exception_msg OUT NOCOPY VARCHAR2
)IS
BEGIN
   OPEN x_territories FOR
     SELECT T.TERRITORY_CODE, T.ISO_NUMERIC_CODE, TL.TERRITORY_SHORT_NAME, TL.DESCRIPTION
     FROM   FND_TERRITORIES T, FND_TERRITORIES_TL TL
     WHERE  T.TERRITORY_CODE = TL.territory_code AND
     T.TERRITORY_CODE NOT IN ('ZR','FX','LX')
     AND    TL.LANGUAGE = p_theLanguage
     ORDER BY TL.TERRITORY_SHORT_NAME;

   x_STATUS  :='S';
   x_exception_msg       :=NULL;
EXCEPTION
   WHEN OTHERS THEN
      x_STATUS  :='U';
      raise;
END get_all_territories;


END PON_GEOGRAPHY_PKG;


/
