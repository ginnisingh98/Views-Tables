--------------------------------------------------------
--  DDL for Package BSC_BIS_LOCKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_LOCKS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPLOCS.pls 120.1 2005/07/12 08:49:50 adrao noship $ */

  TYPE t_numberTable IS TABLE OF number
    INDEX BY BINARY_INTEGER;
  TYPE t_cursor is REF CURSOR;

  C_TIME_STAMP_FORMAT varchar2(20) := 'YY/MM/DD-HH24:MI:SS';

  TYPE t_lock_Rec IS RECORD(
     obj_key1          number      /* object Id */
    ,obj_key2          number      /* sub-object Id */
    ,obj_index       number        /* objecr order */
    ,obj_Flag        varchar(10)   /* D= Deleted, A= Added, C=Change */
  );

  TYPE t_lock_table IS TABLE OF t_lock_Rec
    INDEX BY BINARY_INTEGER;     /* The Object Id will used to Index */

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dataset
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DATASET (
      p_dataset_id          IN              number
) return varchar2 ;
/*------------------------------------------------------------------------------------------
Getting Time Stamp for Datasource
-------------------------------------------------------------------------------------------*/
Function  GET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN              number
) return varchar2;
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Data set
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dataset_id          IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for Setting Time Stamp for Data set to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASET (
      p_dataset_id          IN             number
     ,p_lud                 IN             BSC_SYS_DATASETS_B.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
Setting Time Stamp for Datasource
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN             number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
Bug#4045278: Overloaded for Setting Time Stamp for Datasource to take in last_update_date parameter
-------------------------------------------------------------------------------------------*/
Procedure  SET_TIME_STAMP_DATASOURCE (
      p_measure_id          IN             number
     ,p_lud                 IN             BSC_SYS_MEASURES.LAST_UPDATE_DATE%TYPE
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
Procedure to Lock a Datasets
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DATASET (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 := null
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
Procedure to Lock a Datasource
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DATASOURCE(
  p_measure_id           IN             number
 ,p_time_stamp           IN             varchar2 := null
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);

/*------------------------------------------------------------------------------------------
4.2.1.  Lock prcedure to Create a new Measure
-------------------------------------------------------------------------------------------------------------------*/
/*
Procedure LOCK_CREATE_MEASURE (
  p_dataset_id           IN             number
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);
*/
/*------------------------------------------------------------------------------------------
4.2.2.  Lock prcedure to Update an existing Measure
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_UPDATE_MEASURE (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 := null
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
4.2.3.  Lock prcedure to Delete an existing Measure
-------------------------------------------------------------------------------------------------------------------*/
Procedure LOCK_DELETE_MEASURE (
  p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 := null
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);
/*------------------------------------------------------------------------------------------
4.2.4.  Lock prcedure to Assign Dataset to Analysis option combination (KPI)
-------------------------------------------------------------------------------------------------------------------*/

Procedure LOCK_ASSIGN_MEASURE (
  p_kpi_Id               IN             number
 ,p_dataset_id           IN             number
 ,p_time_stamp           IN             varchar2 := null  /* KPI Time Stamp */
 ,x_return_status        OUT NOCOPY     varchar2
 ,x_msg_count            OUT NOCOPY     number
 ,x_msg_data             OUT NOCOPY     varchar2
);

/*------------------------------------------------------------------------------------------
Procedure to Lock a Dimension Objects
-------------------------------------------------------------------------------------------------------------------*/
    Procedure LOCK_DIM_LEVEL(
      p_dim_level_id         IN             number
     ,p_time_stamp           IN             varchar2 := null
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );
/*------------------------------------------------------------------------------------------
Procedure to Lock  a Dimension Group
-------------------------------------------------------------------------------------------------------------------*/
    Procedure LOCK_DIM_GROUP (
      p_dim_group_id        IN             number
     ,p_time_stamp         IN             varchar2 := null
     ,x_return_status      OUT NOCOPY     varchar2
     ,x_msg_count          OUT NOCOPY     number
     ,x_msg_data           OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Procedure to Lock  a Dimension Set
-------------------------------------------------------------------------------------------------------------------*/
    Procedure LOCK_DIM_SET (
     p_kpi_id               IN             number
     ,p_dim_set_id          IN             number
     ,p_time_stamp          IN             varchar2 := null
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Procedure to Lock  a KPI
-------------------------------------------------------------------------------------------------------------------*/
    Procedure LOCK_KPI(
     p_kpi_id                IN              number
     ,p_time_stamp           IN             varchar2 := null
     ,p_full_lock_flag       IN             varchar2 := FND_API.G_FALSE
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dimension Level
------------------------------------------------------------------------------------------*/
    Function  GET_TIME_STAMP_DIM_LEVEL(
      p_dim_level_id          IN              number
    ) return varchar2;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for Dimension Group
-------------------------------------------------------------------------------------------*/
    Function  GET_TIME_STAMP_DIM_GROUP (
      p_dim_group_id          IN              number
    ) return varchar2;

/*------------------------------------------------------------------------------------------
Getting Time Stamp Dimension Set
-------------------------------------------------------------------------------------------*/
    Function  GET_TIME_STAMP_DIM_SET (
     p_kpi_id                 IN              number
     ,p_dim_set_id           IN              number
    ) return varchar2;

/*------------------------------------------------------------------------------------------
Getting Time Stamp for  KPIs (Indicators)
-------------------------------------------------------------------------------------------*/
    Function  GET_TIME_STAMP_KPI (
     p_kpi_id                 IN              number
    ) return varchar2;

/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Objects
-------------------------------------------------------------------------------------------*/
    Procedure SET_TIME_STAMP_DIM_LEVEL (
      p_dim_level_id        IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Group
-------------------------------------------------------------------------------------------*/
    Procedure  SET_TIME_STAMP_DIM_GROUP (
      p_dim_group_id        IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Setting Time Stamp for Dimension Set
-------------------------------------------------------------------------------------------*/
    Procedure  SET_TIME_STAMP_DIM_SET (
     p_kpi_id               IN              number
     , p_dim_set_id         IN              number
     ,x_return_status       OUT NOCOPY     varchar2
     ,x_msg_count           OUT NOCOPY     number
     ,x_msg_data            OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Setting Time Stamp for KPI
-------------------------------------------------------------------------------------------*/
    Procedure SET_TIME_STAMP_KPI (
     p_kpi_id                IN              number
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

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
     p_selected_dim_objets   IN         t_numberTable
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

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
     ,p_time_stamp           IN             varchar2 := null
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

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
    );

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
    );

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
     p_dim_object_id         IN             number
     ,p_selected_dimensions  IN         t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

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
     ,p_selected_parends     IN         t_numberTable
     ,p_selected_childs      IN         t_numberTable
     ,p_time_stamp           IN             varchar2
     ,x_return_status        OUT NOCOPY     varchar2
     ,x_msg_count            OUT NOCOPY     number
     ,x_msg_data             OUT NOCOPY     varchar2
    );

/*------------------------------------------------------------------------------------------
Procedure LOCK_ASSIGN_ DIM_SET
    Use this procedure to lock necessary object when a Dimension Set need to be assign
        to a specific Analysis Option
  <parameters>
     p_kpi_id   : Indicator Id
     p_dim_set_id   : Dimension Set Id
     p_time_stamp   : Time stamp.

    Note: By Now this parmeter will used to make the lock.
              Future version will used other parameters

-------------------------------------------------------------------------------------------*/
    Procedure LOCK_ASSIGN_DIM_SET (
     p_kpi_id           IN      number
    ,p_option_group0    IN      number
    ,p_option_group1    IN      number
    ,p_option_group2    IN      number
    ,p_serie_id         IN      number
    ,p_dim_set_id       IN      number
    ,p_time_stamp       IN              varchar2
    ,x_return_status    OUT NOCOPY      varchar2
    ,x_msg_count        OUT NOCOPY      number
    ,x_msg_data         OUT NOCOPY      varchar2
    );

/************************************************************************************
                     LOCK THE TAB
/************************************************************************************/
  PROCEDURE LOCK_TAB
  (
      p_tab_id              IN        NUMBER
     ,p_time_stamp          IN        VARCHAR2 := NULL
     ,x_return_status    OUT NOCOPY   VARCHAR2
     ,x_msg_count        OUT NOCOPY   NUMBER
     ,x_msg_data         OUT NOCOPY   VARCHAR2
  );

/************************************************************************************
                     LOCK BSC_CURRENT_SESSION
/************************************************************************************/
PROCEDURE  Lock_Designer_Session_AT (

       p_Entity_Name        IN VARCHAR2
      ,p_Entity_Type        IN VARCHAR2
      ,p_Action_Type        IN VARCHAR2
      ,x_Return_Status      OUT NOCOPY VARCHAR2
      ,x_Msg_Count          OUT NOCOPY NUMBER
      ,x_Msg_Data           OUT NOCOPY VARCHAR2

);

PROCEDURE  Unlock_Designer_Session_AT;

/*------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------*/


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
);


PROCEDURE Lock_Calendar (
     p_Calendar_Id    IN NUMBER
   , p_Time_Stamp     IN VARCHAR2
   , x_Return_Status  OUT NOCOPY  VARCHAR2
   , x_Msg_Count      OUT NOCOPY  NUMBER
   , x_Msg_Data       OUT NOCOPY  VARCHAR2
);


PROCEDURE Lock_Periodicity (
     p_Periodicity_Id  IN NUMBER
   , p_Time_Stamp      IN VARCHAR2
   , x_Return_Status   OUT NOCOPY  VARCHAR2
   , x_Msg_Count       OUT NOCOPY  NUMBER
   , x_Msg_Data        OUT NOCOPY  VARCHAR2
);


/*------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------*/

END  BSC_BIS_LOCKS_PUB;

 

/
