--------------------------------------------------------
--  DDL for Package Body ZX_TAX_VERTEX_GEO_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_VERTEX_GEO_STUB" AS
/* $Header: zxvtxgeb.pls 120.0 2005/09/09 08:20:16 asengupt noship $ */
/* ************** Procedure and Function Specifications *************** */
PROCEDURE GeoSetGeoCodeCriteria (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                 pGeoLevel      IN      BINARY_INTEGER,
                 pGeoState      IN      NUMBER,
                 pGeoCounty     IN      NUMBER,
                 pGeoCity       IN      NUMBER,
                 pCityRecType   IN      BINARY_INTEGER) IS
BEGIN
null;
END;

PROCEDURE GeoSetGeoCodeCriteria (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                 pGeoLevel      IN      BINARY_INTEGER,
                 pFullGeoCode   IN      NUMBER,
                 pCityRecType   IN      BINARY_INTEGER) IS
BEGIN
null;
END;

PROCEDURE GeoSetNameCriteria (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                 pGeoLevel          IN      BINARY_INTEGER,
                 pStateAbbrev       IN      VARCHAR2,
                 pStateNamePrefix   IN      BOOLEAN,
                 pStateName         IN      VARCHAR2,
                 pCountyNamePrefix  IN      BOOLEAN,
                 pCountyName        IN      VARCHAR2,
                 pCityNamePrefix    IN      BOOLEAN,
                 pCityNameCompress  IN      BOOLEAN,
                 pCityName          IN      VARCHAR2,
                 pZipCodePrefix     IN      BOOLEAN,
                 pZipCode           IN      VARCHAR2,
                 pCityRecType       IN      BINARY_INTEGER) IS
BEGIN
null;
END;

FUNCTION GeoRetrieveFirst (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                       pGeoResultsRec IN OUT NOCOPY tGeoResultsRecord) RETURN BOOLEAN IS
BEGIN
return FALSE;
END;

FUNCTION GeoRetrieveNext (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                       pGeoResultsRec IN OUT NOCOPY tGeoResultsRecord) RETURN BOOLEAN IS
BEGIN
return FALSE;
END;

PROCEDURE GeoGetVersionInfo (pVersionRec OUT NOCOPY tGeoVersionRecord) IS
BEGIN
null;
END;

FUNCTION GeoGetLevel (pGeoCode IN NUMBER) RETURN BINARY_INTEGER IS
BEGIN
return 0;
END;

FUNCTION GeoPackGeoCode (pGeoState IN NUMBER,
                        pGeoCounty IN NUMBER,
                        pGeoCity IN NUMBER) RETURN NUMBER IS
BEGIN
return 0;
END;

PROCEDURE GeoUnPackGeoCode (pGeoState OUT NOCOPY NUMBER,
                        pGeoCounty OUT NOCOPY NUMBER,
                        pGeoCity OUT NOCOPY NUMBER,
                        pFullGeoCode IN NUMBER) IS
BEGIN
null;
END;

PROCEDURE GeoCloseSearch (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord) IS
BEGIN
null;
END;

FUNCTION GeoCompressCityName(pCompressCityStr IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
return ('FALSE');
END;

END ZX_TAX_VERTEX_GEO_STUB;

/
