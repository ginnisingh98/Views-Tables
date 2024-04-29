--------------------------------------------------------
--  DDL for Package Body BSC_LAUNCH_PAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_LAUNCH_PAD_PUB" AS
/* $Header: BSCCVDEFB.pls 120.1 2006/05/22 21:28:16 akchan ship $ */


PROCEDURE Delete_LaunchPad_Links
(
     p_menu_id              IN          NUMBER
    ,x_return_status        OUT NOCOPY  VARCHAR2
    ,x_msg_count            OUT NOCOPY  NUMBER
    ,x_msg_data             OUT NOCOPY  VARCHAR2
);

/*
  is_Menu_Id_Valid added for Bug #3236356
*/
FUNCTION is_Menu_Id_Valid
(
  p_Menu_Id         IN NUMBER
)RETURN NUMBER;

/**********************************************************************
 Name :- get_Form_Function_Name
 Description :- This fucntion will return the form fucntion name
                corresponding to the fucntion id.
 Input :- p_Function_Id
 OutPut:- Form fucntion name
 Creator ;-ashankar 15-DEC-2003
/**********************************************************************/


FUNCTION get_Form_Function_Name
(
  p_Function_Id         IN      FND_FORM_FUNCTIONS.function_id% TYPE
)RETURN VARCHAR2
IS
l_function_name         FND_FORM_FUNCTIONS.Function_Name%TYPE;

 BEGIN

    SELECT Function_Name
    INTO   l_function_name
    FROM   FND_FORM_FUNCTIONS
    WHERE  Function_Id     =   p_Function_Id;

 RETURN  l_function_name;
END get_Form_Function_Name;

/*****************************************************************************
 Name   :- get_next_entry_sequence
 Description :- This fucntion will return the entry sequence of the menu id
 Input :- menu id
 Output :- Next Entry sequence
/*****************************************************************************/


FUNCTION get_next_entry_sequence
(
    p_Menu_Id      FND_MENUS.menu_id%TYPE
)RETURN NUMBER
IS
    l_count     NUMBER;
BEGIN

   SELECT NVL(MAX(Entry_Sequence),0)Entry_Sequence
   INTO   l_count
   FROM   FND_MENU_ENTRIES
   WHERE  Menu_Id =p_Menu_Id;

   RETURN  (l_count + 1);

END get_next_entry_sequence;


/*********************************************************************************/
FUNCTION Is_More
(       p_fucntion_ids   IN  OUT NOCOPY  VARCHAR2
    ,   p_fucntion_id        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_fucntion_ids IS NOT NULL) THEN
        l_pos_ids        := INSTR(p_fucntion_ids,   ',');
        IF (l_pos_ids > 0) THEN
            p_fucntion_id  :=  TRIM(SUBSTR(p_fucntion_ids,    1,    l_pos_ids - 1));
            p_fucntion_ids :=  TRIM(SUBSTR(p_fucntion_ids,    l_pos_ids + 1));
        ELSE
            p_fucntion_id  :=  TRIM(p_fucntion_ids);
            p_fucntion_ids :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;

/*****************************************************************************
 Name :- get_Menu_Name
 Description :-This fucntion returns the default menu name by appending the menu
               id if menu name is not being passed from UI.
 Input  :- menuid
 output :- 'BSC_LAUNCHPAD_menuid
 Creator:-  ashankar 21-OCT-2003
/******************************************************************************/

FUNCTION get_Menu_Name(
    p_Menu_Id     IN     FND_MENUS.MENU_ID%TYPE
)
RETURN VARCHAR2
IS
BEGIN

    RETURN 'BSC_LAUNCHPAD_'|| p_Menu_Id;

END get_Menu_Name;

/*****************************************************************************
 Name :- validate_Menu_UserMenu_Names
 Description :-This function validates if the menu name and the user menu name entered by the
               user are valid or not .i.e it checks for the uniqueness of menu name and
               user menu name. if either of the name is invalid it returns 'N' and 'U'.
               otherwise it reurns 'T'.
 Input :-   p_menu_id
            p_menu_name
            p_user_menu_name
 Ouput :- 'T' valid
          'U' invalid user menu name
          'N' invalid menu name
 Creator:-  ashankar 21-OCT-2003
 /******************************************************************************/

FUNCTION validate_Menu_UserMenu_Names(
     p_menu_id                 IN       NUMBER
    ,p_menu_name               IN       VARCHAR2
    ,p_user_menu_name          IN       VARCHAR2
)RETURN VARCHAR2
IS
    l_return       VARCHAR2(2);
BEGIN
    l_return := BSC_LAUNCH_PAD_PVT.CHECK_MENU_NAMES
                (
                   X_MENU_ID        => p_menu_id
                  ,X_MENU_NAME      => p_menu_name
                  ,X_USER_MENU_NAME => p_user_menu_name
                );

   RETURN l_return;

END validate_Menu_UserMenu_Names;
/*****************************************************************************
 Name :- validate_Function_Names
 Description :- This function validates if the menu name and the user menu name entered by the
                user are valid or not .i.e it checks for the uniqueness of menu name and
                user menu name. if either of the name is invalid it returns 'N' and 'U'.
                otherwise it reurns 'T'.
 Input :-   p_function_id
            p_fucntion_name
            p_user_function_name
 Ouput :- 'T' valid
          'U' invalid user_function_name
          'N' invalid fucntion_name
 Creator:-  ashankar 21-OCT-2003
 /******************************************************************************/

FUNCTION validate_Function_Names(
     p_function_id             IN       NUMBER
    ,p_fucntion_name           IN       VARCHAR2
    ,p_user_function_name      IN       VARCHAR2
)RETURN VARCHAR2
IS
    l_return       VARCHAR2(2);
BEGIN
    l_return := BSC_LAUNCH_PAD_PVT.CHECK_FUNCTION_NAMES
                (
                      X_FUNCTION_ID         => p_function_id
                    , X_FUNCTION_NAME       => p_fucntion_name
                    , X_USER_FUNCTION_NAME  => p_user_function_name
                );

   RETURN l_return;

