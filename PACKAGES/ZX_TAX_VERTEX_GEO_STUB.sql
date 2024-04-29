--------------------------------------------------------
--  DDL for Package ZX_TAX_VERTEX_GEO_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_VERTEX_GEO_STUB" AUTHID CURRENT_USER AS
/* $Header: zxvtxges.pls 120.0 2005/09/09 08:24:53 asengupt noship $ */
/* *********************** Constant Declarations *********************** */

/* constants returned from the GeoGetLevel function and passed into the GeoSet...Criteria procedures */
cGeoCodeLevelState  CONSTANT BINARY_INTEGER := 0;
cGeoCodeLevelCounty CONSTANT BINARY_INTEGER := 1;
cGeoCodeLevelCity   CONSTANT BINARY_INTEGER := 2;

/* GeoCoder String Lengths */
cGeoLocGeoCdLen CONSTANT BINARY_INTEGER := 9;
cGeoLocGeoStLen CONSTANT BINARY_INTEGER := 2;
cGeoLocGeoCoLen CONSTANT BINARY_INTEGER := 3;
cGeoLocGeoCiLen CONSTANT BINARY_INTEGER := 4;

/* GeoCoder City APO/FPO Codes */
cGeoLocPOTypeAPO       CONSTANT BINARY_INTEGER := 1;
cGeoLocPOTypeFPO       CONSTANT BINARY_INTEGER := 2;
cGeoLocPOTypeNonApoFpo CONSTANT BINARY_INTEGER := 0;

/* GeoCoder City Record Type Codes */
cGeoLocCiRecTypeNA       CONSTANT BINARY_INTEGER := 0;
cGeoLocCiRecTypeActual   CONSTANT BINARY_INTEGER := 3;
cGeoLocCiRecTypeZipRange CONSTANT BINARY_INTEGER := 4;
cGeoLocCiRecTypeTwnshp   CONSTANT BINARY_INTEGER := 5;
cGeoLocCiRecTypeAlt      CONSTANT BINARY_INTEGER := 8;

cGeoErrCd20500 CONSTANT NUMBER := -20500;
cGeoErrMsg20500 CONSTANT VARCHAR2(100) := 'An invalid GeoCode level was provided.';

cGeoErrCd20501 CONSTANT NUMBER := -20501;
cGeoErrMsg20501 CONSTANT VARCHAR2(100) := 'An invalid city record type was provided.';

cGeoErrCd20000 CONSTANT NUMBER := -20000;
cGeoErrMsg20000 CONSTANT VARCHAR2(34) := 'An Oracle exception was raised in ';

/* ************************** Type Definitions ************************* */

/* Version information record type. */
TYPE tGeoVersionRecord IS RECORD (
    fVersionNumber VARCHAR2(19) := NULL,
    fReleaseDate   DATE         := NULL);

/* GeoCode search record type. */
TYPE tGeoSearchRecord IS RECORD (
    /* the query criteria */
    fGeoState           NUMBER(2),
    fGeoCounty          NUMBER(3),
    fGeoCity            NUMBER(4),
    fGeoLevel           BINARY_INTEGER,

    fStateAbbrev        VARCHAR2(2),
    fStateNamePrefix    BOOLEAN,
    fStateName          VARCHAR2(25),

    fCountyNamePrefix   BOOLEAN,
    fCountyName         VARCHAR2(20),

    fCityNamePrefix     BOOLEAN,
    fCityNameCompress   BOOLEAN,
    fCityName           VARCHAR2(25),

    fZipCodePrefix      BOOLEAN,
    fZipCode            VARCHAR2(6),

    fCityRecType        BINARY_INTEGER,

    fUseGeoLookup       BOOLEAN,

    fCursorIsOpen       BOOLEAN := NULL,

    fCursorId           INTEGER
    );

TYPE tGeoResultsRecord IS RECORD (
    /* the query results */
    fResGeoState            NUMBER(2),
    fResGeoCounty           NUMBER(3),
    fResGeoCity             NUMBER(4),

    fResStateName           CHAR(25),
    fResStateAbbrev         CHAR(2),

    fResCountyName          CHAR(20),
    fResCountyAbbrev        CHAR(5),

    fResCityName            CHAR(25),
    fResCityNameCompressed  CHAR(25),
    fResCityNameAbbrev      CHAR(6),
    fResCityNameType        BINARY_INTEGER,

    fResZipCodeStart        CHAR(6),
    fResZipCodeEnd          CHAR(6),

    fResApoFpoInd           BINARY_INTEGER
    );

/* ************** Procedure and Function Specifications *************** */
PROCEDURE GeoSetGeoCodeCriteria (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                 pGeoLevel      IN      BINARY_INTEGER,
                 pGeoState      IN      NUMBER,
                 pGeoCounty     IN      NUMBER,
                 pGeoCity       IN      NUMBER,
                 pCityRecType   IN      BINARY_INTEGER);

PROCEDURE GeoSetGeoCodeCriteria (pGeoSearchRec IN OUT  NOCOPY tGeoSearchRecord,
                 pGeoLevel      IN      BINARY_INTEGER,
                 pFullGeoCode   IN      NUMBER,
                 pCityRecType   IN      BINARY_INTEGER);

PROCEDURE GeoSetNameCriteria (pGeoSearchRec IN OUT  NOCOPY tGeoSearchRecord,
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
                 pCityRecType       IN      BINARY_INTEGER);

FUNCTION GeoRetrieveFirst (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                       pGeoResultsRec IN OUT NOCOPY tGeoResultsRecord) RETURN BOOLEAN;

FUNCTION GeoRetrieveNext (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord,
                       pGeoResultsRec IN OUT NOCOPY tGeoResultsRecord) RETURN BOOLEAN;

PROCEDURE GeoGetVersionInfo (pVersionRec OUT NOCOPY tGeoVersionRecord);

FUNCTION GeoGetLevel (pGeoCode IN NUMBER) RETURN BINARY_INTEGER;

FUNCTION GeoPackGeoCode (pGeoState IN NUMBER,
                        pGeoCounty IN NUMBER,
                        pGeoCity IN NUMBER) RETURN NUMBER;

PROCEDURE GeoUnPackGeoCode (pGeoState OUT NOCOPY NUMBER,
                        pGeoCounty OUT NOCOPY NUMBER,
                        pGeoCity OUT NOCOPY NUMBER,
                        pFullGeoCode IN NUMBER);

PROCEDURE GeoCloseSearch (pGeoSearchRec IN OUT NOCOPY tGeoSearchRecord);

FUNCTION GeoCompressCityName(pCompressCityStr IN VARCHAR2) RETURN VARCHAR2;

END ZX_TAX_VERTEX_GEO_STUB;

 

/
