--------------------------------------------------------
--  DDL for Package Body BSC_BIS_LOCKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_LOCKS_PUB" as
/* $Header: BSCPLOCB.pls 120.5 2006/04/20 07:26:37 visuri noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_BIS_LOCKS_PUB';
g_db_object                             varchar2(30) := null;
/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dataset
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DATASET (
      p_dataset_id          IN              number
) return varchar2 is
Begin
 return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_DATASET (p_dataset_id );
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_DATASET;
/*------------------------------------------------------------------------------------------
Getting Time Stamp for Datasource
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN              number
) return varchar2 is
Begin
return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_DATASOURCE (p_measure_id);
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_DATASOURCE;

/*------------------------------------------------------------------------------------------
Setting Time Stamp for Data set
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dataset_id          IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is

begin

  SAVEPOINT BSCSetTimeDataSetPUB;

/* change time stamp for current dataset */
 BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET (
      p_dataset_id
     ,sysdate
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
 );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPUB;
  --dbms_output.put_line(' G_EXC_UNEXPECTED_ERROR ' );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
  --dbms_output.put_line(' OTHERS '  );
    ROLLBACK TO BSCSetTimeDataSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASET;

/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for Setting Time Stamp for Data set to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dataset_id          IN             number
     ,p_lud                 IN             BSC_SYS_DATASETS_B.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(3000);
  l_operation           varchar2(20);
  l_measure_id1         number;
  l_measure_id2         number;
  l_dataset_id          number;

begin

  SAVEPOINT BSCSetTimeDataSetPUB;

/* change time stamp for current dataset */
 BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DATASET (
      p_dataset_id
     ,p_lud
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
 );
--dbms_output.put_line(' x_return_status = ' || x_return_status );

 /* change Time stamp of the all Dimension Set using Measures used by currrent
    dataset */
  l_sql := '
    SELECT MEASURE_ID1, OPERATION, MEASURE_ID2
    FROM BSC_SYS_DATASETS_VL
    WHERE DATASET_ID =:1';
  open l_cursor for l_sql USING p_dataset_id;
 --dbms_output.put_line(' l_sql = ' || l_sql );

  -- mdamle 7/11/03 - Fixed order of fetch
  fetch l_cursor into l_measure_id1, l_operation, l_measure_id2;
 --dbms_output.put_line(' l_measure_id1 = ' || l_measure_id1 );
 --dbms_output.put_line(' l_measure_id2 = ' || l_measure_id2 );
  if (l_cursor%found) then
   l_sql := '
     SELECT DISTINCT DATASET_ID
     FROM BSC_SYS_DATASETS_B
     WHERE (MEASURE_ID1 =:1 OR MEASURE_ID1 =:2
       OR MEASURE_ID2 =:3 OR MEASURE_ID2 =:4)';

   open l_cursor for l_sql USING l_measure_id1, nvl(l_measure_id2,l_measure_id1)
                ,l_measure_id1, nvl(l_measure_id2,l_measure_id1);
  --dbms_output.put_line(' l_sql = ' || l_sql );
   loop
     fetch l_cursor into l_dataset_id;
     EXIT WHEN l_cursor%NOTFOUND;
    --dbms_output.put_line(' l_dataset_id = ' || l_dataset_id );
     if l_dataset_id <> p_dataset_id then
         BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DATASET (
            l_dataset_id
            ,p_lud
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
         );
       --dbms_output.put_line(' x_return_status = ' || x_return_status );
     end if;
   end loop;
  end if;
  close l_cursor;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPUB;
  --dbms_output.put_line(' G_EXC_UNEXPECTED_ERROR ' );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
  --dbms_output.put_line(' OTHERS '  );
    ROLLBACK TO BSCSetTimeDataSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASET;

/*------------------------------------------------------------------------------------------
Setting Time Stamp for Datasource
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCSetTimeDataSrcPUB;


 BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE (
      p_measure_id
     ,sysdate
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASOURCE;

/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for Setting Time Stamp for Datasource to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN             number
     ,p_lud                 IN             BSC_SYS_MEASURES.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCSetTimeDataSrcPUB;


 BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DATASOURCE (
      p_measure_id
     ,p_lud
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASOURCE;
/*------------------------------------------------------------------------------------------
Procedure to Lock a Datasets
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DATASET (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 /*:= null*/
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(3000);
  l_measure_id1         number;
  l_measure_id2         number;
  l_temp_id1            number;
  l_temp_id2            number;
  l_dataset_id          number;
  l_kpi_id              number;

