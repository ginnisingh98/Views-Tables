--------------------------------------------------------
--  DDL for Package Body BSC_CUSTOM_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CUSTOM_VIEW_PVT" AS
  /* $Header: BSCCVDVB.pls 120.0 2005/06/01 16:15:52 appldev noship $ */
/*********************************************************************************/


/*
  Added get_Tab_Id_Count for Performace Bug #3236356
*/

FUNCTION get_Tab_Id_Count
(
  p_Tab_Id         IN NUMBER
)RETURN NUMBER;


FUNCTION Is_More
(       p_cust_Views   IN  OUT NOCOPY  VARCHAR2
    ,   p_cust_View        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_cust_Views IS NOT NULL) THEN
        l_pos_ids        := INSTR(p_cust_Views,   ',');
        IF (l_pos_ids > 0) THEN
            p_cust_View  :=  TRIM(SUBSTR(p_cust_Views,    1,    l_pos_ids - 1));
            p_cust_Views :=  TRIM(SUBSTR(p_cust_Views,    l_pos_ids + 1));
        ELSE
            p_cust_View  :=  TRIM(p_cust_Views);
            p_cust_Views :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;


/******************************************************************************************
  This fucntion will return the enabled flag for the tabview.
  If it returns 1 it means the view is enabled for the view.
  0 means the view is not enabled for the view.
/******************************************************************************************/

FUNCTION get_enabled_flag_for_View
(
    p_tab_id         IN    NUMBER
   ,p_tab_view_id    IN    NUMBER
) RETURN NUMBER
IS
l_enabled           BSC_TAB_VIEWS_B.enabled_flag%TYPE;
BEGIN

       --DBMS_OUTPUT.PUT_LINE\n('p_tab_id-->'|| p_tab_id);
       --DBMS_OUTPUT.PUT_LINE\n('p_tab_view_id-->'|| p_tab_view_id);

       IF ((p_tab_view_id > -1)AND(p_tab_view_id<2)) THEN

         IF (p_tab_view_id=0) THEN
         -- for scorecard view

           SELECT KPI_MODEL
           INTO l_enabled
           FROM BSC_TABS_B
           WHERE tab_id =p_tab_id;

         ELSE
            SELECT BSC_MODEL
            INTO l_enabled
            FROM BSC_TABS_B
            WHERE tab_id =p_tab_id;
         END IF;

       ELSE

            SELECT enabled_flag
            INTO   l_enabled
            FROM   BSC_TAB_VIEWS_B
            WHERE  tab_id =p_tab_id
            AND    tab_view_id = p_tab_view_id;

      END IF;

      RETURN  l_enabled;

      --DBMS_OUTPUT.PUT_LINE\n('l_enabled-->'|| l_enabled);

END  get_enabled_flag_for_View;

/***************************************************************************
 This function validates if particular view exist for the tab or not.
 if not then the count will be 0 otherwise it will be greater than 0


/***************************************************************************/


FUNCTION Validate_Tab_View
(
    p_tab_id         IN    NUMBER
   ,p_tab_view_id    IN    NUMBER
) RETURN NUMBER
IS
l_count             NUMBER;
BEGIN

        SELECT COUNT(0)
        INTO l_count
        FROM BSC_TAB_VIEWS_B
        WHERE tab_id = p_tab_id
        AND  tab_view_id =p_tab_view_id;

        RETURN l_count;

END Validate_Tab_View;

/*******************************************************************************
 Decription :- This procedure will Assign the custom views for the tab.
               It means it will set the enabled_flag =1 in BSC_TAB_VIEWS_B table
               for tree view, detail_view and custom views.
               For scorecard view, strategy map view it will set KPI_MODEL =1
               and BSC_MODEL =1 in BSC_TABS_B table.
 Input      :- Comma separated views ids which needs to be Assigned.
 Created by :- ashankar 27-Oct-2003
/*******************************************************************************/


PROCEDURE Assign_Cust_Views
(    p_commit                 IN              VARCHAR2 := FND_API.G_FALSE
    ,p_tab_id                 IN              NUMBER
    ,p_assign_views           IN              VARCHAR2
    ,x_return_status          OUT    NOCOPY   VARCHAR2
    ,x_msg_count              OUT    NOCOPY   NUMBER
    ,x_msg_data               OUT    NOCOPY   VARCHAR2
 )IS
   l_count                    NUMBER;
   l_cust_views               VARCHAR2(32000);
   l_cust_View                VARCHAR2(10);
   l_Tab_Rec                  BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
   l_Tab_View_Rec             BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
   l_tab_view_id              NUMBER;
 BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_tab_id IS NOT NULL) THEN

       -- Bug #3236356
       l_count := get_Tab_Id_Count(p_tab_id);

       IF(l_count =0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
            FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', p_tab_id);
        FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
  ELSE
       FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

      IF(p_assign_views IS NOT NULL) THEN
         l_cust_views := p_assign_views;
        WHILE (Is_More(  p_cust_Views   =>  l_cust_views
                        ,p_cust_View    =>  l_cust_View)
              ) LOOP
                l_tab_view_id := TO_NUMBER(l_cust_View);

                IF(l_tab_view_id>-1 AND l_tab_view_id<2) THEN

                    l_Tab_Rec.Bsc_Tab_Id := p_tab_id;

                    IF(l_tab_view_id =0) THEN
                        l_Tab_Rec.Bsc_Kpi_Model :=1;
                    ELSE
                        l_Tab_Rec.Bsc_Bsc_Model :=1;
                    END IF;

                    BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View
                    (
                      p_Tab_Rec      => l_Tab_Rec
                     ,x_return_status => x_return_status
                     ,x_msg_count    => x_msg_count
                     ,x_msg_data     => x_msg_data
                    );
                     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_default_View Failed: at BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;

                ELSE
                    l_Tab_View_Rec.Bsc_Tab_Id := p_tab_id;
                    l_Tab_View_Rec.Bsc_Tab_View_Id := l_tab_view_id;
                    l_Tab_View_Rec.Bsc_Enabled_Flag :=1;

                    -- VALIDATE FOR -2 AND -1 that whether the record for it exists or not.
                    --If no records exists then no need to insert the record into the data base
                    -- just skip it.
                    l_count := -1;
                    IF (l_Tab_View_Rec.Bsc_Tab_View_Id < 0) THEN
                        l_count := BSC_CUSTOM_VIEW_PVT.Validate_Tab_View
                                    (
                                        p_tab_id        => l_Tab_View_Rec.Bsc_Tab_Id
                                      , p_tab_view_id   => l_Tab_View_Rec.Bsc_Tab_View_Id
                                    );

                    END IF;
                    IF ((l_count = -1) OR (l_count > 0)) THEN
                        BSC_CUSTOM_VIEW_PVT.Update_Tab_View
                         (
                             p_Tab_View_Rec  => l_Tab_View_Rec
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                         );
                         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                            ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_Tab_View Failed: at BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views <'||x_msg_data||'>');
                            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                         END IF;
                       END IF;
                   END IF;
            END LOOP;
      END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
                  (    p_encoded   =>  FND_API.G_FALSE
                      ,p_count     =>  x_msg_count
                      ,p_data      =>  x_msg_data
          );
    END IF;

   ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
   x_return_status :=  FND_API.G_RET_STS_ERROR;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
                ,  p_count     =>  x_msg_count
                ,  p_data      =>  x_msg_data
            );
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

     WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
      ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
      END IF;

      ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);

     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
      ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
      END IF;

      ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);
 END Assign_Cust_Views;

