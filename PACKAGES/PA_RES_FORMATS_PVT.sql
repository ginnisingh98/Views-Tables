--------------------------------------------------------
--  DDL for Package PA_RES_FORMATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_FORMATS_PVT" AUTHID CURRENT_USER as
/* $Header: PARFMTVS.pls 120.0 2005/05/29 12:04:43 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID,
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_CREATION_DATE             in DATE    ,
  P_CREATED_BY                in NUMBER  ,
  P_LAST_UPDATE_DATE          in DATE    ,
  P_LAST_UPDATED_BY           in NUMBER  ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) ;

procedure LOCK_ROW (
  P_RES_FORMAT_ID             in NUMBER
) ;

procedure UPDATE_ROW (
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_LAST_UPDATE_DATE          in DATE     ,
  P_LAST_UPDATED_BY           in NUMBER   ,
  P_LAST_UPDATE_LOGIN         in NUMBER
) ;

procedure DELETE_ROW (
  P_RES_FORMAT_ID             in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  P_RES_FORMAT_ID             in NUMBER   ,
  P_OWNER                     in VARCHAR2 ,
  P_NAME                      in VARCHAR2 ,
  P_DESCRIPTION               in VARCHAR2
);

procedure LOAD_ROW(
  P_RES_FORMAT_ID             in NUMBER,
  P_RESOURCE_FORMAT_SEQ       in NUMBER,
  P_RESOURCE_CLASS_ID         in NUMBER,
  P_RES_TYPE_ID               in NUMBER,
  P_RES_TYPE_ENABLED_FLAG     in VARCHAR2,
  P_RESOURCE_TYPE_DISP_CHARS  in NUMBER,
  P_ORGN_ENABLED_FLAG         in VARCHAR2,
  P_ORGN_DISP_CHARS           in NUMBER,
  P_FIN_CAT_ENABLED_FLAG      in VARCHAR2,
  P_FIN_CAT_DISP_CHARS        in NUMBER,
  P_INCURRED_BY_ENABLED_FLAG  in VARCHAR2,
  P_INCURRED_BY_DISP_CHARS    in NUMBER,
  P_SUPPLIER_ENABLED_FLAG     in VARCHAR2,
  P_SUPPLIER_DISP_CHARS       in NUMBER,
  P_ROLE_ENABLED_FLAG         in VARCHAR2,
  P_ROLE_DISP_CHARS           in NUMBER,
  P_RESOURCE_CLASS_FLAG       in VARCHAR2,
  P_NAME                      in VARCHAR2,
  P_DESCRIPTION               in VARCHAR2,
  P_OWNER                     in VARCHAR2
);

end pa_res_formats_pvt;

 

/
