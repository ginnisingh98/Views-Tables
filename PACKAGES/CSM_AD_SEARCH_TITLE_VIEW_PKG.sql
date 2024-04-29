--------------------------------------------------------
--  DDL for Package CSM_AD_SEARCH_TITLE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_AD_SEARCH_TITLE_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: csmlasts.pls 120.1 2008/02/07 09:14:43 trajasek noship $ */
PROCEDURE INSERT_ROW (
                      X_SEARCH_TYPE    IN VARCHAR2,
                      X_LEVEL_ID       IN NUMBER,
                      X_LEVEL_VALUE    IN NUMBER,
                      X_SEARCH_TITLE   IN VARCHAR2,
                      X_VO_NAME        IN VARCHAR2,
                      X_SEARCH_TYPE_ID IN NUMBER,
                      X_OWNER          IN VARCHAR2
                      );

PROCEDURE UPDATE_ROW (
                      X_SEARCH_TYPE    IN VARCHAR2,
                      X_LEVEL_ID       IN NUMBER,
                      X_LEVEL_VALUE    IN NUMBER,
                      X_SEARCH_TITLE   IN VARCHAR2,
                      X_VO_NAME        IN VARCHAR2,
                      X_SEARCH_TYPE_ID IN NUMBER,
                      X_OWNER          IN VARCHAR2
                      );

PROCEDURE LOAD_ROW (
                     X_ID             IN NUMBER,
                     X_SEARCH_TYPE    IN VARCHAR2,
                     X_LEVEL_ID       IN NUMBER,
                     X_LEVEL_VALUE    IN NUMBER,
                     X_SEARCH_TITLE   IN VARCHAR2,
                     X_VO_NAME        IN VARCHAR2,
                     X_SEARCH_TYPE_ID IN NUMBER,
                     X_OWNER          IN VARCHAR2
                     );

END CSM_AD_SEARCH_TITLE_VIEW_PKG;

/
