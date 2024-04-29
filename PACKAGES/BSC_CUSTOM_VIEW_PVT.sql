--------------------------------------------------------
--  DDL for Package BSC_CUSTOM_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CUSTOM_VIEW_PVT" AUTHID CURRENT_USER as
/* $Header: BSCCVDVS.pls 120.0 2005/06/01 15:43:02 appldev noship $ */
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

FUNCTION Is_More
(     p_cust_Views   IN  OUT NOCOPY  VARCHAR2
    , p_cust_View        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;


FUNCTION get_enabled_flag_for_View
(
    p_tab_id         IN    NUMBER
   ,p_tab_view_id    IN    NUMBER
) RETURN NUMBER;

FUNCTION get_Tab_Default_View
(
    p_Tab_Id    IN    BSC_TABS_B.tab_id%TYPE
)RETURN NUMBER;

FUNCTION Validate_Tab_View
(
     p_tab_id        IN    NUMBER
    ,p_tab_view_id   IN    NUMBER
) RETURN NUMBER;

/*********************************************************************************
                        Retrieve tab information
*********************************************************************************/

PROCEDURE Retrieve_Tab
(
  p_Tab_Rec             IN              BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
 ,x_Tab_Rec             IN OUT NOCOPY   BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
 ,x_return_status       OUT NOCOPY      VARCHAR2
 ,x_msg_count           OUT NOCOPY      NUMBER
 ,x_msg_data            OUT NOCOPY      VARCHAR2
) ;

/*********************************************************************************
                        Retrieve tab view information
*********************************************************************************/

PROCEDURE Retrieve_Tab_View
(
     p_Tab_View_Rec         IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_Tab_View_Rec         IN OUT NOCOPY   BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status        OUT NOCOPY      VARCHAR2
    ,x_msg_count            OUT NOCOPY      NUMBER
    ,x_msg_data             OUT NOCOPY      VARCHAR2
);

/*********************************************************************************
                        Update Tab View
*********************************************************************************/


PROCEDURE Update_Tab_View
(
     p_commit              IN               VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_View_Rec        IN               BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status       OUT NOCOPY       VARCHAR2
    ,x_msg_count           OUT NOCOPY       NUMBER
    ,x_msg_data            OUT NOCOPY       VARCHAR2

);

/*********************************************************************************
                        Update Tab default View
*********************************************************************************/


PROCEDURE Update_Tab_default_View
(
     p_commit              IN               VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_Rec             IN               BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
    ,x_return_status       OUT NOCOPY       VARCHAR2
    ,x_msg_count           OUT NOCOPY       NUMBER
    ,x_msg_data            OUT NOCOPY       VARCHAR2

);


/*********************************************************************************
                        DELETE CUSTOM VIEW
*********************************************************************************/
PROCEDURE delete_Custom_View
(
   p_commit                     IN              VARCHAR2   := FND_API.G_FALSE
  ,p_CustView_Rec               IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
) ;
/*********************************************************************************
                       ASSIGN_UNASSIGN CUSTOM VIEW
*********************************************************************************/

PROCEDURE Assign_Unassign_Views
(
    p_commit             IN              VARCHAR2   := FND_API.G_FALSE
   ,p_tab_id             IN              NUMBER
   ,p_default_value      IN              NUMBER
   ,p_assign_views       IN              VARCHAR2
   ,p_unassign_views     IN              VARCHAR2
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

  /*********************************************************************************
                         CREATE TAB VIEW
  *********************************************************************************/
  PROCEDURE Create_Tab_View
  (
     p_commit           IN              VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_View_Rec     IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status    OUT NOCOPY      VARCHAR2
    ,x_msg_count        OUT NOCOPY      NUMBER
    ,x_msg_data         OUT NOCOPY      VARCHAR2
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


END BSC_CUSTOM_VIEW_PVT;

 

/
