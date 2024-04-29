--------------------------------------------------------
--  DDL for Package PN_SET_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SET_TYPES_PKG" AUTHID CURRENT_USER As
  -- $Header: PNTSTTYS.pls 115.11 2002/11/12 23:11:49 stripath ship $

procedure INSERT_ROW (
                       X_ROWID             in out NOCOPY VARCHAR2,
                       X_SET_ID            in out NOCOPY NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2,
                       X_CREATION_DATE     in DATE,
                       X_CREATED_BY        in NUMBER,
                       X_LAST_UPDATE_DATE  in DATE,
                       X_LAST_UPDATED_BY   in NUMBER,
                       X_LAST_UPDATE_LOGIN in NUMBER
                     );

procedure LOCK_ROW   (
                       X_SET_ID            in NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2
                     );

procedure UPDATE_ROW (
                       X_SET_ID            in NUMBER,
                       X_SET_NAME          in VARCHAR2,
                       X_DESCRIPTION       in VARCHAR2,
                       X_LAST_UPDATE_DATE  in DATE,
                       X_LAST_UPDATED_BY   in NUMBER,
                       X_LAST_UPDATE_LOGIN in NUMBER
                     );

procedure DELETE_ROW (
                       X_SET_ID in NUMBER
                     );

procedure ADD_LANGUAGE;

end PN_SET_TYPES_PKG;

 

/
