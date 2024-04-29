--------------------------------------------------------
--  DDL for Package Body BIS_OBJECT_EXTENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_OBJECT_EXTENSIONS_PUB" AS
/* $Header: BISPEXTB.pls 120.1 2005/11/17 05:54:35 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPEXTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the extension tables        |
REM |             - BIS_MEASURES_EXTENSION_TL                               |
REM |             - BIS_FORM_FUNCTION_EXTENSION_TL                          |
REM | NOTES                                                                 |
REM | 08-DEC-2004 Krishna  Created.                                         |
REM | 27-DEC-2004 ashankar  Added the following methods                     |
REM |                       1.Validate_Object_Mapping                       |
REM |                       2.Measure_Funct_Area_Map                        |
REM |                       3.Form_Func_Functional_Area_Map                 |
REM |                       4.Are_Obj_Func_Area_Mapped                      |
REM | 19-MAY-2005  visuri   GSCC Issues bug 4363854                         |
REM | 17-Nov-2005  akoduri  bug4725352: Issue in translating seed data      |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_OBJECT_EXTENSIONS_PUB';
FUNCTION Get_FA_Id_By_Short_Name (p_Functional_Area_Short_Name IN VARCHAR2)RETURN NUMBER;

PROCEDURE Validate_Measure_Extension(
  p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,p_Action_Type         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Form_Func_Extension(
    p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  p_Action_Type         IN          VARCHAR2
 ,  x_Return_Status       OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count           OUT NOCOPY  NUMBER
 ,  x_Msg_Data            OUT NOCOPY  VARCHAR2
);

/***************************************************
           Functional Area Mapping APIS start
/***************************************************/
FUNCTION Validate_Object_Mapping
(
    p_object_type         IN          VARCHAR2
 ,  p_object_name         IN          VARCHAR2
) RETURN NUMBER;