Begin
 /* Lock the Current Dataset and the Measures assicated with it */
  --dbms_output.put_line(' p_dataset_id = '|| p_dataset_id);

   SAVEPOINT BSCLockDataSetPUB;

   BSC_BIS_LOCKS_PVT.LOCK_DATASET (
        p_dataset_id            =>  p_dataset_id
        ,p_time_stamp           =>  p_time_stamp
        ,x_measure_id1          =>  l_measure_id1
        ,x_measure_id2          =>  l_measure_id2
        ,x_return_status        =>  x_return_status
        ,x_msg_count            =>  x_msg_count
        ,x_msg_data             =>  x_msg_data
   ) ;
  --dbms_output.put_line(' l_measure_id1 = '|| l_measure_id1);
  --dbms_output.put_line(' l_measure_id2 = '|| l_measure_id2);

 /* Lock the Datasets using Measures associated with curent dataset */

  l_sql := '
     SELECT DISTINCT DATASET_ID
     FROM BSC_SYS_DATASETS_B
     WHERE (MEASURE_ID1 =:1 OR MEASURE_ID1 =:2
       OR MEASURE_ID2 =:3 OR MEASURE_ID2 =:4)';

  open l_cursor for l_sql USING l_measure_id1, nvl(l_measure_id2,l_measure_id1)
                ,l_measure_id1, nvl(l_measure_id2,l_measure_id1);

  loop
     fetch l_cursor into l_dataset_id;
     EXIT WHEN l_cursor%NOTFOUND;
     if l_dataset_id <> p_dataset_id then
  --dbms_output.put_line(' l_dataset_id = '|| l_dataset_id);
       BSC_BIS_LOCKS_PVT.LOCK_DATASET (
          p_dataset_id            =>  l_dataset_id
          ,p_time_stamp           =>  null
          ,x_measure_id1          =>  l_temp_id1
          ,x_measure_id2          =>  l_temp_id1
          ,x_return_status        =>  x_return_status
          ,x_msg_count            =>  x_msg_count
          ,x_msg_data             =>  x_msg_data
       ) ;
     end if;
  --dbms_output.put_line(' l_dataset_id = '|| l_dataset_id);
  --dbms_output.put_line(' x_return_status = '|| x_return_status);
  end loop;
  close l_cursor;

 /* Lock the KPIs associated with curent dataset */
  --Performance fix PAJOHRI 28-AUG-2003
  l_sql := '
    SELECT  DISTINCT KM.INDICATOR
    FROM    bsc_kpi_analysis_measures_b KM,
            (  SELECT  DATASET_ID
               FROM    BSC_SYS_DATASETS_B
               WHERE   MEASURE_ID1 IN (:1,:2)
               UNION   ALL
               SELECT  DATASET_ID
               FROM    BSC_SYS_DATASETS_B
               where   MEASURE_ID2 IN (:3,:4)
            ) D
    WHERE   KM.DATASET_ID = D.DATASET_ID';

  open l_cursor for l_sql USING l_measure_id1, nvl(l_measure_id2,l_measure_id1)
                               ,l_measure_id1, nvl(l_measure_id2,l_measure_id1);
  loop
     fetch l_cursor into l_kpi_id;
     EXIT WHEN l_cursor%NOTFOUND;
     if l_dataset_id <> p_dataset_id then
       --dbms_output.put_line(' l_kpi_id = '|| l_kpi_id);
        BSC_BIS_LOCKS_PUB.LOCK_KPI(
             p_Kpi_Id              =>  l_kpi_id
             ,p_time_stamp         =>  null
             ,p_Full_Lock_Flag     =>  null
             ,x_return_status      =>  x_return_status
             ,x_msg_count          =>  x_msg_count
             ,x_msg_data           =>  x_msg_data
        );
     end if;
  end loop;
  close l_cursor;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDataSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDataSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDataSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DATASET;

/*------------------------------------------------------------------------------------------
Procedure to Lock a Datasource
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DATASOURCE(
  p_measure_id           IN             number
 ,p_time_stamp           IN             varchar2 /*:= null*/
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

   SAVEPOINT BSCLockDataSrcPUB;


BSC_BIS_LOCKS_PVT.LOCK_DATASOURCE(
  p_measure_id
 ,p_time_stamp
 ,null
 ,x_return_status
 ,x_msg_count
 ,x_msg_data
) ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDataSrcPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DATASOURCE;

/*------------------------------------------------------------------------------------------
4.2.1.  Lock prcedure to Create a new Measure
-------------------------------------------------------------------------------------------------------------------*/
/*
Procedure LOCK_CREATE_MEASURE (
  p_dataset_id           IN             number
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

LOCK_DATASET (
      p_dataset_id           =>  p_dataset_id
     ,p_time_stamp           =>  p_time_stamp
     ,x_return_status        =>  x_return_status
     ,x_msg_count            =>  x_msg_count
     ,x_msg_data             =>  x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_CREATE_MEASURE;
*/

/*------------------------------------------------------------------------------------------
4.2.2.  Lock prcedure to Update an existing Measure
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_MEASURE (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 /*:= null*/
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

