--------------------------------------------------------
--  DDL for Package FND_EID_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_INSTANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: fndeidinsts.pls 120.0.12010000.1 2012/07/06 06:21:34 rnagaraj noship $ */

procedure DELETE_ROW( X_EID_INSTANCE_ID in NUMBER);


procedure LOAD_ROW(
        X_EID_INSTANCE_ID                  IN  VARCHAR2,
        X_APPLICATION_ID                   IN  VARCHAR2,
        X_EID_DATA_STORE_NAME              IN  VARCHAR2,
        X_EID_RELEASE_VERSION              IN  VARCHAR2,
        X_ENBL_WILDCARD_VAL_SRCH    IN  VARCHAR2,
        X_CONFIG_MERGE_POLICY       IN  VARCHAR2,
        X_CONFIG_SEARCH_CHARS       IN  VARCHAR2,
        X_MIN_OCCRNCS_INDXNG_SPL_STD   IN  VARCHAR2,
        X_MIN_INDXNG_SPL_CRCTN_STD   IN  VARCHAR2,
        X_MAX_INDXNG_SPL_CRCTN_STD   IN  VARCHAR2,
        X_MIN_OCCRNCS_INDXNG_SPL_MGD   IN  VARCHAR2,
        X_MIN_INDXNG_SPL_CRCTN_MGD   IN  VARCHAR2,
        X_MAX_INDXNG_SPL_CRCTN_MGD   IN  VARCHAR2,
        X_ENDECA_SERVER_PORT               IN  VARCHAR2,
        X_ENDECA_SERVER_HOST               IN  VARCHAR2,
        X_LAST_UPDATE_DATE                 IN  VARCHAR2,
        X_APPLICATION_SHORT_NAME           IN  VARCHAR2,
        X_OWNER                            IN  VARCHAR2
	);

end FND_EID_INSTANCE_PKG;

/
