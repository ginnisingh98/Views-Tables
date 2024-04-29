--------------------------------------------------------
--  DDL for Package BSC_TABS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_TABS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCTABS.pls 115.8 2003/02/12 14:29:51 adeulgao ship $ */


PROCEDURE TRANSLATE_ROW
(
    X_SHORT_NAME              IN VARCHAR2,
    X_NAME                    IN VARCHAR2,
    X_HELP                    IN VARCHAR2,
    X_ADDITIONAL_INFO         IN VARCHAR2
);

PROCEDURE INSERT_ROW
(
    X_ROWID 		in out NOCOPY VARCHAR2,
    X_TAB_ID            IN      NUMBER,
    X_KPI_MODEL         IN      NUMBER,
    X_BSC_MODEL         IN      NUMBER,
    X_CROSS_MODEL       IN      NUMBER,
    X_DEFAULT_MODEL     IN      NUMBER,
    X_ZOOM_FACTOR       IN      NUMBER,
    X_CREATED_BY        IN      NUMBER,
    X_LAST_UPDATED_BY   IN      NUMBER,
    X_LAST_UPDATE_LOGIN IN      NUMBER DEFAULT 0 ,
    X_PARENT_TAB_ID     IN      NUMBER,
    X_OWNER_ID          IN      NUMBER,
    X_SHORT_NAME        IN      VARCHAR2,
    X_NAME              IN      VARCHAR2,
    X_HELP              IN      VARCHAR2,
    X_ADDITIONAL_INFO   IN      VARCHAR2
);

procedure LOCK_ROW (
  X_TAB_ID in NUMBER,
  X_KPI_MODEL in NUMBER,
  X_BSC_MODEL in NUMBER,
  X_CROSS_MODEL in NUMBER,
  X_DEFAULT_MODEL in NUMBER,
  X_ZOOM_FACTOR in NUMBER,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
);
PROCEDURE UPDATE_ROW
(
    X_TAB_ID                  IN NUMBER,
    X_SHORT_NAME              IN VARCHAR2,
    X_KPI_MODEL               IN NUMBER,
    X_BSC_MODEL               IN NUMBER,
    X_CROSS_MODEL             IN NUMBER,
    X_DEFAULT_MODEL           IN NUMBER,
    X_ZOOM_FACTOR             IN NUMBER,
    X_TAB_INDEX               IN NUMBER,
    X_PARENT_TAB_ID           IN NUMBER,
    X_OWNER_ID                IN NUMBER,
    X_LAST_UPDATE_DATE        IN DATE DEFAULT SYSDATE,
    X_LAST_UPDATED_BY         IN NUMBER,
    X_NAME                    IN VARCHAR2,
    X_HELP                    IN VARCHAR2,
    X_LAST_UPDATE_LOGIN       IN NUMBER,
    X_ADDITIONAL_INFO         IN VARCHAR2
);
procedure DELETE_ROW (
  X_TAB_ID in NUMBER
);
procedure ADD_LANGUAGE;
end BSC_TABS_PKG;

 

/
