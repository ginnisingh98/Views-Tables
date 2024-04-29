--------------------------------------------------------
--  DDL for Package CLN_CH_DISPLAY_LABELS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_CH_DISPLAY_LABELS_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: ECXDISLS.pls 120.0 2005/08/25 04:45:12 nparihar noship $ */
--
--  Package
--    CLN_CH_DISPLAY_LABELS_DTL_PKG
--
--  Purpose
--    Spec of package CLN_CH_DISPLAY_LABELS_DTL_PKG
--  This package is used for downloading/uploading the display labels data into the database
--  History
--

PROCEDURE TRANSLATE_ROW
  (
   X_GUID                IN RAW,
   X_OWNER               IN VARCHAR2,
   X_DISPLAY_LABEL       IN VARCHAR2
   ) ;

PROCEDURE LOAD_ROW
  (
   X_GUID            IN RAW ,
   X_OWNER                      IN VARCHAR2,
   X_PARENT_GUID         IN RAW,
   X_CLN_COLUMNS         IN VARCHAR2,
   X_DISPLAY_LABEL       IN VARCHAR2,
   X_SEARCH_ENABLED      IN VARCHAR2,
   X_DISPLAY_ENABLED_EVENTS_SCR IN VARCHAR2,
   X_DISPLAY_ENABLED_RESULTS_TBL IN VARCHAR2
  ) ;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2
);

procedure UPDATE_ROW (
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_GUID in RAW
);

procedure ADD_LANGUAGE;

end CLN_CH_DISPLAY_LABELS_DTL_PKG;

 

/
