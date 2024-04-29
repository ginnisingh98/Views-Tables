--------------------------------------------------------
--  DDL for Package Body BSC_DATASETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DATASETS_PUB" as
/* $Header: BSCPDTSB.pls 120.2 2007/02/08 13:31:27 akoduri ship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_DATASETS_PUB';

--: This procedure creates a BSC measure.  This is the entry point for the
--: Data Set API.
--: This procedure is part of the Data Set API.
-- mdamle 03/12/2003 - PMD - Measure Definer - Added x_dataset_id
procedure Create_Measures (
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Id      OUT NOCOPY  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
l_measure_col           BSC_SYS_MEASURES.MEASURE_COL%TYPE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dataset_Rec := p_Dataset_Rec;

  -- Assign certain default values if they are currently null.
  if l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag is null then
    l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag := 0;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Color_Method is null then
    l_Dataset_Rec.Bsc_Dataset_Color_Method := 1;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Format_Id is null then
    l_Dataset_Rec.Bsc_Dataset_Format_Id := 5;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Projection_Flag is null then
    l_Dataset_Rec.Bsc_Dataset_Projection_Flag := 1;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Group_Id is null then
    l_Dataset_Rec.Bsc_Measure_Group_Id := -1;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Help is null then
    l_Dataset_Rec.Bsc_Measure_Help := 'Help: ' || l_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Max_Act_Value is null then
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := 1500;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Max_Bud_Value is null then
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := 1500;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Min_Act_Value is null then
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := 1000;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Min_Bud_Value is null then
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := 1000;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Projection_Id is null then
    l_Dataset_Rec.Bsc_Measure_Projection_Id := 3;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Random_Style is null then
    l_Dataset_Rec.Bsc_Measure_Random_Style := 1;
  end if;
  if l_Dataset_Rec.Bsc_Meas_Type is null then
    l_Dataset_Rec.Bsc_Meas_Type := 0;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Created_By is null then
    l_Dataset_Rec.Bsc_Measure_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;


  -- If Measure does not exist then create it.
  if BSC_DATASETS_PVT.Validate_Measure(l_Dataset_Rec.Bsc_Measure_Short_Name) < 1 then

    -- Get the next ID in measure table to assign to current measure.
    l_Dataset_Rec.Bsc_Measure_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_MEASURES'
                                                                      ,'measure_id');

    -- Call the following procedure.
    Create_Dataset( p_commit
                 ,l_Dataset_Rec
         ,x_Dataset_Id
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data);

    -- mdamle 04/23/2003 - PMD - Measure Definer
    -- Switched order of create_dataset and create_measures as well.
    if l_Dataset_Rec.Bsc_Measure_Short_Name is null then
    l_Dataset_Rec.Bsc_Measure_Short_Name := BSC_BIS_MEASURE_PUB.c_PMD || x_Dataset_id;
    end if;
    if l_Dataset_Rec.Bsc_Measure_Col is null then
        l_measure_col := BSC_BIS_MEASURE_PUB.get_measure_col(l_Dataset_Rec.Bsc_Dataset_Name, NULL, l_Dataset_Rec.Bsc_Measure_Id,l_Dataset_Rec.Bsc_Measure_Short_Name);
        if (l_measure_col is not null) then
            l_Dataset_Rec.Bsc_Measure_Col := l_measure_col;
        else
            l_Dataset_Rec.Bsc_Measure_Col := l_Dataset_Rec.Bsc_Measure_Short_Name;
        end if;
    end if;

    -- Call private version of the procedure.
    BSC_DATASETS_PVT.Create_Measures( p_commit
                                     ,l_Dataset_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);


  end if;


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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Measures ';
        END IF;
end Create_Measures;

/************************************************************************************
************************************************************************************/

