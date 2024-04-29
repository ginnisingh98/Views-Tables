--------------------------------------------------------
--  DDL for Package BSC_LAUNCH_PAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_LAUNCH_PAD_PUB" AUTHID CURRENT_USER as
/* $Header: BSCCVDEFS.pls 115.4 2004/01/09 14:48:03 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCCVDEFS.pls                                                               |
 |                                                                                      |
 | Creation Date:                                                                       |
 |          October 22, 2003                                                            |
 |                                                                                      |
 | Creator:                                                                             |
 |          ashankar                                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |          Public specs for package.                                                   |
 |          																            |
 +======================================================================================+
*/

TYPE Bsc_LauchPad_Rec_Type is RECORD(

   Bsc_menu_id               FND_MENUS_VL.menu_id%TYPE
  ,Bsc_menu_name             FND_MENUS_VL.menu_name%TYPE
  ,Bsc_type                  FND_MENUS_VL.type%TYPE
  ,Bsc_last_update_date      FND_MENUS_VL.last_update_date%TYPE
  ,Bsc_last_updated_by       FND_MENUS_VL.last_updated_by%TYPE
  ,Bsc_last_update_login     FND_MENUS_VL.last_update_login%TYPE
  ,Bsc_user_menu_name        FND_MENUS_VL.user_menu_name%TYPE
  ,Bsc_description           FND_MENUS_VL.description%TYPE
);

TYPE Bsc_LauchPad_Tbl_Type IS TABLE OF Bsc_LauchPad_Rec_Type
INDEX BY BINARY_INTEGER;

