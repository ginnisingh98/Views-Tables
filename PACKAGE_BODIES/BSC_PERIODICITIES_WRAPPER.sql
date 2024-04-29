--------------------------------------------------------
--  DDL for Package Body BSC_PERIODICITIES_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODICITIES_WRAPPER" AS
/* $Header: BSCWPERB.pls 120.5 2006/04/18 22:34:58 ashankar noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCWPERB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper package body to manage periodicities              |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 19-SEP-2005 ashankar    Fixed Bug#4612590 in Update_Periodicity()     |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 21-MAR-2006 ashankar  Fixed bug#5099465 Modified Validate_Periodicity |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_WRAPPER';

PROCEDURE Create_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_Id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Custom_Code              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Calendar_Time_Stamp      IN          VARCHAR2 := NULL
 ,p_disable_period_val_flag  IN          VARCHAR
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
BEGIN

    SAVEPOINT CreatePeriodicityWRP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Periodicities_Rec_Type.Periodicity_Id      := p_Periodicity_Id;
    l_Periodicities_Rec_Type.Num_Of_Periods      := p_Num_Of_Periods;
    l_Periodicities_Rec_Type.Base_Periodicity_Id := p_Base_Periodicity_Id;
    l_Periodicities_Rec_Type.Calendar_Id         := p_Calendar_Id;
    l_Periodicities_Rec_Type.Name                := p_Periodicity_Name;
    l_Periodicities_Rec_Type.Description         := p_Periodicity_Description;
    l_Periodicities_Rec_Type.Period_IDs          := p_Period_Ids;
    l_Periodicities_Rec_Type.Application_id      := p_Application_Id;
    l_Periodicities_Rec_Type.Short_Name          := p_Short_Name;
    l_Periodicities_Rec_Type.Custom_Code         := p_Custom_Code;
    --l_Periodicities_Rec_Type.ForceRunPopulateCalendar     := FND_API.G_FALSE;

    BSC_BIS_LOCKS_PUB.Lock_Calendar (
       p_Calendar_Id    => p_Calendar_Id
     , p_Time_Stamp     => p_Calendar_Time_Stamp
     , x_Return_Status  => x_Return_Status
     , x_Msg_Count      => x_Msg_Count
     , x_Msg_Data       => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BSC_PERIODICITIES_PUB.Create_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_disable_period_val_flag => p_disable_period_val_flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Create_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Create_Periodicity ';
        END IF;
END Create_Periodicity;


PROCEDURE Update_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2 := NULL
 ,p_Custom_Code              IN          NUMBER
 ,p_disable_period_val_flag  IN          VARCHAR
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
BEGIN
    SAVEPOINT UpdatePeriodicityWRP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Periodicities_Rec_Type.Periodicity_Id      := p_Periodicity_id;
    l_Periodicities_Rec_Type.Num_Of_Periods      := p_Num_Of_Periods;
    l_Periodicities_Rec_Type.Base_Periodicity_Id := p_Base_Periodicity_Id;
    l_Periodicities_Rec_Type.Calendar_Id         := p_Calendar_Id;
    l_Periodicities_Rec_Type.Name                := p_Periodicity_Name;
    l_Periodicities_Rec_Type.Description         := p_Periodicity_Description;
    l_Periodicities_Rec_Type.Period_IDs          := p_Period_Ids;
    l_Periodicities_Rec_Type.Application_id      := p_Application_Id;
    l_Periodicities_Rec_Type.Short_Name          := p_Short_Name;
    l_Periodicities_Rec_Type.Custom_Code         := p_Custom_Code;

    IF (p_Short_Name IS NULL) THEN
        l_Periodicities_Rec_Type.Short_Name := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Short_Name (
                                                p_Periodicity_id
                                               );
    END IF;

    BSC_BIS_LOCKS_PUB.Lock_Periodicity (
         p_Periodicity_Id  => p_Periodicity_Id
       , p_Time_Stamp      => p_Periodicity_Time_Stamp
       , x_Return_Status   => x_Return_Status
       , x_Msg_Count       => x_Msg_Count
       , x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Update_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_disable_period_val_flag => p_disable_period_val_flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Update_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Update_Periodicity ';
        END IF;
END Update_Periodicity;


PROCEDURE Delete_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Calendar_Id              IN          NUMBER
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2  := NULL
 ,p_Calendar_Time_Stamp      IN          VARCHAR2  := NULL
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
BEGIN
    SAVEPOINT DeletePeriodicityWRP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_LOCKS_PUB.Lock_Periodicity (
         p_Periodicity_Id  => p_Periodicity_Id
       , p_Time_Stamp      => p_Periodicity_Time_Stamp
       , x_Return_Status   => x_Return_Status
       , x_Msg_Count       => x_Msg_Count
       , x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- passed the calendar_id instead.
    BSC_BIS_LOCKS_PUB.Lock_Calendar (
       p_Calendar_Id    => p_Calendar_Id
     , p_Time_Stamp     => p_Calendar_Time_Stamp
     , x_Return_Status  => x_Return_Status
     , x_Msg_Count      => x_Msg_Count
     , x_Msg_Data       => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_Periodicities_Rec_Type.Periodicity_Id      := p_Periodicity_id;
    l_Periodicities_Rec_Type.Calendar_Id         := p_Calendar_Id;

    BSC_PERIODICITIES_PUB.Delete_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeletePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeletePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeletePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Delete_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeletePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Delete_Periodicity ';
        END IF;
END Delete_Periodicity;

PROCEDURE Validate_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Calendar_Id              IN          NUMBER
 ,p_Action_Type              IN          VARCHAR2
 ,p_disable_period_val_flag  IN          VARCHAR2
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
BEGIN
    SAVEPOINT ValidatePeriodicityWRP;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Periodicities_Rec_Type.Periodicity_Id      := p_Periodicity_id;
    l_Periodicities_Rec_Type.Calendar_Id         := p_Calendar_Id;

    BSC_PERIODICITIES_PUB.Validate_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_Action_Type             => p_Action_Type
     ,p_disable_period_val_flag => p_disable_period_val_flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO ValidatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ValidatePeriodicityWRP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ValidatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Validate_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Validate_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO ValidatePeriodicityWRP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_WRAPPER.Validate_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_WRAPPER.Validate_Periodicity ';
        END IF;
END Validate_Periodicity;

PROCEDURE Create_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_Id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Custom_Code              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Calendar_Time_Stamp      IN          VARCHAR2 := NULL
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
BEGIN
  BSC_PERIODICITIES_WRAPPER.Create_Periodicity
  (
    p_Commit                     =>    p_Commit
   ,p_Periodicity_Id             =>    p_Periodicity_Id
   ,p_Periodicity_Name           =>    p_Periodicity_Name
   ,p_Periodicity_Description    =>    p_Periodicity_Description
   ,p_Short_Name                 =>    p_Short_Name
   ,p_Application_Id             =>    p_Application_Id
   ,p_Base_Periodicity_Id        =>    p_Base_Periodicity_Id
   ,p_Num_Of_Periods             =>    p_Num_Of_Periods
   ,p_Calendar_Id                =>    p_Calendar_Id
   ,p_Custom_Code                =>    p_Custom_Code
   ,p_Period_Ids                 =>    p_Period_Ids
   ,p_Calendar_Time_Stamp        =>    p_Calendar_Time_Stamp
   ,p_disable_period_val_flag    =>    FND_API.G_FALSE
   ,x_Return_Status              =>    x_Return_Status
   ,x_Msg_Count                  =>    x_Msg_Count
   ,x_Msg_Data                   =>    x_Msg_Data
);

END Create_Periodicity;

PROCEDURE Update_Periodicity (
  p_Commit                   IN          VARCHAR2
 ,p_Periodicity_id           IN          VARCHAR2
 ,p_Periodicity_Name         IN          VARCHAR2
 ,p_Periodicity_Description  IN          VARCHAR2
 ,p_Short_Name               IN          VARCHAR2
 ,p_Application_Id           IN          NUMBER
 ,p_Base_Periodicity_Id      IN          NUMBER
 ,p_Num_Of_Periods           IN          NUMBER
 ,p_Calendar_Id              IN          NUMBER
 ,p_Period_Ids               IN          VARCHAR2
 ,p_Periodicity_Time_Stamp   IN          VARCHAR2 := NULL
 ,p_Custom_Code              IN          NUMBER
 ,x_Return_Status            OUT NOCOPY  VARCHAR2
 ,x_Msg_Count                OUT NOCOPY  NUMBER
 ,x_Msg_Data                 OUT NOCOPY  VARCHAR2
) IS
BEGIN

 BSC_PERIODICITIES_WRAPPER.Update_Periodicity (
   p_Commit                   =>  p_Commit
  ,p_Periodicity_id           =>  p_Periodicity_id
  ,p_Periodicity_Name         =>  p_Periodicity_Name
  ,p_Periodicity_Description  =>  p_Periodicity_Description
  ,p_Short_Name               =>  p_Short_Name
  ,p_Application_Id           =>  p_Application_Id
  ,p_Base_Periodicity_Id      =>  p_Base_Periodicity_Id
  ,p_Num_Of_Periods           =>  p_Num_Of_Periods
  ,p_Calendar_Id              =>  p_Calendar_Id
  ,p_Period_Ids               =>  p_Period_Ids
  ,p_Periodicity_Time_Stamp   =>  p_Periodicity_Time_Stamp
  ,p_Custom_Code              =>  p_Custom_Code
  ,p_disable_period_val_flag  =>  FND_API.G_FALSE
  ,x_Return_Status            =>  x_Return_Status
  ,x_Msg_Count                =>  x_Msg_Count
  ,x_Msg_Data                 =>  x_Msg_Data
);

END Update_Periodicity;

END BSC_PERIODICITIES_WRAPPER;

/
