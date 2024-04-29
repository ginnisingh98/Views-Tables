--------------------------------------------------------
--  DDL for Package Body BSC_PERIODICITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODICITIES_PVT" AS
/* $Header: BSCVPERB.pls 120.4 2005/11/30 02:48:25 kyadamak noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVPERB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: PRIVATE package body to manage periodicities              |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 08-AUG-2005 Aditya Rao  Fixed Bug#4539411 in Update_Periodicity()     |
REM | 19-SEP-2005 ashankar    Fixed Bug#4612590 in Update_Periodicity()     |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_PVT';

/*
Procedure Name
Parameters

*/

PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
BEGIN
    SAVEPOINT CreatePeriodicityPVT;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Periodicities_Rec_Type := p_Periodicities_Rec_Type;

    /*
        NOTE: These are raw insert statements, for validations,
        please refer to the public and wrapper layeres
    */

    -- Insert into Periodicity base tables
    INSERT INTO BSC_SYS_PERIODICITIES (
              PERIODICITY_ID
            , NUM_OF_PERIODS
            , SOURCE
            , NUM_OF_SUBPERIODS
            , PERIOD_COL_NAME
            , SUBPERIOD_COL_NAME
            , YEARLY_FLAG
            , EDW_FLAG
            , CALENDAR_ID
            , EDW_PERIODICITY_ID
            , CUSTOM_CODE
            , DB_COLUMN_NAME
            , PERIODICITY_TYPE
            , PERIOD_TYPE_ID
            , RECORD_TYPE_ID
            , XTD_PATTERN
            , SHORT_NAME
    ) VALUES (
              l_Periodicities_Rec_Type.Periodicity_Id
            , l_Periodicities_Rec_Type.Num_Of_Periods
            , l_Periodicities_Rec_Type.Source
            , l_Periodicities_Rec_Type.Num_Of_Subperiods
            , l_Periodicities_Rec_Type.Period_Col_Name
            , l_Periodicities_Rec_Type.Subperiod_Col_Name
            , l_Periodicities_Rec_Type.Yearly_Flag
            , l_Periodicities_Rec_Type.Edw_Flag
            , l_Periodicities_Rec_Type.Calendar_Id
            , l_Periodicities_Rec_Type.Edw_Periodicity_Id
            , l_Periodicities_Rec_Type.Custom_Code
            , l_Periodicities_Rec_Type.Db_Column_Name
            , l_Periodicities_Rec_Type.Periodicity_Type
            , l_Periodicities_Rec_Type.Period_Type_Id
            , l_Periodicities_Rec_Type.Record_Type_Id
            , l_Periodicities_Rec_Type.Xtd_Pattern
            , l_Periodicities_Rec_Type.Short_Name
    );

    -- Insert into Periodicity transalatable tables
    INSERT INTO BSC_SYS_PERIODICITIES_TL (
              PERIODICITY_ID
            , LANGUAGE
            , SOURCE_LANG
            , NAME
            , CREATED_BY
            , CREATION_DATE
            , LAST_UPDATED_BY
            , LAST_UPDATE_DATE
            , LAST_UPDATE_LOGIN
    )
    SELECT
              l_Periodicities_Rec_Type.Periodicity_Id
            , L.LANGUAGE_CODE
            , USERENV('LANG')
            , l_Periodicities_Rec_Type.Name
            , l_Periodicities_Rec_Type.Created_By
            , l_Periodicities_Rec_Type.Creation_Date
            , l_Periodicities_Rec_Type.Last_Updated_By
            , l_Periodicities_Rec_Type.Last_Update_Date
            , l_Periodicities_Rec_Type.Last_Update_Login
    FROM     FND_LANGUAGES L
    WHERE    L.INSTALLED_FLAG IN ('I', 'B')
    AND      NOT EXISTS
             (
               SELECT NULL
               FROM   BSC_SYS_PERIODICITIES_TL T
               WHERE  T.PERIODICITY_ID = l_Periodicities_Rec_Type.Periodicity_Id
               AND    T.LANGUAGE       = L.LANGUAGE_CODE
             );


    IF ((p_Commit IS NOT NULL) AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreatePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreatePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreatePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Create_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreatePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Create_Periodicity ';
        END IF;

END Create_Periodicity;

PROCEDURE Retrieve_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    CURSOR c_RetrievePeriodicity IS
    SELECT
       B.PERIODICITY_ID
     , B.NUM_OF_PERIODS
     , B.SOURCE
     , B.NUM_OF_SUBPERIODS
     , B.PERIOD_COL_NAME
     , B.SUBPERIOD_COL_NAME
     , B.YEARLY_FLAG
     , B.EDW_FLAG
     , B.CALENDAR_ID
     , B.EDW_PERIODICITY_ID
     , B.CUSTOM_CODE
     , B.DB_COLUMN_NAME
     , B.PERIODICITY_TYPE
     , B.PERIOD_TYPE_ID
     , B.RECORD_TYPE_ID
     , B.XTD_PATTERN
     , B.SHORT_NAME
     , TL.NAME
     , TL.CREATED_BY
     , TL.CREATION_DATE
     , TL.LAST_UPDATED_BY
     , TL.LAST_UPDATE_DATE
     , TL.LAST_UPDATE_LOGIN
    FROM
       BSC_SYS_PERIODICITIES B
     , BSC_SYS_PERIODICITIES_TL TL
    WHERE
         B.PERIODICITY_ID  = p_Periodicities_Rec_Type.Periodicity_Id
     AND TL.PERIODICITY_ID = B.PERIODICITY_ID
     AND TL.LANGUAGE       = USERENV('LANG');

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR C1RP IN c_RetrievePeriodicity LOOP
        x_Periodicities_Rec_Type.Periodicity_Id     := C1RP.PERIODICITY_ID;
        x_Periodicities_Rec_Type.Num_Of_Periods     := C1RP.NUM_OF_PERIODS;
        x_Periodicities_Rec_Type.Source             := C1RP.SOURCE;
        x_Periodicities_Rec_Type.Num_Of_Subperiods  := C1RP.NUM_OF_SUBPERIODS;
        x_Periodicities_Rec_Type.Period_Col_Name    := C1RP.PERIOD_COL_NAME;
        x_Periodicities_Rec_Type.Subperiod_Col_Name := C1RP.SUBPERIOD_COL_NAME;
        x_Periodicities_Rec_Type.Yearly_Flag        := C1RP.YEARLY_FLAG;
        x_Periodicities_Rec_Type.Edw_Flag           := C1RP.EDW_FLAG;
        x_Periodicities_Rec_Type.Calendar_Id        := C1RP.CALENDAR_ID;
        x_Periodicities_Rec_Type.Edw_Periodicity_Id := C1RP.EDW_PERIODICITY_ID;
        x_Periodicities_Rec_Type.Custom_Code        := C1RP.CUSTOM_CODE;
        x_Periodicities_Rec_Type.Db_Column_Name     := C1RP.DB_COLUMN_NAME;
        x_Periodicities_Rec_Type.Periodicity_Type   := C1RP.PERIODICITY_TYPE;
        x_Periodicities_Rec_Type.Period_Type_Id     := C1RP.PERIOD_TYPE_ID;
        x_Periodicities_Rec_Type.Record_Type_Id     := C1RP.RECORD_TYPE_ID;
        x_Periodicities_Rec_Type.Xtd_Pattern        := C1RP.XTD_PATTERN;
        x_Periodicities_Rec_Type.Short_Name         := C1RP.SHORT_NAME;
        x_Periodicities_Rec_Type.Name               := C1RP.NAME;
        x_Periodicities_Rec_Type.Created_By         := C1RP.CREATED_BY;
        x_Periodicities_Rec_Type.Creation_Date      := C1RP.CREATION_DATE;
        x_Periodicities_Rec_Type.Last_Updated_By    := C1RP.LAST_UPDATED_BY;
        x_Periodicities_Rec_Type.Last_Update_Date   := C1RP.LAST_UPDATE_DATE;
        x_Periodicities_Rec_Type.Last_Update_Login  := C1RP.LAST_UPDATE_LOGIN ;
    END LOOP;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
        --removed rollback here.
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Retrieve_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Retrieve_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Retrieve_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Retrieve_Periodicity ';
        END IF;
END Retrieve_Periodicity;

-- Private Update Periodicity API

PROCEDURE Update_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Structural_Flag         OUT NOCOPY  VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type    BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
    l_Base_Periodicity_Source   BSC_SYS_PERIODICITIES.SOURCE%TYPE;

BEGIN
    SAVEPOINT UpdatePeriodicityPVT;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    x_Structural_Flag := FND_API.G_FALSE;

    BSC_PERIODICITIES_PVT.Retrieve_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,x_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Periodicities_Rec_Type.Num_Of_Periods IS NOT NULL) THEN

        IF(l_Periodicities_Rec_Type.Num_Of_Periods <> p_Periodicities_Rec_Type.Num_Of_Periods) THEN
            x_Structural_Flag := FND_API.G_TRUE;
        END IF;

        l_Periodicities_Rec_Type.Num_Of_Periods := p_Periodicities_Rec_Type.Num_Of_Periods;
    END IF;

    IF (p_Periodicities_Rec_Type.Base_Periodicity_Id IS NOT NULL) THEN
        -- Fixed for Bug#4539411 ,all Custom Periodicities should *not* have comma separated list.
        IF (TO_CHAR(p_Periodicities_Rec_Type.Base_Periodicity_Id) <> l_Periodicities_Rec_Type.Source) THEN
            x_Structural_Flag := FND_API.G_TRUE;
            l_Periodicities_Rec_Type.Base_Periodicity_Id := p_Periodicities_Rec_Type.Base_Periodicity_Id;
            l_Periodicities_Rec_Type.Source := p_Periodicities_Rec_Type.Base_Periodicity_Id;
        END IF;
    END IF;

    IF (p_Periodicities_Rec_Type.Name IS NOT NULL) THEN
        l_Periodicities_Rec_Type.Name := p_Periodicities_Rec_Type.Name;
    END IF;

    IF (p_Periodicities_Rec_Type.Last_Updated_By IS NOT NULL) THEN
        l_Periodicities_Rec_Type.Last_Updated_By := p_Periodicities_Rec_Type.Last_Updated_By;
    ELSE
        l_Periodicities_Rec_Type.Last_Updated_By := FND_GLOBAL.USER_ID;
    END IF;

    IF (p_Periodicities_Rec_Type.Last_Update_Date IS NOT NULL) THEN
        l_Periodicities_Rec_Type.Last_Update_Date := p_Periodicities_Rec_Type.Last_Update_Date;
    ELSE
        l_Periodicities_Rec_Type.Last_Update_Date := SYSDATE;
    END IF;

    IF (p_Periodicities_Rec_Type.Last_Update_Login IS NOT NULL) THEN
        l_Periodicities_Rec_Type.Last_Update_Login := p_Periodicities_Rec_Type.Last_Update_Login;
    ELSE
        l_Periodicities_Rec_Type.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    END IF;

    IF(p_Periodicities_Rec_Type.Custom_Code IS NOT NULL)THEN
       l_Periodicities_Rec_Type.Custom_Code :=p_Periodicities_Rec_Type.Custom_Code;
    END IF;

    --BSC_PERIODS_UTILITY_PKG.Print_Period_Metadata ('Update_Periodicity 1', l_Periodicities_Rec_Type);


    UPDATE bsc_sys_periodicities b
    SET    b.num_of_periods = l_Periodicities_Rec_Type.Num_Of_Periods
          ,b.source         = l_Periodicities_Rec_Type.Source
          ,b.custom_code    = l_Periodicities_Rec_Type.Custom_Code
    WHERE  b.periodicity_id = l_Periodicities_Rec_Type.Periodicity_id;


    UPDATE bsc_sys_periodicities_tl t
    SET    t.name              = l_Periodicities_Rec_Type.Name
          ,t.last_updated_by   = l_Periodicities_Rec_Type.Last_Updated_By
          ,t.last_update_date  = l_Periodicities_Rec_Type.Last_Update_Date
          ,t.last_update_login = l_Periodicities_Rec_Type.Last_Update_Login
         ,SOURCE_LANG       = userenv('LANG')
    WHERE  t.periodicity_id    = l_Periodicities_Rec_Type.Periodicity_id
    AND    USERENV('LANG')    IN (t.language, t.source_lang);

    SELECT name INTO l_Periodicities_Rec_Type.Name
    FROM   bsc_sys_periodicities_vl
    WHERE  periodicity_id = l_Periodicities_Rec_Type.Periodicity_id;
    --dbms_output.PUT_LINE('Name - ' ||l_Periodicities_Rec_Type.Name);


    IF ((p_Commit IS NOT NULL) AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdatePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdatePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdatePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Update_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdatePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Update_Periodicity ';
        END IF;
END Update_Periodicity;

PROCEDURE Incr_Refresh_Objectives(
  p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    CURSOR c_Objectives IS
        SELECT K.INDICATOR
        FROM   BSC_KPI_PERIODICITIES K
        WHERE  K.PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id;
BEGIN
    SAVEPOINT IncrRefreshPerPVT;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    FOR cObj IN c_Objectives LOOP
        BSC_DESIGNER_PVT.ActionFlag_Change(cObj.INDICATOR, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
    END LOOP;

    IF ((p_Commit IS NOT NULL) AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IncrRefreshPerPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IncrRefreshPerPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO IncrRefreshPerPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Incr_Refresh_Objectives ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Incr_Refresh_Objectives ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO IncrRefreshPerPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Incr_Refresh_Objectives ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Incr_Refresh_Objectives ';
        END IF;
END Incr_Refresh_Objectives;


PROCEDURE Delete_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
BEGIN
    SAVEPOINT DeletePeriodicityPVT;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    DELETE BSC_SYS_PERIODS_TL
    WHERE PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id;

    DELETE BSC_SYS_PERIODS
    WHERE PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id;

    DELETE BSC_SYS_PERIODICITIES_TL
    WHERE PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id;

    DELETE BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id;

    IF ((p_Commit IS NOT NULL) AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeletePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeletePeriodicityPVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeletePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Delete_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeletePeriodicityPVT;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PVT.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PVT.Delete_Periodicity ';
        END IF;
END Delete_Periodicity;


END BSC_PERIODICITIES_PVT;

/
