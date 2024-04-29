--------------------------------------------------------
--  DDL for Package PA_OBJECT_DIST_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OBJECT_DIST_LISTS_PKG" AUTHID CURRENT_USER AS
 /* $Header: PATODLHS.pls 115.0 2002/04/09 10:42:48 pkm ship        $ */
procedure INSERT_ROW (
  P_LIST_ID 		in NUMBER,
  P_OBJECT_TYPE 	in VARCHAR2,
  P_OBJECT_ID 	        in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) ;

procedure UPDATE_ROW (
  P_LIST_ID             in NUMBER,
  P_OBJECT_TYPE         in VARCHAR2,
  P_OBJECT_ID           in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) ;

procedure DELETE_ROW (
		      P_LIST_ID     in NUMBER,
  		      P_OBJECT_TYPE in VARCHAR2,
  		      P_OBJECT_ID   in NUMBER
                      ) ;
END  PA_OBJECT_DIST_LISTS_PKG;

 

/
