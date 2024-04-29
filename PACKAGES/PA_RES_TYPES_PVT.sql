--------------------------------------------------------
--  DDL for Package PA_RES_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_TYPES_PVT" AUTHID CURRENT_USER as
/* $Header: PARRTPVS.pls 120.0 2005/05/31 00:27:08 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_CODE             in VARCHAR2,
  P_ENABLED_FLAG              in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_CREATION_DATE             in DATE     ,
  P_CREATED_BY                in NUMBER   ,
  P_LAST_UPDATE_DATE          in DATE     ,
  P_LAST_UPDATED_BY           in NUMBER   ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) ;

procedure LOCK_ROW (
  P_RES_TYPE_ID                 in NUMBER
) ;

procedure UPDATE_ROW (
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_CODE             in VARCHAR2,
  P_ENABLED_FLAG              in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_LAST_UPDATE_DATE          in DATE     ,
  P_LAST_UPDATED_BY           in NUMBER   ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) ;

procedure DELETE_ROW (
  P_RES_TYPE_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_RES_TYPE_ID                 in NUMBER   ,
  P_OWNER                       in VARCHAR2 ,
  P_NAME                        in VARCHAR2 ,
  P_DESCRIPTION                 in VARCHAR2
);

procedure LOAD_ROW(
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_CODE             in VARCHAR2,
  P_ENABLED_FLAG              in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_OWNER                     in VARCHAR2
);

end PA_RES_TYPES_PVT;

 

/