/*******************************************************************************
 Decription :- This procedure will unassign the custom views for the tab.
               It means it will set the enabled_flag =0 in BSC_TAB_VIEWS_B table
               for tree view, detail_view and custom views.
               For scorecard view, strategy map view it will set KPI_MODEL =0
               and BSC_MODEL =0 in BSC_TABS_B table.
 Input      :- Comma separated views ids which needs to be unassigned.
 Created by :- ashankar 23-Oct-2003
/*******************************************************************************/

PROCEDURE Unassign_Cust_Views
(    p_commit                 IN              VARCHAR2 := FND_API.G_FALSE
    ,p_tab_id                 IN              NUMBER
    ,p_unassign_views         IN              VARCHAR2
    ,x_return_status          OUT    NOCOPY   VARCHAR2
    ,x_msg_count              OUT    NOCOPY   NUMBER
    ,x_msg_data               OUT    NOCOPY   VARCHAR2
 )IS

   l_count                    NUMBER;
   l_cust_views               VARCHAR2(32000);
   l_cust_View                VARCHAR2(10);
   l_Tab_Rec                  BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
   l_Tab_View_Rec             BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
   l_tab_view_id              NUMBER;
 BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF (p_tab_id IS NOT NULL) THEN
           -- Bug #3236356
           l_count := get_Tab_Id_Count(p_tab_id);

           IF(l_count =0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
                FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', p_tab_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
       ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF(p_unassign_views IS NOT NULL) THEN
        l_cust_Views := p_unassign_views;
        WHILE (Is_More(  p_cust_Views   =>  l_cust_views
                        ,p_cust_View    =>  l_cust_View)
              ) LOOP
              l_tab_view_id := TO_NUMBER(l_cust_View);

              ----DBMS_OUTPUT.PUT_LINE\n('  l_tab_view_id--> '|| l_tab_view_id) ;

              IF(l_tab_view_id>-1 AND l_tab_view_id<2) THEN

                    l_Tab_Rec.Bsc_Tab_Id := p_tab_id;
                IF(l_tab_view_id =0) THEN
                    l_Tab_Rec.Bsc_Kpi_Model :=0;
                ELSE
                    l_Tab_Rec.Bsc_Bsc_Model :=0;
                END IF;

                ----DBMS_OUTPUT.PUT_LINE\n(' inside if l_tab_view_id--> '|| l_tab_view_id) ;
                BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View
                (
                     p_Tab_Rec       => l_Tab_Rec
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                );
                 IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_default_View Failed: at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

              ELSE

                ----DBMS_OUTPUT.PUT_LINE\n(' outside if l_tab_view_id--> '|| l_tab_view_id) ;
                l_Tab_View_Rec.Bsc_Tab_Id       := p_tab_id;
                l_Tab_View_Rec.Bsc_Tab_View_Id  := l_tab_view_id;
                l_Tab_View_Rec.Bsc_Enabled_Flag := 0;

                -- Check if the records are there for the tab view id -2 and -1.
                -- if not then create a record for -2 and -1 and setthe enabled flag to 0
                IF (l_Tab_View_Rec.Bsc_Tab_View_Id < 0) THEN
                    l_count := BSC_CUSTOM_VIEW_PVT.Validate_Tab_View
                                (
                                    p_tab_id        => l_Tab_View_Rec.Bsc_Tab_Id
                                  , p_tab_view_id   => l_Tab_View_Rec.Bsc_Tab_View_Id
                                );

                  IF  (l_count = 0) THEN

                    IF (l_Tab_View_Rec.Bsc_Tab_View_Id =-1) THEN

                       IF (BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DETAILED_VIEW') IS NOT NULL)THEN
                        l_Tab_View_Rec.Bsc_Name := BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DETAILED_VIEW');
                        l_Tab_View_Rec.Bsc_Help := l_Tab_View_Rec.Bsc_Name;
                       ELSE
                        l_Tab_View_Rec.Bsc_Name := 'Detailed View';
                        l_Tab_View_Rec.Bsc_Help := l_Tab_View_Rec.Bsc_Name;
                       END IF;

                    ELSE

                       IF (BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TREE_VIEW') IS NOT NULL)THEN
                        l_Tab_View_Rec.Bsc_Name := BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TREE_VIEW');
                        l_Tab_View_Rec.Bsc_Help := l_Tab_View_Rec.Bsc_Name;
                       ELSE
                       l_Tab_View_Rec.Bsc_Name  := 'Tree View';
                       l_Tab_View_Rec.Bsc_Help  := l_Tab_View_Rec.Bsc_Name;
                       END IF;
                    END IF;

                    BSC_CUSTOM_VIEW_PVT.Create_Tab_View
                     (
                         p_Tab_View_Rec  => l_Tab_View_Rec
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                     );
                     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                          ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_Tab_View Failed: at BSC_CUSTOM_VIEW_PVT.Create_Tab_View <'||x_msg_data||'>');
                          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                   END IF;
                END IF;

                BSC_CUSTOM_VIEW_PVT.Update_Tab_View
                 (
                     p_Tab_View_Rec  => l_Tab_View_Rec
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                 );
                 IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_Tab_View Failed: at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views <'||x_msg_data||'>');
                      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END IF;
           END LOOP;
      END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;

    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
    x_return_status :=  FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
                ,  p_count     =>  x_msg_count
                ,  p_data      =>  x_msg_data
            );
        END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);
 END  Unassign_Cust_Views;

/******************************************************************************************
  This procedure will do the following.
  For the current tab what views need to be shown.
  All the assign_Views which are coming from the UI should be visible in the popdown list
  in IViewer and shown as seleceted in the table.
  The default view needs to be updated in BSC_TABS_B.
  If scorecard view and startegy map view are enabled then they should go into
  BSC_TABS_B COLUMNS KPI_MODEL and BSC_MODEL.
  For other views like Tree View/Detail View and other custom views should be
  updated in BSC_TAB_VIEWS_B with enabled flag set to 1/0.

  if user unassigns all the views we have to set scorecard view as default.
  The default view should be updated in the last only.
  if we are trying to set the default view of the view which is disabled then we have to throw
  the exception.

/******************************************************************************************/


PROCEDURE Assign_Unassign_Views(
    p_commit             IN              VARCHAR2 := FND_API.G_FALSE
   ,p_tab_id             IN              NUMBER
   ,p_default_value      IN              NUMBER
   ,p_assign_views       IN              VARCHAR2
   ,p_unassign_views     IN              VARCHAR2
   ,x_return_status      OUT    NOCOPY   VARCHAR2
   ,x_msg_count          OUT    NOCOPY   NUMBER
   ,x_msg_data           OUT    NOCOPY   VARCHAR2
)IS
  l_count                    NUMBER;
  l_Tab_Rec                  BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
  l_Tab_View_Rec             BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_tab_id IS NULL) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
       FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_ID'), TRUE);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_default_value IS NULL) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DEFAULT_ID');
       FND_MESSAGE.SET_TOKEN('BSC_DEF_ID', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DEFAULT_TAB_ID'), TRUE);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call the unassign first and then assign the views APIS.

    --DBMS_OUTPUT.PUT_LINE\n('p_tab_id--->' || p_tab_id);
    --DBMS_OUTPUT.PUT_LINE\n('p_default_value--->' || p_default_value);
    --DBMS_OUTPUT.PUT_LINE\n('p_assign_views--->' || p_assign_views);
    --DBMS_OUTPUT.PUT_LINE\n('p_unassign_views--->' || p_unassign_views);

    IF (p_unassign_views IS NOT NULL) THEN

        BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views
    (    p_commit                =>  FND_API.G_FALSE
        ,p_tab_id                =>  p_tab_id
        ,p_unassign_views        =>  p_unassign_views
        ,x_return_status         =>  x_return_status
        ,x_msg_count             =>  x_msg_count
        ,x_msg_data              =>  x_msg_data
        );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Assign_Unassign_Views Failed: at BSC_CUSTOM_VIEW_PVT.Assign_Unassign_Views');
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE\n('aFTER SC_CUSTOM_VIEW_PVT.Unassign_Cust_Views');
    -- call the assign view API

    IF (p_assign_views IS NOT NULL) THEN

     BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views
     (    p_commit                =>  FND_API.G_FALSE
         ,p_tab_id                =>  p_tab_id
         ,p_assign_views          =>  p_assign_views
         ,x_return_status         =>  x_return_status
         ,x_msg_count             =>  x_msg_count
         ,x_msg_data              =>  x_msg_data
      );

      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views Failed: at BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    --DBMS_OUTPUT.PUT_LINE\n('aFTER SC_CUSTOM_VIEW_PVT.Assign_Cust_Views');

    --Now set the default view.
    --Check if the view we are going to set as default has enabled flag set to 1.
     IF (p_default_value < 0) THEN

           l_Tab_View_Rec.Bsc_Tab_Id        := p_tab_id;
           l_Tab_View_Rec.Bsc_Tab_View_Id   := p_default_value ;
           l_Tab_View_Rec.Bsc_Enabled_Flag  := 1;

           l_count := BSC_CUSTOM_VIEW_PVT.Validate_Tab_View
                      (
                         p_tab_id       => l_Tab_View_Rec.Bsc_Tab_Id
                       , p_tab_view_id  => l_Tab_View_Rec.Bsc_Tab_View_Id
                      );

           IF  (l_count = 0) THEN
              IF (l_Tab_View_Rec.Bsc_Tab_View_Id =-1) THEN
                  l_Tab_View_Rec.Bsc_Name := BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DETAILED_VIEW');
              ELSE
                  l_Tab_View_Rec.Bsc_Name := BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TREE_VIEW');
              END IF;

              l_Tab_View_Rec.Bsc_Help := l_Tab_View_Rec.Bsc_Name;

              BSC_CUSTOM_VIEW_PVT.Create_Tab_View
               (
                 p_Tab_View_Rec    => l_Tab_View_Rec
                ,x_return_status   => x_return_status
                ,x_msg_count       => x_msg_count
                ,x_msg_data        => x_msg_data
               );
              IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 ----DBMS_OUTPUT.PUT_LINE\n('BSC_CUSTOM_VIEW_PVT.Update_Tab_View Failed: at BSC_CUSTOM_VIEW_PVT.Create_Tab_View <'||x_msg_data||'>');
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
     END IF;

    l_count :=  BSC_CUSTOM_VIEW_PVT.get_enabled_flag_for_View
            (
                p_tab_id        => p_tab_id
              , p_tab_view_id   => p_default_value
            );

    IF(l_count=0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NOTSET_DEFAULT_ID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_Tab_Rec.Bsc_Tab_Id        := p_tab_id;
    l_Tab_Rec.Bsc_Default_Model := p_default_value;
    l_Tab_Rec.Bsc_Last_Update_Date := SYSDATE;

    BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View
    (
         p_Tab_Rec       => l_Tab_Rec
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
    );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;

    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
    x_return_status :=  FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
          FND_MSG_PUB.Count_And_Get
           (   p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
            );
        END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);
END Assign_Unassign_Views;

/******************************************************************************************
  This procedure will create a new record into the BSC_TAB_VIEWS_B and BSC_TAB_VIEWS_TL table.

/******************************************************************************************/

PROCEDURE Create_Tab_View
(
     p_commit           IN              VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_View_Rec     IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status    OUT NOCOPY      VARCHAR2
    ,x_msg_count        OUT NOCOPY      NUMBER
    ,x_msg_data         OUT NOCOPY      VARCHAR2
)IS
  l_Tab_View_Rec        BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
  l_count               NUMBER;
BEGIN
    SAVEPOINT CreateTabView;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_Tab_View_Rec := p_Tab_View_Rec;

    IF (l_Tab_View_Rec.Bsc_Tab_Id IS NOT NULL) THEN
            -- Bug #3236356
            l_count := get_Tab_Id_Count(l_Tab_View_Rec.Bsc_Tab_Id);

            IF(l_count =0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
                FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', l_Tab_View_Rec.Bsc_Tab_Id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    ELSE
                FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
    END IF;


    INSERT INTO BSC_TAB_VIEWS_B
                    (    tab_id
                        ,tab_view_id
                        ,enabled_flag
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date
                        ,last_update_login
                     )VALUES
                      (    l_Tab_View_Rec.Bsc_Tab_Id
                          ,l_Tab_View_Rec.Bsc_Tab_View_Id
                          ,l_Tab_View_Rec.Bsc_Enabled_Flag
                          ,fnd_global.USER_ID
                          ,SYSDATE
                          ,fnd_global.USER_ID
                          ,SYSDATE
                          ,fnd_global.LOGIN_ID
                        );

     INSERT INTO BSC_TAB_VIEWS_TL
                    (    tab_id
                        ,tab_view_id
                        ,language
                        ,source_lang
                        ,name
                        ,help
                        ,created_by
                        ,creation_date
                        ,last_updated_by
                        ,last_update_date
                        ,last_update_login
                      )
                      SELECT  l_Tab_View_Rec.Bsc_Tab_Id
                             ,l_Tab_View_Rec.Bsc_Tab_View_Id
                             ,L.LANGUAGE_CODE
                             ,USERENV('LANG')
                             ,l_Tab_View_Rec.Bsc_Name
                             ,l_Tab_View_Rec.Bsc_Help
                             ,fnd_global.USER_ID
                             ,sysdate
                             ,fnd_global.USER_ID
                             ,sysdate
                             ,fnd_global.LOGIN_ID
                      FROM  FND_LANGUAGES L
                      WHERE L.INSTALLED_FLAG IN ('I', 'B')
                      AND NOT EXISTS
                      ( SELECT NULL
                        FROM   BSC_TAB_VIEWS_TL T
                        WHERE  T.tab_id     = l_Tab_View_Rec.Bsc_Tab_Id
                        AND  T.tab_view_id  = l_Tab_View_Rec.Bsc_Tab_View_Id
                        AND  T.LANGUAGE     = L.LANGUAGE_CODE);


    IF (p_commit =FND_API.G_TRUE) THEN
       commit;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO CreateTabView;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                 ,p_data   =>      x_msg_data);
       RAISE;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CreateTabView;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                 ,p_data     =>      x_msg_data);
       RAISE;

     WHEN NO_DATA_FOUND THEN
      ROLLBACK TO CreateTabView;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Retrieve_Tab';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Retrieve_Tab';
       END IF;
       RAISE;
     WHEN OTHERS THEN
      ROLLBACK TO CreateTabView;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
          x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Create_Tab_View';
       ELSE
          x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Create_Tab_View';
       END IF;
       RAISE;

