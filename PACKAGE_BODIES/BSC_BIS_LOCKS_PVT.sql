--------------------------------------------------------
--  DDL for Package Body BSC_BIS_LOCKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_LOCKS_PVT" as
/* $Header: BSCVLOCB.pls 120.1 2005/07/12 08:48:34 adrao noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPLOCB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      Mayo 27 , 2003                                                  |
 |                                                                                      |
 | Creator:                                                                             |
 |                      William Cano                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |          Private Body Version.                                                       |
 |          This package is used for Locking all PMD Entities                           |
 |                                                                                      |
 | History:                                                                             |
 |         10-JUN-03 Aditya modified procedure   SET_TIME_STAMP_KPI                     |
 |         18=JUN-03 Aditya added SAVEPOINT and ROLLBACK                                |
 |         29-JUN-03 Aditya fixed GET_TIME_STAMP_KPI() procedure                        |
 |         29-JUL-03 Aditya fixed for bug #3047483
 |         20-OCT-03 Kyadamak fixed for the bug #3269334
 |         11-DEC-03 Pradeep  Correct Message for Locked Tab bug #3299614
 |         20-Dec-03 Sawu   Overloaded Set_Time_Stamp_Dataset and Set_Time_Stamp_Datasource
 |                          for bug#4045278
 |         04-JUL-05 Aditya Rao added Calendar and Periodicity Locking APIs             |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_BIS_LOCKS_PVT';
g_db_object                             varchar2(30) := null;


/*-------------------------------------------------------------------------------------------------------------------
    Procedure private functions
-------------------------------------------------------------------------------------------------------------------*/
FUNCTION get_Dataset_Name(
   p_dataset_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM BSC_SYS_DATASETS_VL WHERE DATASET_ID =:1';
  open l_cursor for l_sql USING p_dataset_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_DataSet_Name;

FUNCTION get_Datasource_Name(
   p_datasource_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  temp varchar2(1000);
Begin
  l_sql := 'SELECT MEASURE_COL FROM BSC_SYS_MEASURES WHERE MEASURE_ID =:1';
  open l_cursor for l_sql USING p_datasource_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_Datasource_Name;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dataset
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DATASET (
      p_dim_set_id          IN              number
) return varchar2 is
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
  l_sql := '
    SELECT LAST_UPDATE_DATE
    FROM BSC_SYS_DATASETS_B
    WHERE DATASET_ID =:1';


  open l_cursor for l_sql USING p_dim_set_id;
  fetch l_cursor into temp;
  close l_cursor;
  return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

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
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
  l_sql := '
    SELECT LAST_UPDATE_DATE
    FROM BSC_SYS_MEASURES
    WHERE MEASURE_ID =:1';

  open l_cursor for l_sql USING p_measure_id;
  fetch l_cursor into temp;
  close l_cursor;
  return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

EXCEPTION
  WHEN OTHERS THEN
     return NULL;

end GET_TIME_STAMP_DATASOURCE;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Data set
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dim_set_id          IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_sql                 varchar2(32000);
begin
  SAVEPOINT BSCSetTimeDataSetPVT;

  BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DATASET (
      p_dim_set_id          => p_dim_set_id
     ,p_lud                 => sysdate
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
  );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASET;

/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for setting Time Stamp for Dataset to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dim_set_id          IN             number
     ,p_lud                 IN             BSC_SYS_DATASETS_B.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_sql                 varchar2(32000);
begin
  SAVEPOINT BSCSetTimeDataSetPVT;

  l_sql := '
    UPDATE BSC_SYS_DATASETS_B
    SET LAST_UPDATE_DATE = :1
    WHERE DATASET_ID  =:2';
  execute immediate l_sql USING p_lud, p_dim_set_id;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSetPVT;
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
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeDataSrcPVT;

  BSC_BIS_LOCKS_PVT.SET_TIME_STAMP_DATASOURCE (
      p_measure_id          => p_measure_id
     ,p_lud                 => sysdate
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
  );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASOURCE;
/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for setting Time Stamp for Datasource to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN             number
     ,p_lud                 IN             BSC_SYS_MEASURES.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeDataSrcPVT;

  l_sql := '
    UPDATE BSC_SYS_MEASURES
    SET LAST_UPDATE_DATE = :1
    WHERE MEASURE_ID  =:2';
  execute immediate l_sql USING p_lud, p_measure_id;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

end SET_TIME_STAMP_DATASOURCE;
/*------------------------------------------------------------------------------------------
Procedure to Lock a Datasets
             Lock the Dataset
             Lock the measure(s) asociated to the Dataset

    out parameter:
            x_measure_id1   First Measure associated with the dataset
            x_measure_id2   Second Measure associated with the dataset

-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DATASET (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2/* := null */
 ,x_measure_id1          OUT NOCOPY     number
 ,x_measure_id2          OUT NOCOPY     number
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_object_id           number;
  l_last_update_date    date;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);

  l_operation           varchar2(20);
  l_dataset_name        varchar2(500);
  l_meaning             varchar2(60);   -- Added by ADRAO for Delete Message.

begin
   --dbms_output.put_line(' pvt.LOCK_DATASET p_dataset_id = '  || p_dataset_id );
  /*  Lock the Dimension Set  */

  SAVEPOINT BSCLockDataSetPVT;

  l_sql := 'SELECT DATASET_ID, LAST_UPDATE_DATE
    FROM BSC_SYS_DATASETS_B
    WHERE DATASET_ID =:1
    FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_dataset_id;
  fetch l_cursor into l_object_id, l_last_update_date;
  if (l_cursor%notfound) then
   --dbms_output.put_line(' p_dataset_id = '  || p_dataset_id || ' Deleted by other user ');
    close l_cursor;
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');    -- ADRAO changed Measage
      l_meaning := bsc_apps.get_lookup_value('BSC_UI_COMMON', 'EDW_MEASURE');     -- added by ADRAO
      FND_MESSAGE.SET_TOKEN('TYPE', l_meaning, TRUE);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  if not p_time_stamp is null then
    if p_time_stamp <> TO_CHAR(l_last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) then
   --dbms_output.put_line(' p_dataset_id = '  || p_dataset_id || ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE', get_Dataset_Name(p_dataset_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
       l_last_update_date := l_last_update_date;
    end if;
  end if;

  /*  Lock the Data Sources associated with the Dataset  */
  l_sql := '
    SELECT NAME, MEASURE_ID1, OPERATION, MEASURE_ID2
    FROM BSC_SYS_DATASETS_VL
    WHERE DATASET_ID =:1';
 --dbms_output.put_line(' Flag p_dataset_id = '  || p_dataset_id );
  open l_cursor for l_sql USING p_dataset_id;
  fetch l_cursor into l_dataset_name, x_measure_id1, l_operation , x_measure_id2;
   --dbms_output.put_line(' x_measure_id1 = '  || x_measure_id1 );
   --dbms_output.put_line(' x_measure_id2 = '  || x_measure_id2 );
  if (l_cursor%found) then
    if x_measure_id2 is not null then
      BSC_BIS_LOCKS_PVT.LOCK_DATASOURCE(
        x_measure_id1
       ,null
       ,l_dataset_name
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
      ) ;
    end if;
    if x_measure_id2 is not null and l_operation is not null then
      BSC_BIS_LOCKS_PVT.LOCK_DATASOURCE(
        x_measure_id2
       ,null
       ,l_dataset_name
       ,x_return_status
       ,x_msg_count
       ,x_msg_data
      ) ;
    end if;

  else
    x_measure_id1 := null;
    x_measure_id2 := null;
  end if;
  close l_cursor;
     --dbms_output.put_line(' p_dataset_id = '  || p_dataset_id || ' successfuly locked ');


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDataSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDataSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  ROLLBACK TO BSCLockDataSetPVT;
  if (SQLCODE = -00054) then
   --dbms_output.put_line(' p_dataset_id = '  || p_dataset_id || ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE', get_Dataset_Name(p_dataset_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
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
 ,p_time_stamp           IN             varchar2/* := null */
 ,p_dataset_name         IN             varchar2/* := null */
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_object_id           number;
  l_last_update_date    date;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
begin

--SQL statement used to lock a dimension:

  SAVEPOINT BSCLockDataSrcPVT;

  l_sql := '
    SELECT MEASURE_ID, LAST_UPDATE_DATE
    FROM BSC_SYS_MEASURES
    WHERE MEASURE_ID =:1
    FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_measure_id;
  fetch l_cursor into l_object_id, l_last_update_date;
  if (l_cursor%notfound) then
    close l_cursor;
   --dbms_output.put_line(' p_measure_id = '  || p_measure_id || ' deleted by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE', nvl(p_dataset_name, nvl(get_Datasource_Name(p_measure_id),p_measure_id)));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;

  if not p_time_stamp is null then
    if p_time_stamp <> TO_CHAR(l_last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) then
   --dbms_output.put_line(' p_measure_id = '  || p_measure_id || ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE', nvl(p_dataset_name,get_Datasource_Name(p_measure_id)));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
       l_last_update_date := l_last_update_date;
    end if;
  end if;
     --dbms_output.put_line(' p_measure_id = '  || p_measure_id || ' successfuly locked ');

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDataSrcPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN OTHERS THEN
  ROLLBACK TO BSCLockDataSrcPVT;
  if (SQLCODE = -00054) then
   --dbms_output.put_line(' p_measure_id = '  || p_measure_id || ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE', nvl(p_dataset_name, get_Datasource_Name(p_measure_id)));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
end LOCK_DATASOURCE;
/*-------------------------------------------------------------------------------------------------------------------
    Procedure private functions
-------------------------------------------------------------------------------------------------------------------*/
FUNCTION get_Dim_Level_Name(
   p_dim_level_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  object_id             number;
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM BSC_SYS_DIM_LEVELS_VL WHERE DIM_LEVEL_ID =:1';
  open l_cursor for l_sql USING p_dim_level_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_Dim_Level_Name;
/*-------------------------------------------------------------------------------------------------------------------*/
FUNCTION get_Dim_Group_Name(
   p_dim_group_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  object_id             number;
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM BSC_SYS_DIM_GROUPS_VL WHERE DIM_GROUP_ID =:1';
  open l_cursor for l_sql USING p_dim_group_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_Dim_Group_Name;
/*-------------------------------------------------------------------------------------------------------------------*/
FUNCTION get_Dim_Set_Name(
   p_kpi_id IN NUMBER
   ,p_dim_set_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  object_id             number;
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM bsc_kpi_dim_sets_vl
            WHERE INDICATOR =:1 AND DIM_SET_ID =:2';
  open l_cursor for l_sql USING p_kpi_id, p_dim_set_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_Dim_Set_Name;
/*-------------------------------------------------------------------------------------------------------------------*/

FUNCTION get_KPI_Name(
   p_kpi_id IN NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  object_id             number;
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM BSC_KPIS_VL WHERE INDICATOR =:1';
  open l_cursor for l_sql USING p_kpi_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_KPI_Name;

/*************************************************************************


/*************************************************************************/

FUNCTION get_TabView_Name(
    p_tab_id        IN      NUMBER
   ,p_tab_view_id   IN      NUMBER
) RETURN VARCHAR2 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  object_id             number;
  temp varchar2(300);
Begin
  l_sql := 'SELECT NAME FROM BSC_TAB_VIEWS_VL WHERE TAB_ID =:1 AND TAB_VIEW_ID=:2';
  open l_cursor for l_sql USING p_tab_id,p_tab_view_id;
  fetch l_cursor into temp;
  close l_cursor;
  return temp;
EXCEPTION
  WHEN OTHERS THEN
     return NULL;
END get_TabView_Name;


/*-------------------------------------------------------------------------------------------------------------------*/
Procedure get_selected_dim_objs(
    p_dimension_id          IN              NUMBER
    ,x_selected_dim_objs    OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  l_lock_Rec            t_lock_Rec;
  l_count               number;

Begin
  l_sql := '
    SELECT DIM_LEVEL_ID
    FROM BSC_sys_dim_levels_by_group
    WHERE DIM_GROUP_ID =:1
    ORDER BY DIM_LEVEL_INDEX';

  open l_cursor for l_sql USING p_dimension_id;
  l_count :=1;
  LOOP
      fetch l_cursor into l_lock_Rec.obj_key1;
      exit when l_cursor%NOTFOUND;
      l_lock_Rec.obj_index := l_count;
      x_selected_dim_objs(l_lock_Rec.obj_key1) := l_lock_Rec;
      l_count := l_count + 1;
  END LOOP;
  close l_cursor;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
END get_selected_dim_objs;

/*-------------------------------------------------------------------------------------------------------------------*/
Procedure get_selected_dimensions(
    p_dim_obj_id           IN              NUMBER
    ,x_selected_dimensions  OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  l_lock_Rec            t_lock_Rec;
  l_count               number;

Begin
  l_sql := '
    SELECT DIM_GROUP_ID
    FROM BSC_sys_dim_levels_by_group
    WHERE DIM_LEVEL_ID =:1';

  open l_cursor for l_sql USING p_dim_obj_id;
  l_count :=1;
  LOOP
      fetch l_cursor into l_lock_Rec.obj_key1;
      exit when l_cursor%NOTFOUND;
      l_lock_Rec.obj_index := l_count;
      x_selected_dimensions(l_lock_Rec.obj_key1) := l_lock_Rec;
      l_count := l_count + 1;
  END LOOP;
  close l_cursor;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
END get_selected_dimensions;

/*----------------------------------------------------------------------------
It compare selected and previous objects and return the
impacted object.
It used t_lock_Rec.obj_Flag : 'D'= Delected , 'A'= Added
object Id is used as t_lock_table index
----------------------------------------------------------------------------*/

Procedure get_impacted_objects(
     p_selected_objects     IN              t_lock_table
    ,p_previous_objects     IN              t_lock_table
    ,x_impacted_objects     OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_lock_Rec            t_lock_Rec;
  l_count               number;
  object_id             number;

Begin

  /* Find Added Objects */
  if p_selected_objects.COUNT > 0 then
    object_id := p_selected_objects.FIRST;
    LOOP
       if NOT p_previous_objects.EXISTS(object_id) then
            l_lock_Rec := p_selected_objects(object_id);
            l_lock_Rec.obj_Flag := 'A';
            x_impacted_objects(object_id) := l_lock_Rec;
       END IF;
       IF object_id = p_selected_objects.LAST then
          exit;
       end if;
       object_id := p_selected_objects.NEXT(object_id);
    END LOOP;
  end if;
  /* Find deleted objects */
  if p_previous_objects.COUNT > 0 then
    object_id := p_previous_objects.FIRST;
    LOOP
       if NOT p_selected_objects.EXISTS(object_id) then
            l_lock_Rec := p_previous_objects(object_id);
            l_lock_Rec.obj_Flag := 'D';
            x_impacted_objects(object_id) := l_lock_Rec;
       END IF;
       IF object_id = p_previous_objects.LAST then
          exit;
       end if;
       object_id := p_previous_objects.NEXT(object_id);
    END LOOP;
  end if;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
END get_impacted_objects;
/*----------------------------------------------------------------------------
 Convert
----------------------------------------------------------------------------*/
Procedure convert_table(
     p_numberTable          IN              BSC_BIS_LOCKS_PUB.t_numberTable
    ,x_lock_table           OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_lock_Rec            t_lock_Rec;
  l_count               number;
  object_id             number;
  l_index               number;
Begin
  if p_numberTable.COUNT > 0 then
    l_count := 1;
    l_index := p_numberTable.FIRST;
    LOOP
        object_id := p_numberTable(l_index);
        l_lock_Rec.obj_key1 := object_id;
        l_lock_Rec.obj_index := l_count;
        x_lock_table(object_id) :=   l_lock_Rec;
       IF l_index = p_numberTable.LAST then
          exit;
       end if;
       l_index := p_numberTable.NEXT(l_index);
       l_count := l_count + 1;
    END LOOP;
  end if;

EXCEPTION
WHEN OTHERS THEN
--  rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;
END convert_table;





/*--------------------------------------------------------------------
Retun the KPI Dimension Sets using a list of dimensions (Dim Groups)
--------------------------------------------------------------------*/

Procedure get_kpi_dim_sets_by_dim(
    p_selected_dimensions   IN              t_lock_table
    ,x_selected_dim_sets    OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  l_lock_Rec            t_lock_Rec;
  l_index               number;
  l_count               number;

Begin

 if p_selected_dimensions.COUNT > 0 then
  /* build the dimanic query */
  l_sql := '
    SELECT DISTINCT INDICATOR, DIM_SET_ID
    FROM bsc_kpi_dim_groups
    WHERE';
    l_index := p_selected_dimensions.FIRST;
    LOOP
       l_sql := l_sql || ' DIM_GROUP_ID = ' ||  p_selected_dimensions(l_index).obj_key1;
       IF l_index <> p_selected_dimensions.LAST then
           l_sql := l_sql || ' OR ' ;
       else
          l_sql := l_sql  || ' ORDER BY INDICATOR, DIM_SET_ID' ;
          exit;
       end if;
       l_index := p_selected_dimensions.NEXT(l_index);
    END LOOP;
      --dbms_output.put_line('l_sq =l ' || l_sql);

  /* Execute the query */
  open l_cursor for l_sql;
  l_count := 1;
  LOOP
      fetch l_cursor into l_lock_Rec.obj_key1, l_lock_Rec.obj_key2;
      exit when l_cursor%NOTFOUND;
      x_selected_dim_sets(l_count) := l_lock_Rec;
      l_count := l_count + 1;

   END LOOP;
   close l_cursor;
 end if;

EXCEPTION
WHEN OTHERS THEN
--  rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

        --dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));

END get_kpi_dim_sets_by_dim;

/*--------------------------------------------------------------------
Retun the KPI Dimension Sets using a relationships

--------------------------------------------------------------------*/

Procedure get_kpi_dim_sets_by_Rel(
    p_child_dim_obj         IN              number
    ,p_parent_dim_obj        IN              number
    ,x_selected_dim_sets    OUT NOCOPY      t_lock_table
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  l_lock_Rec            t_lock_Rec;
  l_index               number;
  l_count               number;

Begin

  /* build the dimanic query */
  l_sql := '
   Select DISTINCT C.K, C.DS
   FROM (
    SELECT  K.INDICATOR K, K.DIM_SET_ID DS, S.DIM_LEVEL_ID DL
        FROM bsc_kpi_dim_levels_b K,
        bsc_sys_dim_levels_b s
        WHERE K.LEVEL_TABLE_NAME = S.LEVEL_TABLE_NAME
    )P,
    ( SELECT  K.INDICATOR K, K.DIM_SET_ID DS, S.DIM_LEVEL_ID DL
        FROM bsc_kpi_dim_levels_b K,
        bsc_sys_dim_levels_b s
       WHERE K.LEVEL_TABLE_NAME = S.LEVEL_TABLE_NAME
     )C
   WHERE C.K = P.K
    AND  C.DS = P.DS
    AND( C.DL =:1  AND P.DL =:2 )';

  /* Execute the query */
  open l_cursor for l_sql USING p_child_dim_obj, p_parent_dim_obj ;
  l_count := 1;
  LOOP
      fetch l_cursor into l_lock_Rec.obj_key1, l_lock_Rec.obj_key2;
      exit when l_cursor%NOTFOUND;
      x_selected_dim_sets(l_count) := l_lock_Rec;
      l_count := l_count + 1;

   END LOOP;
   close l_cursor;

EXCEPTION
WHEN OTHERS THEN
--  rollback;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

        --dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));

END get_kpi_dim_sets_by_Rel;


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
  l_object_id           number;
  l_last_update_date    date;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCLockDimObjPVT;

--SQL statement used to lock a dimension:
  l_sql := '
  SELECT DIM_LEVEL_ID, LAST_UPDATE_DATE
  FROM BSC_SYS_DIM_LEVELS_B
  WHERE DIM_LEVEL_ID =:1
  FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_dim_level_id;
  fetch l_cursor into l_object_id, l_last_update_date;
  if (l_cursor%notfound) then
    close l_cursor;
     --dbms_output.put_line('Dimension Level Id = '  || p_dim_level_id || ' Deleted by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_DIM_LEVEL');
      FND_MESSAGE.SET_TOKEN('DIM_LEVEL', nvl(get_Dim_Level_Name(p_dim_level_id),p_dim_level_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;

  if not p_time_stamp is null then
    if p_time_stamp <> TO_CHAR(l_last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) then
       --dbms_output.put_line('Dimension Level Id = '  || p_dim_level_id || ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_DIM_LEVEL');
      FND_MESSAGE.SET_TOKEN('DIM_LEVEL', get_Dim_Level_Name(p_dim_level_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
       l_last_update_date := l_last_update_date;
    end if;
  end if;
     --dbms_output.put_line('Dimension Level Id = '  || p_dim_level_id || ' successfuly locked ');

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimObjPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  ROLLBACK TO BSCLockDimObjPVT;
  if (SQLCODE = -00054) then
       --dbms_output.put_line('Dimension Level Id = '  || p_dim_level_id || ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_DIM_LEVEL');
      FND_MESSAGE.SET_TOKEN('DIM_LEVEL', get_Dim_Level_Name(p_dim_level_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
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
  l_object_id           number;
  l_last_update_date    date;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);

begin

  SAVEPOINT BSCLockDimPVT;

 --SQL statement used to lock a dimension group:
 l_sql := '
     SELECT DIM_GROUP_ID
          , LAST_UPDATE_DATE
     FROM   BSC_SYS_DIM_GROUPS_TL
     WHERE  DIM_GROUP_ID = :1
     AND    LANGUAGE     =  USERENV(''LANG'')
     ORDER BY LAST_UPDATE_DATE DESC
     FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_dim_group_id;
  fetch l_cursor into l_object_id, l_last_update_date;

  if (l_cursor%notfound) then
    close l_cursor;
         --dbms_output.put_line('Dimension Group Id = '  || p_dim_group_id || ' Deleted by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_DIM_GROUP');
      FND_MESSAGE.SET_TOKEN('DIM_GROUP', nvl(get_Dim_Group_Name(p_dim_group_id),p_dim_group_id));
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  if not p_time_stamp is null then
    if p_time_stamp <> TO_CHAR(l_last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) then
             --dbms_output.put_line('Dimension Group Id = '  || p_dim_group_id || ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_DIM_GROUP');
      FND_MESSAGE.SET_TOKEN('DIM_GROUP', get_Dim_Group_Name(p_dim_group_id));
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;
         --dbms_output.put_line('Dimension Group Id = '  || p_dim_group_id || ' successfuly locked ');

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockDimPVT;
  if (SQLCODE = -00054) then
             --dbms_output.put_line('Dimension Group Id = '  || p_dim_group_id || ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_DIM_GROUP');
      FND_MESSAGE.SET_TOKEN('DIM_GROUP', get_Dim_Group_Name(p_dim_group_id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;

  end if;

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
  l_kpi_id              number;
  l_dim_set_id          number;
  l_last_update_date    date;
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);

Begin

  SAVEPOINT BSCLockDimSetPVT;


    --SQL statement used to lock a dimension:
  l_sql := '
    SELECT INDICATOR, DIM_SET_ID, LAST_UPDATE_DATE
    FROM bsc_kpi_dim_sets_tl
    WHERE INDICATOR =:1
     AND DIM_SET_ID =:2
    ORDER BY LAST_UPDATE_DATE DESC
    FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_kpi_Id, p_dim_set_id;
  fetch l_cursor into l_kpi_id, l_dim_set_id, l_last_update_date;
  if (l_cursor%notfound) then
    close l_cursor;
       --dbms_output.put_line('Kpi = ' || p_kpi_id  || '  Dimension Set  Id = '  || p_dim_set_id || ' Deleted by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_DIM_SET');
      FND_MESSAGE.SET_TOKEN('DIM_SET', nvl(get_Dim_Set_Name(p_kpi_Id, p_dim_set_id), p_dim_set_id )); -- Fixed Bug#3047483
      FND_MESSAGE.SET_TOKEN('KPI', nvl(get_KPI_Name(p_kpi_Id),p_kpi_Id));  -- Fixed Bug#3047483
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  if not p_time_stamp is null then
    if p_time_stamp <> TO_CHAR(l_last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) then
       --dbms_output.put_line('Kpi = ' || p_kpi_id  || '  Dimension Set  Id = '  || p_dim_set_id ||  ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_DIM_SET');
      FND_MESSAGE.SET_TOKEN('DIM_SET', get_Dim_Set_Name(p_kpi_Id, p_dim_set_id)); -- Fixed Bug#3047483
      FND_MESSAGE.SET_TOKEN('KPI', get_KPI_Name(p_kpi_Id)); -- Fixed Bug#3047483
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;
       --dbms_output.put_line('Kpi = ' || p_kpi_id  || '  Dimension Set  Id = '  || p_dim_set_id ||  ' successfuly locked ');

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockDimSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockDimSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
   ROLLBACK TO BSCLockDimSetPVT;
   if (SQLCODE = -00054) then
       --dbms_output.put_line('Kpi = ' || p_kpi_id  || '  Dimension Set  Id = '  || p_dim_set_id ||  ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_DIM_SET');
      FND_MESSAGE.SET_TOKEN('DIM_SET', get_Dim_Set_Name(p_dim_set_id, p_kpi_Id));
      FND_MESSAGE.SET_TOKEN('KPI', get_KPI_Name(p_kpi_Id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
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
  l_kpi_id              number;
  l_dim_set_id          number;
  l_last_update_date    varchar2(50);
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);
  l_temp                varchar2(300);

Begin

  SAVEPOINT BSCLockKpiPVT;

    --SQL statement used to lock a dimension:
  l_sql := '
    SELECT PROPERTY_CODE
    FROM BSC_KPI_PROPERTIES
    WHERE PROPERTY_CODE = ''LOCK_INDICATOR''
        AND INDICATOR =:1
    FOR UPDATE NOWAIT';

  open l_cursor for l_sql USING p_kpi_Id;
  fetch l_cursor into l_temp;

  if (l_cursor%notfound) then
     close l_cursor;
       --dbms_output.put_line('Kpi = ' || p_kpi_id  || ' Deleted by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_KPI_1');
      FND_MESSAGE.SET_TOKEN('KPI', nvl(get_KPI_Name(p_kpi_Id),p_kpi_Id ));
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_cursor;

  if not p_time_stamp is null then
    l_last_update_date := get_time_stamp_kpi( p_kpi_Id);
    if p_time_stamp <> l_last_update_date then
       --dbms_output.put_line('Kpi = ' || p_kpi_id  ||  ' updated by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_KPI_1');
      FND_MESSAGE.SET_TOKEN('KPI', get_KPI_Name(p_kpi_Id));
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  If p_full_lock_flag = FND_API.G_TRUE then
    --SQL statement used to lock ALL the Dimension Sets:
    l_sql := '
     SELECT INDICATOR, DIM_SET_ID
     FROM bsc_kpi_dim_sets_tl
     WHERE INDICATOR =:1
      FOR UPDATE NOWAIT';
    open l_cursor for l_sql USING p_kpi_Id;
    close l_cursor;
  End if;

  --dbms_output.put_line('Kpi = ' || p_kpi_id  ||  ' successfuly locked ');


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockKpiPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockKpiPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
   --dbms_output.put_line('Procedure = LOCK_KPI  G_EXC_UNEXPECTED_ERROR ');

    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockKpiPVT;
  if (SQLCODE = -00054) then
     --dbms_output.put_line('Kpi = ' || p_kpi_id  || ' locked by other user ');
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_KPI_1');
      FND_MESSAGE.SET_TOKEN('KPI', get_KPI_Name(p_kpi_Id));
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
      RAISE FND_API.G_EXC_ERROR;
  end if;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
   --dbms_output.put_line('Procedure = LOCK_KPI  OTHERS ');

  raise;
End LOCK_KPI;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dimension Level
------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DIM_LEVEL(
      p_dim_level_id          IN              number
) return varchar2 is
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
  l_sql := '
    SELECT LAST_UPDATE_DATE
    FROM BSC_SYS_DIM_LEVELS_B
    WHERE DIM_LEVEL_ID =:1';

  open l_cursor for l_sql USING p_dim_level_id;
  fetch l_cursor into temp;
  close l_cursor;
  return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

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
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
  l_sql := '
    SELECT LAST_UPDATE_DATE
    FROM   BSC_SYS_DIM_GROUPS_VL
    WHERE  DIM_GROUP_ID = :1';

  open l_cursor for l_sql USING p_dim_group_id;
  fetch l_cursor into temp;
  close l_cursor;
  return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

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
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
  l_sql := '
    SELECT MAX(LAST_UPDATE_DATE)
    FROM bsc_kpi_dim_sets_tl
    WHERE INDICATOR =:1
       AND DIM_SET_ID =:2';

  open l_cursor for l_sql USING p_kpi_Id, p_dim_set_id;
  fetch l_cursor into temp;
  close l_cursor;
 return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

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
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  object_id             number;
  temp                  date;
Begin
--  SELECT LAST_UPDATE_DATE

  l_sql := 'SELECT LAST_UPDATE_DATE ' ||
           ' FROM BSC_KPIS_B ' ||
           ' WHERE  INDICATOR =:1' ;
  open l_cursor for l_sql USING p_kpi_Id;
  fetch l_cursor into temp;
  close l_cursor;
  return TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

EXCEPTION
  WHEN OTHERS THEN
     return NULL;
end GET_TIME_STAMP_KPI;

/******************************************************************
 Name :-    get_tab_time_stamp
 Description :- This fucntion will return the time stamp corresponding to
                tab id
 Input :- p_tab_id
 Creator :- ashankar 05-NOV-2003
/******************************************************************/

FUNCTION get_tab_time_stamp(
    p_tab_id                IN            NUMBER
)RETURN VARCHAR2
IS
    l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
    l_sql                 VARCHAR2(32000);
    temp                  BSC_TABS_B.last_update_date%TYPE;
BEGIN
l_sql := 'SELECT LAST_UPDATE_DATE ' ||
        ' FROM BSC_TABS_B ' ||
        ' WHERE TAB_ID =:1 ';


OPEN l_cursor FOR l_sql USING p_tab_id;
FETCH l_cursor INTO temp;
CLOSE l_cursor;

RETURN TO_CHAR(temp,BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END get_tab_time_stamp;


/******************************************************************
 Name :-    get_tabview_time_stamp
 Description :- This fucntion will return the time stamp corresponding to
                tab view
 Input :- p_tab_id
          p_tab_view_id
 Creator :- ashankar 05-NOV-2003
/******************************************************************/

FUNCTION  get_tabview_time_stamp (
      p_tab_id                IN            NUMBER
     ,p_tab_view_id           IN            NUMBER
) RETURN VARCHAR2
 IS
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 VARCHAR2(32000);
  object_id             NUMBER;
  temp                  DATE;
Begin

  l_sql := 'SELECT LAST_UPDATE_DATE ' ||
           ' FROM BSC_TAB_VIEWS_B ' ||
           ' WHERE  TAB_ID =:1 AND TAB_VIEW_ID =:2' ;

  OPEN l_cursor FOR l_sql USING p_tab_id,p_tab_view_id;

  FETCH l_cursor INTO temp;
  CLOSE l_cursor;

  RETURN TO_CHAR(temp,  BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
end get_tabview_time_stamp;


/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Objects
-------------------------------------------------------------------------------------------*/
Procedure SET_TIME_STAMP_DIM_LEVEL (
      p_dim_level_id        IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
) is
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeDimObjPVT;

  l_sql := '
    UPDATE  BSC_SYS_DIM_LEVELS_B
    SET LAST_UPDATE_DATE = sysdate
    WHERE DIM_LEVEL_ID =:1';

  execute immediate l_sql USING p_dim_level_id;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimObjPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

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
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeDimPVT;

  l_sql := '
    UPDATE BSC_SYS_DIM_GROUPS_TL
    SET    LAST_UPDATE_DATE = SYSDATE
    WHERE  DIM_GROUP_ID     =:1
    AND    USERENV(''LANG'') IN (LANGUAGE, SOURCE_LANG)';

  execute immediate l_sql USING p_dim_group_id;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

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
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeDimSetPVT;

  l_sql := '
    UPDATE  bsc_kpi_dim_sets_tl
    SET  LAST_UPDATE_DATE = sysdate
    WHERE INDICATOR =:1
    AND DIM_SET_ID =:2';
  execute immediate l_sql USING p_kpi_Id, p_dim_set_id;

  SET_TIME_STAMP_KPI (p_Kpi_Id
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data  );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeDimSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeDimSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeDimSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

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
  l_sql                 varchar2(32000);
begin

  SAVEPOINT BSCSetTimeKpiPVT;
  -- Modified by Aditya 10-JUN-03
  l_sql := ' UPDATE BSC_KPIS_B ' ||
           ' SET LAST_UPDATE_DATE = SYSDATE ' ||
           ' WHERE  INDICATOR =:1';

  execute immediate l_sql USING p_kpi_Id;

  -- Added Exception block

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCSetTimeKpiPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCSetTimeKpiPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
WHEN OTHERS THEN
    ROLLBACK TO BSCSetTimeKpiPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);

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
     p_selected_dim_objets   IN             BSC_BIS_LOCKS_PUB.t_numberTable
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_index           number;
  l_dim_level_id    number;
Begin

   SAVEPOINT BSCLockCreDimPVT;

   if p_selected_dim_objets.COUNT > 0 then
    l_index := p_selected_dim_objets.FIRST;
    LOOP
       l_dim_level_id := p_selected_dim_objets(l_index);
       BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
            p_dim_level_id        => l_dim_level_id
            ,p_time_stamp         => null
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
        );
        if l_index = p_selected_dim_objets.LAST then
          exit;
        end if;
        l_index := p_selected_dim_objets.NEXT(l_index);
    END LOOP;
  end if;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockCreDimPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockCreDimPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockCreDimPVT;
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
     ,p_selected_dim_objets  IN             BSC_BIS_LOCKS_PUB.t_numberTable
     ,p_time_stamp           IN             varchar2/* := null */
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_index               number;
  l_dim_level_id        number;

  l_selected_dim_objets t_lock_table;
  l_previous_dim_objets t_lock_table;

  l_impacted_dim_sets   t_lock_table;
  l_impacted_dimentions t_lock_table;

  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(300);

  l_lock_Rec             t_lock_Rec;
  l_count                number;
  l_change_dim_sets_flag boolean;

Begin

   SAVEPOINT BSCLockUpdDimPVT;

  /*1 Lock the Dimension calling: */
  BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP (
        p_dim_group_id        => p_dimension_id
        ,p_time_stamp         => p_time_stamp
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
  );

  /* 0. Just passed selected Dimension Object into l_selected_dim_objets */
   if p_selected_dim_objets.COUNT > 0 then
     l_count := 1;
     l_index := p_selected_dim_objets.FIRST;
     LOOP
        l_dim_level_id := p_selected_dim_objets(l_index);
        l_lock_Rec.obj_key1 := l_dim_level_id;
        l_lock_Rec.obj_index := l_count;
        l_selected_dim_objets(l_dim_level_id) := l_lock_Rec;
       IF l_index = p_selected_dim_objets.LAST then
          exit;
       end if;
       l_index := p_selected_dim_objets.NEXT(l_index);
       l_count := l_count + 1;
    END LOOP;
   end if;

  /*2. Query the dimension object that actually have the dimension */
  get_selected_dim_objs(
        p_dimension_id          => p_dimension_id
        ,x_selected_dim_objs    => l_previous_dim_objets
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
 );

  l_change_dim_sets_flag := false;

  /* 3.1 Find the Deleted dimension objects */
  if l_previous_dim_objets.COUNT > 0 then
    l_index := l_previous_dim_objets.FIRST;
    LOOP
       l_dim_level_id := l_previous_dim_objets(l_index).obj_key1;
       if NOT l_selected_dim_objets.EXISTS(l_dim_level_id) then
            /* 4.1 Lock Dimension Objects deleted from de list*/
          BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
              p_dim_level_id         => l_dim_level_id
             ,p_time_stamp           => null
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
          );
          l_change_dim_sets_flag := true;
       END IF;
       IF l_index = l_previous_dim_objets.LAST then
          exit;
       end if;
       l_index := l_previous_dim_objets.NEXT(l_index);
    END LOOP;
  end if;
  /* 3.2 Find the Added dimension objects */
  if l_selected_dim_objets.COUNT > 0 then
    l_index := l_selected_dim_objets.FIRST;
    LOOP
       l_dim_level_id := l_selected_dim_objets(l_index).obj_key1;
       if NOT l_previous_dim_objets.EXISTS(l_dim_level_id) then
            /* 4.2 Lock Dimension Objects Added to de list*/
          BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
              p_dim_level_id         => l_dim_level_id
             ,p_time_stamp           => null
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
          );
          l_change_dim_sets_flag := true;
       elsif l_change_dim_sets_flag = false then
            /* Validate if the dim object order have been changed */
            if l_selected_dim_objets(l_index).obj_index <>
               l_previous_dim_objets(l_index).obj_index   then
                    l_change_dim_sets_flag := true;
            end if;
       end if;
       If l_index = l_selected_dim_objets.LAST then
          exit;
       end if;
       l_index := l_selected_dim_objets.NEXT(l_index);
    END LOOP;
  end if;

 /* 5.Lock all the KPI Dimension Sets using the Dimension (Dimension Group) */
 IF l_change_dim_sets_flag = true then
    l_impacted_dimentions(1).obj_key1:= p_dimension_id;
    get_kpi_dim_sets_by_dim(
             p_selected_dimensions   => l_impacted_dimentions
             ,x_selected_dim_sets    => l_impacted_dim_sets
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
    );
    if not l_impacted_dim_sets is null then
        for l_index in 1.. l_impacted_dim_sets.count loop
          l_lock_Rec := l_impacted_dim_sets(l_index);
          BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
              p_Kpi_Id             =>  l_lock_Rec.obj_key1
             ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
             ,p_time_stamp         =>  null
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );
        end loop;
    end if;
 end if;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimPVT;
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

  l_impacted_dim_sets   t_lock_table;
  l_impacted_dimentions t_lock_table;
  l_lock_Rec             t_lock_Rec;
Begin

   SAVEPOINT BSCLockUpdDimInObjPVT;


/* Lock Dimension  */
  BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP (
        p_dim_group_id        => p_dimension_id
        ,p_time_stamp         => p_time_stamp
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
  );
/* LocKl Dimension Object */
    BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
        p_dim_level_id        => p_dim_object_id
        ,p_time_stamp         => null
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
    );

/* lOCK Kpi Dimension Sets  */
    l_impacted_dimentions(1).obj_key1:= p_dimension_id;
    get_kpi_dim_sets_by_dim(
             p_selected_dimensions   => l_impacted_dimentions
             ,x_selected_dim_sets    => l_impacted_dim_sets
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
    );
    for l_index in 1.. l_impacted_dim_sets.count loop
          l_lock_Rec := l_impacted_dim_sets(l_index);
          BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
              p_Kpi_Id             =>  l_lock_Rec.obj_key1
             ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
             ,p_time_stamp         =>  null
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );
    end loop;





EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimInObjPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimInObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimInObjPVT;
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
    p_selected_dimensions   IN      BSC_BIS_LOCKS_PUB.t_numberTable
    ,x_return_status        OUT NOCOPY      varchar2
    ,x_msg_count            OUT NOCOPY      number
    ,x_msg_data             OUT NOCOPY      varchar2
) is
  l_index                   number;
  l_dim_group_id            number;
  l_impacted_dimentions     t_lock_table;
  l_impacted_dim_sets       t_lock_table;
  l_lock_Rec                t_lock_Rec;

Begin


   SAVEPOINT BSCLockCreDimObjPVT;

   /*1. Lock  all the Dimension where the Dimension Object will be assigned*/
  if p_selected_dimensions.COUNT > 0 then
    l_index := p_selected_dimensions.FIRST;
    LOOP
        l_dim_group_id := p_selected_dimensions(l_index);
        l_impacted_dimentions(l_index).obj_key1 := l_dim_group_id;
        BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP (
            p_dim_group_id        => l_dim_group_id
            ,p_time_stamp         => null
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
        );
        if l_index = p_selected_dimensions.LAST then
          exit;
        end if;
        l_index := p_selected_dimensions.NEXT(l_index);
    END LOOP;
  end if;

 IF l_impacted_dimentions.COUNT > 0 then
   /* 2. Get all the KPI Dimension Sets using the selected Dimensions
   (Dimension Groups) for the new Dimension object*/
    get_kpi_dim_sets_by_dim(
             p_selected_dimensions   => l_impacted_dimentions
             ,x_selected_dim_sets    => l_impacted_dim_sets
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
    );
    /* Lock affected KPI Dimension Sets */
    for l_index in 1.. l_impacted_dim_sets.count loop
          l_lock_Rec := l_impacted_dim_sets(l_index);
          BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
              p_Kpi_Id             =>  l_lock_Rec.obj_key1
             ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
             ,p_time_stamp         =>  null
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );
    end loop;
 end if;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockCreDimObjPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockCreDimObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockCreDimObjPVT;
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
     ,p_selected_dimensions  IN             BSC_BIS_LOCKS_PUB.t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                 varchar2(32000);
  l_dim_set_id          number;
  l_kpi_id              number;

  l_selected_dimensions t_lock_table;
  l_previous_dimensions t_lock_table;
  l_impacted_dim_sets   t_lock_table;
  l_impacted_dimentions t_lock_table;
  l_lock_Rec            t_lock_Rec;
  l_dimension_id        number;
  l_count               number;
  l_index               number;


Begin

   SAVEPOINT BSCLockUpdDimObjPVT;

  /* 0. Just passed p_selected Dimension into l_selected Dimension */
  if p_selected_dimensions.COUNT > 0 then
    l_count := 1;
    l_index := p_selected_dimensions.FIRST;
    LOOP
        l_dimension_id := p_selected_dimensions(l_index);
        l_lock_Rec.obj_key1 := l_dimension_id;
        l_lock_Rec.obj_index := l_count;
        l_selected_dimensions(l_dimension_id) :=   l_lock_Rec;
       IF l_index = p_selected_dimensions.LAST then
          exit;
       end if;
       l_index := p_selected_dimensions.NEXT(l_index);
       l_count := l_count + 1;
    END LOOP;
  end if;

  /* 1. Lock the Dimension object that will be updated */
    BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
        p_dim_level_id        => p_dim_object_id
        ,p_time_stamp         => p_time_stamp
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
    );

 /* 2. Get the KPI Dimension Set that uses the Dimension object*/
  l_sql := '
    SELECT INDICATOR, DIM_SET_ID
    FROM BSC_sys_dim_levels_by_group DLG,
         bsc_kpi_dim_groups KDG
    WHERE DLG.DIM_LEVEL_ID =:1
    AND KDG.DIM_GROUP_ID = DLG.DIM_GROUP_ID';
  open l_cursor for l_sql USING p_dim_object_id ;
  LOOP
      fetch l_cursor into l_kpi_id, l_dim_set_id;
      exit when l_cursor%NOTFOUND;
      /* 3. Lock  each Dimension Set  where the Dimension object is used: */
      BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
              p_Kpi_Id             =>  l_Kpi_Id
             ,p_Dim_Set_Id         =>  l_Dim_Set_Id
             ,p_time_stamp         =>  null
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
      );
  END LOOP;
  close l_cursor;

  /* Followed instructions are for changes in the Selected Dimensions
    for the current Dimension Object */

  /* 4. Get previous Selected Dimension : */
  get_selected_dimensions(
        p_dim_obj_id            => p_dim_object_id
        ,x_selected_dimensions  => l_previous_dimensions
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
   );
   /*5. Compare previous Dimension queried in step 4 with the
         Selected Dimension in  p_Selected_Dimensions to find Dimension
         that was deleted from or added to the Selected Dimension list; This are
         Impacted Dimension  */

  /* 5.1 Find the deleted dimension.  */
  if l_previous_dimensions.COUNT > 0 then
    l_dimension_id := l_previous_dimensions.FIRST;
    LOOP
       if NOT l_selected_dimensions.EXISTS(l_dimension_id) then
            l_lock_Rec := l_previous_dimensions(l_dimension_id);
            l_lock_Rec.obj_Flag := 'D';
            l_impacted_dimentions(l_dimension_id) := l_lock_Rec;
       END IF;
       IF l_dimension_id = l_previous_dimensions.LAST then
          exit;
       end if;
       l_dimension_id := l_previous_dimensions.NEXT(l_dimension_id);
    END LOOP;
  end if;
  /* 5.2 Find the Added dimension.  */
  if l_selected_dimensions.COUNT > 0 then
    l_dimension_id := l_selected_dimensions.FIRST;
    LOOP
       if NOT l_previous_dimensions.EXISTS(l_dimension_id) then
            l_lock_Rec := l_selected_dimensions(l_dimension_id);
            l_lock_Rec.obj_Flag := 'A';
            l_impacted_dimentions(l_dimension_id) := l_lock_Rec;
       END IF;
       IF l_dimension_id = l_selected_dimensions.LAST then
          exit;
       end if;
       l_dimension_id := l_selected_dimensions.NEXT(l_dimension_id);
    END LOOP;
  end if;
  /* 6. Lock the affected dimensions found in step 5 */
   if l_impacted_dimentions.COUNT > 0 then
    l_dimension_id := l_impacted_dimentions.FIRST;
    LOOP
        BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP (
            p_dim_group_id        => l_dimension_id
            ,p_time_stamp         => null
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
        );
        if l_dimension_id = l_impacted_dimentions.LAST then
          exit;
        end if;
        l_dimension_id := l_impacted_dimentions.NEXT(l_dimension_id);
    END LOOP;
  end if;

  /* 7. Get all the KPI Dimension Sets using the Afected Dimensions */
    get_kpi_dim_sets_by_dim(
             p_selected_dimensions   => l_impacted_dimentions
             ,x_selected_dim_sets    => l_impacted_dim_sets
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
    );
 /* 8. Lock each Dimension Set found in Step 7 calling: */
 if not l_impacted_dim_sets is null then
        for l_index in 1.. l_impacted_dim_sets.count loop
          l_lock_Rec := l_impacted_dim_sets(l_index);
          BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
              p_Kpi_Id             =>  l_lock_Rec.obj_key1
             ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
             ,p_time_stamp         =>  null
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
          );
        end loop;
 end if;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimObjPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimObjPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimObjPVT;
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
     ,p_selected_parends     IN             BSC_BIS_LOCKS_PUB.t_numberTable
     ,p_selected_childs      IN             BSC_BIS_LOCKS_PUB.t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
) is
  l_cursor                  BSC_BIS_LOCKS_PUB.t_cursor;
  l_sql                     varchar2(300);
  l_lock_Rec                t_lock_Rec;
  l_count                   number;
  l_index                   number;

  l_selected_parends        t_lock_table;
  l_selected_childs         t_lock_table;
  l_impacted_dim_objects    t_lock_table;
  l_impacted_dim_sets       t_lock_table;
  l_previous_parends        t_lock_table;
  l_previous_childs         t_lock_table;
  l_dim_object_id           number;
  l_child_dim_object_id     number;
  l_parent_dim_object_id    number;

Begin

  SAVEPOINT BSCLockUpdDimRelsPVT;

  /*1. Lock the Dimension object that will be updated: */
  BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
        p_dim_level_id        => p_dim_object_id
        ,p_time_stamp         => p_time_stamp
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
  );

  /*2. Get the previous Parent Dimension Object from the database.*/
  l_sql := '
    SELECT PARENT_DIM_LEVEL_ID
    FROM BSC_SYS_DIM_LEVEL_RELS
    WHERE DIM_LEVEL_ID =:1';
  open l_cursor for l_sql USING p_dim_object_id ;
  LOOP
      fetch l_cursor into l_dim_object_id;
      exit when l_cursor%NOTFOUND;
      l_lock_Rec.obj_key1  := l_dim_object_id;
      l_previous_parends(l_dim_object_id) := l_lock_Rec ;
  END LOOP;
  close l_cursor;

  /*3. Compare Selected parent in p_Selected_Parents and previous parents
         queried in Step 1 to find deleted  and added parent in
         l_impacted_dim_objects  */

  convert_table(
     p_numberTable        => p_selected_parends
    ,x_lock_table         => l_selected_parends
    ,x_return_status      => x_return_status
    ,x_msg_count          => x_msg_count
    ,x_msg_data           => x_msg_data
  );
  get_impacted_objects(
     p_selected_objects   => l_selected_parends
    ,p_previous_objects   => l_previous_parends
    ,x_impacted_objects   => l_impacted_dim_objects
    ,x_return_status      => x_return_status
    ,x_msg_count          => x_msg_count
    ,x_msg_data           => x_msg_data
  );
   if l_impacted_dim_objects.COUNT > 0 then
    l_index := l_impacted_dim_objects.FIRST;
    LOOP
       l_parent_dim_object_id := l_impacted_dim_objects(l_index).obj_key1;
      /*4.  Lock Deleted and  added  Parent Dimension object */
       BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
            p_dim_level_id        => l_parent_dim_object_id
            ,p_time_stamp         => null
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
        );
       /*5. Get Dimension Sets where the deleted or added Relationship */
        get_kpi_dim_sets_by_Rel(
            p_child_dim_obj       => p_dim_object_id
            ,p_parent_dim_obj     => l_parent_dim_object_id
            ,x_selected_dim_sets  => l_impacted_dim_sets
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
          );
        /*6. Lock the Dimension Set got it in step 5 */
         for l_index in 1.. l_impacted_dim_sets.count loop
              l_lock_Rec := l_impacted_dim_sets(l_index);
              BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
                  p_Kpi_Id             =>  l_lock_Rec.obj_key1
                 ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
                 ,p_time_stamp         =>  null
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
              );
        end loop;
        if l_index = l_impacted_dim_objects.LAST then
          exit;
        end if;
        l_index := l_impacted_dim_objects.NEXT(l_index);
    END LOOP;
  end if;


  /*7. Get the previous Child Dimension Object from the database. */
   l_sql := '
    SELECT DIM_LEVEL_ID
    FROM BSC_SYS_DIM_LEVEL_RELS
    WHERE PARENT_DIM_LEVEL_ID =:1';
  open l_cursor for l_sql USING p_dim_object_id ;
  LOOP
      fetch l_cursor into l_dim_object_id;
      exit when l_cursor%NOTFOUND;
      l_lock_Rec.obj_key1  := l_dim_object_id;
      l_previous_childs(l_dim_object_id) := l_lock_Rec ;
  END LOOP;
  close l_cursor;

  /*8. Compare Selected Child in p_Selected_Chlilds and previous
       childs queried in Step 7 to find deleted and added childs. These are
       l_impacted_dim_objects */
  convert_table(
     p_numberTable        => p_selected_childs
    ,x_lock_table         => l_selected_childs
    ,x_return_status      => x_return_status
    ,x_msg_count          => x_msg_count
    ,x_msg_data           => x_msg_data
  );
  get_impacted_objects(
     p_selected_objects   => l_selected_childs
    ,p_previous_objects   => l_previous_childs
    ,x_impacted_objects   => l_impacted_dim_objects
    ,x_return_status      => x_return_status
    ,x_msg_count          => x_msg_count
    ,x_msg_data           => x_msg_data
  );
   if l_impacted_dim_objects.COUNT > 0 then
    l_index := l_impacted_dim_objects.FIRST;
    LOOP
      l_child_dim_object_id := l_impacted_dim_objects(l_index).obj_key1;
      /*9.  Lock deleted and added Child Dimension object*/
       BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL(
            p_dim_level_id        => l_child_dim_object_id
            ,p_time_stamp         => null
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
        );
      /*10. Get Dimension Sets impacted by the Dimension object Relationship */
        get_kpi_dim_sets_by_Rel(
            p_child_dim_obj       => l_child_dim_object_id
            ,p_parent_dim_obj     => p_dim_object_id
            ,x_selected_dim_sets  => l_impacted_dim_sets
            ,x_return_status      => x_return_status
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
          );
      /*11. Lock the Dimension Sets got it in step 10. */
         for l_index in 1.. l_impacted_dim_sets.count loop
              l_lock_Rec := l_impacted_dim_sets(l_index);
              BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
                  p_Kpi_Id             =>  l_lock_Rec.obj_key1
                 ,p_Dim_Set_Id         =>  l_lock_Rec.obj_key2
                 ,p_time_stamp         =>  null
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
              );
        end loop;
        if l_index = l_impacted_dim_objects.LAST then
          exit;
        end if;
        l_index := l_impacted_dim_objects.NEXT(l_index);
    END LOOP;
  end if;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockUpdDimRelsPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockUpdDimRelsPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
    ROLLBACK TO BSCLockUpdDimRelsPVT;
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
  temp number;

Begin

    /* By now,  this procedure will lock the KPI instead of
       the specific analysis options. This because the analysis option are not
       handle by this PMD version yet */

    /*1. Lock the Dimension Set */

    SAVEPOINT BSCLockAsgnDimSetPVT;

    BSC_BIS_LOCKS_PUB.LOCK_DIM_SET (
         p_Kpi_Id              =>  p_Kpi_Id
         ,p_Dim_Set_Id         =>  p_Dim_Set_Id
         ,p_time_stamp         =>  null
         ,x_return_status      =>  x_return_status
         ,x_msg_count          =>  x_msg_count
         ,x_msg_data           =>  x_msg_data
    );
    /*2. Lock the KPI */

    BSC_BIS_LOCKS_PUB.LOCK_KPI(
     p_Kpi_Id              =>  p_Kpi_Id
     ,p_time_stamp         =>  p_time_stamp
     ,p_Full_Lock_Flag     =>  null
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BSCLockAsgnDimSetPVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BSCLockAsgnDimSetPVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    raise;
WHEN OTHERS THEN
  ROLLBACK TO BSCLockAsgnDimSetPVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
  raise;

end LOCK_ASSIGN_DIM_SET;

/************************************************************************
 Name :-    LOCK_TAB
 Description :- This procedure will lock the row corresponding to
                tab_id in BSC_TABS_B table.
 Input :- p_tab_id

 Creator :- ashankar 05-NOV-2003
/************************************************************************/

PROCEDURE LOCK_TAB
(
    p_tab_id                IN      NUMBER
   ,p_time_stamp            IN      VARCHAR2 := NULL
   ,x_return_status    OUT NOCOPY   VARCHAR2
   ,x_msg_count        OUT NOCOPY   NUMBER
   ,x_msg_data         OUT NOCOPY   VARCHAR2
)IS
 l_last_update_date    VARCHAR2(50);
 l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
 l_sql                 varchar2(300);
 l_temp                VARCHAR2(300);

BEGIN

    SAVEPOINT bsclocktabpvt;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_sql := ' SELECT TAB_ID
               FROM BSC_TABS_B
               WHERE TAB_ID = :1
               FOR UPDATE NOWAIT ';


    OPEN l_cursor FOR l_sql USING p_tab_id;
    FETCH l_cursor INTO l_temp;

    IF(l_cursor%NOTFOUND) THEN
        CLOSE l_cursor;
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_IVIEWER', 'SCORECARD'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( p_time_stamp IS NOT NULL) THEN
      l_last_update_date := get_tab_time_stamp
                            ( p_tab_id => p_tab_id
                            );

      IF (p_time_stamp <> l_last_update_date) THEN
        FND_MSG_PUB.Initialize;
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_SCORECARD');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF (l_cursor%ISOPEN) THEN
     CLOSE l_cursor;
    END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN

    IF (l_cursor%ISOPEN) THEN
         CLOSE l_cursor;
    END IF;

    ROLLBACK TO bsclocktabpvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded  => 'F'
                                ,p_count    => x_msg_count
                                ,p_data     => x_msg_data);
    RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF (l_cursor%ISOPEN) THEN
     CLOSE l_cursor;
    END IF;

    ROLLBACK TO bsclocktabpvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded  => 'F'
                                ,p_count    => x_msg_count
                                ,p_data     => x_msg_data);
    RAISE;
WHEN OTHERS THEN
    IF (l_cursor%ISOPEN) THEN
         CLOSE l_cursor;
    END IF;
    ROLLBACK TO bsclocktabpvt;
    IF (SQLCODE = -00054) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSERS_LOCKED_TAB');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => 'F' ,p_count => x_msg_count
                                                  ,p_data => x_msg_data);
    RAISE;
    ROLLBACK TO bsclocktabpvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded   => 'F'
                                ,p_count    => x_msg_count
                                ,p_data     => x_msg_data);
    RAISE;
END LOCK_TAB;



/************************************************************************
 Name :-    LOCK_TAB_VIEW_ID
 Description :- This procedure will lock the row corresponding to
                tab_id and tab_view_id in BSC_TAB_VIEWS_B table.
 Input :- p_tab_id
          p_tab_view_id
 Creator :- ashankar 05-NOV-2003
 Note :- This API needs to be modified.
/************************************************************************/

PROCEDURE LOCK_TAB_VIEW_ID
(
     p_tab_id               IN      NUMBER
    ,p_tab_view_id          IN      NUMBER
    ,p_time_stamp           IN      VARCHAR2 := NULL
    ,x_return_status    OUT NOCOPY  VARCHAR2
    ,x_msg_count        OUT NOCOPY  NUMBER
    ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
    l_last_update_date    VARCHAR2(50);
    l_cursor              BSC_BIS_LOCKS_PUB.t_cursor;
    l_sql                 VARCHAR2(300);
    l_temp                VARCHAR2(300);
BEGIN

    SAVEPOINT bsclocktabviewpvt;

    l_sql := '
              SELECT TAB_ID,TAB_VIEW_ID
              FROM   BSC_TAB_VIEWS_B
              WHERE  TAB_ID      = :1
              AND    TAB_VIEW_ID = :2
              FOR UPDATE NOWAIT ';

    OPEN l_cursor FOR l_sql USING p_tab_id,p_tab_view_id;
    FETCH l_cursor INTO l_temp;

    IF (l_cursor%notfound) THEN
         CLOSE l_cursor;
          --DBMS_OUTPUT.PUT_LINE('Kpi = ' || p_kpi_id  || ' Deleted by other user ');
          FND_MSG_PUB.Initialize;
          --FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETED_KPI_1');
          FND_MESSAGE.SET_NAME('BSC','The current tab view has been deleted by another user');
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(p_encoded => 'F'
                                    ,p_count  => x_msg_count
                                    ,p_data   => x_msg_data);
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE l_cursor;

    IF NOT p_time_stamp IS NULL THEN
        l_last_update_date := get_tabview_time_stamp(
                               p_tab_id     => p_tab_id
                              ,p_tab_view_id=> p_tab_view_id
                              );
        IF p_time_stamp <> l_last_update_date THEN
           --dbms_output.put_line('Kpi = ' || p_kpi_id  ||  ' updated by other user ');
          FND_MSG_PUB.Initialize;
          FND_MESSAGE.SET_NAME('BSC','The Current view has been modified by another user');
          --FND_MESSAGE.SET_TOKEN('KPI', get_TabView_Name(p_tab_id,p_tab_view_id);
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                    ,p_count   => x_msg_count
                                    ,p_data    => x_msg_data);
          RAISE FND_API.G_EXC_ERROR;
        END IF;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO bsclocktabviewpvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded  => 'F'
                                ,p_count    => x_msg_count
                                ,p_data     => x_msg_data);
    RAISE;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO bsclocktabviewpvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => 'F'
                                ,p_count  => x_msg_count
                                ,p_data   => x_msg_data);
    RAISE;
WHEN OTHERS THEN
  ROLLBACK TO bsclocktabviewpvt;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded  => 'F'
                                ,p_count    => x_msg_count
                                ,p_data     => x_msg_data);
  RAISE;

END  LOCK_TAB_VIEW_ID;


PROCEDURE Lock_Calendar (
     p_Calendar_Id    IN NUMBER
   , p_Time_Stamp     IN VARCHAR2
   , x_Return_Status  OUT NOCOPY  VARCHAR2
   , x_Msg_Count      OUT NOCOPY  NUMBER
   , x_Msg_Data       OUT NOCOPY  VARCHAR2
) IS

    l_Object_Id         NUMBER;
    l_Last_Update_Date  DATE;
    l_Sql               VARCHAR2(1024);
    l_Cursor            BSC_BIS_LOCKS_PUB.t_CURSOR;
    l_Meaning           BSC_LOOKUPS.MEANING%TYPE;

BEGIN
    SAVEPOINT LockCalendarPVT;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Sql :=   ' SELECT CALENDAR_ID, LAST_UPDATE_DATE '
             ||' FROM BSC_SYS_CALENDARS_B '
             ||' WHERE CALENDAR_ID = :1 '
             ||' FOR UPDATE NOWAIT ';

    OPEN l_Cursor FOR l_Sql USING p_Calendar_Id;
    FETCH l_Cursor INTO l_Object_Id, l_Last_Update_Date;

    IF (l_Cursor%NOTFOUND) THEN
        CLOSE l_Cursor;
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        l_Meaning := Bsc_Apps.Get_Lookup_Value('BSC_UI_COMMON', 'CALENDAR');
        FND_MESSAGE.SET_TOKEN('TYPE', l_Meaning, TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT p_Time_Stamp IS NULL THEN
        IF p_Time_Stamp <> TO_CHAR(l_Last_Update_Date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_CALENDAR');
          FND_MESSAGE.SET_TOKEN('CALENDAR', Get_Calendar_Name(p_Calendar_Id));
          FND_MSG_PUB.ADD;
          x_Return_Status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF (l_Cursor%ISOPEN) THEN
        CLOSE l_Cursor;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LockCalendarPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LockCalendarPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LockCalendarPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PVT.Lock_Calendar ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PVT.Lock_Calendar ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO LockCalendarPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (SQLCODE = -00054) THEN
            FND_MSG_PUB.Initialize;
            FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_CALENDAR');
            FND_MESSAGE.SET_TOKEN('CALENDAR', Get_Calendar_Name(p_Calendar_Id));
            FND_MSG_PUB.ADD;
            x_Return_Status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF (x_msg_data IS NOT NULL) THEN
                x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PVT.Lock_Calendar ';
            ELSE
                x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PVT.Lock_Calendar ';
            END IF;
        END IF;
        RAISE;
END Lock_Calendar;

PROCEDURE Lock_Periodicity (
     p_Periodicity_Id    IN NUMBER
   , p_Time_Stamp        IN VARCHAR2
   , x_Return_Status     OUT NOCOPY  VARCHAR2
   , x_Msg_Count         OUT NOCOPY  NUMBER
   , x_Msg_Data          OUT NOCOPY  VARCHAR2
) IS
    l_Object_Id         NUMBER;
    l_Last_Update_Date  DATE;
    l_Sql               VARCHAR2(1024);
    l_Cursor            BSC_BIS_LOCKS_PUB.t_CURSOR;
    l_Meaning           BSC_LOOKUPS.MEANING%TYPE;

BEGIN
    SAVEPOINT LockPeriodicityPVT;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Sql :=   ' SELECT PERIODICITY_ID, LAST_UPDATE_DATE '
             ||' FROM BSC_SYS_PERIODICITIES_TL '
             ||' WHERE PERIODICITY_ID = :1 '
             ||' AND LANGUAGE         = USERENV(''LANG'') '
             ||' FOR UPDATE NOWAIT ';

    OPEN l_Cursor FOR l_Sql USING p_Periodicity_Id;
    FETCH l_Cursor INTO l_Object_Id, l_Last_Update_Date;
    IF (l_Cursor%NOTFOUND) THEN
        CLOSE l_Cursor;
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        l_Meaning := Bsc_Apps.Get_Lookup_Value('BSC_UI_COMMON', 'PERIODICITY');
        FND_MESSAGE.SET_TOKEN('TYPE', l_Meaning, TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF NOT p_Time_Stamp IS NULL THEN
        IF p_Time_Stamp <> TO_CHAR(l_Last_Update_Date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT) THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_MODIFIED_PERIODICITY');
          FND_MESSAGE.SET_TOKEN('PERIODICITY', Get_Periodicity_Name(p_Periodicity_Id));
          FND_MSG_PUB.ADD;
          x_Return_Status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF (l_Cursor%ISOPEN) THEN
        CLOSE l_Cursor;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO LockPeriodicityPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO LockPeriodicityPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO LockPeriodicityPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PVT.Lock_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PVT.Lock_Periodicity ';
        END IF;
        RAISE;
    WHEN OTHERS THEN
        ROLLBACK TO LockPeriodicityPVT;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        IF (l_Cursor%ISOPEN) THEN
            CLOSE l_Cursor;
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (SQLCODE = -00054) THEN
            FND_MSG_PUB.Initialize;
            FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_LOCKED_PERIODICITY');
            FND_MESSAGE.SET_TOKEN('PERIODICITY', Get_Periodicity_Name(p_Periodicity_Id));
            FND_MSG_PUB.ADD;
            x_Return_Status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF (x_msg_data IS NOT NULL) THEN
                x_msg_data      :=  x_msg_data||' -> BSC_BIS_LOCKS_PVT.Lock_Periodicity ';
            ELSE
                x_msg_data      :=  SQLERRM||' at BSC_BIS_LOCKS_PVT.Lock_Periodicity ';
            END IF;
        END IF;
        RAISE;
END Lock_Periodicity;

FUNCTION Get_Calendar_Name (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Calendar_Name  BSC_SYS_CALENDARS_VL.NAME%TYPE;
BEGIN

    SELECT C.NAME INTO l_Calendar_Name
    FROM   BSC_SYS_CALENDARS_VL C
    WHERE  C.CALENDAR_ID = p_Calendar_Id;

    RETURN l_Calendar_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Calendar_Name;


FUNCTION Get_Periodicity_Name (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Periodicity_Name BSC_SYS_PERIODICITIES_VL.NAME%TYPE;
BEGIN
    SELECT P.NAME INTO l_Periodicity_Name
    FROM   BSC_SYS_PERIODICITIES_VL P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id;


    RETURN l_Periodicity_Name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Periodicity_Name;



End BSC_BIS_LOCKS_PVT;

/
