--------------------------------------------------------
--  DDL for Package BIS_MENU_ENTRIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MENU_ENTRIES_PUB" AUTHID CURRENT_USER as
/* $Header: BISPMNES.pls 120.1 2005/11/03 01:26:55 rpenneru noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_MENU_ENTRIES_PUB                                    --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--		  insert records in the FND tables.          		      --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  12/25/03   mdamle     Added a generic routine to attach function to   --
--  			  menus   					  --
--  06/24/04   bewong	  Added a procedure to update the prompt of 	  --
-- 						  the function
--  07/14/04   ppalpart	  Added a procedures to delete roles     	      --
--  07/19/04   ppalpart	  Added a procedure to delete roles taking     	  --
--                        only Menu_Id                                    --
--  03/01/05   mdamle     Added UPDATE_ROW, LOCK_ROW                      --
--  11/03/05   rpenneru   Added SUBMIT_COMPILE                            --
----------------------------------------------------------------------------

procedure INSERT_ROW (
	  X_ROWID in out NOCOPY VARCHAR2,
	  X_USER_ID in NUMBER,
	  X_MENU_ID in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_PROMPT in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2);

procedure INSERT_ROW (
	  X_MENU_ID 			in NUMBER,
	  X_ENTRY_SEQUENCE 		in NUMBER,
	  X_SUB_MENU_ID 		in NUMBER,
	  X_FUNCTION_ID 		in NUMBER,
	  X_GRANT_FLAG			in VARCHAR2,
	  X_PROMPT 				in VARCHAR2,
	  X_DESCRIPTION			in VARCHAR2,
	  x_return_status       OUT NOCOPY VARCHAR2,
          x_msg_count           OUT NOCOPY NUMBER,
          x_msg_data            OUT NOCOPY VARCHAR2);

procedure UPDATE_ROW (
	  X_MENU_ID 			in NUMBER,
	  X_ENTRY_SEQUENCE 		in NUMBER,
	  X_SUB_MENU_ID 		in NUMBER,
	  X_FUNCTION_ID 		in NUMBER,
	  X_GRANT_FLAG			in VARCHAR2,
	  X_PROMPT 				in VARCHAR2,
	  X_DESCRIPTION			in VARCHAR2,
	  x_return_status       OUT NOCOPY VARCHAR2,
          x_msg_count           OUT NOCOPY NUMBER,
          x_msg_data            OUT NOCOPY VARCHAR2);

procedure UPDATE_PROMPT (
	  X_USER_ID in NUMBER,
	  X_MENU_ID in NUMBER,
	  X_OLD_ENTRY_SEQUENCE in NUMBER,
	  X_FUNCTION_ID in NUMBER,
	  X_PROMPT in VARCHAR2);

procedure DELETE_ROW (
	  X_MENU_ID              in         NUMBER,
	  X_ENTRY_SEQUENCE       in         NUMBER,
	  x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2);

procedure DELETE_ROW (
	  X_MENU_ID              in         NUMBER,
	  x_return_status        OUT NOCOPY VARCHAR2,
          x_msg_count            OUT NOCOPY NUMBER,
          x_msg_data             OUT NOCOPY VARCHAR2);

procedure AttachFunctionToMenus(
p_function_id           IN NUMBER
,p_menu_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

procedure AttachFunctionsToMenu(
 p_menu_id           IN NUMBER
,p_function_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

procedure DeleteFunctionsFromMenu(
 p_menu_id           IN NUMBER
,p_function_ids      IN FND_TABLE_OF_NUMBER
,x_return_status     OUT NOCOPY VARCHAR2
,x_msg_count         OUT NOCOPY NUMBER
,x_msg_data          OUT NOCOPY VARCHAR2
);

procedure DeleteFunctionFromMenus(
p_function_id           IN NUMBER
,p_menu_ids    		IN FND_TABLE_OF_NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE LOCK_ROW
(  p_menu_id	                  IN         NUMBER
 , p_entry_sequence			      IN 		 NUMBER
 , p_last_update_date		   	  IN		 DATE
);

FUNCTION submit_compile RETURN VARCHAR2;

END BIS_MENU_ENTRIES_PUB;

 

/