END Create_Tab_View;


/****************************************************************************
 This procedure retrives the data corresponding to the particula tab_id
 It will be used when we will be updating the tab record.
/*****************************************************************************/

PROCEDURE Retrieve_Tab(
  p_Tab_Rec             IN              BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
 ,x_Tab_Rec             IN OUT NOCOPY   BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
 ,x_return_status       OUT NOCOPY      VARCHAR2
 ,x_msg_count           OUT NOCOPY      NUMBER
 ,x_msg_data            OUT NOCOPY      VARCHAR2
) IS
BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT   a.tab_id
                ,a.kpi_model
                ,a.bsc_model
                ,a.cross_model
                ,a.default_model
                ,a.zoom_factor
                ,a.created_by
                ,a.creation_date
                ,a.last_updated_by
                ,a.last_update_date
                ,a.last_update_login
                ,a.tab_index
                ,a.parent_tab_id
                ,a.owner_id
                ,a.short_name
       INTO      x_Tab_Rec.Bsc_Tab_Id
                ,x_Tab_Rec.Bsc_Kpi_Model
                ,x_Tab_Rec.Bsc_Bsc_Model
                ,x_Tab_Rec.Bsc_Cross_Model
                ,x_Tab_Rec.Bsc_Default_Model
                ,x_Tab_Rec.Bsc_Zoom_Factor
                ,x_Tab_Rec.Bsc_Created_By
                ,x_Tab_Rec.Bsc_Creation_Date
                ,x_Tab_Rec.Bsc_Last_updated_By
                ,x_Tab_Rec.Bsc_Last_update_Date
                ,x_Tab_Rec.Bsc_Last_update_Login
                ,x_Tab_Rec.Bsc_Tab_Index
                ,x_Tab_Rec.Bsc_Parent_Tab_id
                ,x_Tab_Rec.Bsc_Owner_Id
                ,x_Tab_Rec.Bsc_Short_Name
      FROM      BSC_TABS_B a
      WHERE     a.tab_id = p_Tab_Rec.Bsc_Tab_Id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Retrieve_Tab ';
    ELSE
       x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Retrieve_Tab ';
    END IF;
    RAISE;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
   ELSE
       x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
   END IF;
   RAISE;
