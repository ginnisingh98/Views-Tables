--------------------------------------------------------
--  DDL for Package Body BIS_OBJECT_EXTENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_OBJECT_EXTENSIONS_PVT" AS
/* $Header: BISVEXTB.pls 120.2 2005/12/12 12:35:45 hengliu noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVEXTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for populating the extension tables               |
REM |             - BIS_MEASURES_EXTENSION_TL                               |
REM |             - BIS_FORM_FUNCTION_EXTENSION_TL                          |
REM | NOTES                                                                 |
REM | 24-NOV-2004 Krishna  Created.                                         |
REM | 31-Jan-2005 rpenneru Modified for #4153331, BIS_MEASURES_EXTENSION_TL |
REM |             Name and Description should not be updated, if the values |
REM |             are BIS_COMMON_UTILS.G_DEF_CHAR                           |
REM |       19-MAY-2005  visuri   GSCC Issues bug 4363854                   |
REM |       24-Aug-2005  hengliu  bug#4572274: issue in loading seed data   |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_OBJECT_EXTENSIONS_PVT';

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
    l_Form_Func_Extn_Rec BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
BEGIN
    SAVEPOINT  CreateFormFuncSP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('i am calling validate from create ');
    l_Form_Func_Extn_Rec := p_Form_Func_Extn_Rec;

    IF ( l_Form_Func_Extn_Rec.Name = BIS_COMMON_UTILS.G_DEF_CHAR ) THEN
      l_Form_Func_Extn_Rec.Name := NULL;
    END IF;

    IF ( l_Form_Func_Extn_Rec.Description =  BIS_COMMON_UTILS.G_DEF_CHAR) THEN
      l_Form_Func_Extn_Rec.Description := NULL;
    END IF;

    -- Insert into base tables
    INSERT INTO BIS_FORM_FUNCTION_EXTENSION
    (
          OBJECT_TYPE
        , OBJECT_NAME
        , APPLICATION_ID
        , FUNCTIONAL_AREA_ID
        , CREATED_BY
        , CREATION_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATE_LOGIN
    )
    VALUES
    (
        l_Form_Func_Extn_Rec.Object_Type
      , TRIM(l_Form_Func_Extn_Rec.Object_Name)
      , l_Form_Func_Extn_Rec.Application_Id
      , l_Form_Func_Extn_Rec.Func_Area_Id
      , NVL(l_Form_Func_Extn_Rec.Created_By,FND_GLOBAL.USER_ID)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Date,SYSDATE)
      , NVL(l_Form_Func_Extn_Rec.Last_Updated_By,FND_GLOBAL.USER_ID)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Date,SYSDATE)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
    );

    INSERT INTO BIS_FORM_FUNCTION_EXTENSION_TL
    (
          OBJECT_NAME
        , NAME
        , DESCRIPTION
        , LANGUAGE
        , SOURCE_LANG
        , CREATED_BY
        , CREATION_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATE_LOGIN
    )
    SELECT
        l_Form_Func_Extn_Rec.Object_Name
      , l_Form_Func_Extn_Rec.Name
      , l_Form_Func_Extn_Rec.Description
      , L.LANGUAGE_CODE
      , USERENV('LANG')
      , NVL(l_Form_Func_Extn_Rec.Created_By,FND_GLOBAL.USER_ID)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Date,SYSDATE)
      , NVL(l_Form_Func_Extn_Rec.Last_Updated_By,FND_GLOBAL.USER_ID)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Date,SYSDATE)
      , NVL(l_Form_Func_Extn_Rec.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_FORM_FUNCTION_EXTENSION_TL T
          WHERE  T.OBJECT_NAME = l_Form_Func_Extn_Rec.Object_Name
          AND    T.LANGUAGE    = L.LANGUAGE_CODE
        );

  IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateFormFuncSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateFormFuncSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateFormFuncSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Create_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Create_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateFormFuncSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Create_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Create_Form_Func_Extension ';
        END IF;
END Create_Form_Func_Extension;



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
    l_Form_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
BEGIN
    SAVEPOINT  UpdateFormFuncSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;

    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Form_Func_Extn_Rec  =>  l_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF(p_Form_Func_Extn_Rec.Application_Id IS NOT NULL) THEN
        l_Form_Func_Extn_Rec.Application_Id := p_Form_Func_Extn_Rec.Application_Id;
    END IF;
    IF(p_Form_Func_Extn_Rec.Func_Area_Id IS NOT NULL) THEN
        l_Form_Func_Extn_Rec.Func_Area_Id:= p_Form_Func_Extn_Rec.Func_Area_Id;
    END IF;

    IF(p_Form_Func_Extn_Rec.Last_Update_Date IS NULL) THEN
        l_Form_Func_Extn_Rec.Last_Update_Date := SYSDATE;
    ELSE
        l_Form_Func_Extn_Rec.Last_Update_Date := p_Form_Func_Extn_Rec.Last_Update_Date;
    END IF;

    IF (p_Form_Func_Extn_Rec.Last_Updated_By IS NULL) THEN
      l_Form_Func_Extn_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Form_Func_Extn_Rec.Last_Updated_By := p_Form_Func_Extn_Rec.Last_Updated_By;
    END IF;

    IF (p_Form_Func_Extn_Rec.Last_Update_Login IS NULL) THEN
      l_Form_Func_Extn_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Form_Func_Extn_Rec.Last_Update_Login := p_Form_Func_Extn_Rec.Last_Update_Login;
    END IF;

    UPDATE BIS_FORM_FUNCTION_EXTENSION
    SET
        APPLICATION_ID     = l_Form_Func_Extn_Rec.Application_id
      , FUNCTIONAL_AREA_ID = l_Form_Func_Extn_Rec.Func_Area_Id
      , LAST_UPDATED_BY    = l_Form_Func_Extn_Rec.Last_Updated_By
      , LAST_UPDATE_DATE   = l_Form_Func_Extn_Rec.Last_Update_Date
      , LAST_UPDATE_LOGIN  = l_Form_Func_Extn_Rec.Last_Update_Login
    WHERE OBJECT_NAME      = l_Form_Func_Extn_Rec.Object_Name;


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
        ROLLBACK TO UpdateFormFuncSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateFormFuncSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateFormFuncSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Update_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Update_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateFormFuncSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Update_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Update_Form_Func_Extension ';
        END IF;
END Update_Form_Func_Extension;

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
    l_Form_Func_Extn_Rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
    l_valid_func_ext_rec    BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
BEGIN
    SAVEPOINT  TransalteFormFuncSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF( p_Commit IS NULL) THEN
        l_Commit    := FND_API.G_FALSE;
    ELSE
        l_Commit := p_Commit;
    END IF;
    --dbms_output.put_line('calling validate from trans');

    --dbms_output.put_line('calling validate from trans after');
    BIS_OBJECT_EXTENSIONS_PUB.Retrieve_Form_Func_Extension(
        p_Form_Func_Extn_Rec  =>  p_Form_Func_Extn_Rec
     ,  x_Form_Func_Extn_Rec  =>  l_Form_Func_Extn_Rec
     ,  x_Return_Status       =>  x_Return_Status
     ,  x_Msg_Count           =>  x_Msg_Count
     ,  x_Msg_Data            =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_Form_Func_Extn_Rec.Name IS NULL ) THEN
      l_Form_Func_Extn_Rec.Name := NULL;
    ELSIF ((p_Form_Func_Extn_Rec.Name <> BIS_COMMON_UTILS.G_DEF_CHAR)
		  AND ((l_Form_Func_Extn_Rec.Name IS NULL) OR (l_Form_Func_Extn_Rec.Name <> p_Form_Func_Extn_Rec.Name))) THEN
      l_Form_Func_Extn_Rec.Name := p_Form_Func_Extn_Rec.Name;
    END IF;

    IF ( p_Form_Func_Extn_Rec.Description IS NULL ) THEN
      l_Form_Func_Extn_Rec.Description := NULL;
    ELSIF ( (p_Form_Func_Extn_Rec.Description <>  BIS_COMMON_UTILS.G_DEF_CHAR)
	   AND ((l_Form_Func_Extn_Rec.Description IS NULL) OR (l_Form_Func_Extn_Rec.Description <> p_Form_Func_Extn_Rec.Description))) THEN
      l_Form_Func_Extn_Rec.Description := p_Form_Func_Extn_Rec.Description;
    END IF;

    IF(p_Form_Func_Extn_Rec.Last_Update_Date IS NULL) THEN
        l_Form_Func_Extn_Rec.Last_Update_Date := SYSDATE;
    ELSE
        l_Form_Func_Extn_Rec.Last_Update_Date := p_Form_Func_Extn_Rec.Last_Update_Date;
    END IF;

    IF (p_Form_Func_Extn_Rec.Last_Updated_By IS NULL) THEN
      l_Form_Func_Extn_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Form_Func_Extn_Rec.Last_Updated_By := p_Form_Func_Extn_Rec.Last_Updated_By;
    END IF;

    IF (p_Form_Func_Extn_Rec.Last_Update_Login IS NULL) THEN
      l_Form_Func_Extn_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Form_Func_Extn_Rec.Last_Update_Login := p_Form_Func_Extn_Rec.Last_Update_Login;
    END IF;

    UPDATE BIS_FORM_FUNCTION_EXTENSION_TL
    SET
        NAME               = l_Form_Func_Extn_Rec.Name
      , DESCRIPTION        = l_Form_Func_Extn_Rec.Description
      , LAST_UPDATED_BY    = l_Form_Func_Extn_Rec.Last_Updated_By
      , LAST_UPDATE_DATE   = l_Form_Func_Extn_Rec.Last_Update_Date
      , LAST_UPDATE_LOGIN  = l_Form_Func_Extn_Rec.Last_Update_Login
      , SOURCE_LANG        = USERENV('LANG')
    WHERE OBJECT_NAME      = l_Form_Func_Extn_Rec.Object_Name
    AND USERENV('LANG')      IN (LANGUAGE, SOURCE_LANG);
----dbms_output.put_line('after updating    BIS_FORM_FUNCTION_EXTENSION_TL in tras');

    IF (l_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO TransalteFormFuncSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TransalteFormFuncSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TransalteFormFuncSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Translate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Translate_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TransalteFormFuncSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Translate_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Translate_Form_Func_Extension ';
        END IF;
END Translate_Form_Func_Extension;


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

----dbms_output.put_line('before retrieve');

    SELECT  F.OBJECT_TYPE
           ,F.OBJECT_NAME
           ,F.NAME
           ,F.DESCRIPTION
           ,F.APPLICATION_ID
           ,F.FUNCTIONAL_AREA_ID
           ,F.CREATED_BY
           ,F.CREATION_DATE
           ,F.LAST_UPDATED_BY
           ,F.LAST_UPDATE_DATE
           ,F.LAST_UPDATE_LOGIN
    INTO    x_Form_Func_Extn_Rec.Object_Type
           ,x_Form_Func_Extn_Rec.Object_Name
           ,x_Form_Func_Extn_Rec.Name
           ,x_Form_Func_Extn_Rec.Description
           ,x_Form_Func_Extn_Rec.Application_Id
           ,x_Form_Func_Extn_Rec.Func_Area_Id
           ,x_Form_Func_Extn_Rec.Created_By
           ,x_Form_Func_Extn_Rec.Creation_Date
           ,x_Form_Func_Extn_Rec.Last_Updated_By
           ,x_Form_Func_Extn_Rec.Last_Update_Date
           ,x_Form_Func_Extn_Rec.Last_Update_Login
    FROM   BIS_FORM_FUNCTION_EXTENSION_VL F
    WHERE  F.OBJECT_NAME = trim(p_Form_Func_Extn_Rec.Object_Name);
----dbms_output.put_line('after retrieve');
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
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Form_Func_Extension ';
        END IF;
END Retrieve_Form_Func_Extension;

/*********************************************************************************************
        FUNCTION Name :- Retrieve_Form_Func_Extension
        PARAMETERS    :-
            p_Form_Func_Extn_Rec :- This record details sent from UI
            DESCRIPTION   :- This delete the record in BIS_FORM_FUNCTION_EXTENSION table
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
BEGIN
    SAVEPOINT  DeleteFormFuncSP_Pvt;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    -- Delete from base table
    DELETE FROM  BIS_FORM_FUNCTION_EXTENSION
    WHERE  OBJECT_NAME =   TRIM(p_Form_Func_Extn_Rec.Object_Name);

    DELETE FROM  BIS_FORM_FUNCTION_EXTENSION_TL
    WHERE  OBJECT_NAME =   TRIM(p_Form_Func_Extn_Rec.Object_Name);

    IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteFormFuncSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteFormFuncSP_Pvt;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteFormFuncSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Delete_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Delete_Form_Func_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteFormFuncSP_Pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Delete_Form_Func_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Delete_Form_Func_Extension ';
        END IF;
END Delete_Form_Func_Extension;



PROCEDURE Create_Measure_Extension(
  p_Api_Version         IN          NUMBER
 ,p_Commit              IN          VARCHAR2
 ,p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS
    l_Count           NUMBER;
    l_Meas_Extn_Rec   BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;
BEGIN
    SAVEPOINT CreateMeasExtnSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Meas_Extn_Rec := p_Meas_Extn_Rec;

    l_Count := 0;

    -- rpenneru bug#4153331
    -- Create_Measures_Extension will be called from BISPMFLD.lct (Uploading Measures)
    -- in the case Name and Description fields should be inserted as NULL values.
    -- The value of the Name and Description from BISPMFLD.lct will be BIS_COMMON_UTILS.G_DEF_CHAR

    IF ( l_Meas_Extn_Rec.Name = BIS_COMMON_UTILS.G_DEF_CHAR ) THEN
      l_Meas_Extn_Rec.Name := NULL;
    END IF;

    IF ( l_Meas_Extn_Rec.Description =  BIS_COMMON_UTILS.G_DEF_CHAR) THEN
      l_Meas_Extn_Rec.Description := NULL;
    END IF;


    INSERT INTO BIS_MEASURES_EXTENSION
    (
       MEASURE_SHORT_NAME
      ,FUNCTIONAL_AREA_ID
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
       TRIM(l_Meas_Extn_Rec.Measure_Short_Name)
      ,l_Meas_Extn_Rec.Functional_Area_Id
      ,NVL(l_Meas_Extn_Rec.Created_By, FND_GLOBAL.USER_ID)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Date,SYSDATE)
      ,NVL(l_Meas_Extn_Rec.Created_By, FND_GLOBAL.USER_ID)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Date,SYSDATE)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Login, FND_GLOBAL.LOGIN_ID)
    );

    INSERT INTO BIS_MEASURES_EXTENSION_TL
    (
       MEASURE_SHORT_NAME
      ,NAME
      ,DESCRIPTION
      ,LANGUAGE
      ,SOURCE_LANG
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
    )
    SELECT
       l_Meas_Extn_Rec.Measure_Short_Name
      ,l_Meas_Extn_Rec.Name
      ,l_Meas_Extn_Rec.Description
      ,L.LANGUAGE_CODE
      ,USERENV('LANG')
      ,NVL(l_Meas_Extn_Rec.Created_By, FND_GLOBAL.USER_ID)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Date,SYSDATE)
      ,NVL(l_Meas_Extn_Rec.Created_By, FND_GLOBAL.USER_ID)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Date,SYSDATE)
      ,NVL(l_Meas_Extn_Rec.Last_Update_Login, FND_GLOBAL.LOGIN_ID)
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_MEASURES_EXTENSION_TL T
          WHERE  T.MEASURE_SHORT_NAME = l_Meas_Extn_Rec.Measure_Short_Name
          AND    T.LANGUAGE           = L.LANGUAGE_CODE
        );
  -- Commit if required
  IF (p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Create_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Create_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Create_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Create_Measure_Extension ';
        END IF;

END Create_Measure_Extension;


PROCEDURE Retrieve_Measure_Extension(
  p_Meas_Extn_Rec       IN          BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Meas_Extn_Rec       OUT NOCOPY  BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
) IS

    l_Flag  BOOLEAN;

    CURSOR cMeasurExtension IS
     SELECT  B.MEASURE_SHORT_NAME
            ,B.NAME
            ,B.DESCRIPTION
            ,B.FUNCTIONAL_AREA_ID
            ,B.CREATED_BY
            ,B.CREATION_DATE
            ,B.LAST_UPDATED_BY
            ,B.LAST_UPDATE_DATE
            ,B.LAST_UPDATE_LOGIN
     FROM   BIS_MEASURES_EXTENSION_VL B
     WHERE  B.MEASURE_SHORT_NAME = TRIM(p_Meas_Extn_Rec.Measure_Short_Name);

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Flag := FALSE;

    FOR cME IN cMeasurExtension LOOP
        x_Meas_Extn_Rec.Measure_Short_Name := cME.MEASURE_SHORT_NAME;
        x_Meas_Extn_Rec.Name               := cME.NAME;
        x_Meas_Extn_Rec.Description        := cME.DESCRIPTION;
        x_Meas_Extn_Rec.Functional_Area_Id := cME.FUNCTIONAL_AREA_ID;
        x_Meas_Extn_Rec.Created_By         := cME.CREATED_BY;
        x_Meas_Extn_Rec.Creation_Date      := cME.CREATION_DATE;
        x_Meas_Extn_Rec.Last_Updated_By    := cME.LAST_UPDATED_BY;
        x_Meas_Extn_Rec.Last_Update_Date   := cME.LAST_UPDATE_DATE;
        x_Meas_Extn_Rec.Last_Update_Login  := cME.LAST_UPDATE_LOGIN;
        l_Flag := TRUE;
    END LOOP;

    IF(l_Flag = FALSE) THEN
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
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension ';
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

    SAVEPOINT TranslateMeasExtnSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  ------dbms_output.put_line ('l_Meas_Extn_Rec.Measure_Short_Name - ' || l_Meas_Extn_Rec.Measure_Short_Name);


    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,x_Meas_Extn_Rec  => l_Meas_Extn_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- rpenneru bug#4153331
    -- Translate_Measures_Extension will be called from BISPMFLD.lct (Uploading Measures)
    -- in the case Name and Description fields should not be updated.
    -- The value of the Name and Description from BISPMFLD.lct will be BIS_COMMON_UTILS.G_DEF_CHAR
    IF ( p_Meas_Extn_Rec.Name IS NULL ) THEN
      l_Meas_Extn_Rec.Name := NULL;
    ELSIF ((p_Meas_Extn_Rec.Name <> BIS_COMMON_UTILS.G_DEF_CHAR)
		  AND ((l_Meas_Extn_Rec.Name IS NULL) OR (l_Meas_Extn_Rec.Name <> p_Meas_Extn_Rec.Name))) THEN
      l_Meas_Extn_Rec.Name := p_Meas_Extn_Rec.Name;
    END IF;

    IF ( p_Meas_Extn_Rec.Description IS NULL ) THEN
      l_Meas_Extn_Rec.Description := NULL;
    ELSIF ( (p_Meas_Extn_Rec.Description <>  BIS_COMMON_UTILS.G_DEF_CHAR)
	   AND ((l_Meas_Extn_Rec.Description IS NULL) OR (l_Meas_Extn_Rec.Description <> p_Meas_Extn_Rec.Description))) THEN
      l_Meas_Extn_Rec.Description := p_Meas_Extn_Rec.Description;
    END IF;

    IF(p_Meas_Extn_Rec.Last_Update_Date IS NULL ) THEN
        l_Meas_Extn_Rec.Last_Update_Date := SYSDATE;
    ELSE
        l_Meas_Extn_Rec.Last_Update_Date := p_Meas_Extn_Rec.Last_Update_Date;
    END IF;

    IF (p_Meas_Extn_Rec.Last_Updated_By IS NULL) THEN
      l_Meas_Extn_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Meas_Extn_Rec.Last_Updated_By := p_Meas_Extn_Rec.Last_Updated_By;
    END IF;

    IF (p_Meas_Extn_Rec.Last_Update_Login IS NULL) THEN
      l_Meas_Extn_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Meas_Extn_Rec.Last_Update_Login := p_Meas_Extn_Rec.Last_Update_Login;
    END IF;

    -- Update the trans table
    UPDATE BIS_MEASURES_EXTENSION_TL B
    SET
        B.NAME               = l_Meas_Extn_Rec.Name
      , B.DESCRIPTION        = l_Meas_Extn_Rec.Description
      , B.LAST_UPDATED_BY    = l_Meas_Extn_Rec.Last_Updated_By
      , B.LAST_UPDATE_DATE   = l_Meas_Extn_Rec.Last_Update_Date
      , B.LAST_UPDATE_LOGIN  = l_Meas_Extn_Rec.Last_Update_Login
      , B.SOURCE_LANG        = USERENV('LANG')
    WHERE
        B.MEASURE_SHORT_NAME = l_Meas_Extn_Rec.Measure_Short_Name
    AND USERENV('LANG')    IN (B.LANGUAGE, B.SOURCE_LANG);

    -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO TranslateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO TranslateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO TranslateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO TranslateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension ';
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
    l_Meas_Extn_Rec   BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;

BEGIN
    SAVEPOINT UpdateMeasExtnSP;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- Since there is no base table, a direct transalation
    -- should suffice.

    BIS_OBJECT_EXTENSIONS_PVT.Retrieve_Measure_Extension(
      p_Meas_Extn_Rec  => p_Meas_Extn_Rec
     ,x_Meas_Extn_Rec  => l_Meas_Extn_Rec
     ,x_Return_Status  => x_Return_Status
     ,x_Msg_Count      => x_Msg_Count
     ,x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF((p_Meas_Extn_Rec.Functional_Area_Id  IS NOT NULL)
           AND (p_Meas_Extn_Rec.Functional_Area_Id <> l_Meas_Extn_Rec.Functional_Area_Id)) THEN
        l_Meas_Extn_Rec.Functional_Area_Id:= p_Meas_Extn_Rec.Functional_Area_Id;
    END IF;


    IF(p_Meas_Extn_Rec.Last_Update_Date IS NULL ) THEN
        l_Meas_Extn_Rec.Last_Update_Date := SYSDATE;
    ELSE
        l_Meas_Extn_Rec.Last_Update_Date := p_Meas_Extn_Rec.Last_Update_Date;
    END IF;

    IF (p_Meas_Extn_Rec.Last_Updated_By IS NULL) THEN
      l_Meas_Extn_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
    ELSE
      l_Meas_Extn_Rec.Last_Updated_By := p_Meas_Extn_Rec.Last_Updated_By;
    END IF;

    IF (p_Meas_Extn_Rec.Last_Update_Login IS NULL) THEN
      l_Meas_Extn_Rec.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    ELSE
      l_Meas_Extn_Rec.Last_Update_Login := p_Meas_Extn_Rec.Last_Update_Login;
    END IF;

    UPDATE BIS_MEASURES_EXTENSION
    SET
        FUNCTIONAL_AREA_ID = l_Meas_Extn_Rec.Functional_Area_Id
      , LAST_UPDATED_BY    = l_Meas_Extn_Rec.Last_Updated_By
      , LAST_UPDATE_DATE   = l_Meas_Extn_Rec.Last_Update_Date
      , LAST_UPDATE_LOGIN  = l_Meas_Extn_Rec.Last_Update_Login
    WHERE
        MEASURE_SHORT_NAME = l_Meas_Extn_Rec.Measure_Short_Name;

    BIS_OBJECT_EXTENSIONS_PVT.Translate_Measure_Extension(
      p_Api_Version     => p_Api_Version
     ,p_Commit          => p_Commit
     ,p_Meas_Extn_Rec   => p_Meas_Extn_Rec
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
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
        ROLLBACK TO UpdateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Update_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Update_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdateMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Update_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Update_Measure_Extension ';
        END IF;
END Update_Measure_Extension;
/*********************************************************************************************
        FUNCTION Name :- Retrieve_Form_Func_Extension
        PARAMETERS    :-
            p_Meas_Extn_Rec :- This record details sent from UI
            DESCRIPTION   :- This delete the record in BIS_MEASURES_EXTENSION table
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

BEGIN
    SAVEPOINT DeleteMeasExtnSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM BIS_MEASURES_EXTENSION
    WHERE MEASURE_SHORT_NAME = TRIM(p_Meas_Extn_Rec.Measure_Short_Name);

    DELETE FROM BIS_MEASURES_EXTENSION_TL
    WHERE MEASURE_SHORT_NAME = TRIM(p_Meas_Extn_Rec.Measure_Short_Name);


  -- Commit if required
    IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteMeasExtnSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Delete_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Delete_Measure_Extension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteMeasExtnSP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_OBJECT_EXTENSIONS_PVT.Delete_Measure_Extension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_OBJECT_EXTENSIONS_PVT.Delete_Measure_Extension ';
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
     RETURN BIS_OBJECT_EXTENSIONS_PUB.C_INVALID;
END Get_FA_Id_By_Short_Name;

-- procedure to add a language.
PROCEDURE Add_Language IS
BEGIN


    -- Add language for the BIS_MEASURES_EXTENSION_TL
   BEGIN
        DELETE FROM BIS_MEASURES_EXTENSION_TL T
        WHERE NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_MEASURES_EXTENSION B
          WHERE  B.MEASURE_SHORT_NAME = T.MEASURE_SHORT_NAME
        );

        UPDATE BIS_MEASURES_EXTENSION_TL T SET (
            NAME,
            DESCRIPTION
        ) = (SELECT
                B.NAME,
                B.DESCRIPTION
             FROM  BIS_MEASURES_EXTENSION_TL B
             WHERE B.MEASURE_SHORT_NAME = T.MEASURE_SHORT_NAME
             AND   B.LANGUAGE           = T.SOURCE_LANG)
             WHERE (
                T.MEASURE_SHORT_NAME,
                T.LANGUAGE
             ) IN (SELECT
                    SUBT.MEASURE_SHORT_NAME,
                    SUBT.LANGUAGE
                    FROM  BIS_MEASURES_EXTENSION_TL SUBB, BIS_MEASURES_EXTENSION_TL SUBT
                    WHERE SUBB.MEASURE_SHORT_NAME = SUBT.MEASURE_SHORT_NAME
                    AND   SUBB.LANGUAGE           = SUBT.SOURCE_LANG
                    AND (
                         SUBB.NAME              <> SUBT.NAME
                         OR SUBB.DESCRIPTION    <> SUBT.DESCRIPTION
                        )
                    );

        INSERT INTO BIS_MEASURES_EXTENSION_TL
        (
           MEASURE_SHORT_NAME
          ,NAME
          ,DESCRIPTION
          ,LANGUAGE
          ,SOURCE_LANG
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
        )
        SELECT
            B.MEASURE_SHORT_NAME
          , B.NAME
          , B.DESCRIPTION
          , L.LANGUAGE_CODE
          , B.SOURCE_LANG
          , B.CREATED_BY
          , B.CREATION_DATE
          , B.LAST_UPDATED_BY
          , B.LAST_UPDATE_DATE
          , B.LAST_UPDATE_LOGIN
       FROM  BIS_MEASURES_EXTENSION_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND   B.LANGUAGE = USERENV('LANG')
       AND   NOT EXISTS
            (
              SELECT NULL
              FROM   BIS_MEASURES_EXTENSION_TL T
              WHERE  UPPER(T.MEASURE_SHORT_NAME) = UPPER(B.MEASURE_SHORT_NAME)
              AND    T.LANGUAGE           = L.LANGUAGE_CODE
            );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

    -- Add language for the BIS_MEASURES_EXTENSION_TL

   BEGIN
        DELETE FROM BIS_FORM_FUNCTION_EXTENSION_TL T
        WHERE NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_FORM_FUNCTION_EXTENSION B
          WHERE  B.OBJECT_NAME = T.OBJECT_NAME
        );

        UPDATE BIS_FORM_FUNCTION_EXTENSION_TL T SET (
            NAME,
            DESCRIPTION
        ) = (SELECT
                B.NAME,
                B.DESCRIPTION
             FROM  BIS_FORM_FUNCTION_EXTENSION_TL B
             WHERE B.OBJECT_NAME  = T.OBJECT_NAME
             AND   B.LANGUAGE     = T.SOURCE_LANG)
             WHERE (
                T.OBJECT_NAME,
                T.LANGUAGE
             ) IN (SELECT
                    SUBT.OBJECT_NAME,
                    SUBT.LANGUAGE
                    FROM  BIS_FORM_FUNCTION_EXTENSION_TL SUBB, BIS_FORM_FUNCTION_EXTENSION_TL SUBT
                    WHERE SUBB.OBJECT_NAME = SUBT.OBJECT_NAME
                    AND   SUBB.LANGUAGE    = SUBT.SOURCE_LANG
                    AND (
                         SUBB.NAME              <> SUBT.NAME
                         OR SUBB.DESCRIPTION    <> SUBT.DESCRIPTION
                        )
                    );

        INSERT INTO BIS_FORM_FUNCTION_EXTENSION_TL
        (
           OBJECT_NAME
          ,NAME
          ,DESCRIPTION
          ,LANGUAGE
          ,SOURCE_LANG
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
        )
        SELECT
            B.OBJECT_NAME
          , B.NAME
          , B.DESCRIPTION
          , L.LANGUAGE_CODE
          , B.SOURCE_LANG
          , B.CREATED_BY
          , B.CREATION_DATE
          , B.LAST_UPDATED_BY
          , B.LAST_UPDATE_DATE
          , B.LAST_UPDATE_LOGIN
       FROM  BIS_FORM_FUNCTION_EXTENSION_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND   B.LANGUAGE = USERENV('LANG')
       AND   NOT EXISTS
            (
              SELECT NULL
              FROM   BIS_FORM_FUNCTION_EXTENSION_TL T
              WHERE  T.OBJECT_NAME = B.OBJECT_NAME
              AND    T.LANGUAGE    = L.LANGUAGE_CODE
            );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
END Add_Language;

END BIS_OBJECT_EXTENSIONS_PVT;

/
