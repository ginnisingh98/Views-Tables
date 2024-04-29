--------------------------------------------------------
--  DDL for Package PA_DIST_LIST_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DIST_LIST_DENORM_PKG" AUTHID CURRENT_USER AS
 /* $Header: PATDLDHS.pls 115.0 2002/04/09 10:41:34 pkm ship        $ */
procedure INSERT_ROW (
  P_LIST_ID 		in NUMBER,
  P_RESOURCE_TYPE_ID	in NUMBER,
  P_RESOURCE_SOURCE_ID	in NUMBER,
  P_ACCESS_LEVEL 	in NUMBER,
  P_MENU_ID 		in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) ;

procedure UPDATE_ROW (
  P_LIST_ID             in NUMBER,
  P_RESOURCE_TYPE_ID    in NUMBER,
  P_RESOURCE_SOURCE_ID  in NUMBER,
  P_ACCESS_LEVEL        in NUMBER,
  P_MENU_ID             in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) ;

procedure DELETE_ROW (
  P_LIST_ID             in NUMBER,
  P_RESOURCE_TYPE_ID    in NUMBER,
  P_RESOURCE_SOURCE_ID  in NUMBER
) ;

END  PA_DIST_LIST_DENORM_PKG;

 

/
