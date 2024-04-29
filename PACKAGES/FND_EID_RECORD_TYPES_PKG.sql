--------------------------------------------------------
--  DDL for Package FND_EID_RECORD_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_RECORD_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: fndeidrectyps.pls 120.0.12010000.1 2012/07/06 06:18:02 rnagaraj noship $ */

procedure DELETE_ROW( X_EID_INSTANCE_ID in NUMBER);

procedure LOAD_ROW(
  X_EID_INSTANCE_ID               IN     VARCHAR2,
  X_RECORD_TYPE                   IN     VARCHAR2,
  X_VIEW_NAME                     IN     VARCHAR2,
  X_EID_FULL_LOAD_ETL_GRAPH       IN     VARCHAR2,
  X_EID_INCR_LOAD_ETL_GRAPH       IN     VARCHAR2,
  X_EID_DELETE_ETL_GRAPH          IN     VARCHAR2,
  X_EID_RELEASE_VERSION           IN     VARCHAR2,
  X_OBSOLETED_FLAG                IN     VARCHAR2,
  X_OBSOLETED_EID_RELEASE_VER     IN     VARCHAR2,
  X_LAST_UPDATE_DATE              IN     VARCHAR2,
  X_APPLICATION_SHORT_NAME        IN     VARCHAR2,
  X_OWNER                         IN     VARCHAR2
	);

end FND_EID_RECORD_TYPES_PKG;

/