LOCK_DATASET (
      p_dataset_id           =>  p_dataset_id
     ,p_time_stamp           =>  p_time_stamp
     ,x_return_status        =>  x_return_status
     ,x_msg_count            =>  x_msg_count
     ,x_msg_data             =>  x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    --rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  --rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_UPDATE_MEASURE;
/*------------------------------------------------------------------------------------------
4.2.3.  Lock prcedure to Delete an existing Measure
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DELETE_MEASURE (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 /*:= null*/
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

LOCK_DATASET (
      p_dataset_id           =>  p_dataset_id
     ,p_time_stamp           =>  p_time_stamp
     ,x_return_status        =>  x_return_status
     ,x_msg_count            =>  x_msg_count
     ,x_msg_data             =>  x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    --rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  --rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DELETE_MEASURE;
/*------------------------------------------------------------------------------------------
4.2.4.  Lock prcedure to Assign Dataset to Analysis option combination (KPI)
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_ASSIGN_MEASURE (
  p_kpi_Id               IN             number
 ,p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 /* := null */
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is
l_temp1     number;
l_temp2     number;
Begin


   SAVEPOINT BSCLockAsgnMeasurePUB;
/* Lock the KPI */
    BSC_BIS_LOCKS_PUB.LOCK_KPI(
     p_Kpi_Id              =>  p_Kpi_Id
     ,p_time_stamp         =>  p_time_stamp
     ,p_Full_Lock_Flag     =>  null
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );

/* Lock the Dataset and the associated Measures */
   BSC_BIS_LOCKS_PVT.LOCK_DATASET (
        p_dataset_id            =>  p_dataset_id
        ,p_time_stamp           =>  null
        ,x_measure_id1          =>  l_temp1
        ,x_measure_id2          =>  l_temp2
        ,x_return_status        =>  x_return_status
        ,x_msg_count            =>  x_msg_count
        ,x_msg_data             =>  x_msg_data
   ) ;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockAsgnMeasurePUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockAsgnMeasurePUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockAsgnMeasurePUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_ASSIGN_MEASURE;
/*-------------------------------------------------------------------------------------------------------------------
    Procedure to Lock a Dimension Objects
-------------------------------------------------------------------------------------------------------------------*/

Procedure LOCK_DIM_LEVEL(
      p_dim_level_id         IN             number
     ,p_time_stamp           IN             varchar2 /*:= null*/
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCLockDimObjPUB;


  BSC_BIS_LOCKS_PVT.LOCK_DIM_LEVEL(
      p_dim_level_id
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
  );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimObjPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimObjPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDimObjPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DIM_LEVEL;

/*-------------------------------------------------------------------------------------------------------------------
    Procedure to Lock  a Dimension Group
-------------------------------------------------------------------------------------------------------------------*/

Procedure LOCK_DIM_GROUP (
     p_dim_group_id        IN             number
     ,p_time_stamp         IN             varchar2 /*:= null */
     ,x_return_status      OUT NOCOPY     varchar2
     ,x_msg_count          OUT NOCOPY     number
     ,x_msg_data           OUT NOCOPY     varchar2

) is
begin

  SAVEPOINT BSCLockDimPUB;


BSC_BIS_LOCKS_PVT.LOCK_DIM_GROUP (
     p_dim_group_id
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data

);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDimPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DIM_GROUP;

/*-------------------------------------------------------------------------------------------------------------------
    Procedure to Lock  a Dimension Set
-------------------------------------------------------------------------------------------------------------------*/

Procedure LOCK_DIM_SET (
     p_kpi_Id               IN             number
     ,p_dim_set_id          IN             number
     ,p_time_stamp          IN             varchar2 /*:= null*/
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is

Begin

  SAVEPOINT BSCLockDimSetPUB;


BSC_BIS_LOCKS_PVT.LOCK_DIM_SET (
     p_kpi_Id
     ,p_dim_set_id
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDimSetPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DIM_SET;

/*-------------------------------------------------------------------------------------------------------------------
    Procedure to Lock  a KPI
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_KPI(
      p_kpi_Id               IN             number
     ,p_time_stamp           IN             varchar2 /* := null */
     ,p_full_lock_flag       IN             varchar2 /*:= FND_API.G_FALSE  */
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

  SAVEPOINT BSCLockKpiPUB;


BSC_BIS_LOCKS_PVT.LOCK_KPI(
      p_kpi_Id
     ,p_time_stamp
     ,p_full_lock_flag
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockKpiPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockKpiPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockKpiPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
End LOCK_KPI;
/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dimension Level
------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DIM_LEVEL(
      p_dim_level_id          IN              number
) return varchar2 is
Begin
  return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_DIM_LEVEL(p_dim_level_id);
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_DIM_LEVEL;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dimension Group
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DIM_GROUP (
      p_dim_group_id          IN              number
) return varchar2 is
Begin
  return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_DIM_GROUP(p_dim_group_id);
EXCEPTION
  WHEN OTHERS THEN
     return NULL;

end GET_TIME_STAMP_DIM_GROUP;
/*------------------------------------------------------------------------------------------
Getting Time Stamp Dimension Set
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DIM_SET (
    p_kpi_Id                IN              number
    ,p_dim_set_id           IN              number
) return varchar2 is
Begin
  return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_DIM_SET(p_kpi_Id,p_dim_set_id);
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_DIM_SET;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for  KPIs (Indicators)
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_KPI (
     p_kpi_Id                 IN              number
) return varchar2 is
Begin
  return BSC_BIS_LOCKS_PVT.GET_TIME_STAMP_KPI(p_kpi_Id);
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_KPI;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Objects
-------------------------------------------------------------------------------------------*/
Procedure SET_TIME_STAMP_DIM_LEVEL (
      p_dim_level_id        IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
begin
  SAVEPOINT BSCSetTimeDimObjPUB;


 BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DIM_LEVEL (
      p_dim_level_id
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimObjPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimObjPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimObjPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end  SET_TIME_STAMP_DIM_LEVEL;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Group
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DIM_GROUP (
      p_dim_group_id        IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCSetTimeDimPUB;


BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DIM_GROUP (
      p_dim_group_id
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end SET_TIME_STAMP_DIM_GROUP;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Set
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DIM_SET (
     p_kpi_Id               IN              number
     , p_dim_set_id         IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCSetTimeDimSetPUB;


BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DIM_SET (
     p_kpi_Id
     , p_dim_set_id
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimSetPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end SET_TIME_STAMP_DIM_SET;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for KPI
-------------------------------------------------------------------------------------------*/
Procedure SET_TIME_STAMP_KPI (
     p_kpi_Id                IN              number
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
begin

  SAVEPOINT BSCSetTimeKpiPUB;


 BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_KPI (
     p_kpi_Id
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeKpiPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeKpiPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeKpiPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end SET_TIME_STAMP_KPI;

/*------------------------------------------------------------------------------------------
Procedure LOCK_CREATE_DIMENSION

    This Procedure will make all the necessaries locks to Create a Dimensions (Dimension Group)
        according with the PMD UI  for   'Performance Measures > Dimensions > Create Dimension'
    This procedure will lock all the dimension object that will assign to the new Dimension
  <parameters>
    p_selected_dim_objets:  Array  with the Ids corresponding to the Dimesion Objects
                                that will be assigned to the new dimension.
-------------------------------------------------------------------------------------------*/
Procedure LOCK_CREATE_DIMENSION (
     p_selected_dim_objets   IN             t_numberTable
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
Begin

   SAVEPOINT BSCLockCreDimPUB;


BSC_BIS_LOCKS_PVT.LOCK_CREATE_DIMENSION(
     p_selected_dim_objets
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockCreDimPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockCreDimPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockCreDimPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;

end LOCK_CREATE_DIMENSION;
/*------------------------------------------------------------------------------------------
Procedure LOCK_UPDATE_DIMENSION
    This Procedure will make all the necessaries locks to Update a Dimension (Dimension Group)
        according with the PMD UI  for   'Performance Measures > Dimensions > Update Dimension'
    This procedure will lock  the dimension passed in the parameter p_dimension_id,
        the dimension objects passed in the parameter p_selected_dim_objets,
        and the dimension set (in the kpis) that uses the dimension when it is necessary.
  <parameters>
    p_dimension_id:  Dimension Id (Dimension Group) to update
    p_selected_dim_objets:  This array  has the Ids corresponding to the Dimension Objects
                                that will have the dimension.
    p_time_stamp:  Last update of dimension information changed by the user


-------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_DIMENSION (
     p_dimension_id          IN             number
     ,p_selected_dim_objets  IN             t_numberTable
     ,p_time_stamp           IN             varchar2 /*:= null*/
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

   SAVEPOINT BSCLockUpdDimPUB;


BSC_BIS_LOCKS_PVT.LOCK_UPDATE_DIMENSION (
     p_dimension_id
     ,p_selected_dim_objets
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_UPDATE_DIMENSION;

/*------------------------------------------------------------------------------------------
Procedure LOCK_UPDATE_DIM_OBJ_IN_DIM
    This procedure will make all the necessaries locks to Update a Dimension
    Object propertis in a dimencion.
    (Dimension level properties in a Dimension Group

-------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_DIM_OBJ_IN_DIM(
     p_dim_object_id         IN             number
     ,p_dimension_id         IN             number
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
)is
Begin

   SAVEPOINT BSCLockUpdDimInObjPUB;


BSC_BIS_LOCKS_PVT.LOCK_UPDATE_DIM_OBJ_IN_DIM(
     p_dim_object_id
     ,p_dimension_id
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimInObjPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimInObjPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimInObjPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
End LOCK_UPDATE_DIM_OBJ_IN_DIM;

/*------------------------------------------------------------------------------------------
Procedure LOCK_CREATE_DIMENSION_OBJECT
    This procedure will make all the necessaries locks to Create a Dimension Object (Dimension Level)
        according with the PMD UI for 'Performance Measures > Dimensions > Dimension Objects >
        Create Dimension Object'
  <parameters>
    p_selected_dimensions:  This Array  has the Ids corresponding to the Dimensions  where
                                the dimension object will be assigned.
-------------------------------------------------------------------------------------------*/
Procedure LOCK_CREATE_DIMENSION_OBJECT(
    p_selected_dimensions   IN      t_numberTable
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) is

Begin

   SAVEPOINT BSCLockCreDimObjPUB;


BSC_BIS_LOCKS_PVT.LOCK_CREATE_DIMENSION_OBJECT(
    p_selected_dimensions
    ,x_return_status
    ,x_msg_count
    ,x_msg_data
) ;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockCreDimObjPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockCreDimObjPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockCreDimObjPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;

End LOCK_CREATE_DIMENSION_OBJECT;
/*------------------------------------------------------------------------------------------
Procedure LOCK_UPDATE_DIMENSION_OBJECT
    This procedure will make all the necessaries locks to Update a Dimension Object (Dimension Level)
        according with the PMD UI for 'Performance Measures > Dimensions > Dimension Objects >
        Update Dimension Object'
  <parameters>
    p_dim_object_id:        Dimension Object Id (Dimension Level) to update
    p_selected_dim_objets:  This array  has the Ids corresponding to the Dimension Objects
                                that will have the dimension.
    p_time_stamp:  Last update of dimension object information changed by the user.
                       It is  mandatory in order of checking if the dimension object has been
                       updated by other user.
-------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_DIMENSION_OBJECT(
      p_dim_object_id        IN             number
     ,p_selected_dimensions  IN             t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is

Begin

   SAVEPOINT BSCLockUpdDimObjPUB;


BSC_BIS_LOCKS_PVT.LOCK_UPDATE_DIMENSION_OBJECT(
      p_dim_object_id
     ,p_selected_dimensions
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimObjPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimObjPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimObjPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;

end LOCK_UPDATE_DIMENSION_OBJECT;
/*------------------------------------------------------------------------------------------
Procedure LOCK_UPDATE_DIM_OBJ_RELATIONSHIPS
    This process Lock all affected object when the relationships for a given dimension
        object are updated.
  <parameters>
    p_dim_object_id:     Dimension Object Id (Dimension Level) to update
    p_selected_parends:  This array  has the Ids corresponding to the Parent Dimension Objects
                             that will have the dimension object (Selected Parent Dimension Objects)
    p_selected_childs:  This array  has the Ids corresponding to the Child Dimension Objects
                            that will have the dimension object (Selected Child Dimension Objects).
    p_time_stamp:  Last update of dimension object information changed by the user.
                       It is  mandatory in order of checking  if the dimension object has
                       been updated by other user.
-------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_RELATIONSHIPS(
     p_dim_object_id         IN             number
     ,p_selected_parends     IN             t_numberTable
     ,p_selected_childs      IN             t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
Begin

  SAVEPOINT BSCLockUpdDimRelsPUB;


BSC_BIS_LOCKS_PVT.LOCK_UPDATE_RELATIONSHIPS(
     p_dim_object_id
     ,p_selected_parends
     ,p_selected_childs
     ,p_time_stamp
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
) ;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimRelsPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimRelsPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimRelsPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;

end LOCK_UPDATE_RELATIONSHIPS;
/*------------------------------------------------------------------------------------------
Procedure LOCK_ASSIGN_ DIM_SET
    Use this procedure to lock necessary object when a Dimension Set need to be assign
        to a specific Analysis Option
  <parameters>
     p_kpi_Id   : Indicator Id
     p_dim_set_id   : Dimension Set Id
     p_time_stamp   : Time stamp.

    Note: By Now this parmeter will used to make the lock.
              Future version will used other parameters

-------------------------------------------------------------------------------------------*/
Procedure LOCK_ASSIGN_DIM_SET (
     p_kpi_Id           IN      number
    ,p_option_group0    IN      number
    ,p_option_group1    IN      number
    ,p_option_group2    IN      number
    ,p_serie_id         IN      number
    ,p_dim_set_id       IN      number
    ,p_time_stamp       IN              varchar2
    ,x_return_status    OUT NOCOPY      varchar2
    ,x_msg_count        OUT NOCOPY      number
    ,x_msg_data         OUT NOCOPY      varchar2
) is

Begin

    SAVEPOINT BSCLockAsgnDimSetPUB;


BSC_BIS_LOCKS_PVT.LOCK_ASSIGN_DIM_SET (
     p_kpi_Id
    ,p_option_group0
    ,p_option_group1
    ,p_option_group2
    ,p_serie_id
    ,p_dim_set_id
    ,p_time_stamp
    ,x_return_status
    ,x_msg_count
    ,x_msg_data
) ;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockAsgnDimSetPUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockAsgnDimSetPUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockAsgnDimSetPUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_ASSIGN_DIM_SET;

/***********************************************************************
 Name :-  LOCK_ASSIGN_DIM_SET
 Description :- This procedure will lock the Custom View for the tab.
 Input :- p_tab_id
          p_tab_view_id
          p_time_stamp --> corresponds to the time stamp from BSC_TAB_VIEWS_B
 Creator :- ashankar   05-NOV-2003
/***********************************************************************/

PROCEDURE  LOCK_TAB_VIEW_ID
(
     p_tab_id               IN      NUMBER
    ,p_tab_view_id          IN      NUMBER
    ,p_time_stamp           IN      VARCHAR2 := NULL
    ,x_return_status    OUT NOCOPY  VARCHAR2
    ,x_msg_count        OUT NOCOPY  NUMBER
    ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
BEGIN

BSC_BIS_LOCKS_PVT.LOCK_TAB_VIEW_ID
(
     p_tab_id           =>   p_tab_id
    ,p_tab_view_id      =>   p_tab_view_id
    ,p_time_stamp       =>   p_time_stamp
    ,x_return_status    =>   x_return_status
    ,x_msg_count        =>   x_msg_count
    ,x_msg_data         =>   x_msg_data

);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;

END  LOCK_TAB_VIEW_ID;

/***********************************************************************
 Name :-  LOCK_TAB
 Description :- This procedure will lock the tab
 Input :- p_tab_id
          p_time_stamp --> corresponds to the time stamp from BSC_TABS_B
 Creator :- ashankar   10-NOV-2003
/***********************************************************************/

PROCEDURE LOCK_TAB
(
    p_tab_id                IN      NUMBER
   ,p_time_stamp            IN      VARCHAR2 := NULL
   ,x_return_status    OUT NOCOPY   VARCHAR2
   ,x_msg_count        OUT NOCOPY   NUMBER
   ,x_msg_data         OUT NOCOPY   VARCHAR2
)IS
BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_LOCKS_PVT.LOCK_TAB
    (
         p_tab_id           =>   p_tab_id
        ,p_time_stamp       =>   p_time_stamp
        ,x_return_status    =>   x_return_status
        ,x_msg_count        =>   x_msg_count
        ,x_msg_data         =>   x_msg_data

    );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                               ,p_data => x_msg_data);
    RAISE;
END LOCK_TAB;

PROCEDURE raise_lock_error (
       p_Program_id       IN NUMBER
      ,p_User_Name        IN VARCHAR2
      ,p_Machine          IN VARCHAR2
      ,p_Terminal         IN VARCHAR2
) IS
    TYPE t_array_varchar2 IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
    h_modules       t_array_varchar2;
BEGIN
    FND_MSG_PUB.Initialize;
    h_modules(-100) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader UI
    h_modules(-101) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'BSC_LOADER'); -- Loader concurrent program
    h_modules(-200) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER');
    h_modules(-201) := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'METADATA_OPTIMIZER'); --Generate documentation
    h_modules(-700) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'UPGRADE');
    h_modules(-800) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');
    h_modules(-802) := bsc_apps.get_lookup_value('BSC_UI_SETUP', 'SYSTEM_MIGRATION');

    FND_MESSAGE.SET_NAME('BSC','BSC_SEC_LOCKED_SYSTEM');
    FND_MESSAGE.SET_TOKEN('COMPONENT',h_modules(p_Program_id) , TRUE);
    FND_MESSAGE.SET_TOKEN('USERNAME' ,p_User_Name , TRUE);
    FND_MESSAGE.SET_TOKEN('MACHINE'  ,p_Machine , TRUE);
    FND_MESSAGE.SET_TOKEN('TERMINAL' ,p_Terminal, TRUE);
    FND_MSG_PUB.ADD;
    --DBMS_OUTPUT.PUT_LINE('if loop:- ' ||cd.program_id);
    RAISE FND_API.G_EXC_ERROR;
END;

/***********************************************************************
 Name :-  Lock_Designer_Session_AT
 Description :- This procecure will check lock against conflicting moudles and return
                error if one finds. If doesnt find any it will lock for designer
 Input :- p_Entity_Name -> Name of object ie  dimension,dimension object,measure,dim obj relation
          p_Entity_Type -> source type  ie  PMF,BSC
          p_Action_Type -> action on object ie create,update,delete
Creator :- KRISHNA   19-OCT-2004
/***********************************************************************/

PROCEDURE  Lock_Designer_Session_AT (

       p_Entity_Name        IN VARCHAR2
      ,p_Entity_Type        IN VARCHAR2
      ,p_Action_Type        IN VARCHAR2
      ,x_Return_Status      OUT NOCOPY VARCHAR2
      ,x_Msg_Count          OUT NOCOPY NUMBER
      ,x_Msg_Data           OUT NOCOPY VARCHAR2

)IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR c_conflict_session IS
    SELECT c.program_id, u.user_name, s.machine, s.terminal
    FROM   bsc_current_sessions c, v$session s, bsc_apps_users_v u
    WHERE  c.session_id = s.audsid
    AND    c.program_id IN (-100, -101, -200, -201, -700, -800, -802)
    AND    c.session_id <> USERENV('SESSIONID')
    AND    c.user_id = u.user_id (+);

    CURSOR c_sessions IS
    SELECT session_id
    FROM   bsc_current_sessions
    WHERE  program_id IN (-100,-101,-200,-201,-202,-700,-800, -802);

    l_session_ids       VARCHAR2(8000);
    l_sql               VARCHAR2(8000);

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- First we need to delete the orphan sessions
   --Delete all orphan the sessions
    DELETE BSC_CURRENT_SESSIONS
    WHERE  SESSION_ID NOT IN
           (SELECT VS.AUDSID
            FROM V$SESSION VS);

   --Delete all the session not being reused by FND
    DELETE BSC_CURRENT_SESSIONS
    WHERE  ICX_SESSION_ID IN (
            SELECT SESSION_ID
            FROM ICX_SESSIONS
            WHERE (FND_SESSION_MANAGEMENT.CHECK_SESSION(SESSION_ID,NULL,NULL,'N') <> 'VALID'));

    --Delete all the Metadata/Loader sessions, which have their concurrent programs in invalid or hang status
    /**************************************
     Changed for the POSCO bug 4955767
     The logic is the following.
      1.First we will check if there are any sessions
        in BSC_CURRENT_SESSIONS for those programs for which
        concurrent programs are run.
        This include loader,Metadata optimizer,system migration and upgrade
      2.If there are sessions corresponding to above programs then only
        it will enter into the curose loop otherwise it will not.
        This will improve the performance.
      3.Even if it finds the records then it will delete the records only
        for the above programs instead of taking all the programs for which
        concurrent programs are not run.
        This will again imporve the performance
    /**************************************/
    FOR cd IN c_sessions LOOP
      IF(l_session_ids IS NULL ) THEN
         l_session_ids :=cd.session_id;
      ELSE
         l_session_ids := l_session_ids ||','||cd.session_id;
      END IF;
    END LOOP;

    IF(l_session_ids IS NOT NULL) THEN
       l_sql  := ' DELETE bsc_current_sessions'||
                 ' WHERE session_id IN '||
                 ' ( '||
                 ' SELECT oracle_session_id '||
                 ' FROM   fnd_concurrent_requests  '||
                 ' WHERE  program_application_id =271 '||
                 ' AND    oracle_session_id IN ('||l_session_ids ||' )'||
                 ' AND    phase_code=''C'')';
       EXECUTE IMMEDIATE l_sql ;
    END IF;

    --Delete all the Killed Sessions
    DELETE BSC_CURRENT_SESSIONS
    WHERE  SESSION_ID IN (
           SELECT VS.AUDSID
           FROM V$SESSION VS
           WHERE VS.STATUS = 'KILLED');
    --INSERT INTO test_debug_log VALUES ('0','in autonomus',SYSDATE);
    COMMIT;
    FOR cd IN c_conflict_session LOOP
        --DBMS_OUTPUT.PUT_LINE('find program id :- ' ||cd.program_id);
        IF(cd.program_id IN (-700,-800, -802) ) THEN
            raise_lock_error
            ( p_Program_id    => cd.program_id
            , p_User_Name     => cd.user_name
            , p_Machine       => cd.machine
            , p_Terminal      => cd.terminal
            );

        ELSIF (cd.program_id IN (-100, -101, -200, -201) ) THEN
            IF(p_Entity_Name = bsc_utility.c_CALENDAR AND  p_Action_Type = bsc_utility.c_UPDATE) THEN
                raise_lock_error
                ( p_Program_id    => cd.program_id
                , p_User_Name     => cd.user_name
                , p_Machine       => cd.machine
                , p_Terminal      => cd.terminal
                );
            ELSIF (p_Entity_Type = bsc_utility.c_BSC) THEN
              IF((p_Entity_Name NOT IN (bsc_utility.c_DIMENSION,bsc_utility.c_MEASURE)) OR (p_Action_Type <> bsc_utility.c_CREATE)) THEN
                  raise_lock_error
                  ( p_Program_id    => cd.program_id
                  , p_User_Name     => cd.user_name
                  , p_Machine       => cd.machine
                  , p_Terminal      => cd.terminal
                  );
                END IF;

            END IF;
        END IF;

    END LOOP;

    INSERT INTO BSC_CURRENT_SESSIONS (
                        SESSION_ID,
                        PROGRAM_ID,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        USER_ID,
                        ICX_SESSION_ID
                        ) VALUES
                        (
                         USERENV('SESSIONID'),
                         -400,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         FND_GLOBAL.USER_ID,
                         USERENV('SESSIONID')
                        );
    --DBMS_OUTPUT.PUT_LINE('the session id is :- '||USERENV('SESSIONID'));
    COMMIT;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Designer_Session_AT ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Designer_Session_AT ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Lock_Designer_Session_AT;
/***********************************************************************
 Name :-  Lock_Designer_Session_AT
 Description :- This procedure unlock the lock created by Lock_Designer_Session_AT
                This should be called at the end of wrapper API and in all exception blocks
 Creator :- krishna   19-OCT-2004
/***********************************************************************/

PROCEDURE  Unlock_Designer_Session_AT
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    DELETE FROM bsc_current_sessions
    WHERE  session_id = USERENV('SESSIONID')
    AND    program_id = -400;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN  --Need to consume the exception here
        NULL;
END Unlock_Designer_Session_AT;

/*------------------------------------------------------------------------------------------
 *
 * Calendar and Periodicities locking public APIs
 *
-------------------------------------------------------------------------------------------*/

PROCEDURE Lock_Calendar_And_Periods (
     p_Calendar_Id    IN NUMBER
   , p_Time_Stamp     IN VARCHAR2
   , x_Return_Status  OUT NOCOPY  VARCHAR2
   , x_Msg_Count      OUT NOCOPY  NUMBER
   , x_Msg_Data       OUT NOCOPY  VARCHAR2
) IS
    CURSOR c_Periodicity_Ids IS
        SELECT PERIODICITY_ID
        FROM   BSC_SYS_PERIODICITIES
        WHERE  CALENDAR_ID = p_Calendar_Id;
BEGIN
    SAVEPOINT LockUpdateCalendarPUB;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_LOCKS_PVT.Lock_Calendar (
         p_Calendar_Id    => p_Calendar_Id
       , p_Time_Stamp     => p_Time_Stamp
       , x_Return_Status  => x_Return_Status
       , x_Msg_Count      => x_Msg_Count
       , x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FOR cPerIds IN c_Periodicity_Ids LOOP
        BSC_BIS_LOCKS_PVT.Lock_Periodicity (
             p_Periodicity_Id => cPerIds.PERIODICITY_ID
           , p_Time_Stamp     => NULL
           , x_Return_Status  => x_Return_Status
           , x_Msg_Count      => x_Msg_Count
           , x_Msg_Data       => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LockUpdateCalendarPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LockUpdateCalendarPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LockUpdateCalendarPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Calendar_And_Periods ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Calendar_And_Periods ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO LockUpdateCalendarPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Calendar_And_Periods ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Calendar_And_Periods ';
        END IF;
END Lock_Calendar_And_Periods;


PROCEDURE Lock_Calendar (
     p_Calendar_Id    IN NUMBER
   , p_Time_Stamp     IN VARCHAR2
   , x_Return_Status  OUT NOCOPY  VARCHAR2
   , x_Msg_Count      OUT NOCOPY  NUMBER
   , x_Msg_Data       OUT NOCOPY  VARCHAR2
) IS
BEGIN
    SAVEPOINT LockCalendarPUB;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_LOCKS_PVT.Lock_Calendar (
         p_Calendar_Id    => p_Calendar_Id
       , p_Time_Stamp     => p_Time_Stamp
       , x_Return_Status  => x_Return_Status
       , x_Msg_Count      => x_Msg_Count
       , x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LockCalendarPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LockCalendarPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LockCalendarPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Calendar ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Calendar ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO LockCalendarPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Calendar ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Calendar ';
        END IF;
END Lock_Calendar;


PROCEDURE Lock_Periodicity (
     p_Periodicity_Id  IN NUMBER
   , p_Time_Stamp      IN VARCHAR2
   , x_Return_Status   OUT NOCOPY  VARCHAR2
   , x_Msg_Count       OUT NOCOPY  NUMBER
   , x_Msg_Data        OUT NOCOPY  VARCHAR2
) IS
BEGIN
    SAVEPOINT LockPeriodicityPUB;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_LOCKS_PVT.Lock_Periodicity (
         p_Periodicity_Id => p_Periodicity_Id
       , p_Time_Stamp     => p_Time_Stamp
       , x_Return_Status  => x_Return_Status
       , x_Msg_Count      => x_Msg_Count
       , x_Msg_Data       => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LockPeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LockPeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LockPeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO LockPeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PUB.Lock_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PUB.Lock_Periodicity ';
        END IF;
END Lock_Periodicity;

End BSC_BIS_LOCKS_PUB;

/
