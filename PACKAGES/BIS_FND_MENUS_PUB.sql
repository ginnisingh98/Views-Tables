--------------------------------------------------------
--  DDL for Package BIS_FND_MENUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FND_MENUS_PUB" AUTHID CURRENT_USER as
/* $Header: BISPFMNS.pls 120.0 2005/06/01 18:09:38 appldev noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_FND_MENUS_PUB                                       --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--		  insert records in the FND tables.          		      --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  03/05/04   nbarik     Initial creation                                --
--  03/01/05   mdamle     Added LOCK_ROW, X_MENU_ID In/Out parameter      --
--                        Added validation								  --
--  19-MAY-2005  visuri   GSCC Issues bug 4363854                         --
----------------------------------------------------------------------------

TYPE Fnd_Menu_Rec_Type IS RECORD (
  menu_name			VARCHAR2(30),
  user_menu_name		VARCHAR2(80),
  type				VARCHAR2(30),
  description			VARCHAR2(240)
);

procedure INSERT_ROW (
 p_MENU_NAME 	in VARCHAR2
,p_USER_MENU_NAME 	in VARCHAR2
,p_TYPE 		in VARCHAR2 := NULL
,p_DESCRIPTION 		in VARCHAR2 := NULL
,x_MENU_ID 		in  OUT NOCOPY NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

procedure UPDATE_ROW (
 p_MENU_ID 			in NUMBER
,p_USER_MENU_NAME 		in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION 			in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,x_return_status        	OUT NOCOPY VARCHAR2
,x_msg_count            	OUT NOCOPY NUMBER
,x_msg_data             	OUT NOCOPY VARCHAR2
);

PROCEDURE DELETE_ROW (
 p_MENU_ID 			            in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 );

PROCEDURE DELETE_ROW_MENU_MENUENTRIES (
 p_MENU_ID 			in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 );

PROCEDURE LOCK_ROW
(  p_menu_id	                  IN         NUMBER
 , p_last_update_date		   	  IN		 DATE
);

END BIS_FND_MENUS_PUB;

 

/
