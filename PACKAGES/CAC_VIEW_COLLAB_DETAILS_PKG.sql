--------------------------------------------------------
--  DDL for Package CAC_VIEW_COLLAB_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_COLLAB_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfcvcds.pls 115.2 2004/06/29 20:29:26 cijang noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);


procedure LOCK_ROW (
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2
);
procedure UPDATE_ROW (
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_COLLAB_ID in NUMBER
);
procedure ADD_LANGUAGE;


END; -- Package spec

 

/