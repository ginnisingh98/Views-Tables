--------------------------------------------------------
--  DDL for Package CS_PARTY_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_PARTY_ROLES_PKG" AUTHID CURRENT_USER as
/* $Header: csxptyrs.pls 120.0 2005/08/18 19:25 aneemuch noship $ */

procedure INSERT_ROW (
  PX_PARTY_ROLE_CODE in out NOCOPY VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_SEEDED_FLAG in VARCHAR2,
  P_SORT_ORDER in NUMBER  ,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
);

procedure UPDATE_ROW (
  P_PARTY_ROLE_CODE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_SEEDED_FLAG in VARCHAR2,
  P_SORT_ORDER in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER
);

procedure DELETE_ROW (
  P_PARTY_ROLE_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  P_PARTY_ROLE_CODE            IN VARCHAR2,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_SORT_ORDER                 IN VARCHAR2,
  P_NAME                       IN VARCHAR2,
  P_DESCRIPTION                IN VARCHAR2,
  P_OWNER                      IN VARCHAR2,
  P_CREATION_DATE              IN VARCHAR2,
  P_CREATED_BY                 IN NUMBER,
  P_LAST_UPDATE_DATE           IN VARCHAR2,
  P_LAST_UPDATED_BY            IN NUMBER,
  P_LAST_UPDATE_LOGIN          IN NUMBER,
  P_OBJECT_VERSION_NUMBER      IN NUMBER );

procedure TRANSLATE_ROW ( X_PARTY_ROLE_CODE  in  varchar2,
                          X_NAME in varchar2,
                          X_DESCRIPTION  in varchar2,
                          X_LAST_UPDATE_DATE in date,
                          X_LAST_UPDATE_LOGIN in number,
                          X_OWNER in varchar2);

end CS_PARTY_ROLES_PKG;

 

/