END Retrieve_Tab;

/*************************************************************************************
 Description :- This procedure retrieves the data from BSC_TAB_VIEWS_B table.
 Input       :- p_Tab_View_Rec.Bsc_Tab_Id and p_Tab_View_Rec.Bsc_Tab_View_Id
 OutPut      :- x_Tab_View_Rec
 Created By  :- ashankar 23-Oct-2003
/**************************************************************************************/

PROCEDURE Retrieve_Tab_View
(    p_Tab_View_Rec         IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_Tab_View_Rec         IN OUT NOCOPY   BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status        OUT NOCOPY      VARCHAR2
    ,x_msg_count            OUT NOCOPY      NUMBER
    ,x_msg_data             OUT NOCOPY      VARCHAR2
)IS
BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      ----DBMS_OUTPUT.PUT_LINE\n('p_Tab_View_Rec.Bsc_Tab_Id --->' ||  p_Tab_View_Rec.Bsc_Tab_Id);
      ----DBMS_OUTPUT.PUT_LINE\n('p_Tab_View_Rec.Bsc_Tab_View_Id --->' ||  p_Tab_View_Rec.Bsc_Tab_View_Id);

     SELECT   tab_id
             ,tab_view_id
             ,enabled_flag
             ,created_by
             ,creation_date
             ,last_updated_by
             ,last_update_date
             ,last_update_login
     INTO     x_Tab_View_Rec.Bsc_Tab_Id
             ,x_Tab_View_Rec.Bsc_Tab_View_Id
             ,x_Tab_View_Rec.Bsc_Enabled_Flag
             ,x_Tab_View_Rec.Bsc_Created_By
             ,x_Tab_View_Rec.Bsc_Creation_Date
             ,x_Tab_View_Rec.Bsc_Last_Updated_By
             ,x_Tab_View_Rec.Bsc_Last_Update_Date
             ,x_Tab_View_Rec.Bsc_Last_Update_Login
     FROM    BSC_TAB_VIEWS_B
     WHERE   tab_id = p_Tab_View_Rec.Bsc_Tab_Id
     AND     tab_view_id =p_Tab_View_Rec.Bsc_Tab_View_Id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    ----DBMS_OUTPUT.PUT_LINE\n('insdei exception p_Tab_View_Rec.Bsc_Tab_Id --->' ||  p_Tab_View_Rec.Bsc_Tab_Id);
    ----DBMS_OUTPUT.PUT_LINE\n('p_Tab_View_Rec.Bsc_Tab_View_Id --->' ||  p_Tab_View_Rec.Bsc_Tab_View_Id);x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Retrieve_Tab_View ';
    ELSE
       x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Retrieve_Tab_View ';
    END IF;
    RAISE;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Retrieve_Tab_View ';
   ELSE
       x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Retrieve_Tab_View ';
   END IF;
   RAISE;
