--------------------------------------------------------
--  DDL for Package BSC_CUSTOM_VIEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CUSTOM_VIEW_PUB" AUTHID CURRENT_USER as
/* $Header: BSCCVDBS.pls 120.0 2005/06/01 15:44:40 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |          BSCCVDBS.pls                                                                |
 |                                                                                      |
 | Creation Date:                                                                       |
 |          October 22, 200                                                             |
 |                                                                                      |
 | Creator:                                                                             |
 |          ashankar                                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |          Public specs for package.                                                   |
 |                                                                                      |
 +======================================================================================+
*/
TYPE Bsc_Cust_View_Rec_Type is RECORD(

  Bsc_Tab_Id                    BSC_TAB_VIEWS_B.tab_id%TYPE
 ,Bsc_Tab_View_Id               BSC_TAB_VIEWS_B.tab_view_id%TYPE
 ,Bsc_Enabled_Flag              BSC_TAB_VIEWS_B.enabled_flag%TYPE
 ,Bsc_Image_Id                  BSC_SYS_IMAGES.image_id%TYPE
 ,Bsc_Help                      BSC_TAB_VIEWS_TL.help%TYPE
 ,Bsc_Name                      BSC_TAB_VIEWS_TL.name%TYPE
 ,Bsc_Created_By                number
 ,Bsc_Creation_Date             date
 ,Bsc_Last_Updated_By           number
 ,Bsc_Last_Update_Date          date
 ,Bsc_Last_Update_Login         number
);

TYPE Bsc_Cust_View_Tbl_Type IS TABLE OF Bsc_Cust_View_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Bsc_Tab_Rec_Type is RECORD(

  Bsc_Tab_Id                  BSC_TABS_B.tab_id%TYPE
 ,Bsc_Kpi_Model               BSC_TABS_B.kpi_model%TYPE
 ,Bsc_Bsc_Model               BSC_TABS_B.Bsc_Model%TYPE
 ,Bsc_Cross_Model             BSC_TABS_B.Cross_Model%TYPE
 ,Bsc_Default_Model           BSC_TABS_B.Default_Model%TYPE
 ,Bsc_Zoom_Factor             BSC_TABS_B.Zoom_Factor%TYPE
 ,Bsc_Created_By              BSC_TABS_B.Created_By%TYPE
 ,Bsc_Creation_Date           BSC_TABS_B.Creation_Date%TYPE
 ,Bsc_Last_Updated_By         BSC_TABS_B.Last_updated_By%TYPE
 ,Bsc_Last_Update_Date        BSC_TABS_B.Last_update_Date%TYPE
 ,Bsc_Last_Update_Login       BSC_TABS_B.Last_update_Login%TYPE
 ,Bsc_Tab_Index               BSC_TABS_B.Tab_Index%TYPE
 ,Bsc_Parent_Tab_id           BSC_TABS_B.Parent_Tab_id%TYPE
 ,Bsc_Owner_Id                BSC_TABS_B.Owner_Id%TYPE
 ,Bsc_Short_Name              BSC_TABS_B.Short_Name%TYPE
);

TYPE Bsc_Tab_Tbl_Type IS TABLE OF Bsc_Tab_Rec_Type
INDEX BY BINARY_INTEGER;


/*********************************************************************************
                        DELETE CUSTOM VIEW
*********************************************************************************/
PROCEDURE delete_Custom_View
(
   p_commit             IN           VARCHAR2   := FND_API.G_FALSE
  ,p_tab_id             IN           NUMBER
  ,p_tab_view_id        IN           NUMBER
  ,x_return_status      OUT NOCOPY   VARCHAR2
  ,x_msg_count          OUT NOCOPY   NUMBER
  ,x_msg_data           OUT NOCOPY   VARCHAR2
  ,p_time_stamp                 IN              VARCHAR2    := NULL
) ;

/*********************************************************************************
                       ASSIGN_UNASSIGN CUSTOM VIEW
*********************************************************************************/

PROCEDURE Assign_Unassign_Views(
    p_commit             IN              VARCHAR2 := FND_API.G_FALSE
   ,p_tab_id             IN              NUMBER
   ,p_default_value      IN              NUMBER
   ,p_assign_views       IN              VARCHAR2
   ,p_unassign_views     IN              VARCHAR2
   ,p_time_stamp         IN              VARCHAR2 :=NULL
   ,x_return_status      OUT    NOCOPY   VARCHAR2
   ,x_msg_count          OUT    NOCOPY   NUMBER
   ,x_msg_data           OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                       UNASSIGN CUSTOM VIEW
*********************************************************************************/

PROCEDURE Unassign_Cust_Views
(
     p_commit                 IN              VARCHAR2  := FND_API.G_FALSE
    ,p_tab_id                 IN              NUMBER
    ,p_unassign_views         IN              VARCHAR2
    ,x_return_status          OUT    NOCOPY   VARCHAR2
    ,x_msg_count              OUT    NOCOPY   NUMBER
    ,x_msg_data               OUT    NOCOPY   VARCHAR2

 );

/*********************************************************************************
                       ASSIGN CUSTOM VIEW
*********************************************************************************/
 PROCEDURE Assign_Cust_Views
 (
     p_commit                 IN              VARCHAR2  := FND_API.G_FALSE
    ,p_tab_id                 IN              NUMBER
    ,p_assign_views           IN              VARCHAR2
    ,x_return_status          OUT    NOCOPY   VARCHAR2
    ,x_msg_count              OUT    NOCOPY   NUMBER
    ,x_msg_data               OUT    NOCOPY   VARCHAR2

 );


/********************************************************************************
          DELETE CUSTOM VIEW LINKS
/*******************************************************************************/

  PROCEDURE Delete_Custom_View_Links
  (
      p_commit                 IN              VARCHAR2  := FND_API.G_FALSE
    , p_tab_id                 IN              NUMBER
    , p_obj_id                 IN              NUMBER
    , x_return_status          OUT    NOCOPY   VARCHAR2
    , x_msg_count              OUT    NOCOPY   NUMBER
    , x_msg_data               OUT    NOCOPY   VARCHAR2
  );


END BSC_CUSTOM_VIEW_PUB;

 

/
