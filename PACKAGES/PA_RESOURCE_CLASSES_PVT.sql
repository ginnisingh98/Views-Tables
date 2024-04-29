--------------------------------------------------------
--  DDL for Package PA_RESOURCE_CLASSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_CLASSES_PVT" AUTHID CURRENT_USER as
/* $Header: PARRCLVS.pls 120.0 2005/05/29 18:38:03 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                           in out NOCOPY ROWID,
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_CREATION_DATE                   in DATE     ,
  P_CREATED_BY                      in NUMBER   ,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) ;

procedure LOCK_ROW (
  P_RESOURCE_CLASS_ID                 in NUMBER
) ;

procedure UPDATE_ROW (
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_LAST_UPDATE_DATE                in DATE     ,
  P_LAST_UPDATED_BY                 in NUMBER   ,
  P_LAST_UPDATE_LOGIN               in NUMBER
) ;

procedure DELETE_ROW (
  P_RESOURCE_CLASS_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_RESOURCE_CLASS_ID                 in NUMBER   ,
  P_OWNER                             in VARCHAR2 ,
  P_NAME                              in VARCHAR2 ,
  P_DESCRIPTION                       in VARCHAR2
);

procedure LOAD_ROW(
  P_RESOURCE_CLASS_ID               in NUMBER,
  P_RESOURCE_CLASS_CODE             in VARCHAR2,
  P_RESOURCE_CLASS_SEQ              in NUMBER,
  P_NAME                            in VARCHAR2,
  P_DESCRIPTION                     in VARCHAR2,
  P_OWNER                           in VARCHAR2
);

end PA_RESOURCE_CLASSES_PVT;

 

/
