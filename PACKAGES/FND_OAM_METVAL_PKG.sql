--------------------------------------------------------
--  DDL for Package FND_OAM_METVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_METVAL_PKG" AUTHID CURRENT_USER AS
  /* $Header: AFOAMMTS.pls 120.2 2005/10/19 11:12:12 ilawler noship $ */
  procedure LOAD_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_METRIC_VALUE          in  VARCHAR2,
    X_STATUS_CODE           in  VARCHAR2,
    X_GROUP_ID              in  VARCHAR2,
    X_SEQUENCE              in  VARCHAR2,
    X_NODE_NAME             in  VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  VARCHAR2,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2);

  procedure LOAD_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_METRIC_VALUE          in  VARCHAR2,
    X_STATUS_CODE           in  VARCHAR2,
    X_GROUP_ID              in  VARCHAR2,
    X_SEQUENCE              in  VARCHAR2,
    X_NODE_NAME             in  VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  VARCHAR2,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2,
    x_custom_mode           in  varchar2,
    x_last_update_date      in  varchar2);

  procedure TRANSLATE_ROW (
    X_METRIC_SHORT_NAME         in      VARCHAR2,
    X_OWNER                     in      VARCHAR2,
    X_METRIC_DISPLAY_NAME             in        VARCHAR2,
    X_DESCRIPTION                           in  VARCHAR2);

  procedure TRANSLATE_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2,
    X_CUSTOM_MODE                       in      VARCHAR2,
    X_LAST_UPDATE_DATE      in  VARCHAR2);


  procedure INSERT_ROW (
    X_ROWID             IN OUT NOCOPY   VARCHAR2,
    X_METRIC_SHORT_NAME in VARCHAR2,
    X_METRIC_VALUE in VARCHAR2,
    X_STATUS_CODE in NUMBER,
    X_GROUP_ID in NUMBER,
    X_SEQUENCE  in      VARCHAR2,
    X_NODE_NAME in VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  DATE,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  NUMBER,
    X_METRIC_DISPLAY_NAME       in      VARCHAR2,
    X_DESCRIPTION       in      VARCHAR2,
    X_CREATED_BY                in      NUMBER,
    X_CREATION_DATE     in      DATE,
    X_LAST_UPDATED_BY   in      NUMBER,
    X_LAST_UPDATE_DATE  in      DATE,
    X_LAST_UPDATE_LOGIN         in      NUMBER);

  procedure UPDATE_ROW (
    X_METRIC_SHORT_NAME in VARCHAR2,
    X_METRIC_VALUE in VARCHAR2,
    X_STATUS_CODE in NUMBER,
    X_GROUP_ID in NUMBER,
    X_SEQUENCE in NUMBER,
    X_NODE_NAME in VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  DATE,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  NUMBER,
    X_METRIC_DISPLAY_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_LAST_UPDATED_BY in NUMBER,
    X_LAST_UPDATE_LOGIN in NUMBER);

  procedure DELETE_ROW (
    X_METRIC_SHORT_NAME in VARCHAR2);

  procedure ADD_LANGUAGE;

END fnd_oam_metval_pkg;

 

/
