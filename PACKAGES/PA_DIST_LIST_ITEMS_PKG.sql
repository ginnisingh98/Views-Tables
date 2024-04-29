--------------------------------------------------------
--  DDL for Package PA_DIST_LIST_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DIST_LIST_ITEMS_PKG" AUTHID CURRENT_USER AS
 /* $Header: PATDLIHS.pls 120.1 2005/08/19 17:03:35 mwasowic noship $ */

procedure INSERT_ROW (
  P_LIST_ITEM_ID 	in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_LIST_ID 		in NUMBER,
  P_RECIPIENT_TYPE 	in VARCHAR2,
  P_RECIPIENT_ID 	in VARCHAR2,
  P_ACCESS_LEVEL 	in NUMBER,
  P_MENU_ID 		in NUMBER,
  P_EMAIL           in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) ;

procedure UPDATE_ROW (
  P_LIST_ITEM_ID        in NUMBER,
  P_LIST_ID             in NUMBER,
  P_RECIPIENT_TYPE      in VARCHAR2,
  P_RECIPIENT_ID        in VARCHAR2,
  P_ACCESS_LEVEL        in NUMBER,
  P_MENU_ID             in NUMBER,
  P_EMAIL               in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) ;

procedure DELETE_ROW (
		      P_LIST_ITEM_ID in NUMBER ) ;
END  PA_DIST_LIST_ITEMS_PKG;

 

/
