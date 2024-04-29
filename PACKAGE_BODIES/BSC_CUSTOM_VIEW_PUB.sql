--------------------------------------------------------
--  DDL for Package Body BSC_CUSTOM_VIEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CUSTOM_VIEW_PUB" AS
 /* $Header: BSCCVDBB.pls 120.1 2005/08/22 17:07:48 hengliu noship $ */
/*****************************************************************************
 This procedure will delete the custom view from the tab.
 The entry will be deleted from the following tables.
    1.BSC_TAB_VIEWS_B
    2.BSC_TAB_VIEWS_TL
    3.BSC_TAB_VIEW_KPI_TL
    4.BSC_TAB_VIEW_LABELS_B
    5.BSC_TAB_VIEW_LABELS_TL
    6.BSC_SYS_IMAGES_MAP_TL
    7.BSC_SYS_IMAGES (need for cascading)

 /******************************************************************************/
PROCEDURE delete_Custom_View
(
   p_commit                     IN              VARCHAR2   := FND_API.G_FALSE
  ,p_tab_id                     IN              NUMBER
  ,p_tab_view_id                IN              NUMBER
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
  ,p_time_stamp                 IN              VARCHAR2    := NULL
) IS

 l_CustView_Rec           BSC_CUSTOM_VIEW_PUB.Bsc_Cust_View_Rec_Type;
 l_dep_obj_list			  VARCHAR2(1000);
 l_exist_dependency		  VARCHAR2(5);