END Retrieve_Tab_View;


/*****************************************************************************************
  Description :- This procedure updates the BSC_TABS_B table.
                 This procedure should be called from assign and unassign views.
  Input       :- p_tab_View_rec
  Ouput       :- Updates the BSC_TABS_B
  Created By  :- ashankar 23-Oct-2003
/******************************************************************************************/
PROCEDURE Update_Tab_View
(    p_commit              IN               VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_View_Rec        IN               BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
    ,x_return_status       OUT NOCOPY       VARCHAR2
    ,x_msg_count           OUT NOCOPY       NUMBER
    ,x_msg_data            OUT NOCOPY       VARCHAR2

)IS
    l_Tab_View_Rec         BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
    l_Tab_View_Out_Rec     BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
    l_count                NUMBER;

BEGIN
    SAVEPOINT UpdateTabView;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_Tab_View_Rec.Bsc_Tab_Id := p_Tab_View_Rec.Bsc_Tab_Id;

    IF(l_Tab_View_Rec.Bsc_Tab_Id IS NOT NULL) THEN
          -- Bug #3236356
          l_count := get_Tab_Id_Count(l_Tab_View_Rec.Bsc_Tab_Id);

          IF(l_count =0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
            FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', l_Tab_View_Rec.Bsc_Tab_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

    ELSE

          FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;

    END IF;

    l_Tab_View_Rec.Bsc_Tab_View_Id := p_Tab_View_Rec.Bsc_Tab_View_Id;

    ----DBMS_OUTPUT.PUT_LINE\n('l_Tab_View_Rec.Bsc_Tab_View_Id-->' || l_Tab_View_Rec.Bsc_Tab_View_Id);
    ----DBMS_OUTPUT.PUT_LINE\n('l_Tab_View_Rec.Bsc_Tab_Id --->'||l_Tab_View_Rec.Bsc_Tab_Id );

    Retrieve_Tab_View
    (
         p_Tab_View_Rec     => l_Tab_View_Rec
        ,x_Tab_View_Rec     => l_Tab_View_Out_Rec
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data

    );

    IF (p_Tab_View_Rec.Bsc_Enabled_Flag IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Enabled_Flag := p_Tab_View_Rec.Bsc_Enabled_Flag;
    END IF;

    IF (p_Tab_View_Rec.Bsc_Created_By IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Created_By := p_Tab_View_Rec.Bsc_Created_By;
    END IF;

    IF (p_Tab_View_Rec.Bsc_Creation_Date IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Creation_Date := p_Tab_View_Rec.Bsc_Creation_Date;
    END IF;

    IF (p_Tab_View_Rec.Bsc_Last_Updated_By IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Last_Updated_By := p_Tab_View_Rec.Bsc_Last_Updated_By;
    END IF;

    IF (p_Tab_View_Rec.Bsc_Last_Update_Date IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Last_Update_Date := p_Tab_View_Rec.Bsc_Last_Update_Date;
    END IF;

    IF (p_Tab_View_Rec.Bsc_Last_Update_Login IS NOT NULL) THEN
        l_Tab_View_Out_Rec.Bsc_Last_Update_Login := p_Tab_View_Rec.Bsc_Last_Update_Login;
    END IF;

    UPDATE BSC_TAB_VIEWS_B
    SET    Enabled_Flag= l_Tab_View_Out_Rec.Bsc_Enabled_Flag
          ,Created_By= l_Tab_View_Out_Rec.Bsc_Created_By
          ,Creation_Date=l_Tab_View_Out_Rec.Bsc_Creation_Date
          ,Last_Updated_By= l_Tab_View_Out_Rec.Bsc_Last_Updated_By
          ,Last_Update_Date= l_Tab_View_Out_Rec.Bsc_Last_Update_Date
          ,Last_Update_Login=l_Tab_View_Out_Rec.Bsc_Last_Update_Login
   WHERE  tab_id =l_Tab_View_Rec.Bsc_Tab_Id
   AND    tab_view_id = l_Tab_View_Rec.Bsc_Tab_View_Id;

   IF (p_commit = FND_API.G_TRUE) THEN
        commit;
   END IF;

 EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateTabView;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateTabView;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateTabView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Update_Tab_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Update_Tab_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO UpdateTabView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Update_Tab_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Update_Tab_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);
END Update_Tab_View;


/****************************************************************************
 This procedure is used to update the default view of the tab.
 User can change the default view of the tab.
/*****************************************************************************/


PROCEDURE Update_Tab_default_View
(
     p_commit              IN               VARCHAR2 := FND_API.G_FALSE
    ,p_Tab_Rec             IN               BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type
    ,x_return_status       OUT NOCOPY       VARCHAR2
    ,x_msg_count           OUT NOCOPY       NUMBER
    ,x_msg_data            OUT NOCOPY       VARCHAR2

)IS

l_Tab_Ret_Rec               BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
l_Tab_Rec                   BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
l_count                     NUMBER;

BEGIN
    SAVEPOINT UpdateTabdefaultView;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_Tab_Rec.Bsc_Tab_Id := p_Tab_Rec.Bsc_Tab_Id;

    IF(l_Tab_Rec.Bsc_Tab_Id IS NOT NULL) THEN

      -- Bug #3236356
      l_count := get_Tab_Id_Count(l_Tab_Rec.Bsc_Tab_Id);

      IF(l_count =0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
        FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', l_Tab_Rec.Bsc_Tab_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE

        FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

        Retrieve_Tab
        (
             p_Tab_Rec          => l_Tab_Rec
            ,x_Tab_Rec          => l_Tab_Ret_Rec
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data

        );

    IF (p_Tab_Rec.Bsc_Kpi_Model IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Kpi_Model := p_Tab_Rec.Bsc_Kpi_Model;
    END IF;

    IF (p_Tab_Rec.Bsc_Bsc_Model IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Bsc_Model :=  p_Tab_Rec.Bsc_Bsc_Model;
    END IF;

    IF (p_Tab_Rec.Bsc_Cross_Model IS NOT NULL) THEN
         l_Tab_Ret_Rec.Bsc_Cross_Model := p_Tab_Rec.Bsc_Cross_Model;
    END IF;

    IF (p_Tab_Rec.Bsc_Default_Model IS NOT NULL) THEN
         l_Tab_Ret_Rec.Bsc_Default_Model := p_Tab_Rec.Bsc_Default_Model;
    END IF;

    IF (p_Tab_Rec.Bsc_Zoom_Factor IS NOT NULL) THEN
         l_Tab_Ret_Rec.Bsc_Zoom_Factor :=  p_Tab_Rec.Bsc_Zoom_Factor;
    END IF;

    IF (p_Tab_Rec.Bsc_Created_By IS NOT NULL) THEN
         l_Tab_Ret_Rec.Bsc_Created_By :=  p_Tab_Rec.Bsc_Created_By;
    END IF;

    IF (p_Tab_Rec.Bsc_Creation_Date IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Creation_Date :=  p_Tab_Rec.Bsc_Creation_Date;
    END IF;

    IF (p_Tab_Rec.Bsc_Last_updated_By IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Last_updated_By :=  p_Tab_Rec.Bsc_Last_updated_By;
    END IF;

    IF (p_Tab_Rec.Bsc_Last_update_Date IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Last_update_Date :=  p_Tab_Rec.Bsc_Last_update_Date ;
    END IF;

    IF (p_Tab_Rec.Bsc_Last_update_Login IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Last_update_Login :=  p_Tab_Rec.Bsc_Last_update_Login;
    END IF;

    IF (p_Tab_Rec.Bsc_Tab_Index IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Tab_Index :=  p_Tab_Rec.Bsc_Tab_Index;
    END IF;

    IF (p_Tab_Rec.Bsc_Parent_Tab_id IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Parent_Tab_id :=  p_Tab_Rec.Bsc_Parent_Tab_id;
    END IF;

    IF (p_Tab_Rec.Bsc_Owner_Id IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Owner_Id   :=  p_Tab_Rec.Bsc_Owner_Id ;
    END IF;

    IF (p_Tab_Rec.Bsc_Short_Name IS NOT NULL) THEN
        l_Tab_Ret_Rec.Bsc_Short_Name    :=  p_Tab_Rec.Bsc_Short_Name;
    END IF;

    UPDATE   BSC_TABS_B
    SET      Kpi_Model=l_Tab_Ret_Rec.Bsc_Kpi_Model
            ,Bsc_Model=l_Tab_Ret_Rec.Bsc_Bsc_Model
            ,Cross_Model=l_Tab_Ret_Rec.Bsc_Cross_Model
            ,Default_Model=l_Tab_Ret_Rec.Bsc_Default_Model
            ,Zoom_Factor=l_Tab_Ret_Rec.Bsc_Zoom_Factor
            ,Created_By =l_Tab_Ret_Rec.Bsc_Created_By
            ,Creation_Date =l_Tab_Ret_Rec.Bsc_Creation_Date
            ,Last_updated_By=l_Tab_Ret_Rec.Bsc_Last_updated_By
            ,Last_update_Date=l_Tab_Ret_Rec.Bsc_Last_update_Date
            ,Last_update_Login=l_Tab_Ret_Rec.Bsc_Last_update_Login
            ,Tab_Index=l_Tab_Ret_Rec.Bsc_Tab_Index
            ,Parent_Tab_id=l_Tab_Ret_Rec.Bsc_Parent_Tab_id
            ,Owner_Id=l_Tab_Ret_Rec.Bsc_Owner_Id
            ,Short_Name=l_Tab_Ret_Rec.Bsc_Short_Name
    WHERE   Tab_Id = l_Tab_Ret_Rec.Bsc_Tab_Id;

    IF (p_commit = FND_API.G_TRUE) THEN
        commit;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateTabdefaultView;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateTabdefaultView;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateTabdefaultView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO UpdateTabdefaultView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);

END Update_Tab_default_View;

/*******************************************************************************
 This fucntion returns the default view which is attached with the tab id.
 INPUT   :- p_Tab_ID
 OutPut  :- default_view_id
/********************************************************************************/

FUNCTION get_Tab_Default_View
(
    p_Tab_Id    IN    BSC_TABS_B.tab_id%TYPE
)RETURN NUMBER
IS
 l_default_view       BSC_TABS_B.default_model%TYPE;
BEGIN

    SELECT default_model
    INTO   l_default_view
    FROM   BSC_TABS_B
    WHERE  tab_id = p_Tab_Id;

    RETURN l_default_view;

END get_Tab_Default_View;



/*****************************************************************************
 Name :- delete_Custom_View
 Description :- This procedure will delete the custom view from bsc_tab_views_b table.
                It will do the following validations.
                1. Before deleting the custom view it will verify if it is the default
                   view which is being deleted. If yes then it will set scorecard view
                   as default view and delete the custom view.
                   Otherwise it will update the last update date of the tab.
                   This is required for Granular locking purpose.

                The entry will be deleted from the following tables.
                1.BSC_TAB_VIEWS_B
                2.BSC_TAB_VIEWS_TL
                3.BSC_TAB_VIEW_KPI_TL
                4.BSC_TAB_VIEW_LABELS_B
                5.BSC_TAB_VIEW_LABELS_TL
                6.BSC_SYS_IMAGES_MAP_TL
                7.BSC_SYS_IMAGES (need for cascading)
                8.Form functoins defined in each custom view upon creation in BSC_CUSTOM_VIEW_UI_WRAPPER.create_function

Input :- p_CustView_Rec
Creator/Modified by :- ashankar 10-NOV-2003
 /******************************************************************************/
PROCEDURE delete_Custom_View
(
   p_commit                     IN              VARCHAR2   := FND_API.G_FALSE
  ,p_CustView_Rec               IN              BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
) IS

  l_CustView_Rec                BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
  l_count                       NUMBER;
  l_Tab_Rec                     BSC_CUSTOM_VIEW_PUB.Bsc_Tab_Rec_Type;
  l_default_view                BSC_TABS_B.default_model%TYPE;

  CURSOR  c_sys_images IS
  SELECT  image_id
  FROM    BSC_SYS_IMAGES
  WHERE   image_id NOT IN
  (     SELECT DISTINCT(image_id)
        FROM   BSC_SYS_IMAGES_MAP_TL);

BEGIN

    SAVEPOINT deleteCustomView;
    ----DBMS_OUTPUT.PUT_LINE\n('Entered inside BSC_CUSTOM_VIEW_PUB.delete_Custom_View ');
    FND_MSG_PUB.Initialize;

    l_CustView_Rec.Bsc_Tab_Id        := p_CustView_Rec.Bsc_Tab_Id;
    l_CustView_Rec.Bsc_Tab_View_Id   := p_CustView_Rec.Bsc_Tab_View_Id;

    IF(l_CustView_Rec.Bsc_Tab_Id IS NOT NULL) THEN
      -- Bug #3236356
      l_count := get_Tab_Id_Count(l_CustView_Rec.Bsc_Tab_Id);

      IF(l_count =0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
        FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', l_CustView_Rec.Bsc_Tab_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE

        FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF((l_CustView_Rec.Bsc_Tab_Id IS NOT NULL) AND (l_CustView_Rec.Bsc_Tab_View_Id IS NOT NULL)) THEN

        SELECT count(0)
        INTO l_count
        FROM bsc_tab_views_b
        WHERE tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;

        IF (l_count =0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
            FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', l_CustView_Rec.Bsc_Tab_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Before deleting the custom view check if it was the default view with the scorecard.
        -- if yes then set the default view to scorecard view and then delete the custom view.
        -- FIRST SET THE ENABLED FLAG TO SCORECARD CARD VIEW AND ALSO SET IT AS DEFAULT


        l_Tab_Rec.Bsc_Tab_Id := l_CustView_Rec.Bsc_Tab_Id;
        l_default_view       := get_Tab_Default_View(l_Tab_Rec.Bsc_Tab_Id);

        IF (l_default_view = l_CustView_Rec.Bsc_Tab_View_Id) THEN

            l_Tab_Rec.Bsc_Default_Model :=0;
            l_Tab_Rec.Bsc_Kpi_Model :=1;
            l_Tab_Rec.Bsc_Last_update_Date := SYSDATE;

            BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View
            (
                 p_Tab_Rec       => l_Tab_Rec
                ,x_return_status => x_return_status
                ,x_msg_count     => x_msg_count
                ,x_msg_data      => x_msg_data
            );
        ELSE

           l_Tab_Rec.Bsc_Last_update_Date := SYSDATE;

           BSC_CUSTOM_VIEW_PVT.Update_Tab_default_View
            (
                 p_Tab_Rec       => l_Tab_Rec
                ,x_return_status => x_return_status
                ,x_msg_count     => x_msg_count
                ,x_msg_data      => x_msg_data
            );
        END IF;

        -- delete form function defined for custom view
        BSC_CUSTOM_VIEW_UI_WRAPPER.delete_function( p_tab_id        => l_CustView_Rec.Bsc_Tab_Id
                                                   ,p_tab_view_id   => l_CustView_Rec.Bsc_Tab_View_Id
                                                   ,x_return_status => x_return_status
                                                   ,x_msg_count     => x_msg_count
                                                   ,x_msg_data      => x_msg_data);

        -- now delete the tab view id

        DELETE
        FROM    BSC_TAB_VIEWS_B
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;

        DELETE
        FROM    BSC_TAB_VIEWS_TL
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;


        DELETE
        FROM    BSC_TAB_VIEW_KPI_TL
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;

        DELETE
        FROM    BSC_TAB_VIEW_LABELS_B
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;

        DELETE
        FROM    BSC_TAB_VIEW_LABELS_B
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     label_type = 1
        AND     link_id = l_CustView_Rec.Bsc_Tab_View_Id;

        DELETE
        FROM    BSC_TAB_VIEW_LABELS_TL
        WHERE   tab_id = l_CustView_Rec.Bsc_Tab_Id
        AND     tab_view_id = l_CustView_Rec.Bsc_Tab_View_Id;


        DELETE
        FROM    BSC_SYS_IMAGES_MAP_TL
        WHERE   SOURCE_TYPE =   1
        AND     SOURCE_CODE =   l_CustView_Rec.Bsc_Tab_Id
        AND     TYPE        =   l_CustView_Rec.Bsc_Tab_View_Id;

        -- now check if there are any unwanted images in the system and not being
        -- used by any of the scorecard then delete them

        FOR cd IN c_sys_images LOOP
          l_CustView_Rec.Bsc_Image_Id   :=  cd.image_id;

          DELETE
          FROM   BSC_SYS_IMAGES
          WHERE  IMAGE_ID   = l_CustView_Rec.Bsc_Image_Id;

        END LOOP;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO deleteCustomView;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;

    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
    x_return_status :=  FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO deleteCustomView;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
                ,  p_count     =>  x_msg_count
                ,  p_data      =>  x_msg_data
            );
        END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO deleteCustomView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO deleteCustomView;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        END IF;
        ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);



END delete_Custom_View;

/*
  Added get_Tab_Id_Count for Bug #3236356
*/

FUNCTION get_Tab_Id_Count
(
  p_Tab_Id         IN NUMBER
)RETURN NUMBER IS
  l_count   NUMBER := 0;
BEGIN

   SELECT COUNT(0)
   INTO   l_count
   FROM   BSC_TABS_B
   WHERE  TAB_ID = p_Tab_Id;

   RETURN l_count;

END get_Tab_Id_Count;


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
  ) IS
    l_Count     NUMBER;

    CURSOR c_CachedData IS
    SELECT tab_id,
           tab_view_id,
           label_id
    FROM   BSC_TAB_VIEW_LABELS_B
    WHERE  tab_id  = p_tab_id
    AND    link_id = p_obj_id;

  BEGIN
        SAVEPOINT DeleteCustomViewLinks;
        FND_MSG_PUB.Initialize;

        IF(p_tab_id IS NOT NULL) THEN
           l_count := get_Tab_Id_Count(p_tab_id);

           IF(l_count =0) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_ID');
              FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', p_tab_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        ELSE
           FND_MESSAGE.SET_NAME('BSC','BSC_NO_SCORECARD_ID_ENTERED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_Count := 0;

        SELECT COUNT(0)
        INTO  l_Count
        FROM  BSC_TAB_VIEW_KPI_VL
        WHERE Tab_Id = p_tab_id
        AND   Indicator = p_obj_id;

        IF(l_Count>0) THEN

          DELETE
          FROM    BSC_TAB_VIEW_KPI_TL
          WHERE   tab_id = p_tab_id
          AND     indicator = p_obj_id;
        END IF;

        /*********************************************
         After the Enhancement adding Actual and Change to the objectives
         the entries corresponding to Actual and Change labels were added in
         BSC_TAB_VIEW_LABLES_B and BSC_TAB_VIEW_LABLES_TL table with label_type
         as 4,5 and 6 corresponding to Objective label,Actual label and Change label.

         So when the objective is deleted we have to cascade these changes in
         BSC_TAB_VIEW_LABELS_B and _TL table.

         So following is the LOGIC

         To delete from TL table we need to cache the TAB_ID,TAB_VIEW_ID and LABEL_ID.

         To delete from _B table we need tab_id and LINK_ID
         *********************************************/


         FOR cd IN c_CachedData LOOP
            DELETE
            FROM    BSC_TAB_VIEW_LABELS_TL
            WHERE   tab_id      = cd.tab_id
            AND     tab_view_id = cd.tab_view_id
            AND     label_id    = cd.label_id;
         END LOOP;

            DELETE
            FROM   BSC_TAB_VIEW_LABELS_B
            WHERE  tab_id = p_tab_id
            AND    LINK_ID  =p_obj_id;

      IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DeleteCustomViewLinks;
     IF (x_msg_data IS NULL) THEN
         FND_MSG_PUB.Count_And_Get
         (      p_encoded   =>  FND_API.G_FALSE
             ,  p_count     =>  x_msg_count
             ,  p_data      =>  x_msg_data
         );
     END IF;

     ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteCustomViewLinks;
    IF (x_msg_data IS NULL) THEN
         FND_MSG_PUB.Count_And_Get
        (    p_encoded   =>  FND_API.G_FALSE
          ,  p_count     =>  x_msg_count
          ,  p_data      =>  x_msg_data
         );
     END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeleteCustomViewLinks;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links ';
    END IF;
 ----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO DeleteCustomViewLinks;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links ';
    END IF;
----DBMS_OUTPUT.PUT_LINE\n('EXCEPTION OTHERS '||x_msg_data);
END Delete_Custom_View_Links;

END BSC_CUSTOM_VIEW_PVT;

/
