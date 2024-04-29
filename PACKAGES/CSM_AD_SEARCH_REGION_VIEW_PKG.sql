--------------------------------------------------------
--  DDL for Package CSM_AD_SEARCH_REGION_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AD_SEARCH_REGION_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: csmlasrs.pls 120.0 2008/01/25 19:16:22 trajasek noship $ */
PROCEDURE INSERT_ROW (
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID      IN NUMBER,
                      X_LEVEL_VALUE   IN NUMBER,
                      X_NAME          IN VARCHAR2,
                      X_COLUMN_NAME   IN VARCHAR2,
                      X_FIELD_TYPE    IN VARCHAR2,
                      X_BASE_VO       IN VARCHAR2,
                      X_PARAMETERS    IN VARCHAR2,
                      X_VO_TEXT_COL   IN VARCHAR2,
                      X_VO_VALUE_COL  IN VARCHAR2,
                      X_DISPLAY_SEQ   IN NUMBER,
                      X_ORIGINAL_SEQ  IN NUMBER,
                      X_IS_REMOVED    IN VARCHAR2,
                      X_DB_TYPE       IN VARCHAR2,
                      X_OPERATION     IN VARCHAR2,
                      X_OWNER         IN VARCHAR2
                      );

PROCEDURE UPDATE_ROW (
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID      IN NUMBER,
                      X_LEVEL_VALUE   IN NUMBER,
                      X_NAME          IN VARCHAR2,
                      X_COLUMN_NAME   IN VARCHAR2,
                      X_FIELD_TYPE    IN VARCHAR2,
                      X_BASE_VO       IN VARCHAR2,
                      X_PARAMETERS    IN VARCHAR2,
                      X_VO_TEXT_COL   IN VARCHAR2,
                      X_VO_VALUE_COL  IN VARCHAR2,
                      X_DISPLAY_SEQ   IN NUMBER,
                      X_ORIGINAL_SEQ  IN NUMBER,
                      X_IS_REMOVED    IN VARCHAR2,
                      X_DB_TYPE       IN VARCHAR2,
                      X_OPERATION     IN VARCHAR2,
                      X_OWNER         IN VARCHAR2
                      );


PROCEDURE LOAD_ROW (
                    X_ID               IN NUMBER,
                    X_SEARCH_TYPE_ID   IN NUMBER,
                    X_LEVEL_ID      IN NUMBER,
                    X_LEVEL_VALUE   IN NUMBER,
                    X_NAME          IN VARCHAR2,
                    X_COLUMN_NAME   IN VARCHAR2,
                    X_FIELD_TYPE    IN VARCHAR2,
                    X_BASE_VO       IN VARCHAR2,
                    X_PARAMETERS    IN VARCHAR2,
                    X_VO_TEXT_COL   IN VARCHAR2,
                    X_VO_VALUE_COL  IN VARCHAR2,
                    X_DISPLAY_SEQ   IN NUMBER,
                    X_ORIGINAL_SEQ  IN NUMBER,
                    X_IS_REMOVED    IN VARCHAR2,
                    X_DB_TYPE       IN VARCHAR2,
                    X_OPERATION     IN VARCHAR2,
                    X_OWNER         IN VARCHAR2
                    );


END CSM_AD_SEARCH_REGION_VIEW_PKG;


/