BEGIN

     --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_CUSTOM_VIEW_PUB.delete_Custom_View procedure');
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
	 l_exist_dependency := FND_API.G_FALSE;

     IF (p_tab_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_tab_view_id IS NULL) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
         FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_VIEW_ID'), TRUE);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;


     l_CustView_Rec.Bsc_Tab_Id       := p_tab_id;
     l_CustView_Rec.Bsc_Tab_View_Id  := p_tab_view_id;

     -- do the validation that the tab_view_id cannot be -1,-2, 0 and 1
     -- if yes then throw the exception that these views cannot be deleted.

     IF((l_CustView_Rec.Bsc_Tab_View_Id IS NOT NULL) AND (l_CustView_Rec.Bsc_Tab_View_Id<2)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_RES_VIEW_NOT_DELETE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

	 -- Do the validation on the dependency of the custom view
	 -- If depedency exist, return the error message.

	 BSC_PMF_UI_WRAPPER.Check_Tabview_Dependency( p_tab_id	  	=> p_tab_id
	 											 ,p_tab_view_id	=> p_tab_view_id
												 ,p_list_dependency => FND_API.G_TRUE
												 ,x_exist_dependency => l_exist_dependency
												 ,x_dep_obj_list => l_dep_obj_list
												 ,x_return_status => x_return_status
												 ,x_msg_count	  => x_msg_count
												 ,x_msg_data	  => x_msg_data);
	 IF ((x_return_status IS NOT NULL)AND(x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	 IF (l_exist_dependency IS NOT NULL) AND (l_exist_dependency = FND_API.G_TRUE) THEN
	 	x_return_status :=  FND_API.G_RET_STS_ERROR;
	 	FND_MESSAGE.SET_NAME('BSC','BSC_DELETE_CUSTOMVIEW_ERR');
        FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST',l_dep_obj_list);
        FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	 END IF;


     BSC_BIS_LOCKS_PUB.LOCK_TAB(
                p_tab_id          => p_tab_id
               ,p_time_stamp             => p_time_stamp  -- Granular Locking
               ,x_return_status          => x_return_status
               ,x_msg_count              => x_msg_count
               ,x_msg_data               => x_msg_data
       );
         IF ((x_return_status IS NOT NULL)AND(x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;


     BSC_CUSTOM_VIEW_PVT.delete_Custom_View
     (
          p_CustView_Rec    => l_CustView_Rec
         ,x_return_status   => x_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data
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

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END delete_Custom_View;

/*******************************************************************************************************
 Description  :- This procedure takes care of assigning and unassigning the views witl the tab and
                 also setting one of the views as the default one.
 Input        :- tab_id,comma separated assign view ids, default view id, comma separated unassinged
                 view ids.
 Output       :- The views are assigned/unassigned to the tab
 Creator      :- ashankar 27-OCT-2003
/*******************************************************************************************************/

PROCEDURE Assign_Unassign_Views(
    p_commit             IN          VARCHAR2 := FND_API.G_FALSE
   ,p_tab_id             IN              NUMBER
   ,p_default_value      IN              NUMBER
   ,p_assign_views       IN              VARCHAR2
   ,p_unassign_views     IN              VARCHAR2
   ,p_time_stamp         IN              VARCHAR2 :=NULL
   ,x_return_status      OUT    NOCOPY   VARCHAR2
   ,x_msg_count          OUT    NOCOPY   NUMBER
   ,x_msg_data           OUT    NOCOPY   VARCHAR2
)IS
BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_tab_id IS NULL) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_VIEW_ID');
       FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_ID'), TRUE);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   BSC_BIS_LOCKS_PUB.LOCK_TAB
   (
        p_tab_id          =>  p_tab_id
       ,p_time_stamp      =>  p_time_stamp
       ,x_return_status   =>  x_return_status
       ,x_msg_count       =>  x_msg_count
       ,x_msg_data        =>  x_msg_data

    );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views Failed: at BSC_BIS_LOCKS_PUB.LOCK_TAB');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   BSC_CUSTOM_VIEW_PVT.Assign_Unassign_Views
   (
     p_tab_id          =>   p_tab_id
    ,p_default_value   =>   p_default_value
    ,p_assign_views    =>   p_assign_views
    ,p_unassign_views  =>   p_unassign_views
    ,x_return_status   =>   x_return_status
    ,x_msg_count       =>   x_msg_count
    ,x_msg_data        =>   x_msg_data
   );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views Failed: at BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views <'||x_msg_data||'>');
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
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

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Unassign_Views ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Assign_Unassign_Views;

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
 BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_tab_id IS NULL) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_VIEW_ID');
       FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_ID'), TRUE);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_assign_views IS NOT NULL) THEN

        BSC_CUSTOM_VIEW_PVT.Assign_Cust_Views
        (
             p_tab_id          =>   p_tab_id
            ,p_assign_views    =>   p_assign_views
            ,x_return_status   =>   x_return_status
            ,x_msg_count       =>   x_msg_count
            ,x_msg_data        =>   x_msg_data
         );

         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views Failed: at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views <'||x_msg_data||'>');
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
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

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
 END Assign_Cust_Views;

 /*******************************************************************************
  Unassign_Cust_Views
  Decription :- This procedure will UnAssign the custom views for the tab.
                It means it will set the enabled_flag =0 in BSC_TAB_VIEWS_B table
                for tree view, detail_view and custom views.
                For scorecard view, strategy map view it will set KPI_MODEL =0
                and BSC_MODEL =0 in BSC_TABS_B table.
  Input      :- Comma separated views ids which needs to be Assigned.
  Created by :- ashankar 27-Oct-2003
/*******************************************************************************/

 PROCEDURE Unassign_Cust_Views
 (    p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
     ,p_tab_id                 IN              NUMBER
     ,p_unassign_views         IN              VARCHAR2
     ,x_return_status          OUT    NOCOPY   VARCHAR2
     ,x_msg_count              OUT    NOCOPY   NUMBER
     ,x_msg_data               OUT    NOCOPY   VARCHAR2
 )IS

 BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_tab_id IS NULL) THEN
           FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SCORECARD_VIEW_ID');
           FND_MESSAGE.SET_TOKEN('BSC_SCORECARD', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'TAB_ID'), TRUE);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(p_unassign_views IS NOT NULL) THEN

        BSC_CUSTOM_VIEW_PVT.Unassign_Cust_Views
        (
            p_tab_id           =>   p_tab_id
            ,p_unassign_views  =>   p_unassign_views
            ,x_return_status   =>   x_return_status
            ,x_msg_count       =>   x_msg_count
            ,x_msg_data        =>   x_msg_data
        );
         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views Failed: at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views <'||x_msg_data||'>');
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
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

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Assign_Cust_Views ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Unassign_Cust_Views;


/*******************************************************************************
  Delete_Custom_View_Links
  Decription :- This procedure will UnAssign the custom views for the tab.
                It means it will set the enabled_flag =0 in BSC_TAB_VIEWS_B table
                for tree view, detail_view and custom views.
                For scorecard view, strategy map view it will set KPI_MODEL =0
                and BSC_MODEL =0 in BSC_TABS_B table.
  Input      :- Comma separated views ids which needs to be Assigned.
  Created by :- ashankar 27-Oct-2003
/*******************************************************************************/
PROCEDURE Delete_Custom_View_Links
  (
      p_commit                 IN              VARCHAR2  := FND_API.G_FALSE
    , p_tab_id                 IN              NUMBER
    , p_obj_id                 IN              NUMBER
    , x_return_status          OUT    NOCOPY   VARCHAR2
    , x_msg_count              OUT    NOCOPY   NUMBER
    , x_msg_data               OUT    NOCOPY   VARCHAR2
  )IS
  l_Count         NUMBER;

  BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links
     (
           p_commit         =>  p_commit
         , p_tab_id         =>  p_tab_id
         , p_obj_id         =>  p_obj_id
         , x_return_status  =>  x_return_status
         , x_msg_count      =>  x_msg_count
         , x_msg_data       =>  x_msg_data
     );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links Failed: at BSC_CUSTOM_VIEW_PVT.Delete_Custom_View_Links <'||x_msg_data||'>');
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
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

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links ';
       ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links ';
       ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Delete_Custom_View_Links ';
       END IF;
       --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
 END Delete_Custom_View_Links;

END BSC_CUSTOM_VIEW_PUB;

/
