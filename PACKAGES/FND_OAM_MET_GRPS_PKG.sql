--------------------------------------------------------
--  DDL for Package FND_OAM_MET_GRPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_MET_GRPS_PKG" AUTHID CURRENT_USER AS
  /* $Header: AFOAMMGS.pls 120.2 2005/10/19 11:27:55 ilawler noship $ */
  procedure LOAD_ROW (
    X_METRIC_GROUP_ID     in  VARCHAR2,
    X_SEQUENCE            in    VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2);

  procedure LOAD_ROW (
    X_METRIC_GROUP_ID     in  VARCHAR2,
    X_SEQUENCE            in    VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2);

  procedure TRANSLATE_ROW (
    X_METRIC_GROUP_ID             in    VARCHAR2,
    X_OWNER                     in      VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2);

  procedure TRANSLATE_ROW (
    X_METRIC_GROUP_ID       in  VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2,
    X_CUSTOM_MODE               in      VARCHAR2,
    X_LAST_UPDATE_DATE  in      VARCHAR2);

  procedure INSERT_ROW (
    X_ROWID             IN OUT NOCOPY   VARCHAR2,
    X_METRIC_GROUP_ID   in      NUMBER,
    X_SEQUENCE  in      VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION       in      VARCHAR2,
    X_CREATED_BY                in      NUMBER,
    X_CREATION_DATE     in      DATE,
    X_LAST_UPDATED_BY   in      NUMBER,
    X_LAST_UPDATE_DATE  in      DATE,
    X_LAST_UPDATE_LOGIN         in      NUMBER);

  procedure UPDATE_ROW (
    X_METRIC_GROUP_ID in NUMBER,
    X_SEQUENCE in NUMBER,
    X_METRIC_GROUP_DISPLAY_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_LAST_UPDATED_BY in NUMBER,
    X_LAST_UPDATE_LOGIN in NUMBER);

  procedure DELETE_ROW (
    X_METRIC_GROUP_ID in NUMBER);

  procedure ADD_LANGUAGE;

END fnd_oam_met_grps_pkg;

 

/