END validate_Function_Names;


/*****************************************************************************
 Name :-get_User_Id
 Ouput :- USER ID
 Creator :- ashankar 26-OCT-2003
 /******************************************************************************/

FUNCTION get_User_Id
RETURN NUMBER
IS
BEGIN

    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    RETURN BSC_APPS.fnd_global_user_id;

END get_User_Id;

/*****************************************************************************
 Name :- get_Menu_Id_From_Menu_Name
 Description :-This function returns menu ID from menu name from the database
 Input :- p_Menu_Name
 Ouput :- l_menu_id
 Creator :- ashankar 26-OCT-2003
/*****************************************************************************/

FUNCTION get_Menu_Id_From_Menu_Name(
    p_Menu_Name     IN     FND_MENUS.MENU_NAME%TYPE
)RETURN NUMBER
IS
 l_menu_id  FND_MENUS.MENU_ID%TYPE;
BEGIN

    SELECT  menu_id
    INTO   l_menu_id
    FROM   fnd_menus
    WHERE  menu_name = p_Menu_Name;

    RETURN l_menu_id;

END get_Menu_Id_From_Menu_Name;

/*****************************************************************************
 Name :- get_Menu_Name_From_Menu_Id
 Description :-This function returns menu name from menu Id from the database
 Input :- p_Menu_Id
 Ouput :- l_menu_name
 Creator :- ashankar 26-OCT-2003
/*****************************************************************************/
FUNCTION get_Menu_Name_From_Menu_Id(
    p_Menu_Id     IN     FND_MENUS.MENU_ID%TYPE
)RETURN VARCHAR2
IS
 l_menu_name  FND_MENUS.MENU_NAME%TYPE;
BEGIN

    SELECT  menu_name
    INTO   l_menu_name
    FROM   fnd_menus
    WHERE  menu_id = p_Menu_Id;

    RETURN l_menu_name;

END get_Menu_Name_From_Menu_Id;

/*********************************************************************************
 Procedure :- get_All_Root_Menu
 Description :- This procedure will return the table which contains all the
                root menus to which the launchpad is to be attached.
                The roor menus are based on the responsibilities to which the
                scorecard is attached when it is created.So when the launchpad is
                created it will be assigned to each of the root menus.
 Input  :-    table type
 Output :-    table type which contains all the root menus to which the launchpad
              needs to be attached.
 creator :- ashankar 12-DEC-03
/*********************************************************************************/

PROCEDURE get_All_Root_Menu
(
    x_Root_Menu_Tbl  IN OUT NOCOPY BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Tbl_Type

)IS
l_count         NUMBER;

CURSOR c_root_menu IS
SELECT  DISTINCT A.Menu_Id
       , A.Menu_Name
FROM   FND_MENUS_VL A
      ,FND_RESPONSIBILITY_VL B
WHERE B.Application_Id =271
AND   B.Menu_Id = A.MENU_ID
AND   B.Responsibility_Id IN (SELECT DISTINCT Responsibility_Id from BSC_USER_TAB_ACCESS);

BEGIN

    FOR table_index in 0..x_Root_Menu_Tbl.COUNT-1 LOOP
        x_Root_Menu_Tbl.DELETE(table_index);
    END LOOP;

    l_count := 0;
    FOR cd IN c_root_menu LOOP
     x_Root_Menu_Tbl(l_count).Bsc_menu_id  := cd.Menu_Id;
     x_Root_Menu_Tbl(l_count).Bsc_menu_name:= cd.Menu_Name;
     l_count := l_count + 1;
    END LOOP;

END get_All_Root_Menu;

/********************************************************************************
Name :- Add_Launch_Pad_Root_Menu
Description :- This fucntion will add the created launchpad to all the root menus
               attached to the scorecards.
Input:- p_Launchpad_Id
        p_Description

Creator :- ashankar 12-DEC-03
/********************************************************************************/

PROCEDURE Add_Launch_Pad_Root_Menu
(
    p_Launchpad_Id           IN              FND_MENUS.menu_id%TYPE
  , p_Description            IN              VARCHAR2
  , x_return_status          OUT    NOCOPY   VARCHAR2
  , x_msg_count              OUT    NOCOPY   NUMBER
  , x_msg_data               OUT    NOCOPY   VARCHAR2
)IS

 l_Root_Menu_Tbl         BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Tbl_Type;
 l_root_menu_count       NUMBER;

BEGIN
   SAVEPOINT AddLaunchPadRootMenu;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_All_Root_Menu(x_Root_Menu_Tbl  => l_Root_Menu_Tbl);
   l_root_menu_count :=0;

   WHILE((l_root_menu_count<= l_Root_Menu_Tbl.COUNT - 1)) LOOP

      BSC_LAUNCH_PAD_PVT.INSERT_APP_MENU_ENTRIES_VB
      (
          X_Menu_Id           => l_Root_Menu_Tbl(l_root_menu_count).Bsc_menu_id
        , X_Entry_Sequence    => get_next_entry_sequence(l_Root_Menu_Tbl(l_root_menu_count).Bsc_menu_id)
        , X_Sub_Menu_Id       => p_Launchpad_Id
        , X_Function_Id       => NULL
        , X_Grant_Flag        =>'Y'
        , X_Prompt            => NULL
        , X_Description       => p_Description
        , X_User_Id           => get_User_Id
      );
      l_root_menu_count := l_root_menu_count + 1;
   END LOOP;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO AddLaunchPadRootMenu;
    IF (x_msg_data IS NULL) THEN
    FND_MSG_PUB.Count_And_Get
    (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
    );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO AddLaunchPadRootMenu;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN NO_DATA_FOUND THEN
    ROLLBACK TO AddLaunchPadRootMenu;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Add_Launch_Pad_Root_Menu ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Add_Launch_Pad_Root_Menu ';
    END IF;

 WHEN OTHERS THEN
    ROLLBACK TO AddLaunchPadRootMenu;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Add_Launch_Pad_Root_Menu ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Add_Launch_Pad_Root_Menu ';
    END IF;