-- ADRAO : Overloaded for iBuilder
procedure Create_Measures (
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
l_measure_col           BSC_SYS_MEASURES.MEASURE_COL%TYPE;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dataset_Rec := p_Dataset_Rec;

  -- Assign certain default values if they are currently null.
  if l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag is null then
    l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag := 0;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Color_Method is null then
    l_Dataset_Rec.Bsc_Dataset_Color_Method := 1;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Format_Id is null then
    l_Dataset_Rec.Bsc_Dataset_Format_Id := 5;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Projection_Flag is null then
    l_Dataset_Rec.Bsc_Dataset_Projection_Flag := 1;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Group_Id is null then
    l_Dataset_Rec.Bsc_Measure_Group_Id := -1;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Help is null then
    l_Dataset_Rec.Bsc_Measure_Help := 'Help: ' || l_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Max_Act_Value is null then
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := 1500;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Max_Bud_Value is null then
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := 3500;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Min_Act_Value is null then
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := -100;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Min_Bud_Value is null then
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := 50;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Projection_Id is null then
    l_Dataset_Rec.Bsc_Measure_Projection_Id := 3;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Random_Style is null then
    l_Dataset_Rec.Bsc_Measure_Random_Style := 1;
  end if;
  if l_Dataset_Rec.Bsc_Meas_Type is null then
    l_Dataset_Rec.Bsc_Meas_Type := 0;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Created_By is null then
    l_Dataset_Rec.Bsc_Measure_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;


  -- If Measure does not exist then create it.
  if BSC_DATASETS_PVT.Validate_Measure(l_Dataset_Rec.Bsc_Measure_Short_Name) < 1 then

    -- Get the next ID in measure table to assign to current measure.
    l_Dataset_Rec.Bsc_Measure_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_MEASURES'
                                                                      ,'measure_id');

    -- Call the following procedure.
    Create_Dataset( p_commit
                 ,l_Dataset_Rec
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data);

    -- mdamle 04/23/2003 - PMD - Measure Definer
    -- Switched order of create_dataset and create_measures as well.
    if l_Dataset_Rec.Bsc_Measure_Col is null then
        l_measure_col := BSC_BIS_MEASURE_PUB.get_measure_col(l_Dataset_Rec.Bsc_Dataset_Name, NULL, l_Dataset_Rec.Bsc_Measure_Id,l_Dataset_Rec.Bsc_Measure_Short_Name);
        if (l_measure_col is not null) then
            l_Dataset_Rec.Bsc_Measure_Col := l_measure_col;
        else
            l_Dataset_Rec.Bsc_Measure_Col := l_Dataset_Rec.Bsc_Measure_Short_Name;
        end if;
     --l_Dataset_Rec.Bsc_Measure_Col := l_Dataset_Rec.Bsc_Measure_Short_Name;
    end if;

    -- Call private version of the procedure.
    BSC_DATASETS_PVT.Create_Measures( p_commit
                                     ,l_Dataset_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);


  end if;


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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Measures ';
        END IF;

end Create_Measures;

/************************************************************************************
************************************************************************************/
-- ADRAO : Overloaded for iBuilder

