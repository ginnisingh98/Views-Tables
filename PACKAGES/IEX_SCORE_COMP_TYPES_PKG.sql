--------------------------------------------------------
--  DDL for Package IEX_SCORE_COMP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_COMP_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: iextscts.pls 120.2 2004/11/05 21:35:07 jypark ship $ */
PROCEDURE INSERT_ROW (
  X_ROWID                   IN OUT NOCOPY VARCHAR2,
  P_SCORE_COMP_TYPE_ID      IN NUMBER,
  P_OBJECT_VERSION_NUMBER   IN NUMBER,
  P_SCORE_COMP_VALUE        IN VARCHAR2,
  P_ACTIVE_FLAG             IN VARCHAR2,
  P_SCORE_COMP_NAME         IN VARCHAR2,
  P_DESCRIPTION             IN VARCHAR2,
  P_CREATION_DATE           IN DATE,
  P_CREATED_BY              IN NUMBER,
  P_LAST_UPDATE_DATE        IN DATE,
  P_LAST_UPDATED_BY         IN NUMBER,
  P_LAST_UPDATE_LOGIN       IN NUMBER,
  P_JTF_OBJECT_CODE         IN VARCHAR2,
  P_FUNCTION_FLAG           IN VARCHAR2,
  P_METRIC_FLAG             IN VARCHAR2,
  P_DISPLAY_ORDER           IN NUMBER);

PROCEDURE LOCK_ROW (
  P_SCORE_COMP_TYPE_ID      IN NUMBER,
  P_OBJECT_VERSION_NUMBER   IN NUMBER,
  P_SCORE_COMP_VALUE        IN VARCHAR2,
  P_ACTIVE_FLAG             IN VARCHAR2,
  P_SCORE_COMP_NAME         IN VARCHAR2);

PROCEDURE UPDATE_ROW (
  P_SCORE_COMP_TYPE_ID      IN NUMBER,
  P_OBJECT_VERSION_NUMBER   IN NUMBER,
  P_SCORE_COMP_VALUE        IN VARCHAR2,
  P_ACTIVE_FLAG             IN VARCHAR2,
  P_SCORE_COMP_NAME         IN VARCHAR2,
  P_LAST_UPDATE_DATE        IN DATE,
  P_LAST_UPDATED_BY         IN NUMBER,
  P_LAST_UPDATE_LOGIN       IN NUMBER,
  P_DESCRIPTION             IN VARCHAR2,
  P_JTF_OBJECT_CODE         IN VARCHAR2,
  P_FUNCTION_FLAG           IN VARCHAR2,
  P_METRIC_FLAG             IN VARCHAR2,
  P_DISPLAY_ORDER           IN NUMBER);

PROCEDURE DELETE_ROW (P_SCORE_COMP_TYPE_ID IN NUMBER);

PROCEDURE ADD_LANGUAGE;

END IEX_SCORE_COMP_TYPES_PKG;

 

/