END Add_Launch_Pad_Root_Menu;

/*****************************************************************************
 Name :- Create_Launch_Pad
 Description :-This fucntion creates the lauchpad entry into FND_MENUS.
 Validations :-

         1. Generate the menu id internally
         2. Generate the menu name internally if null.
         3. Set the type to UNKNOWN if not passed from UI
         4. First create the Menu.
         5. Next create the association between menus and functions
         6. set the order of entry_sequence sequentially.
         7. call the menu function association API
 Input :-   p_menu_name
            p_user_menu_name
            p_menu_type
            p_description
            p_fucntion_ids
            p_fucntions_order
 Ouput :- New launchpad is created
 Creator :- ashankar
/******************************************************************************/

PROCEDURE Create_Launch_Pad
(
   p_commit                     IN              VARCHAR2 := FND_API.G_FALSE
  ,p_menu_name              IN      VARCHAR2 := NULL
  ,p_user_menu_name             IN      VARCHAR2
  ,p_menu_type              IN      VARCHAR2 :='UNKNOWN'
  ,p_description            IN      VARCHAR2
  ,p_fucntion_ids                   IN              VARCHAR2
  ,p_fucntions_order                IN              VARCHAR2 := NULL
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
) IS

 l_check_val          VARCHAR2(2);
 l_user_id            FND_MENUS.LAST_UPDATED_BY%TYPE := NULL;
 l_count              NUMBER :=0;
 l_fucntion_ids       VARCHAR2(32000);
 l_fucntion_id        VARCHAR2(10);
 l_menu_id            FND_MENUS.menu_id%TYPE;
 l_sequence           NUMBER;
 l_menu_name          FND_MENUS.menu_name%TYPE;