procedure Retrieve_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Retrieve_Measures( p_commit
                                         ,p_Dataset_Rec
                                         ,x_Dataset_Rec
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data);

  Retrieve_Dataset( p_commit
                   ,p_Dataset_Rec
                   ,x_Dataset_Rec
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Measures ';
        END IF;
end Retrieve_Measures;

/************************************************************************************
************************************************************************************/

procedure Update_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Update_Measures( p_commit
                                       ,p_Dataset_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

  Update_Dataset( p_commit
                 ,p_Dataset_Rec
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Measures ';
        END IF;
end Update_Measures;

/************************************************************************************
************************************************************************************/

-- mdamle 04/23/2003 - PMD - Measure Definer - Added p_update_dset_calc
procedure Update_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_update_dset_calc    IN      BOOLEAN
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
)is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Update_Measures( p_commit
                                       ,p_Dataset_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

  Update_Dataset( p_commit
                 ,p_Dataset_Rec
         ,p_update_dset_calc
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Measures ';
        END IF;
end Update_Measures;

/************************************************************************************
************************************************************************************/

procedure Delete_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Delete_Dataset( p_commit
                 ,p_Dataset_Rec
                 ,x_return_status
                 ,x_msg_count
                 ,x_msg_data);

  IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) OR (x_return_status IS NULL) ) THEN
    BSC_DATASETS_PVT.Delete_Measures( p_commit
                                     ,p_Dataset_Rec
                                     ,x_return_status
                                     ,x_msg_count
                                     ,x_msg_data);
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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Measures ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Measures ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Measures ';
        END IF;
end Delete_Measures;

/************************************************************************************
************************************************************************************/
/*

procedure Create_Formats(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Formats ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Formats ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Formats ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Formats ';
        END IF;
end Create_Formats;
*/

/************************************************************************************
************************************************************************************/
/*

procedure Delete_Formats(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Formats ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Formats ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Formats ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Formats ';
        END IF;
end Delete_Formats;
*/

/************************************************************************************
************************************************************************************/

--: This procedure creates a dataset for the given measure.
--: This procedure is part of the Data Set API.
-- mdamle 04/23/2003 - PMD - Measure Definer - Added x_dataset_id
procedure Create_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Id      OUT NOCOPY  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

l_count             number;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dataset_Rec := p_Dataset_Rec;


  -- If dataset name is null then give it the measure short name.
  if l_Dataset_Rec.Bsc_Dataset_Name is null then
    l_Dataset_Rec.Bsc_Dataset_Name := l_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;

  -- mdamle 07/24/2003 - Default null description to dataset name
  if l_Dataset_Rec.Bsc_Dataset_Help is null then
    l_Dataset_Rec.Bsc_Dataset_Help := l_Dataset_Rec.Bsc_Dataset_Name;
  end if;

-- 16-JUN-2003 ADRAO added for who columns
  if l_Dataset_Rec.Bsc_Dataset_Created_By is null then
    l_Dataset_Rec.Bsc_Dataset_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;


/*  Remove following validation, in case there are measures with the same name.
  -- Determine if this Data Set already exists.
  select count(*)
    into l_count
    from BSC_SYS_DATASETS_TL a
        ,BSC_SYS_DATASETS_B b
   where upper(a.name) = upper(l_Dataset_Rec.Bsc_Dataset_Name)
     and upper(b.source) = upper(l_Dataset_Rec.Bsc_Source)
     and a.dataset_id = b.dataset_id;
*/

  -- If Data set does not exist then create it, else do nothing.
--  if l_count = 0 then

  -- Get the next ID value in the datasets table for the current data set.
  l_Dataset_Rec.Bsc_Dataset_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_DATASETS_TL'
                                                                            ,'dataset_id');

  -- mdamle 04/23/2003 - PMD - Measure Definer
  x_Dataset_Id := l_Dataset_Rec.Bsc_Dataset_Id;

    -- Call private version of the procedure.
    BSC_DATASETS_PVT.Create_Dataset( p_commit
                                    ,l_Dataset_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

    -- mdamle 07/24/2003 - In the new PMD Measure Definer, the
    -- defaults are taken care of in the UI, and the
    -- update of this table is handled separately.
    -- Call the following procedure.
    /*
    Create_Dataset_Calc( p_commit
                        ,l_Dataset_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);
    */
--  end if;

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset ';
        END IF;
end Create_Dataset;

/************************************************************************************
************************************************************************************/
-- ADRAO : Overloaded for iBuilder
procedure Create_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

l_count             number;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dataset_Rec := p_Dataset_Rec;


  -- If dataset name is null then give it the measure short name.
  if l_Dataset_Rec.Bsc_Dataset_Name is null then
    l_Dataset_Rec.Bsc_Dataset_Name := l_Dataset_Rec.Bsc_Measure_Short_Name;
  end if;

  if l_Dataset_Rec.Bsc_Dataset_Help is null then
    l_Dataset_Rec.Bsc_Dataset_Help := 'No Help comment provided.';
  end if;

-- 16-JUN-2003 ADRAO added for who columns
  if l_Dataset_Rec.Bsc_Dataset_Created_By is null then
    l_Dataset_Rec.Bsc_Dataset_Created_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_By := fnd_global.USER_ID;
  end if;
  if l_Dataset_Rec.Bsc_Dataset_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;


/*  Remove following validation, in case there are measures with the same name.
  -- Determine if this Data Set already exists.
  select count(*)
    into l_count
    from BSC_SYS_DATASETS_TL a
        ,BSC_SYS_DATASETS_B b
   where upper(a.name) = upper(l_Dataset_Rec.Bsc_Dataset_Name)
     and upper(b.source) = upper(l_Dataset_Rec.Bsc_Source)
     and a.dataset_id = b.dataset_id;
*/

  -- If Data set does not exist then create it, else do nothing.
--  if l_count = 0 then

  -- Get the next ID value in the datasets table for the current data set.
  l_Dataset_Rec.Bsc_Dataset_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_DATASETS_TL'
                                                                            ,'dataset_id');

  -- mdamle 04/23/2003 - PMD - Measure Definer
  -- x_Dataset_Id := l_Dataset_Rec.Bsc_Dataset_Id;

    -- Call private version of the procedure.
    BSC_DATASETS_PVT.Create_Dataset( p_commit
                                    ,l_Dataset_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

    -- Call the following procedure.
    Create_Dataset_Calc( p_commit
                        ,l_Dataset_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);

--  end if;

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset ';
        END IF;
end Create_Dataset;

-- ADRAO : Overloaded for iBuilder

/************************************************************************************
************************************************************************************/


procedure Retrieve_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY     BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Retrieve_Dataset( p_commit
                                    ,p_Dataset_Rec
                                    ,x_Dataset_Rec
                                    ,x_return_status
                                    ,x_msg_count
                                    ,x_msg_data);

  /*Retrieve_Dataset_Calc( p_commit
                        ,p_Dataset_Rec
                        ,x_Dataset_Rec
                        ,x_return_status
                        ,x_msg_count
                        ,x_msg_data);*/

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Dataset ';
        END IF;
end Retrieve_Dataset;

/************************************************************************************
************************************************************************************/
/*
procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Update_Dataset( p_commit
                                  ,p_Dataset_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);

  Update_Dataset_Calc( p_commit
                      ,p_Dataset_Rec
                      ,x_return_status
                       ,x_msg_count
                       ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
end Update_Dataset; */

procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_update_dset_calc    IN      BOOLEAN
 ,x_return_status       OUT NOCOPY varchar2
 ,x_msg_count           OUT NOCOPY number
 ,x_msg_data            OUT NOCOPY varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Update_Dataset( p_commit
                                  ,p_Dataset_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);
  IF (p_update_dset_calc) THEN
      Update_Dataset_Calc( p_commit
                          ,p_Dataset_Rec
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
end Update_Dataset;



/****************************/
procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY varchar2
 ,x_msg_count           OUT NOCOPY number
 ,x_msg_data            OUT NOCOPY varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Update_Dataset(
  p_commit              => p_commit
 ,p_Dataset_Rec         => p_Dataset_Rec
 ,p_update_dset_calc    => TRUE
 ,x_return_status       => x_return_status
 ,x_msg_count           => x_msg_count
 ,x_msg_data            => x_msg_data
);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset ';
        END IF;
end Update_Dataset;


/************************************************************************************
************************************************************************************/

procedure Delete_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- mdamle 04/23/2003 - PMD - Measure Definer - Changed the order of deletion
  -- Delete from child table before deleting master record.
  Delete_Dataset_Calc( p_commit
                      ,p_Dataset_Rec
                      ,x_return_status
                      ,x_msg_count
                      ,x_msg_data);


  BSC_DATASETS_PVT.Delete_Dataset( p_commit
                                  ,p_Dataset_Rec
                                  ,x_return_status
                                  ,x_msg_count
                                  ,x_msg_data);


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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Dataset ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Dataset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Dataset ';
        END IF;
end Delete_Dataset;

/************************************************************************************
************************************************************************************/

--: This procedure creates the necessary values for the disabled calc id
--: for the given dimension.
--: This procedure is part of the Data Set API.

procedure Create_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Assign all values in the passed "Record" parameter to the locally defined
  -- "Record" variable.
  l_Dataset_Rec := p_Dataset_Rec;

  -- Loop for values between 3 and 9.
  for i in 3..9 loop
    -- Do not call procedure for value 5.
    if i <> 5 then
      -- Set the value for Disabled_Calc_Id equal to i.
      l_Dataset_Rec.Bsc_Disabled_Calc_Id := i;
      -- Call the private version of the procedure.
      BSC_DATASETS_PVT.Create_Dataset_Calc( p_commit
                                           ,l_Dataset_Rec
                                           ,x_return_status
                                           ,x_msg_count
                                           ,x_msg_data);
    end if;
  end loop;

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset_Calc ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Create_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Create_Dataset_Calc ';
        END IF;
end Create_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Retrieve_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Retrieve_Dataset_Calc( p_commit
                                         ,p_Dataset_Rec
                                         ,x_Dataset_Rec
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Dataset_Calc ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Retrieve_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Retrieve_Dataset_Calc ';
        END IF;
end Retrieve_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Update_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Update_Dataset_Calc( p_commit
                                       ,p_Dataset_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset_Calc ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Update_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Update_Dataset_Calc ';
        END IF;
end Update_Dataset_Calc;

/************************************************************************************
************************************************************************************/

procedure Delete_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) is

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BSC_DATASETS_PVT.Delete_Dataset_Calc( p_commit
                                       ,p_Dataset_Rec
                                       ,x_return_status
                                       ,x_msg_count
                                       ,x_msg_data);

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
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Dataset_Calc ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DATASETS_PUB.Delete_Dataset_Calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DATASETS_PUB.Delete_Dataset_Calc ';
        END IF;
end Delete_Dataset_Calc;

/************************************************************************************
************************************************************************************/
-- Code added for PMF uptaking PMD APIs
--=============================================================================
PROCEDURE Translate_Measure
( p_commit IN VARCHAR2
, p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
, p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
) IS

BEGIN
  BSC_DATASETS_PVT.Translate_Measure(
     p_commit => FND_API.G_FALSE
    ,p_measure_rec => p_measure_rec
    ,p_Dataset_Rec => p_Dataset_Rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END Translate_Measure;
--============================================================================

-- mdamle 09/25/2003 - Sync up measures for all installed languages
PROCEDURE Translate_Measure_By_Lang
( p_commit          IN VARCHAR2
, p_Dataset_Rec     IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, p_lang            IN VARCHAR2
, p_source_lang     IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
) IS

BEGIN
  BSC_DATASETS_PVT.Translate_Measure_By_Lang(
     p_commit        => FND_API.G_FALSE
    ,p_Dataset_Rec   => p_Dataset_Rec
    ,p_lang          => p_lang
    ,p_source_lang   => p_source_lang
    ,x_return_status => x_return_status
    ,x_msg_count     => x_msg_count
    ,x_msg_data      => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
END Translate_Measure_By_Lang;

FUNCTION Get_DataSet_Name(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2 IS
  CURSOR c_dataset_name IS
  SELECT name
  FROM   bsc_sys_datasets_vl
  WHERE  dataset_id = p_DataSet_Id;
  l_Name bsc_sys_datasets_vl.name%TYPE := NULL;
BEGIN

  OPEN c_dataset_name;
  FETCH c_dataset_name INTO l_Name;
  CLOSE c_dataset_name;

  RETURN l_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_DataSet_Name;

FUNCTION Get_DataSet_Source(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2 IS
  CURSOR c_dataset_source IS
  SELECT NVL(source,'BSC')
  FROM   bsc_sys_datasets_vl
  WHERE  dataset_id = p_DataSet_Id;
  l_Source bsc_sys_datasets_vl.source%TYPE;
BEGIN

  OPEN  c_dataset_source;
  FETCH c_dataset_source INTO l_Source;
  CLOSE c_dataset_source;

  RETURN l_Source;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'BSC';
END Get_DataSet_Source;

FUNCTION Get_DataSet_Full_Name(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2
IS
  l_Name VARCHAR2(1000);
  l_No_Report_Message fnd_new_messages.message_text%TYPE;
  CURSOR c_DataSet_Name(p_No_Report_Message VARCHAR2) IS
    SELECT   d.name || '  [' ||
    NVL(DECODE(i.function_name, NULL,
               DECODE(i.actual_data_source, NULL, NULL,
                      (SELECT user_function_name
                       FROM fnd_form_functions_vl
                       WHERE (
                         (type = 'JSP' AND (web_html_call LIKE 'bisviewm.jsp%'
                                            OR web_html_call LIKE 'OA.jsp?page=/oracle/apps/bis/report/webui/BISReportPG%')
                         )
                         OR (type = 'WWW' AND LOWER(web_html_call) LIKE 'bisviewer.showreport%')
                        )
                        AND  UPPER(parameters) LIKE '%PREGIONCODE=' ||
                          UPPER(SUBSTR(i.actual_data_source, 1, INSTR(i.actual_data_source, '.') - 1)) || '%'
                        AND type is not null
                        AND parameters is not null
                        AND web_html_call is not null
                        AND   rownum < 2
                       )
                     ),
              (SELECT ff.user_function_name FROM fnd_form_functions_vl ff WHERE ff.function_name = i.function_name)
       ) , p_No_Report_Message) || ']' name
     FROM
       bis_indicators i,bsc_sys_datasets_vl d
     WHERE
       i.dataset_id = d.dataset_id AND
       d.source = 'PMF' AND
       i.dataset_id = p_DataSet_Id
     UNION
     SELECT
       d.Name
     FROM
       bsc_sys_datasets_vl d
     WHERE
       d.dataset_id = p_DataSet_Id AND
       NVL(d.source,'BSC') <> 'PMF';

BEGIN
  l_No_Report_Message := fnd_message.get_string('BSC','BSC_NO_REPORT_AVAILABLE');
  OPEN c_DataSet_Name(l_No_Report_Message);
  FETCH c_DataSet_Name INTO l_Name;
  CLOSE c_DataSet_Name;

  RETURN l_Name;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_DataSet_Full_Name;

end BSC_DATASETS_PUB;

/