FUNCTION Is_More
(       p_fucntion_ids   IN  OUT NOCOPY  VARCHAR2
    ,   p_fucntion_id        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;


FUNCTION validate_Menu_UserMenu_Names(
	 p_menu_id                 IN       NUMBER
	,p_menu_name               IN		VARCHAR2
	,p_user_menu_name 		   IN		VARCHAR2
)RETURN VARCHAR2;


FUNCTION validate_Function_Names(
	 p_function_id             IN       NUMBER
	,p_fucntion_name           IN		VARCHAR2
	,p_user_function_name	   IN		VARCHAR2
)RETURN VARCHAR2;



FUNCTION get_Menu_Id_From_Menu_Name(
	p_Menu_Name     IN     FND_MENUS.MENU_NAME%TYPE
)RETURN NUMBER;


FUNCTION get_Menu_Name_From_Menu_Id(
	p_Menu_Id     IN     FND_MENUS.MENU_ID%TYPE
)RETURN VARCHAR2;


SEQ_MULTIPLIER CONSTANT NUMBER :=10;

/******************************************************************
		                CREATE LAUNCHPAD
/******************************************************************/
PROCEDURE Create_Launch_Pad
(
   p_commit                		IN              VARCHAR2   := FND_API.G_FALSE
  ,p_menu_name 					IN 				VARCHAR2   := NULL
  ,p_user_menu_name 			IN 				VARCHAR2
  ,p_menu_type    				IN 				VARCHAR2   :='UNKNOWN'
  ,p_description 				IN 				VARCHAR2
  ,p_fucntion_ids               IN              VARCHAR2
  ,p_fucntions_order           	IN              VARCHAR2   := NULL
  ,x_return_status         		OUT    NOCOPY   VARCHAR2
  ,x_msg_count             		OUT    NOCOPY   NUMBER
  ,x_msg_data              		OUT    NOCOPY   VARCHAR2
) ;

/*****************************************************************
                  		RETRIEVE LAUNCHPAD
/*****************************************************************/

PROCEDURE Retrieve_Launch_Pad
(
  	 p_menu_id					IN              NUMBER
	,x_launch_pad_Rec           IN OUT NOCOPY   BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type
	,x_return_status         	OUT    NOCOPY   VARCHAR2
	,x_msg_count             	OUT    NOCOPY   NUMBER
    ,x_msg_data              	OUT    NOCOPY   VARCHAR2

);
/****************************************************************
                    	UPDATE LAUNCHPAD
/****************************************************************/
PROCEDURE Update_Launch_Pad
(
   p_launch_pad_rec             IN 				BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type
  ,x_return_status         		OUT    NOCOPY   VARCHAR2
  ,x_msg_count             		OUT    NOCOPY   NUMBER
  ,x_msg_data              		OUT    NOCOPY   VARCHAR2
);

/***************************************************************
                     UPDATE LAUNCHPAD CALLED FROM UI
/***************************************************************/
PROCEDURE Update_Launch_Pad
(
   p_commit                		IN              VARCHAR2	:= FND_API.G_FALSE
  ,p_menu_id					IN              NUMBER
  ,p_menu_name 					IN 				VARCHAR2	:= NULL
  ,p_user_menu_name 			IN 				VARCHAR2
  ,p_menu_type    				IN 				VARCHAR2
  ,p_description 				IN 				VARCHAR2
  ,p_fucntion_ids               IN              VARCHAR2
  ,p_fucntions_order           	IN              VARCHAR2	:= NULL
  ,x_return_status         		OUT    NOCOPY   VARCHAR2
  ,x_msg_count             		OUT    NOCOPY   NUMBER
  ,x_msg_data              		OUT    NOCOPY   VARCHAR2
);


/****************************************************************
	                     DELETE LAUNCHPAD
/****************************************************************/

PROCEDURE Delete_Launch_Pad
(
	 p_menu_id 				IN				NUMBER
	,x_return_status    	OUT    NOCOPY   VARCHAR2
	,x_msg_count        	OUT    NOCOPY   NUMBER
  	,x_msg_data         	OUT    NOCOPY   VARCHAR2
);


/*****************************************************************
                  	DELETE LAUNCHPAD LINK ASSOCIATION
/****************************************************************/
PROCEDURE Delete_MenuFunction_Link
(
	 p_menu_id				IN     		NUMBER
	,x_return_status        OUT NOCOPY  VARCHAR2
	,x_msg_count          	OUT NOCOPY  NUMBER
  	,x_msg_data            	OUT NOCOPY  VARCHAR2
);

/*****************************************************************
                  	CREATE MENU FUCNTION LINK
/*****************************************************************/
PROCEDURE Create_MenuFunction_Link
(

	  p_menu_id                  IN			 NUMBER
	, p_entry_sequence           IN			 NUMBER
	, p_function_id 			 IN 		 NUMBER
	, p_description 			 IN 		 VARCHAR2
	, x_return_status           OUT NOCOPY   VARCHAR2
	, x_msg_count             	OUT NOCOPY   NUMBER
  	, x_msg_data              	OUT NOCOPY   VARCHAR2

);

/*****************************************************************
                  		CREATE LAUNCHPAD
/*****************************************************************/

PROCEDURE Create_Launch_Pad_Link
(
	   p_commit               	IN              VARCHAR2   := FND_API.G_FALSE
	 , p_user_function_name 	IN 				VARCHAR2
	 , p_url					IN				VARCHAR2
	 , p_type 					IN				VARCHAR2 :='WWW'
	 , x_function_id            OUT    NOCOPY   FND_FORM_FUNCTIONS.function_id%	TYPE
	 , x_return_status         	OUT    NOCOPY   VARCHAR2
	 , x_msg_count             	OUT    NOCOPY   NUMBER
	 , x_msg_data              	OUT    NOCOPY   VARCHAR2
) ;

/*****************************************************************
                 		DELETE LAUCHPAD LINK
/*****************************************************************/

PROCEDURE Delete_Launch_Pad_Link
(
       p_fucntion_id            IN     FND_FORM_FUNCTIONS.function_id%TYPE
	 , x_return_status         	OUT    NOCOPY   VARCHAR2
	 , x_msg_count             	OUT    NOCOPY   NUMBER
     , x_msg_data              	OUT    NOCOPY   VARCHAR2
);

PROCEDURE Update_Launch_Pad_Link
(
   p_commit                 IN              VARCHAR2   := FND_API.G_FALSE
 , p_user_function_name     IN              VARCHAR2
 , p_url                    IN              VARCHAR2
 , p_type                   IN              VARCHAR2 :='WWW'
 , p_function_id            IN              FND_FORM_FUNCTIONS.function_id% TYPE
 , x_return_status          OUT    NOCOPY   VARCHAR2
 , x_msg_count              OUT    NOCOPY   NUMBER
 , x_msg_data               OUT    NOCOPY   VARCHAR2
);

END BSC_LAUNCH_PAD_PUB;

 

/