PROCEDURE Measure_Funct_Area_Map
(
        p_Api_Version         IN          NUMBER
    ,   p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_Obj_Type            IN          VARCHAR2
    ,   p_Obj_Name            IN          VARCHAR2
    ,   p_App_Id              IN          NUMBER
    ,   p_Func_Area_Sht_Name  IN          VARCHAR2
    ,   x_Return_Status       OUT NOCOPY  VARCHAR2
    ,   x_Msg_Count           OUT NOCOPY  NUMBER
    ,   x_Msg_Data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Form_Func_Functional_Area_Map
(
        p_Api_Version         IN          NUMBER
    ,   p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_Obj_Type            IN          VARCHAR2
    ,   p_Obj_Name            IN          VARCHAR2
    ,   p_App_Id              IN          NUMBER
    ,   p_Func_Area_Sht_Name  IN          VARCHAR2
    ,   x_Return_Status       OUT NOCOPY  VARCHAR2
    ,   x_Msg_Count           OUT NOCOPY  NUMBER
    ,   x_Msg_Data            OUT NOCOPY  VARCHAR2
);

/***************************************************
           Functional Area Mapping Ends Here
/***************************************************/

/*********************************************************************************************
        FUNCTION Name :- Retrieve_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- This record details sent from UI
            x_Form_Func_Extn_Rec :- This record sends the details for form given form function to caller
        DESCRIPTION   :- This retrieves the details of give form function name
        AUTHOR        :- KRISHNA
*********************************************************************************************/
PROCEDURE Retrieve_Form_Func_Extension(
    p_Form_Func_Extn_Rec      IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Form_Func_Extn_Rec      OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Return_Status           OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count               OUT NOCOPY  NUMBER
 ,  x_Msg_Data                OUT NOCOPY  VARCHAR2
)IS

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension(
        p_Form_Func_Extn_Rec  => p_Form_Func_Extn_Rec
     ,  x_Form_Func_Extn_Rec  => x_Form_Func_Extn_Rec
     ,  x_Return_Status       => x_Return_Status
     ,  x_Msg_Count           => x_Msg_Count
     ,  x_Msg_Data            => x_Msg_Data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line('after retrieve');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Form_Func_Extension ';
        END IF;
END Retrieve_Form_Func_Extension;
/*********************************************************************************************
        FUNCTION Name :- Translate_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- The Details of form function sent from UI
        DESCRIPTION   :- This basically updates the properties for form functions
                         This can be called from UI directly also
        AUTHOR        :- KRISHNA
*********************************************************************************************/
PROCEDURE Translate_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_Commit                VARCHAR2(30);

BEGIN
    SAVEPOINT  TransalteFormFuncPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('calling validate from trans');
    --dbms_output.put_line('the value i am passing for tarns is :- '||BIS_OBJECT_EXTENSIONS_PKG.C_TRANS);
    Validate_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  p_Action_Type         =>  BIS_OBJECT_EXTENSIONS_PUB.C_TRANS
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Translate_Form_Func_Extension(
        p_Api_Version         =>  p_Api_Version
     ,  p_Commit              =>  p_Commit
     ,  p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO TransalteFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TransalteFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TransalteFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Translate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Translate_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TransalteFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Translate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Translate_Form_Func_Extension ';
        END IF;
END Translate_Form_Func_Extension;
/*********************************************************************************************
        FUNCTION Name :- Update_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- The Details of form function sent from UI for update
        DESCRIPTION   :- This basically updates the properties for form functions
                         This can be called from UI also
        AUTHOR        :- KRISHNA
*********************************************************************************************/
PROCEDURE Update_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_Commit                VARCHAR2(30);

BEGIN
    SAVEPOINT  UpdateFormFuncPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('i am calling validate from update ');
    Validate_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  p_Action_Type         =>  BIS_OBJECT_EXTENSIONS_PUB.C_UPDATE
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Update_Form_Func_Extension(
        p_Api_Version         =>  p_Api_Version
     ,  p_Commit              =>  p_Commit
     ,  p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
     );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension ';
        END IF;
END Update_Form_Func_Extension;
/*********************************************************************************************
        FUNCTION Name :- Create_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- The Details of form function sent from UI for create
        DESCRIPTION   :- Creates the new form function
        AUTHOR        :- KRISHNA
*********************************************************************************************/
PROCEDURE Create_Form_Func_Extension(
    p_Api_Version         IN          NUMBER
 ,  p_Commit              IN          VARCHAR2
 ,  p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Return_Status       OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count           OUT NOCOPY  NUMBER
 ,  x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_Commit        VARCHAR2(30);
    l_Form_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;

BEGIN
    SAVEPOINT  CreateFormFuncPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('i am calling validate from create ');
    Validate_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
    ,   p_Action_Type         =>  BIS_OBJECT_EXTENSIONS_PUB.C_CREATE
    ,   x_Return_Status       =>  x_Return_Status
    ,   x_Msg_Count           =>  x_Msg_Count
    ,   x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Create_Form_Func_Extension(
        p_Api_Version         =>  p_Api_Version
     ,  p_Commit              =>  p_Commit
     ,  p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension ';
        END IF;
END Create_Form_Func_Extension;
/*********************************************************************************************
        FUNCTION Name :- Load_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- The properites of Form function
        DESCRIPTION   :- This is the main function that is being called from ldt/UI
                         And this calls relevant APIs
        AUTHOR        :- KRISHNA
*********************************************************************************************/
PROCEDURE Load_Form_Func_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,p_Custom_mode         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS

l_Commit                VARCHAR2(30);
l_Count                 NUMBER;
l_Form_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
BEGIN
    SAVEPOINT  LoadFormFuncPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;

    Validate_Form_Func_Extension(
       p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     , p_Action_Type         =>  BIS_OBJECT_EXTENSIONS_PUB.C_LOAD
     , x_Return_Status       =>  x_Return_Status
     , x_Msg_Count           =>  x_Msg_Count
     , x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Form_Func_Extn_Rec  =>  l_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    l_Form_Func_Extn_Rec := p_Form_Func_Extn_Rec;
    l_Form_Func_Extn_Rec.Func_Area_Id := Get_FA_Id_By_Short_Name(p_Form_Func_Extn_Rec.Func_Area_short_name);
        BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension(
            p_Api_Version         =>  p_Api_Version
         ,  p_Commit              =>  p_Commit
         ,  p_Form_Func_Extn_Rec  =>  l_Form_Func_Extn_Rec
         ,  x_Return_Status       =>  x_Return_Status
         ,  x_Msg_Count           =>  x_Msg_Count
         ,  x_Msg_Data            =>  x_Msg_Data
        );
    ELSE
        IF (FND_LOAD_UTIL.UPLOAD_TEST(p_Form_Func_Extn_Rec.Last_Updated_By
                                    , p_Form_Func_Extn_Rec.Last_Update_Date
                                    , l_Form_Func_Extn_Rec.Last_Updated_By
                                    , l_Form_Func_Extn_Rec.Last_Update_Date
                                    , p_Custom_mode)) THEN
            l_Form_Func_Extn_Rec := p_Form_Func_Extn_Rec;
            l_Form_Func_Extn_Rec.Func_Area_Id := Get_FA_Id_By_Short_Name(p_Form_Func_Extn_Rec.Func_Area_short_name);
            BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension(
                p_Api_Version         =>  p_Api_Version
             ,  p_Commit              =>  p_Commit
             ,  p_Form_Func_Extn_Rec  =>  l_Form_Func_Extn_Rec
             ,  x_Return_Status       =>  x_Return_Status
             ,  x_Msg_Count           =>  x_Msg_Count
             ,  x_Msg_Data            =>  x_Msg_Data
            );
        END IF;
    END IF;
    --dbms_output.put_line('func  short name i sent is :- '|| l_Form_Func_Extn_Rec.Func_Area_short_name);

   IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LoadFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LoadFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LoadFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Load_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Load_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO LoadFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Load_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Load_Form_Func_Extension ';
        END IF;
END Load_Form_Func_Extension;
/*********************************************************************************************
        FUNCTION Name :- Delete_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- The properites of Form function
        DESCRIPTION   :- This is the main function that is being called from ldt/UI
                         And this calls relevant APIs
        AUTHOR        :- KRISHNA
*********************************************************************************************/

PROCEDURE Delete_Form_Func_Extension(
    p_Api_Version         IN          NUMBER
 ,  p_Commit              IN          VARCHAR2
 ,  p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,  x_Return_Status       OUT NOCOPY  VARCHAR2
 ,  x_Msg_Count           OUT NOCOPY  NUMBER
 ,  x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_Commit        VARCHAR2(30);
    l_Form_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;

BEGIN
    SAVEPOINT  DeleteFormFuncPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('i am calling validate from create ');
    Validate_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
    ,   p_Action_Type         =>  BIS_OBJECT_EXTENSIONS_PUB.C_DELETE
    ,   x_Return_Status       =>  x_Return_Status
    ,   x_Msg_Count           =>  x_Msg_Count
    ,   x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Delete_Form_Func_Extension(
        p_Api_Version         =>  p_Api_Version
     ,  p_Commit              =>  p_Commit
     ,  p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteFormFuncPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteFormFuncPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension ';
        END IF;
END Delete_Form_Func_Extension;


/*
MEASURE EXTENSION APIS

*/

PROCEDURE Create_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

BEGIN
    SAVEPOINT CreateMeasExtnPSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,p_Action_Type    => C_CREATE
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_OBJECT_EXTENSIONS_PVT.Create_Measure_Extension(
       p_Api_Version    => p_Api_Version
      ,p_Commit         => p_Commit
      ,p_Meas_Extn_Rec  => p_Meas_Extn_Rec
      ,x_Return_Status  => x_Return_Status
      ,x_Msg_Count      => x_Msg_Count
      ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension ';
        END IF;

END Create_Measure_Extension;


PROCEDURE Retrieve_Measure_Extension(
  p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Meas_Extn_Rec       OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,x_Meas_Extn_Rec  => x_Meas_Extn_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Measure_Extension ';
        END IF;
END Retrieve_Measure_Extension;


PROCEDURE Translate_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Meas_Extn_Rec   BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
BEGIN

    SAVEPOINT TranslateMeasExtnPSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Meas_Extn_Rec := p_Meas_Extn_Rec;

    ------dbms_output.put_line ('l_Meas_Extn_Rec.Measure_Short_Name - ' || l_Meas_Extn_Rec.Measure_Short_Name);

    Validate_Measure_Extension(
      p_Meas_Extn_Rec  => l_Meas_Extn_Rec
     ,p_Action_Type    => BIS_OBJECT_EXTENSIONS_PUB.C_TRANS
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension(
      p_Api_Version         =>  p_Api_Version
     ,p_Commit              =>  p_Commit
     ,p_Meas_Extn_Rec       =>  p_Meas_Extn_Rec
     ,x_Return_Status       =>  x_Return_Status
     ,x_Msg_Count           =>  x_Msg_Count
     ,x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO TranslateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TranslateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TranslateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Translate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Translate_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TranslateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Translate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Translate_Measure_Extension ';
        END IF;

END Translate_Measure_Extension;

-- Update the Measure Extensions
PROCEDURE Update_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

BEGIN
    SAVEPOINT UpdateMeasExtnPSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    Validate_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,p_Action_Type    => BIS_OBJECT_EXTENSIONS_PUB.C_UPDATE
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_OBJECT_EXTENSIONS_PVT.Update_Measure_Extension(
        p_Api_Version    => p_Api_Version
       ,p_Commit         => p_Commit
       ,p_Meas_Extn_Rec  => p_Meas_Extn_Rec
       ,x_Return_Status  => x_Return_Status
       ,x_Msg_Count      => x_Msg_Count
       ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension ';
        END IF;
END Update_Measure_Extension;

PROCEDURE Load_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,p_Custom_mode         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Meas_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
    l_Mes_up_Rec       BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
 BEGIN
    SAVEPOINT LoadMeasExtnPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    Validate_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,p_Action_Type    => C_LOAD
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
        --dbms_output.put_line('func  short name i sent is :- '|| p_Meas_Extn_Rec.Func_Area_short_name);

    BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Measure_Extension(
      p_Meas_Extn_Rec   => p_Meas_Extn_Rec
     ,x_Meas_Extn_Rec   => l_Meas_Extn_Rec
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    l_Meas_Extn_Rec.Functional_Area_Id := Get_FA_Id_By_Short_Name(p_Meas_Extn_Rec.Func_Area_Short_Name);
    --dbms_output.put_line('l_Meas_Extn_Rec.Measure_Short_NAme --- ' || l_Meas_Extn_Rec.Measure_Short_Name || '* ' ||x_Return_Status || '* ' ||FND_API.G_RET_STS_SUCCESS);

    IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN -- this is the create mode.

       --dbms_output.put_line('In create Mode ' ||x_return_status);

       l_Meas_Extn_Rec := p_Meas_Extn_Rec;
       l_Meas_Extn_Rec.Functional_Area_Id := Get_FA_Id_By_Short_Name(p_Meas_Extn_Rec.Func_Area_Short_Name);

       IF ((l_Meas_Extn_Rec.Functional_Area_Id IS NULL) AND (l_Meas_Extn_Rec.Func_Area_Short_Name IS NOT NULL)) THEN
          l_Meas_Extn_Rec.Functional_Area_Id := Get_FA_Id_By_Short_Name(l_Meas_Extn_Rec.Func_Area_Short_Name);
          IF (l_Meas_Extn_Rec.Functional_Area_Id = C_INVALID) THEN
              FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_NOT_EXISTS');
              FND_MESSAGE.SET_TOKEN('SHORT_NAME', l_Meas_Extn_Rec.Func_Area_Short_Name);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

       BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension(
          p_Api_Version    => p_Api_Version
         ,p_Commit         => p_Commit
         ,p_Meas_Extn_Rec  => l_Meas_Extn_Rec
         ,x_Return_Status  => x_Return_Status
         ,x_Msg_Count      => x_Msg_Count
         ,x_Msg_Data       => x_Msg_Data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    ELSE
     --dbms_output.put_line('FOCE LOAD VALUE IS :-'|| p_Custom_mode);
     --dbms_output.put_line('I AM GOING TO UPDATE FOR MEASURES' );
        IF (FND_LOAD_UTIL.UPLOAD_TEST(p_Meas_Extn_Rec.Last_Updated_By
                                    , p_Meas_Extn_Rec.Last_Update_Date
                                    , l_Meas_Extn_Rec.Last_Updated_By
                                    , l_Meas_Extn_Rec.Last_Update_Date
                                    , p_Custom_mode)) THEN
           --dbms_output.put_line('UPLDOATE SUCESS I AM GOING TO UPDATE FOR MEASURES' );
           l_Mes_up_Rec :=  p_Meas_Extn_Rec;
           l_Mes_up_Rec.Functional_Area_Id := Get_FA_Id_By_Short_Name(p_Meas_Extn_Rec.Func_Area_Short_Name);
           BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension(
              p_Api_Version    => p_Api_Version
             ,p_Commit         => p_Commit
             ,p_Meas_Extn_Rec  => l_Mes_up_Rec
             ,x_Return_Status  => x_Return_Status
             ,x_Msg_Count      => x_Msg_Count
             ,x_Msg_Data       => x_Msg_Data
           );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LoadMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LoadMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LoadMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Load_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Load_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO LoadMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Load_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Load_Measure_Extension ';
        END IF;
END Load_Measure_Extension;
/*********************************************************************************************
        FUNCTION Name :- Delete_Measure_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec:- The Record containing all the vlaues of form function tables
        DESCRIPTION   :- This fucntions takes care of all validations based on action type
        AUTHOR        :- KRISHNA
*********************************************************************************************/


PROCEDURE Delete_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Commit        VARCHAR2(30);
BEGIN
    SAVEPOINT DeleteMeasExtnPSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;

    Validate_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,p_Action_Type    => C_DELETE
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_OBJECT_EXTENSIONS_PVT.Delete_Measure_Extension(
       p_Api_Version    => p_Api_Version
      ,p_Commit         => p_Commit
      ,p_Meas_Extn_Rec  => p_Meas_Extn_Rec
      ,x_Return_Status  => x_Return_Status
      ,x_Msg_Count      => x_Msg_Count
      ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteMeasExtnPSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteMeasExtnPSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension ';
        END IF;

END Delete_Measure_Extension;

-- Get the Functional Area ID from Functional Short_Name
FUNCTION Get_FA_Id_By_Short_Name (
  p_Functional_Area_Short_Name IN VARCHAR2
)RETURN NUMBER IS
  l_FA_Id   NUMBER;
BEGIN
  SELECT FUNCTIONAL_AREA_ID
  INTO   l_FA_Id
  FROM   BIS_FUNCTIONAL_AREAS
  WHERE  UPPER(SHORT_NAME) = UPPER(Trim(p_Functional_Area_Short_Name));

  RETURN l_FA_Id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN C_INVALID;
END Get_FA_Id_By_Short_Name;

-- Validation APIs
PROCEDURE Validate_Measure_Extension(
  p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,p_Action_Type         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Count           NUMBER;
    l_Meas_Extn_Rec   BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Meas_Extn_Rec := p_Meas_Extn_Rec;
    l_Count := 0;

    IF (BIS_UTILITIES_PVT.Value_Missing_Or_Null(TRIM(p_Meas_Extn_Rec.Measure_Short_Name)) = FND_API.G_TRUE) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_MX_SHORT_NAME_IS_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --dbms_output.put_line('FROM CREATE 1');
    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_UPDATE OR  p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_CREATE)  THEN
      IF(Trim(l_Meas_Extn_Rec.Functional_Area_Id) IS NULL) THEN
          FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_ID_NOT_ENTERED');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(BIS_UTILITIES_PVT.Value_Missing_Or_Null(p_Meas_Extn_Rec.Functional_Area_Id) = FND_API.G_FALSE) THEN
        SELECT COUNT(1) INTO l_Count
        FROM   BIS_FUNCTIONAL_AREAS B
        WHERE  B.FUNCTIONAL_AREA_ID = p_Meas_Extn_Rec.Functional_Area_Id;

        IF (l_Count = 0) THEN
          FND_MESSAGE.SET_NAME('BIS','BIS_FUNCID_WRONG');
          FND_MESSAGE.SET_TOKEN('FORM_FUNC',TRIM(p_Meas_Extn_Rec.Functional_Area_Id));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   BIS_MEASURES_EXTENSION
    WHERE  UPPER(MEASURE_SHORT_NAME) = UPPER(Trim(l_Meas_Extn_Rec.Measure_Short_Name));
        --------dbms_output.put_line('FROM CREATE 2' || p_Action_Type);
    IF (p_Action_Type = C_CREATE) THEN
      IF (l_Count <> 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_SHORT_NAME_EXISTS');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', Trim(l_Meas_Extn_Rec.Measure_Short_Name));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (p_Action_Type = C_UPDATE) THEN
      IF (l_Count = 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_SHORT_NAME_NOT_EXISTS');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', Trim(l_Meas_Extn_Rec.Measure_Short_Name));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSIF (p_Action_Type = C_LOAD) THEN
        IF(Trim(l_Meas_Extn_Rec.Func_Area_Short_Name) IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_IS_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            SELECT COUNT(1)
            INTO   l_Count
            FROM   BIS_FUNCTIONAL_AREAS
            WHERE  UPPER(SHORT_NAME) = UPPER(TRIM(l_Meas_Extn_Rec.Func_Area_Short_Name));
            IF(l_Count = 0 ) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_FUNCSHTNAME_WRONG');
                FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(l_Meas_Extn_Rec.Func_Area_Short_Name));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    ELSIF (p_Action_Type = C_RETRIEVE OR p_Action_Type = C_DELETE OR p_Action_Type = C_TRANS) THEN
      IF (l_Count = 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_SHORT_NAME_NOT_EXISTS');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', Trim(l_Meas_Extn_Rec.Measure_Short_Name));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Validate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Validate_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Validate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Validate_Measure_Extension ';
        END IF;
END Validate_Measure_Extension;


/*********************************************************************************************
        FUNCTION Name :- Validate_Form_Func_Extension
        PARAMETERS    :-
            p_Action_Type       :-  Action type this can be either CREATE or UPDATE
            p_Form_Func_Extn_Rec:- The Record containing all the vlaues of form function tables
        DESCRIPTION   :- This fucntions takes care of all validations based on action type
        AUTHOR        :- KRISHNA
*********************************************************************************************/

PROCEDURE Validate_Form_Func_Extension(
  p_Form_Func_Extn_Rec  IN          BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type
 ,p_Action_Type         IN          VARCHAR2
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Count         NUMBER;
    l_cnt_app_id    NUMBER;
    l_cnt_sht_name  NUMBER;
    l_cnt_func_id   NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    SELECT COUNT(1)
    INTO   l_cnt_sht_name
    FROM   BIS_FORM_FUNCTION_EXTENSION
    WHERE  UPPER(OBJECT_NAME) = UPPER(TRIM(p_Form_Func_Extn_Rec.Object_Name));

    SELECT COUNT(1)
    INTO   l_cnt_func_id
    FROM   BIS_FUNCTIONAL_AREAS
    WHERE  FUNCTIONAL_AREA_ID = p_Form_Func_Extn_Rec.Func_Area_Id;

    IF (BIS_UTILITIES_PVT.Value_Missing_Or_Null(TRIM(p_Form_Func_Extn_Rec.Object_Name)) = FND_API.G_TRUE) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_FORM_FUNC_SHTNAME_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_CREATE) THEN
        IF(l_cnt_sht_name <> 0 ) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FORM_FUNC_EXISTS');
            FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(p_Form_Func_Extn_Rec.Object_Name));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_UPDATE) THEN
        IF(l_cnt_sht_name = 0 ) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FORM_FUNC_SHTNAME_NOTEXIST');
            FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(p_Form_Func_Extn_Rec.Object_Name));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_UPDATE OR  p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_CREATE)  THEN
        IF(Trim(p_Form_Func_Extn_Rec.Func_Area_Id) IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FUNC_ID_NOT_ENTERED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF(l_cnt_func_id =0 ) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_FUNCID_WRONG');
                FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(p_Form_Func_Extn_Rec.Func_Area_Id));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
        END IF;
        IF(TRIM(p_Form_Func_Extn_Rec.Application_Id) IS NULL ) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_APPID_CANNOT_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            SELECT COUNT(1)
            INTO l_cnt_app_id
            FROM FND_APPLICATION
            WHERE APPLICATION_ID = p_Form_Func_Extn_Rec.Application_Id;
            IF(l_cnt_app_id = 0 ) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_APPID_WRONG');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;
    END IF;

    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_LOAD) THEN
        IF(Trim(p_Form_Func_Extn_Rec.Func_Area_short_name) IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FA_SHORT_NAME_IS_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            SELECT COUNT(1)
            INTO   l_cnt_func_id
            FROM   BIS_FUNCTIONAL_AREAS
            WHERE  SHORT_NAME = p_Form_Func_Extn_Rec.Func_Area_short_name;
            IF(l_cnt_func_id = 0 ) THEN
                FND_MESSAGE.SET_NAME('BIS','BIS_FUNCSHTNAME_WRONG');
                FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(p_Form_Func_Extn_Rec.Func_Area_short_name));
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;
    IF(p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_TRANS OR p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_DELETE OR p_Action_Type = BIS_OBJECT_EXTENSIONS_PUB.C_RETRIEVE) THEN
        IF(l_cnt_sht_name = 0 ) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_FORM_FUNC_SHTNAME_NOTEXIST');
            FND_MESSAGE.SET_TOKEN('FORM_FUNC',Trim(p_Form_Func_Extn_Rec.Object_Name));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Validate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Validate_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Validate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Validate_Form_Func_Extension ';
        END IF;
END Validate_Form_Func_Extension;

/*********************************************************************************************
FUNCTION Name  : Validate_Object_Mapping
PARAMETERS
          p_object_type               :  Object Type
          p_object_name               :  Object Name

DESCRIPTION
          This function tells whether the mapping between
          object type and functional Area already exists in the
          DataBase.

AUTHOR     : Ashankar
*********************************************************************************************/

FUNCTION Validate_Object_Mapping
(
    p_object_type         IN          VARCHAR2
 ,  p_object_name         IN          VARCHAR2

 ) RETURN NUMBER
 IS
  l_count       NUMBER;
BEGIN

  IF (p_object_type <> BIS_OBJECT_EXTENSIONS_PUB.C_MEASURE) THEN

    SELECT COUNT(0)
    INTO   l_count
    FROM   BIS_FORM_FUNCTION_EXTENSION
    WHERE  UPPER(TRIM(object_name)) = UPPER(TRIM(p_object_name));

  ELSE

    SELECT COUNT(0)
    INTO   l_count
    FROM   BIS_MEASURES_EXTENSION
    WHERE  UPPER(TRIM(measure_short_name)) = UPPER(TRIM(p_object_name));

  END IF;

  RETURN l_count;

EXCEPTION
  WHEN OTHERS THEN
     RETURN C_INVALID;
END Validate_Object_Mapping;

/*********************************************************************************************
PROCEDURE Name  : Object_Funct_Area_Map
PARAMETERS
          p_Obj_Type               :  Object Type
          p_Obj_Name               :  Object Name
          p_App_Id                 :  Application Id             [Will be Null for Measures]
          p_Func_Area_Sht_Name     :  Functional Area Short Name [Can be Null]
DESCRIPTION
          This Method calls either Measure_Funct_Area_Map
          or Form_Func_Functional_Area_Map based on the
          p_Obj_Type
AUTHOR     : Ashankar
*********************************************************************************************/

PROCEDURE Object_Funct_Area_Map
(
   p_Api_Version            IN          NUMBER
 , p_Commit                 IN          VARCHAR2 := FND_API.G_FALSE
 , p_Obj_Type               IN          VARCHAR2
 , p_Obj_Name               IN          VARCHAR2
 , p_App_Id                 IN          NUMBER
 , p_Func_Area_Sht_Name     IN          VARCHAR2
 , x_Return_Status          OUT NOCOPY  VARCHAR2
 , x_Msg_Count              OUT NOCOPY  NUMBER
 , x_Msg_Data               OUT NOCOPY  VARCHAR2

) IS
     l_Meas_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
     l_Mes_up_Rec       BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF(p_Obj_Type=BIS_OBJECT_EXTENSIONS_PUB.C_MEASURE) THEN
        BIS_OBJECT_EXTENSIONS_PUB.Measure_Funct_Area_Map
        (
                p_Api_Version         => p_Api_Version
            ,   p_Commit              => p_Commit
            ,   p_Obj_Type            => p_Obj_Type
            ,   p_Obj_Name            => p_Obj_Name
            ,   p_App_Id              => p_App_Id
            ,   p_Func_Area_Sht_Name  => p_Func_Area_Sht_Name
            ,   x_Return_Status       => x_Return_Status
            ,   x_Msg_Count           => x_Msg_Count
            ,   x_Msg_Data            => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        BIS_OBJECT_EXTENSIONS_PUB.Form_Func_Functional_Area_Map
        (
                p_Api_Version         => p_Api_Version
            ,   p_Commit              => p_Commit
            ,   p_Obj_Type            => p_Obj_Type
            ,   p_Obj_Name            => p_Obj_Name
            ,   p_App_Id              => p_App_Id
            ,   p_Func_Area_Sht_Name  => p_Func_Area_Sht_Name
            ,   x_Return_Status       => x_Return_Status
            ,   x_Msg_Count           => x_Msg_Count
            ,   x_Msg_Data            => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map ';
        END IF;

END Object_Funct_Area_Map;

/*********************************************************************************************
FUNCTION Name  : Measure_Funct_Area_Map
PARAMETERS
            p_Obj_Type               :  Object Type
            p_Obj_Name               :  Object Name
            p_App_Id                 :  Application Id             [Will be Null for Measures]
            p_Func_Area_Sht_Name     :  Functional Area Short Name [Can be Null]

DESCRIPTION
           Following are the Rules here.
           1.Validate if the Object is already mapped.
             If not then check if the functional Area Id is NULL
               If yes then throw the error message that this association doesn't exists.
               else
                Create the mapping for this object typw with the functional Area.
           2.If the Object is already mapped.
               Check if the Object is mapped to the functional Area Id being passed.
                If yes then throw the message that this association already exists.
                else
                 update the object type with the new functional Area Id.
           3.If the Functional Area Id is passed as NULL and the association exists
             for the current Objevt Type then delete that association.
AUTHOR     : Ashankar
*********************************************************************************************/
PROCEDURE Measure_Funct_Area_Map
(
        p_Api_Version         IN          NUMBER
    ,   p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_Obj_Type            IN          VARCHAR2
    ,   p_Obj_Name            IN          VARCHAR2
    ,   p_App_Id              IN          NUMBER
    ,   p_Func_Area_Sht_Name  IN          VARCHAR2
    ,   x_Return_Status       OUT NOCOPY  VARCHAR2
    ,   x_Msg_Count           OUT NOCOPY  NUMBER
    ,   x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_count            NUMBER;
    l_Meas_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_count := Validate_Object_Mapping (p_object_type => p_Obj_Type ,p_object_name=>p_Obj_Name);

    IF(l_count>0)THEN
        IF(p_Func_Area_Sht_Name IS NOT NULL) THEN

            l_Meas_Extn_Rec.Measure_Short_Name   :=  p_Obj_Name;
            l_Meas_Extn_Rec.Functional_Area_Id   :=  Get_FA_Id_By_Short_Name(p_Func_Area_Sht_Name);
            l_Meas_Extn_Rec.Func_Area_Short_Name :=  p_Func_Area_Sht_Name;
            l_Meas_Extn_Rec.Name                 :=  BIS_COMMON_UTILS.G_DEF_CHAR;
            l_Meas_Extn_Rec.Description          :=  BIS_COMMON_UTILS.G_DEF_CHAR;
            l_Meas_Extn_Rec.Created_By           :=  FND_GLOBAL.user_id;
            l_Meas_Extn_Rec.Last_Updated_By      :=  FND_GLOBAL.user_id;
            l_Meas_Extn_Rec.Last_Update_Date     :=  SYSDATE;
            l_Meas_Extn_Rec.Last_Update_Login    :=  FND_GLOBAL.LOGIN_ID;

            BIS_OBJECT_EXTENSIONS_PUB.Update_Measure_Extension
            (
                    p_Api_Version    => p_Api_Version
                ,   p_Commit         => p_Commit
                ,   p_Meas_Extn_Rec  => l_Meas_Extn_Rec
                ,   x_Return_Status  => x_Return_Status
                ,   x_Msg_Count      => x_Msg_Count
                ,   x_Msg_Data       => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_UPDATE_SUCCESSFUL');
                x_Msg_Data := FND_MESSAGE.GET;
            END IF;
        ELSE
            l_Meas_Extn_Rec.Measure_Short_Name   :=  p_Obj_Name;
            BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension
            (
                    p_Api_Version         => p_Api_Version
                ,   p_Commit              => p_Commit
                ,   p_Meas_Extn_Rec       => l_Meas_Extn_Rec
                ,   x_Return_Status       => x_Return_Status
                ,   x_Msg_Count           => x_Msg_Count
                ,   x_Msg_Data            => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
              FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_DELETE_SUCCESSFUL');
              x_Msg_Data := FND_MESSAGE.GET;
            END IF;

        END IF;
    ELSE
        IF(p_Func_Area_Sht_Name IS NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_DOES_NOT_EXIST');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            l_Meas_Extn_Rec.Measure_Short_Name   :=  p_Obj_Name;
            l_Meas_Extn_Rec.Functional_Area_Id   :=  Get_FA_Id_By_Short_Name(p_Func_Area_Sht_Name);
            l_Meas_Extn_Rec.Func_Area_Short_Name :=  p_Func_Area_Sht_Name;
            l_Meas_Extn_Rec.Name                 :=  BIS_COMMON_UTILS.G_DEF_CHAR;
            l_Meas_Extn_Rec.Description          :=  BIS_COMMON_UTILS.G_DEF_CHAR;
            l_Meas_Extn_Rec.Created_By           :=  FND_GLOBAL.user_id;
            l_Meas_Extn_Rec.Creation_Date        :=  SYSDATE;
            l_Meas_Extn_Rec.Last_Updated_By      :=  FND_GLOBAL.user_id;
            l_Meas_Extn_Rec.Last_Update_Date     :=  SYSDATE;
            l_Meas_Extn_Rec.Last_Update_Login    :=  FND_GLOBAL.LOGIN_ID;

            BIS_OBJECT_EXTENSIONS_PUB.Create_Measure_Extension
            (
                    p_Api_Version    => p_Api_Version
                ,   p_Commit         => p_Commit
                ,   p_Meas_Extn_Rec  => l_Meas_Extn_Rec
                ,   x_Return_Status  => x_Return_Status
                ,   x_Msg_Count      => x_Msg_Count
                ,   x_Msg_Data       => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_CREATE_SUCCESSFUL');
                x_Msg_Data := FND_MESSAGE.GET;
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Measure_Funct_Area_Map ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Measure_Funct_Area_Map ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Measure_Funct_Area_Map ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Measure_Funct_Area_Map ';
        END IF;
END Measure_Funct_Area_Map;

/*********************************************************************************************
FUNCTION Name  : Form_Func_Functional_Area_Map
PARAMETERS
            p_Obj_Type               :  Object Type
            p_Obj_Name               :  Object Name
            p_App_Id                 :  Application Id             [Will be Null for Measures]
            p_Func_Area_Sht_Name     :  Functional Area Short Name [Can be Null]

DESCRIPTION
           Following are the Rules here.
           1.Validate if the Object is already mapped.
             If not then check if the functional Area Id is NULL
               If yes then throw the error message that this association doesn't exists.
               else
                Create the mapping for this object typw with the functional Area.
           2.If the Object is already mapped.
               Check if the Object is mapped to the functional Area Id being passed.
                If yes then throw the message that this association already exists.
                else
                 update the object type with the new functional Area Id.
           3.If the Functional Area Id is passed as NULL and the association exists
             for the current Objevt Type then delete that association.
AUTHOR     : Ashankar
*********************************************************************************************/
PROCEDURE Form_Func_Functional_Area_Map
(
        p_Api_Version         IN          NUMBER
    ,   p_Commit              IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_Obj_Type            IN          VARCHAR2
    ,   p_Obj_Name            IN          VARCHAR2
    ,   p_App_Id              IN          NUMBER
    ,   p_Func_Area_Sht_Name  IN          VARCHAR2
    ,   x_Return_Status       OUT NOCOPY  VARCHAR2
    ,   x_Msg_Count           OUT NOCOPY  NUMBER
    ,   x_Msg_Data            OUT NOCOPY  VARCHAR2
)IS
    l_count            NUMBER;
    l_From_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
    --l_out              VARCHAR2(3);
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_count := Validate_Object_Mapping (p_object_type => p_Obj_Type ,p_object_name=>p_Obj_Name);

    IF(l_count>0)THEN
        IF(p_Func_Area_Sht_Name IS NOT NULL) THEN

                l_From_Func_Extn_Rec.Object_Type           := p_Obj_Type;
                l_From_Func_Extn_Rec.Object_Name           := p_Obj_Name;
                l_From_Func_Extn_Rec.Application_Id        := p_App_Id;
                l_From_Func_Extn_Rec.Func_Area_Id          := Get_FA_Id_By_Short_Name(p_Func_Area_Sht_Name);
                l_From_Func_Extn_Rec.Func_Area_short_name  := p_Func_Area_Sht_Name;
                l_From_Func_Extn_Rec.Name                  := BIS_COMMON_UTILS.G_DEF_CHAR;
                l_From_Func_Extn_Rec.Description           := BIS_COMMON_UTILS.G_DEF_CHAR;
                l_From_Func_Extn_Rec.Created_By            := FND_GLOBAL.user_id;
                l_From_Func_Extn_Rec.Last_Updated_By       := FND_GLOBAL.user_id;
                l_From_Func_Extn_Rec.Last_Update_Date      := SYSDATE;
                l_From_Func_Extn_Rec.Last_Update_Login     := FND_GLOBAL.LOGIN_ID;

                BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension
                (
                        p_Api_Version         =>  p_Api_Version
                    ,   p_Commit              =>  p_Commit
                    ,   p_Form_Func_Extn_Rec  =>  l_From_Func_Extn_Rec
                    ,   x_Return_Status       =>  x_Return_Status
                    ,   x_Msg_Count           =>  x_Msg_Count
                    ,   x_Msg_Data            =>  x_Msg_Data
                );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSE
                    FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_UPDATE_SUCCESSFUL');
                    x_Msg_Data := FND_MESSAGE.GET;
                END IF;
        ELSE
            l_From_Func_Extn_Rec.Object_Name := p_Obj_Name;
            BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension
            (
                    p_Api_Version         => p_Api_Version
                ,   p_Commit              => p_Commit
                ,   p_Form_Func_Extn_Rec  => l_From_Func_Extn_Rec
                ,   x_Return_Status       => x_Return_Status
                ,   x_Msg_Count           => x_Msg_Count
                ,   x_Msg_Data            => x_Msg_Data
            );
            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_DELETE_SUCCESSFUL');
                x_Msg_Data := FND_MESSAGE.GET;
            END IF;

        END IF;
    ELSE
      IF(p_Func_Area_Sht_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_DOES_NOT_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
            l_From_Func_Extn_Rec.Object_Type           := p_Obj_Type;
            l_From_Func_Extn_Rec.Object_Name           := p_Obj_Name;
            l_From_Func_Extn_Rec.Application_Id        := p_App_Id;
            l_From_Func_Extn_Rec.Func_Area_Id          := Get_FA_Id_By_Short_Name(p_Func_Area_Sht_Name);
            l_From_Func_Extn_Rec.Func_Area_short_name  := p_Func_Area_Sht_Name;
            l_From_Func_Extn_Rec.Name                  := BIS_COMMON_UTILS.G_DEF_CHAR;
            l_From_Func_Extn_Rec.Description           := BIS_COMMON_UTILS.G_DEF_CHAR;
            l_From_Func_Extn_Rec.Created_By            := FND_GLOBAL.user_id;
            l_From_Func_Extn_Rec.Creation_Date         := SYSDATE;
            l_From_Func_Extn_Rec.Last_Updated_By       := FND_GLOBAL.user_id;
            l_From_Func_Extn_Rec.Last_Update_Date      := SYSDATE;
            l_From_Func_Extn_Rec.Last_Update_Login     := FND_GLOBAL.LOGIN_ID;

            BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension
            (
                    p_Api_Version         =>  p_Api_Version
                ,   p_Commit              =>  p_Commit
                ,   p_Form_Func_Extn_Rec  =>  l_From_Func_Extn_Rec
                ,   x_Return_Status       =>  x_Return_Status
                ,   x_Msg_Count           =>  x_Msg_Count
                ,   x_Msg_Data            =>  x_Msg_Data
            );
            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSE
                FND_MESSAGE.SET_NAME('BIS','BIS_OBJ_EXT_CREATE_SUCCESSFUL');
                x_Msg_Data := FND_MESSAGE.GET;
            END IF;
      END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF (x_msg_data IS NULL) THEN
         FND_MSG_PUB.Count_And_Get
         (      p_encoded   =>  FND_API.G_FALSE
            ,   p_count     =>  x_msg_count
            ,   p_data      =>  x_msg_data
         );
     END IF;
     x_return_status :=  FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (x_msg_data IS NULL) THEN
         FND_MSG_PUB.Count_And_Get
         (      p_encoded   =>  FND_API.G_FALSE
            ,   p_count     =>  x_msg_count
            ,   p_data      =>  x_msg_data
         );
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Form_Func_Functional_Area_Map ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Form_Func_Functional_Area_Map ';
     END IF;
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PUB.Form_Func_Functional_Area_Map ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PUB.Form_Func_Functional_Area_Map ';
    END IF;
END Form_Func_Functional_Area_Map;
PROCEDURE ADD_LANGUAGE
IS
BEGIN
   BIS_OBJECT_EXTENSIONS_PVT.ADD_LANGUAGE;
END ADD_LANGUAGE;

END BIS_OBJECT_EXTENSIONS_PUB;

/
