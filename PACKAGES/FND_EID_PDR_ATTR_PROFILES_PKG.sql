--------------------------------------------------------
--  DDL for Package FND_EID_PDR_ATTR_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_PDR_ATTR_PROFILES_PKG" AUTHID CURRENT_USER AS
/* $Header: fndeidattprofs.pls 120.0.12010000.1 2012/07/06 06:28:20 rnagaraj noship $ */

procedure DELETE_ROW( X_EID_ATTR_PROFILE_ID in NUMBER);


procedure LOAD_ROW(
     X_EID_ATTR_PROFILE_ID             IN VARCHAR2,
     X_EID_ATTR_PROFILE_CODE           IN VARCHAR2,
     X_RANKING_TYPE_CODE               IN VARCHAR2,
     X_SELECT_TYPE_CODE                IN VARCHAR2,
     X_SHOW_RECORD_COUNTS_FLAG         IN VARCHAR2,
     X_VALUE_SEARCHABLE_FLAG           IN VARCHAR2,
     X_TEXT_SEARCHABLE_FLAG            IN VARCHAR2,
     X_SNIPPET_SIZE                    IN VARCHAR2,
     X_UNIQUE_FLAG                     IN VARCHAR2,
     X_SINGLE_ASSIGN_FLAG              IN VARCHAR2,
     X_SEARCH_ALLOWS_WILDCARDS_FLAG    IN VARCHAR2,
     X_NAVIGATION_SORT_FLAG            IN VARCHAR2,
     X_LAST_UPDATE_DATE                IN VARCHAR2,
     X_APPLICATION_SHORT_NAME          IN VARCHAR2,
     X_OWNER                           IN VARCHAR2
	);

end FND_EID_PDR_ATTR_PROFILES_PKG;

/