BEGIN

    SAVEPOINT CreateLaunchPad;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_user_menu_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT FND_MENUS_S.NEXTVAL
    INTO   l_menu_id
    FROM   DUAL;

    l_menu_name := p_menu_name;

    IF (l_menu_name IS NULL) THEN
      l_menu_name := get_Menu_Name(l_menu_id);
    END IF;

    l_check_val := validate_Menu_UserMenu_Names
                    (
                    p_menu_id       =>  l_menu_id
                   ,p_menu_name     =>  l_menu_name
                   ,p_user_menu_name    =>  UPPER(p_user_menu_name)
                    );

    IF (l_check_val<>'T') THEN

        FND_MESSAGE.SET_NAME('BSC','BSC_D_NAME_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

    ELSE

        BSC_LAUNCH_PAD_PVT.INSERT_APP_MENU_VB
         (
              X_MENU_ID        => l_menu_id
             ,X_MENU_NAME      => l_menu_name
             ,X_USER_MENU_NAME => p_user_menu_name
             ,X_MENU_TYPE      => p_menu_type
             ,X_DESCRIPTION    => p_description
             ,X_USER_ID        => get_User_Id
         );

      /*************************************************************************
       Now add the newly created launchpad to the root menus attached to the scorecard
      /*************************************************************************/

        Add_Launch_Pad_Root_Menu
        (
            p_Launchpad_Id  => l_menu_id
          , p_Description   => p_description
          , x_return_status => x_return_status
          , x_msg_count     => x_msg_count
          , x_msg_data      => x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_LAUNCH_PAD_PUB.Create_Launch_Pad Failed: at BSC_LAUNCH_PAD_PUB.Add_Launch_Pad_Root_Menu <'||x_msg_data||'>');
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      /*************************************************************************
       Create the association between the menus and the fucntions
      /*************************************************************************/

        IF (p_fucntion_ids IS NOT NULL) THEN
           l_fucntion_ids := p_fucntion_ids;
           WHILE (Is_More(  p_fucntion_ids   =>  l_fucntion_ids
                           ,p_fucntion_id    =>  l_fucntion_id)
                 )LOOP

                 l_sequence :=   (l_count + 1)*SEQ_MULTIPLIER;

                 Create_MenuFunction_Link
                 (
                      p_menu_id         => l_menu_id
                    , p_entry_sequence  => l_sequence
                    , p_function_id     => l_fucntion_id
                    , p_description     => p_description
                    , x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
                 );
               IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         --DBMS_OUTPUT.PUT_LINE('BSC_LAUNCH_PAD_PUB.Create_MenuFunction_Link Failed: at BSC_LAUNCH_PAD_PUB.Create_Launch_Pad <'||x_msg_data||'>');
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           l_count  := l_count + 1;
          END LOOP;
    END IF;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateLaunchPad;
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
        ROLLBACK TO CreateLaunchPad;
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
        ROLLBACK TO CreateLaunchPad;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Create_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Create_Launch_Pad ';
        END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO CreateLaunchPad;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Create_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Create_Launch_Pad ';
        END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Create_Launch_Pad;


/*****************************************************************************
 Name :- Retrieve_Launch_Pad
 Description :- This procedure will retrieve the metadata corresponding to the
                launchPad.This procedure should be called from update launchpad
 Input Parameters :- p_Menu_Id
                     x_launch_pad_Rec
 Out Parameters   :- x_launch_pad_Rec
 Creatore         :- ashankar
/******************************************************************************/

PROCEDURE Retrieve_Launch_Pad
(
     p_menu_id                  IN              NUMBER
    ,x_launch_pad_Rec           IN OUT NOCOPY   BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type
    ,x_return_status            OUT    NOCOPY   VARCHAR2
    ,x_msg_count                OUT    NOCOPY   NUMBER
    ,x_msg_data                 OUT    NOCOPY   VARCHAR2

) IS
BEGIN
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     SELECT  menu_id
            ,menu_name
            ,type
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,user_menu_name
            ,description
     INTO    x_launch_pad_Rec.Bsc_menu_id
            ,x_launch_pad_Rec.Bsc_menu_name
            ,x_launch_pad_Rec.Bsc_type
            ,x_launch_pad_Rec.Bsc_last_update_date
            ,x_launch_pad_Rec.Bsc_last_updated_by
            ,x_launch_pad_Rec.Bsc_last_update_login
            ,x_launch_pad_Rec.Bsc_user_menu_name
            ,x_launch_pad_Rec.Bsc_description
      FROM  FND_MENUS_VL
      WHERE menu_id = p_menu_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Retrieve_Launch_Pad ';
        ELSE
           x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Retrieve_Launch_Pad ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Retrieve_Tab_View ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Retrieve_Tab_View ';
       END IF;
       RAISE;
END Retrieve_Launch_Pad;

/*****************************************************************************
 Name :- Update_Launch_Pad
 Description :- This procedure will update the menu entries in the database.
                It will get the previous values from the database and check
                it with the new values. if the new values are being passed
                then they will be updated.. otherwise the old values will be
                retained.
 Input Parameters:- p_launch_pad_rec --> which holds the metadata of the menu.
 Output Parameters :- x_return_status
 creator :-ashankar
/******************************************************************************/

PROCEDURE Update_Launch_Pad
(
   p_launch_pad_rec             IN              BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
) IS

    l_launch_pad_rec            BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type;
    l_count                     NUMBER;

BEGIN
    SAVEPOINT UpdateLaunchPad;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_launch_pad_rec.Bsc_menu_id IS NOT NULL) THEN

         -- Bug #3236356
         l_count := is_Menu_Id_Valid(p_launch_pad_rec.Bsc_menu_id);

         IF(l_count =0) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
              FND_MESSAGE.SET_TOKEN('BSC_MENU', p_launch_pad_rec.Bsc_menu_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

    ELSE
              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
              FND_MESSAGE.SET_TOKEN('BSC_MENU', p_launch_pad_rec.Bsc_menu_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
    END IF;

    Retrieve_Launch_Pad
    (
         p_menu_id          =>      p_launch_pad_rec.Bsc_menu_id
        ,x_launch_pad_Rec   =>      l_launch_pad_rec
        ,x_return_status    =>      x_return_status
        ,x_msg_count        =>      x_msg_count
        ,x_msg_data         =>      x_msg_data
    );

    IF(p_launch_pad_rec.Bsc_menu_name IS NOT NULL) THEN
        l_launch_pad_rec.Bsc_menu_name := p_launch_pad_rec.Bsc_menu_name;
    END IF;

    IF(p_launch_pad_rec.Bsc_user_menu_name IS NOT NULL) THEN
        l_launch_pad_rec.Bsc_user_menu_name := p_launch_pad_rec.Bsc_user_menu_name;
    END IF;

    IF(p_launch_pad_rec.Bsc_description IS NOT NULL) THEN
        l_launch_pad_rec.Bsc_description := p_launch_pad_rec.Bsc_description;
    END IF;
    IF(p_launch_pad_rec.Bsc_last_update_login IS NOT NULL) THEN
        l_launch_pad_rec.Bsc_last_update_login := p_launch_pad_rec.Bsc_last_update_login;
    END IF;

    IF(p_launch_pad_rec.Bsc_type IS NOT NULL) THEN
        l_launch_pad_rec.Bsc_type := p_launch_pad_rec.Bsc_type;
    END IF;

    FND_MENUS_PKG.UPDATE_ROW
    (
         X_MENU_ID              => l_launch_pad_rec.Bsc_menu_id
        ,X_MENU_NAME            => l_launch_pad_rec.Bsc_menu_name
        ,X_USER_MENU_NAME       => l_launch_pad_rec.Bsc_user_menu_name
        ,X_MENU_TYPE            => l_launch_pad_rec.Bsc_type
        ,X_DESCRIPTION          => l_launch_pad_rec.Bsc_description
        ,X_LAST_UPDATE_DATE     => SYSDATE
        ,X_LAST_UPDATED_BY      => get_User_Id
        ,X_LAST_UPDATE_LOGIN    => 0
     );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateLaunchPad;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
                ,  p_count     =>  x_msg_count
                ,  p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateLaunchPad;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO UpdateLaunchPad;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Launch_Pad;



/*****************************************************************************
 Name   :- Update_Launch_Pad
 Description    :- This procedure will update the launchpad metadata.
                   It will validate if the menu name and the user menu name being
                   passed are unique or not.
                   It will remove all the associations of menus and fucntions and
                   recreate if any functions are there.
 Validations :-
              1. Check if the user_menu_name being passed is null or not.
                 if yes then throw the exception.
              2. Check for the validity of the menu id
              3. Check if the menu name is null then retrieve the menu name
              4. Validate menu name and user menu name for uniqueness
              5. First update the menu metadata.
              6. remove the menu and function assocation
              7. Recreate the associations if the fucnction ids are not null.

 Created by   :- ashankar 29-OCT-2003
/******************************************************************************/
PROCEDURE Update_Launch_Pad
(
   p_commit                     IN              VARCHAR2   := FND_API.G_FALSE
  ,p_menu_id                    IN              NUMBER
  ,p_menu_name                  IN              VARCHAR2   := NULL
  ,p_user_menu_name             IN              VARCHAR2
  ,p_menu_type                  IN              VARCHAR2
  ,p_description                IN              VARCHAR2
  ,p_fucntion_ids               IN              VARCHAR2
  ,p_fucntions_order            IN              VARCHAR2    := NULL
  ,x_return_status              OUT    NOCOPY   VARCHAR2
  ,x_msg_count                  OUT    NOCOPY   NUMBER
  ,x_msg_data                   OUT    NOCOPY   VARCHAR2
) IS
   l_check_val          VARCHAR2(2);
   l_launch_pad_rec     BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Rec_Type;
   l_fucntion_ids       VARCHAR2(32000);
   l_fucntion_id        VARCHAR2(10);
   l_sequence           NUMBER;
   l_menu_name          FND_MENUS.menu_name%TYPE;
   l_count              NUMBER :=0;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_menu_name := p_menu_name;

    IF(p_user_menu_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(p_menu_id IS NOT NULL) THEN
        -- Bug #3236356
        l_count := is_Menu_Id_Valid(p_menu_id);
         IF(l_count =0) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
              FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

    ELSE
              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
              FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF(l_menu_name IS NULL) THEN
      l_menu_name := get_Menu_Name_From_Menu_Id(p_Menu_Id => p_menu_id);
    END IF;

    l_check_val := validate_Menu_UserMenu_Names
                   (   p_menu_id        =>  p_menu_id
                      ,p_menu_name      =>  l_menu_name
                      ,p_user_menu_name =>  UPPER(p_user_menu_name)
                   );

    IF (l_check_val<>'T') THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_NAME_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
         l_launch_pad_rec.Bsc_menu_id := p_menu_id;
         l_launch_pad_rec.Bsc_menu_name := l_menu_name;
         l_launch_pad_rec.Bsc_user_menu_name := p_user_menu_name;
         l_launch_pad_rec.Bsc_description := p_description;

         BSC_LAUNCH_PAD_PUB.Update_Launch_Pad
         (
           p_launch_pad_rec     =>  l_launch_pad_rec
          ,x_return_status      =>  x_return_status
          ,x_msg_count          =>  x_msg_count
          ,x_msg_data           =>  x_msg_data
         );
       /****************************************************
         The logic here is to delete all the previous associations
         of the menus and fucntions and create the new asociations
         if there are any new fucntions
        1.Delete all the menu and fucntion asspciations
        2.Recreate the menu and the fucntion associations.
       /****************************************************/

         Delete_MenuFunction_Link
          (
             p_menu_id          => p_menu_id
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
          );

        /*****************************************************
         Check if the menu is having the fucntions attached
         to it. if yes then create the association between them.
        /*****************************************************/
         l_count :=0;
         IF (p_fucntion_ids IS NOT NULL) THEN
             l_fucntion_ids := p_fucntion_ids;

             WHILE (Is_More(  p_fucntion_ids   =>  l_fucntion_ids
                             ,p_fucntion_id    =>  l_fucntion_id)
                   )LOOP
                    l_sequence :=   (l_count    + 1)*SEQ_MULTIPLIER;

                    Create_MenuFunction_Link
                    (
                          p_menu_id         => p_menu_id
                        , p_entry_sequence  => l_sequence
                        , p_function_id     => l_fucntion_id
                        , p_description     => p_description
                        , x_return_status   => x_return_status
                        , x_msg_count       => x_msg_count
                        , x_msg_data        => x_msg_data
                     );
                     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --DBMS_OUTPUT.PUT_LINE('BSC_LAUNCH_PAD_PUB.Create_MenuFunction_Link Failed: at BSC_LAUNCH_PAD_PUB.Create_Launch_Pad <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                     l_count                := l_count + 1;
                 END LOOP;
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
            x_msg_data      :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad ';
        END IF;

        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Update_Launch_Pad;

/**************************************************************************************
 Name :- Delete_Root_Menu_LaunchPad
 Description :- This procedure will delete the entry of the launchpads from the rootmenus
                when the launchpad is deleted.
 Input :- p_Launch_pad_Id
 Creator :- ashankar 12-DEC-03
/**************************************************************************************/

PROCEDURE Delete_Root_Menu_LaunchPad
(
      p_Launch_Pad_Id                     FND_MENUS.menu_id%TYPE
    , x_return_status     OUT    NOCOPY   VARCHAR2
    , x_msg_count         OUT    NOCOPY   NUMBER
    , x_msg_data          OUT    NOCOPY   VARCHAR2
)IS
  l_Root_Menu_Tbl         BSC_LAUNCH_PAD_PUB.Bsc_LauchPad_Tbl_Type;
  l_root_menu_count       NUMBER;
  l_entry_sequence        FND_MENU_ENTRIES.Entry_Sequence%TYPE;

BEGIN
     SAVEPOINT DeleteRootMenuLaunchPad;
     FND_MSG_PUB.Initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     get_All_Root_Menu(x_Root_Menu_Tbl  => l_Root_Menu_Tbl);
     l_root_menu_count :=0;

     WHILE((l_root_menu_count)<=(l_Root_Menu_Tbl.COUNT - 1)) LOOP
        IF(BSC_LAUNCH_PAD_PVT.is_Launch_Pad_Attached(p_Menu_Id=>l_Root_Menu_Tbl(l_root_menu_count).Bsc_menu_id,p_Sub_Menu_Id =>p_Launch_pad_Id))THEN
          l_entry_sequence := BSC_LAUNCH_PAD_PVT.get_entry_sequence(p_Menu_Id=>l_Root_Menu_Tbl(l_root_menu_count).Bsc_menu_id,p_Sub_Menu_Id =>p_Launch_pad_Id);

          BSC_LAUNCH_PAD_PVT.DELETE_APP_MENU_ENTRIES_VB
          (
                X_Menu_Id        => l_Root_Menu_Tbl(l_root_menu_count).Bsc_menu_id
              , X_Entry_Sequence => l_entry_sequence
          );
        END IF;
        l_root_menu_count := l_root_menu_count + 1;
     END LOOP;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DeleteRootMenuLaunchPad;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    ROLLBACK TO DeleteRootMenuLaunchPad;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.Delete_Root_Menu_LaunchPad ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.Delete_Root_Menu_LaunchPad ';
    END IF;

END Delete_Root_Menu_LaunchPad;


/*===========================================================================+
|
|   Name:          Delte_Launch_Pad
|
|   Description:   It is a wrapper for FND_MENUS_PKG.DELETE_ROW function.
|                  This procedure is to be called from a JAVA Layer
|
|   Parameters:    x_menu_id - Menu id of the Launch Pad
|   Validations : need to check if the menu id being passed is the valid one or not.
|                 if not then throw the exception that the menu id is invalid /no menu exists
|                 by this id.if it is valid then only delete the menu. otherwise not.
|
|   Notes:
|
+============================================================================*/

PROCEDURE Delete_Launch_Pad
(
     p_menu_id              IN              NUMBER
    ,x_return_status        OUT    NOCOPY   VARCHAR2
    ,x_msg_count            OUT    NOCOPY   NUMBER
    ,x_msg_data             OUT    NOCOPY   VARCHAR2
) IS
    l_count       NUMBER;
BEGIN
  SAVEPOINT DelteLaunchPad;
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_menu_id IS NOT NULL) THEN

       -- Bug #3236356
       l_count := is_Menu_Id_Valid(p_menu_id);

       IF(l_count =0) THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
          FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  ELSE

          FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
          FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;

  END IF;

  FND_MENUS_PKG.DELETE_ROW
  (
    X_MENU_ID  => p_menu_id
  );

  Delete_Root_Menu_LaunchPad
  (
      p_Launch_Pad_Id   => p_menu_id
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );


  Delete_MenuFunction_Link
  (
     p_menu_id          => p_menu_id
    ,x_return_status    => x_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data
  );

  Delete_LaunchPad_Links
  (
        p_menu_id          => p_menu_id
    ,   x_return_status    => x_return_status
    ,   x_msg_count        => x_msg_count
    ,   x_msg_data         => x_msg_data

  );



EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO DelteLaunchPad;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN

      ROLLBACK TO DelteLaunchPad;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Delte_Launch_Pad ';
      ELSE
        x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Delte_Launch_Pad ';
      END IF;

      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Delete_Launch_Pad;


/************************************************************************************
 Description :- This procedure will remove the Launchpad entry from BSC_TAB_VIEW_LABELS_TL
                and BSC_TAB_VIEW_LABELS_B.This should be called from within the delete_launchpad
 Input Parameters :- 1.p_Menu_Id    menu_id

 output           :- return status
 Created BY       :- ashankar
/************************************************************************************/

PROCEDURE Delete_LaunchPad_Links
(
     p_menu_id              IN          NUMBER
    ,x_return_status        OUT NOCOPY  VARCHAR2
    ,x_msg_count            OUT NOCOPY  NUMBER
    ,x_msg_data             OUT NOCOPY  VARCHAR2
)IS
 l_Count        NUMBER;
 l_label_id     BSC_TAB_VIEW_LABELS_VL.label_id%TYPE;

 CURSOR c_Launch_Pad_Links IS
 SELECT Tab_id,Tab_view_id,Label_id
 FROM   BSC_TAB_VIEW_LABELS_VL
 WHERE  LINK_ID = p_menu_id
 AND    LABEL_TYPE =2;

BEGIN
    SAVEPOINT  deletelaunchpadlinks;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_menu_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
        FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR cd IN c_Launch_Pad_Links LOOP
        DELETE FROM BSC_TAB_VIEW_LABELS_TL
        WHERE  Tab_Id      = cd.Tab_Id
        AND    Tab_view_id = cd.Tab_view_id
        AND    Label_id    = cd.Label_id;

        DELETE FROM BSC_TAB_VIEW_LABELS_B
        WHERE  Tab_Id      = cd.Tab_Id
        AND    Tab_view_id = cd.Tab_view_id
        AND    Label_id    = cd.Label_id;
    END LOOP;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

   IF(c_Launch_Pad_Links%ISOPEN) THEN
      CLOSE c_Launch_Pad_Links;
   END IF;

   ROLLBACK TO deletelaunchpadlinks;
   IF (x_msg_data IS NULL) THEN
       FND_MSG_PUB.Count_And_Get
       (            p_encoded    =>  FND_API.G_FALSE
                 ,   p_count     =>  x_msg_count
                 ,   p_data      =>  x_msg_data
       );
   END IF;
   --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
   x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN

    IF(c_Launch_Pad_Links%ISOPEN) THEN
          CLOSE c_Launch_Pad_Links;
    END IF;

    ROLLBACK TO deletelaunchpadlinks;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Delete_LaunchPad_Links ';
    ELSE
      x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Delete_LaunchPad_Links ';
    END IF;

  --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_LaunchPad_Links;


/************************************************************************************
                        FORM FUNCTION ROUTINES (FOR LINKS)
*************************************************************************************/

/************************************************************************************
 Description :- This procedure will remove the menu and fucntion association.
                This procedure should be called while upadting the lauchpads.
 Input Parameters :- 1.p_Menu_Id    menu_id
                     2.p_entry_sequence   order of fucntions/submenu within the menu
 output           :- return status
 Created BY       :- ashankar
/************************************************************************************/

PROCEDURE Delete_MenuFunction_Link
(
     p_menu_id              IN          NUMBER
    ,x_return_status        OUT NOCOPY  VARCHAR2
    ,x_msg_count            OUT NOCOPY  NUMBER
    ,x_msg_data             OUT NOCOPY  VARCHAR2
)IS

    CURSOR c_menu_entries IS
    SELECT entry_sequence
    FROM   FND_MENU_ENTRIES
    WHERE  menu_id = p_menu_id;
BEGIN
      SAVEPOINT  deletemenufunctionlink;
      FND_MSG_PUB.Initialize;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_menu_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
        FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF(c_menu_entries%ISOPEN) THEN
            CLOSE c_menu_entries;
      END IF;

      FOR cd IN c_menu_entries LOOP

        FND_MENU_ENTRIES_PKG.DELETE_ROW
         (
            X_MENU_ID           => p_menu_id
           ,X_ENTRY_SEQUENCE    => cd.entry_sequence
         );
      END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

   IF(c_menu_entries%ISOPEN) THEN
      CLOSE c_menu_entries;
   END IF;

   ROLLBACK TO deletemenufunctionlink;
   IF (x_msg_data IS NULL) THEN
       FND_MSG_PUB.Count_And_Get
       (            p_encoded    =>  FND_API.G_FALSE
                 ,   p_count     =>  x_msg_count
                 ,   p_data      =>  x_msg_data
       );
   END IF;
   --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
   x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN

    IF(c_menu_entries%ISOPEN) THEN
          CLOSE c_menu_entries;
    END IF;

    ROLLBACK TO deletemenufunctionlink;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Delete_MenuFunction_Link ';
    ELSE
      x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Delete_MenuFunction_Link ';
    END IF;

  --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_MenuFunction_Link;

/************************************************************************************
 Create_MenuFunction_Link
 Description :- This procedure will create the menu and the fucntion association
 Input Parameters :- 1.p_Menu_Id
                     2.p_entry_sequence
                     3.p_function_id
                     4.p_description
 output           :- return status
 Created BY       :- ashankar
/************************************************************************************/

PROCEDURE Create_MenuFunction_Link
(
      p_menu_id                  IN          NUMBER
    , p_entry_sequence           IN          NUMBER
    , p_function_id              IN          NUMBER
    , p_description              IN          VARCHAR2
    , x_return_status           OUT NOCOPY   VARCHAR2
    , x_msg_count               OUT NOCOPY   NUMBER
    , x_msg_data                OUT NOCOPY   VARCHAR2

) IS
    row_id             VARCHAR2(30);
    l_user_id          NUMBER ;
BEGIN
      FND_MSG_PUB.Initialize;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_menu_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
        FND_MESSAGE.SET_TOKEN('BSC_MENU', p_menu_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_entry_sequence IS NULL) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_ENTRY_SEQUENCE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_user_id := get_User_Id;

      FND_MENU_ENTRIES_PKG.INSERT_ROW
      (      X_ROWID                =>  row_id
            ,X_MENU_ID              =>  p_menu_id
            ,X_ENTRY_SEQUENCE       =>  p_entry_sequence
            ,X_SUB_MENU_ID          =>  NULL
            ,X_FUNCTION_ID          =>  p_function_id
            ,X_GRANT_FLAG           =>  'Y'
            ,X_PROMPT               =>  NULL
            ,X_DESCRIPTION          =>  p_description
            ,X_CREATION_DATE        =>  SYSDATE
            ,X_CREATED_BY           =>  l_user_id
            ,X_LAST_UPDATE_DATE     =>  SYSDATE
            ,X_LAST_UPDATED_BY      =>  l_user_id
            ,X_LAST_UPDATE_LOGIN    =>  0
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

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (x_msg_data IS NOT NULL) THEN
     x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Create_MenuFunction_Link ';
    ELSE
      x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Create_MenuFunction_Link ';
    END IF;

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_MenuFunction_Link;

/*===========================================================================+
|
|   Name:          INSERT_FORM_FUNCTION_VB
|
|   Description:   This procedure creates  a new fucntion in FND_FORM_FUNCTIONS
|                  metadata.It will also return the fucntion id of the newly created
|                  function.The transaction is still not commited. It will be done from
|                  the UI only.
|   Input Parameters :-  p_user_function_name  --> cannot be null
|                        p_url                 --> can be null
|                        p_type                --> by default 'WWW'
|
|   Out Parameters:
|                        p_function_id         --> needs to be generated
+============================================================================*/

PROCEDURE Create_Launch_Pad_Link
(
   p_commit                 IN              VARCHAR2   := FND_API.G_FALSE
 , p_user_function_name     IN              VARCHAR2
 , p_url                    IN              VARCHAR2
 , p_type                   IN              VARCHAR2 :='WWW'
 , x_function_id            OUT    NOCOPY   FND_FORM_FUNCTIONS.function_id% TYPE
 , x_return_status          OUT    NOCOPY   VARCHAR2
 , x_msg_count              OUT    NOCOPY   NUMBER
 , x_msg_data               OUT    NOCOPY   VARCHAR2
) IS

l_function_id       FND_FORM_FUNCTIONS.function_id% TYPE;
l_function_name     FND_FORM_FUNCTIONS.function_name%TYPE;
l_ret_val           VARCHAR2(2);
l_user_id           NUMBER := NULL;
row_id              VARCHAR2(30);
l_url               FND_FORM_FUNCTIONS.web_host_name%TYPE;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_user_function_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'FUCNTION_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    SELECT FND_FORM_FUNCTIONS_S.NEXTVAL
    INTO l_function_id
    FROM DUAL;

    l_function_name := 'BSC_LINKS_'||l_function_id;
    l_user_id       :=  get_User_Id;


    FND_FORM_FUNCTIONS_PKG.INSERT_ROW
        (
               X_ROWID                  => row_id,
               X_FUNCTION_ID            => l_function_id,
               X_WEB_HOST_NAME          => SUBSTR(p_url,1,79),
               X_WEB_AGENT_NAME         => NULL,
               X_WEB_HTML_CALL          => p_url,
               X_WEB_ENCRYPT_PARAMETERS => 'N',
               X_WEB_SECURED            => 'N',
               X_WEB_ICON               => NULL,
               X_OBJECT_ID              => NULL,
               X_REGION_APPLICATION_ID  => NULL,
               X_REGION_CODE            => NULL,
               X_FUNCTION_NAME          => l_function_name,
               X_APPLICATION_ID         => 271,
               X_FORM_ID                => NULL,
               X_PARAMETERS             => NULL,
               X_TYPE                   => p_type,
               X_USER_FUNCTION_NAME     => p_user_function_name,
               X_DESCRIPTION            => p_url,
               X_CREATION_DATE          => SYSDATE,
               X_CREATED_BY             => l_user_id,
               X_LAST_UPDATE_DATE       => SYSDATE,
               X_LAST_UPDATED_BY        => l_user_id,
               X_LAST_UPDATE_LOGIN      => 0
    );

      x_function_id := l_function_id;

      IF (p_commit = FND_API.G_TRUE) THEN
        commit;
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

WHEN OTHERS THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF (x_msg_data IS NOT NULL) THEN
    x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Create_Launch_Pad_Link ';
  ELSE
    x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Create_Launch_Pad_Link ';
  END IF;

  --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Create_Launch_Pad_Link;


/******************************************************************************
 Description :- This procedure deletes the lauchpad link and its association with
                the menus.First it deletes the lauchpad link and then removes the
                association of the lauchpad links with all the menus using it.
 Input       :- Function_Id

 Creator :-ashankar
/*******************************************************************************/


PROCEDURE Delete_Launch_Pad_Link
(
       p_fucntion_id            IN     FND_FORM_FUNCTIONS.function_id%TYPE
     , x_return_status          OUT    NOCOPY   VARCHAR2
     , x_msg_count              OUT    NOCOPY   NUMBER
     , x_msg_data               OUT    NOCOPY   VARCHAR2
)IS

    CURSOR c_menu_functions IS
    SELECT MENU_ID,
           ENTRY_SEQUENCE
    FROM   FND_MENU_ENTRIES_VL
    WHERE  FUNCTION_ID = p_fucntion_id;

    l_menu_id               FND_MENU_ENTRIES_VL.menu_id%TYPE;
    l_entrysequence         FND_MENU_ENTRIES_VL.entry_sequence%TYPE;
    l_count                 NUMBER;

BEGIN
    SAVEPOINT deletelauchpadlink;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_fucntion_id IS NOT NULL) THEN

         -- Bug #3236356
         SELECT COUNT(0)
         INTO   l_count
         FROM   FND_FORM_FUNCTIONS_TL
         WHERE  FUNCTION_ID = p_fucntion_id;

              IF(l_count =0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
                FND_MESSAGE.SET_TOKEN('BSC_MENU', p_fucntion_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

        ELSE

              FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_MENU_ID');
              FND_MESSAGE.SET_TOKEN('BSC_MENU', p_fucntion_id);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;

    END IF;

    FND_FORM_FUNCTIONS_PKG.DELETE_ROW(X_FUNCTION_ID => p_fucntion_id);

    IF (c_menu_functions%ISOPEN) THEN
      CLOSE c_menu_functions;
    END IF;

    FOR cd IN c_menu_functions LOOP

      l_menu_id := cd.menu_id;
      l_entrysequence := cd.entry_sequence;

      FND_MENU_ENTRIES_PKG.DELETE_ROW
      (
           X_MENU_ID        => l_menu_id
          ,X_ENTRY_SEQUENCE => l_entrysequence
      );

    END LOOP;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
    --DBMS_OUTPUT.PUT_LINE('p_fucntion_id---> '||p_fucntion_id);
    IF (c_menu_functions%ISOPEN) THEN
          CLOSE c_menu_functions;
    END IF;

    ROLLBACK TO deletelauchpadlink;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
            ,  p_count     =>  x_msg_count
            ,  p_data      =>  x_msg_data
        );
    END IF;

    --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
    x_return_status :=  FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('p_fucntion_id others---> '||p_fucntion_id);
    IF (c_menu_functions%ISOPEN) THEN
          CLOSE c_menu_functions;
    END IF;

    ROLLBACK TO deletelauchpadlink;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_PUB.delete_Custom_View ';
    END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Launch_Pad_Link;

/****************************************************************************
 Name :- Update_Launch_Pad_Link
 Description :- This procedure will update the Form Function in the FND_FORM_FUCNTIONS.
                It should be called only for those launchpad links whose short_name
                starts with 'BSC'
 Input :- p_user_function_name
          p_url
          p_type
          p_function_id
 Creator :-ashankar
/****************************************************************************/


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
) IS

l_function_name     FND_FORM_FUNCTIONS.function_name%TYPE;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_user_function_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'FUCNTION_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_user_function_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'ADD_URL'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_function_name := get_Form_Function_Name(p_function_id);

        BSC_LAUNCH_PAD_PVT.UPDATE_FORM_FUNCTION_VB
        (
              X_FUNCTION_ID              => p_function_id
            , X_WEB_HOST_NAME            => SUBSTR(p_url,1,79)
            , X_WEB_AGENT_NAME           => NULL
            , X_WEB_HTML_CALL            => p_url
            , X_WEB_ENCRYPT_PARAMETERS   => 'N'
            , X_WEB_SECURED              => 'N'
            , X_WEB_ICON                 => NULL
            , X_OBJECT_ID                => NULL
            , X_REGION_APPLICATION_ID    => NULL
            , X_REGION_CODE              => NULL
            , X_FUNCTION_NAME            => l_function_name
            , X_APPLICATION_ID           => 271
            , X_FORM_ID                  => NULL
            , X_PARAMETERS               => NULL
            , X_TYPE                     => p_type
            , X_USER_FUNCTION_NAME       => p_user_function_name
            , X_DESCRIPTION              => p_url
            , X_USER_ID                  => get_User_Id
        );


     IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
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

WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data :=  x_msg_data||' -> BSC_LAUNCH_PAD_PUB.Update_Launch_Pad_Link ';
     ELSE
        x_msg_data :=  SQLERRM||' at BSC_LAUNCH_PAD_PUB.Update_Launch_Pad_Link ';
     END IF;
      --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Launch_Pad_Link;

/*
  is_Menu_Id_Valid added for Bug #3236356
*/

FUNCTION is_Menu_Id_Valid
(
  p_Menu_Id         IN NUMBER
)RETURN NUMBER IS

  l_count   NUMBER := 0;

BEGIN
  SELECT COUNT(0)
  INTO   l_count
  FROM   FND_MENUS_TL
  WHERE  MENU_ID = p_Menu_Id;


  RETURN l_count;
END is_Menu_Id_Valid;

END BSC_LAUNCH_PAD_PUB;


/
