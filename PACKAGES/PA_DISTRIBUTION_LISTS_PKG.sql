--------------------------------------------------------
--  DDL for Package PA_DISTRIBUTION_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DISTRIBUTION_LISTS_PKG" AUTHID CURRENT_USER AS
 /* $Header: PATDSLHS.pls 120.1 2005/08/19 17:03:51 mwasowic noship $ */
procedure INSERT_ROW (
  P_LIST_ID 		in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  P_NAME 		in VARCHAR2,
  P_DESCRIPTION 	in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_CREATED_BY 		in NUMBER,
  P_CREATION_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) ;

procedure UPDATE_ROW (
  P_LIST_ID             in NUMBER,
  P_NAME                in VARCHAR2,
  P_DESCRIPTION         in VARCHAR2,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_LAST_UPDATED_BY     in NUMBER,
  P_LAST_UPDATE_DATE    in DATE,
  P_LAST_UPDATE_LOGIN   in NUMBER
) ;

procedure DELETE_ROW (
		      P_LIST_ID in NUMBER ) ;
END  PA_DISTRIBUTION_LISTS_PKG;

 

/
