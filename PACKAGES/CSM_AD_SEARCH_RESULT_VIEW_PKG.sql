--------------------------------------------------------
--  DDL for Package CSM_AD_SEARCH_RESULT_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AD_SEARCH_RESULT_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: csmlasls.pls 120.1 2008/02/20 11:39:04 trajasek noship $ */

PROCEDURE INSERT_ROW (
                      X_ID               IN NUMBER,
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID         IN NUMBER,
                      X_LEVEL_VALUE      IN NUMBER,
                      X_HEADER           IN VARCHAR2,
                      X_COLUMN_NAME      IN VARCHAR2,
                      X_IS_MAIN          IN VARCHAR2,
                      X_IS_LINK          IN VARCHAR2,
                      X_DESTINATION      IN VARCHAR2,
                      X_PARAMETERS       IN VARCHAR2,
                      X_DISPLAY_SEQ      IN NUMBER,
                      X_ORIGINAL_SEQ     IN NUMBER,
                      X_IS_REMOVED       IN VARCHAR2,
                      X_OWNER            IN VARCHAR2
                      );

PROCEDURE UPDATE_ROW (
                      X_ID               IN NUMBER,
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID         IN NUMBER,
                      X_LEVEL_VALUE      IN NUMBER,
                      X_HEADER           IN VARCHAR2,
                      X_COLUMN_NAME      IN VARCHAR2,
                      X_IS_MAIN          IN VARCHAR2,
                      X_IS_LINK          IN VARCHAR2,
                      X_DESTINATION      IN VARCHAR2,
                      X_PARAMETERS       IN VARCHAR2,
                      X_DISPLAY_SEQ      IN NUMBER,
                      X_ORIGINAL_SEQ     IN NUMBER,
                      X_IS_REMOVED       IN VARCHAR2,
                      X_OWNER            IN VARCHAR2
                      );


PROCEDURE LOAD_ROW (
                     X_ID               IN NUMBER,
                     X_SEARCH_TYPE_ID   IN NUMBER,
                     X_LEVEL_ID         IN NUMBER,
                     X_LEVEL_VALUE      IN NUMBER,
                     X_HEADER           IN VARCHAR2,
                     X_COLUMN_NAME      IN VARCHAR2,
                     X_IS_MAIN          IN VARCHAR2,
                     X_IS_LINK          IN VARCHAR2,
                     X_DESTINATION      IN VARCHAR2,
                     X_PARAMETERS       IN VARCHAR2,
                     X_DISPLAY_SEQ      IN NUMBER,
                     X_ORIGINAL_SEQ     IN NUMBER,
                     X_IS_REMOVED       IN VARCHAR2,
                     X_OWNER            IN VARCHAR2
                      );

END CSM_AD_SEARCH_RESULT_VIEW_PKG;

/
