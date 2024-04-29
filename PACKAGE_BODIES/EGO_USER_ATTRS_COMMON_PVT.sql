--------------------------------------------------------
--  DDL for Package Body EGO_USER_ATTRS_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_USER_ATTRS_COMMON_PVT" AS
/* $Header: EGOPEFCB.pls 120.13.12010000.6 2011/06/23 05:02:17 maychen ship $ */



--=======================================================================--
--=*********************************************************************=--
--=*===================================================================*=--
--=*=                                                                 =*=--
--=*=  NOTE: This is a PRIVATE package; it is for internal use only,  =*=--
--=*=  and it is not supported for customer use.                      =*=--
--=*=                                                                 =*=--
--=*===================================================================*=--
--=*********************************************************************=--
--=======================================================================--



                      ------------------------
                      -- Private Data Types --
                      ------------------------

    TYPE LOCAL_DATE_TABLE IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

    TYPE LOCAL_BIG_VARCHAR_TABLE IS TABLE OF VARCHAR2(5000)
      INDEX BY BINARY_INTEGER;

    ---------------------------------------------------------------------
    -- Type for caching of Attribute Group metadata; the type includes --
    -- a LOCAL_DATE_TABLE field to keep track of which Attribute Group --
    -- metadata record has gone unused for the longest amount of time, --
    -- which is how we decide which Attribute Group to replace when    --
    -- adding a new record to a full cache                             --
    ---------------------------------------------------------------------
    TYPE EGO_ATTR_GROUP_BATCH_REC IS RECORD
    (
        CACHED_ATTR_GROUP_METADATA_1         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_2         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_3         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_4         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_5         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_6         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_7         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_8         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_9         EGO_ATTR_GROUP_METADATA_OBJ
       ,CACHED_ATTR_GROUP_METADATA_10        EGO_ATTR_GROUP_METADATA_OBJ
       ,access_times_table                   LOCAL_DATE_TABLE
    );

    ---------------------------------------------------------------------
    -- Type for caching of Extension Table metadata; the type includes --
    -- a LOCAL_DATE_TABLE field to keep track of which Extension Table --
    -- metadata record has gone unused for the longest amount of time, --
    -- which is how we decide which Extension Table to replace when    --
    -- adding a new record to a full cache                             --
    ---------------------------------------------------------------------
    TYPE EGO_EXT_TABLE_BATCH_REC IS RECORD
    (
        CACHED_EXT_TABLE_METADATA_1          EGO_EXT_TABLE_METADATA_OBJ
       ,CACHED_EXT_TABLE_METADATA_2          EGO_EXT_TABLE_METADATA_OBJ
       ,CACHED_EXT_TABLE_METADATA_3          EGO_EXT_TABLE_METADATA_OBJ
       ,CACHED_EXT_TABLE_METADATA_4          EGO_EXT_TABLE_METADATA_OBJ
       ,CACHED_EXT_TABLE_METADATA_5          EGO_EXT_TABLE_METADATA_OBJ
       ,access_times_table                   LOCAL_DATE_TABLE
    );

    ---------------------------------------------------------------------
    -- Type for caching of Data Level metadata; the type includes     --
    -- a LOCAL_DATE_TABLE field to keep track of which Data Level      --
    -- metadata record has gone unused for the longest amount of time, --
    -- which is how we decide which Extension Table to replace when    --
    -- adding a new record to a full cache                             --
    ---------------------------------------------------------------------
    TYPE EGO_DATA_LEVEL_BATCH_REC IS RECORD
    (
        CACHED_DATA_LEVEL_METADATA_1          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_2          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_3          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_4          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_5          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_6          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_7          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_8          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_9          EGO_DATA_LEVEL_METADATA_OBJ
       ,CACHED_DATA_LEVEL_METADATA_10         EGO_DATA_LEVEL_METADATA_OBJ
       ,access_times_table                    LOCAL_DATE_TABLE
    );

                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

    G_PKG_NAME                               CONSTANT VARCHAR2(30) := 'EGO_USER_ATTRS_COMMON_PVT';
    G_CURRENT_USER_ID                        NUMBER := FND_GLOBAL.User_Id;
    G_CURRENT_LOGIN_ID                       NUMBER := FND_GLOBAL.Login_Id;

    G_AG_METADATA_BATCH_1                    EGO_ATTR_GROUP_BATCH_REC;
    G_AG_METADATA_BATCH_2                    EGO_ATTR_GROUP_BATCH_REC;
    G_AG_METADATA_BATCH_3                    EGO_ATTR_GROUP_BATCH_REC;
    G_AG_METADATA_BATCH_4                    EGO_ATTR_GROUP_BATCH_REC;
    G_AG_METADATA_BATCH_5                    EGO_ATTR_GROUP_BATCH_REC;

    G_EXT_TABLE_METADATA_BATCH_1             EGO_EXT_TABLE_BATCH_REC;

    G_DATA_LEVEL_METADATA_BATCH_1            EGO_DATA_LEVEL_BATCH_REC;

    --FP bug7009188
    g_tab_name                               VARCHAR2(30) := NULL;
    g_owner                                  VARCHAR2(30) := NULL;
----------------------------------------------------------------------

               --------------------------------------
               -- Caching Procedures and Functions --
               --------------------------------------

----------------------------------------------------------------------

procedure code_debug (msg   IN  VARCHAR2
                     ,debug_level  IN  NUMBER  default 3
                     ) IS
BEGIN
null;
--  sri_debug('EGOPEFCB '||msg);
  EGO_USER_ATTRS_DATA_PVT.Debug_Msg(msg , debug_level);
END code_debug;

----------------------------------------------------------------------
PROCEDURE Reset_Cache_And_Globals
IS

    l_null_ag_metadata_batch EGO_ATTR_GROUP_BATCH_REC;
    l_null_ext_table_batch   EGO_EXT_TABLE_BATCH_REC;
    l_null_data_level_batch  EGO_DATA_LEVEL_BATCH_REC;

  BEGIN

    G_CURRENT_USER_ID := FND_GLOBAL.User_Id;
    G_CURRENT_LOGIN_ID := FND_GLOBAL.Login_Id;

    G_AG_METADATA_BATCH_1 := l_null_ag_metadata_batch;
    G_AG_METADATA_BATCH_2 := l_null_ag_metadata_batch;
    G_AG_METADATA_BATCH_3 := l_null_ag_metadata_batch;
    G_AG_METADATA_BATCH_4 := l_null_ag_metadata_batch;
    G_AG_METADATA_BATCH_5 := l_null_ag_metadata_batch;
    G_EXT_TABLE_METADATA_BATCH_1 := l_null_ext_table_batch;
    G_DATA_LEVEL_METADATA_BATCH_1 := l_null_data_level_batch;

END Reset_Cache_And_Globals;

----------------------------------------------------------------------

FUNCTION Find_Oldest_Element_Info (
        p_access_times_table            IN   LOCAL_DATE_TABLE
       ,x_oldest_time                   OUT NOCOPY DATE
)
RETURN NUMBER
IS

    l_oldest_index           NUMBER;
    l_current_index          NUMBER;

  BEGIN

    IF (p_access_times_table.COUNT > 0) THEN
      x_oldest_time := SYSDATE;
      l_oldest_index := l_current_index;
      l_current_index := p_access_times_table.FIRST;
      WHILE (l_current_index <= p_access_times_table.LAST)
      LOOP

        IF (p_access_times_table(l_current_index) < x_oldest_time) THEN
          x_oldest_time := p_access_times_table(l_current_index);
          l_oldest_index := l_current_index;
        END IF;

        l_current_index := p_access_times_table.NEXT(l_current_index);
      END LOOP;
    END IF;

    RETURN l_oldest_index;

END Find_Oldest_Element_Info;

----------------------------------------------------------------------

FUNCTION Is_Room_In_AG_Batch (
        p_attr_group_batch_rec          IN   EGO_ATTR_GROUP_BATCH_REC
)
RETURN BOOLEAN
IS

  BEGIN

    RETURN (p_attr_group_batch_rec.access_times_table.COUNT < 10);

END Is_Room_In_AG_Batch;

----------------------------------------------------------------------

FUNCTION Is_Room_In_ET_Batch (
        p_ext_table_batch_rec           IN   EGO_EXT_TABLE_BATCH_REC
)
RETURN BOOLEAN
IS

  BEGIN

    RETURN (p_ext_table_batch_rec.access_times_table.COUNT < 5);

END Is_Room_In_ET_Batch;

----------------------------------------------------------------------

FUNCTION Is_Room_In_DL_Batch (
        p_data_level_batch_rec           IN   EGO_DATA_LEVEL_BATCH_REC
)
RETURN BOOLEAN
IS

  BEGIN

    RETURN (p_data_level_batch_rec.access_times_table.COUNT < 10);

END Is_Room_In_DL_Batch;

----------------------------------------------------------------------


FUNCTION Find_Oldest_AG_Batch_Index
RETURN NUMBER
IS

    l_dummy_index_variable   NUMBER;
    l_batch_1_oldest_time    DATE;
    l_batch_2_oldest_time    DATE;
    l_batch_3_oldest_time    DATE;
    l_batch_4_oldest_time    DATE;
    l_batch_5_oldest_time    DATE;
    l_oldest_batch_index     NUMBER;

  BEGIN

    l_dummy_index_variable := Find_Oldest_Element_Info(G_AG_METADATA_BATCH_1.access_times_table, l_batch_1_oldest_time);
    l_dummy_index_variable := Find_Oldest_Element_Info(G_AG_METADATA_BATCH_2.access_times_table, l_batch_2_oldest_time);
    l_dummy_index_variable := Find_Oldest_Element_Info(G_AG_METADATA_BATCH_3.access_times_table, l_batch_3_oldest_time);
    l_dummy_index_variable := Find_Oldest_Element_Info(G_AG_METADATA_BATCH_4.access_times_table, l_batch_4_oldest_time);
    l_dummy_index_variable := Find_Oldest_Element_Info(G_AG_METADATA_BATCH_5.access_times_table, l_batch_5_oldest_time);

    IF (l_batch_1_oldest_time < l_batch_2_oldest_time AND
        l_batch_1_oldest_time < l_batch_3_oldest_time AND
        l_batch_1_oldest_time < l_batch_4_oldest_time AND
        l_batch_1_oldest_time < l_batch_5_oldest_time) THEN

      l_oldest_batch_index := 1;

    ELSIF (l_batch_2_oldest_time < l_batch_1_oldest_time AND
           l_batch_2_oldest_time < l_batch_3_oldest_time AND
           l_batch_2_oldest_time < l_batch_4_oldest_time AND
           l_batch_2_oldest_time < l_batch_5_oldest_time) THEN

      l_oldest_batch_index := 2;

    ELSIF (l_batch_3_oldest_time < l_batch_1_oldest_time AND
           l_batch_3_oldest_time < l_batch_2_oldest_time AND
           l_batch_3_oldest_time < l_batch_4_oldest_time AND
           l_batch_3_oldest_time < l_batch_5_oldest_time) THEN

      l_oldest_batch_index := 3;

    ELSIF (l_batch_4_oldest_time < l_batch_1_oldest_time AND
           l_batch_4_oldest_time < l_batch_2_oldest_time AND
           l_batch_4_oldest_time < l_batch_3_oldest_time AND
           l_batch_4_oldest_time < l_batch_5_oldest_time) THEN

      l_oldest_batch_index := 4;

    ELSIF (l_batch_4_oldest_time < l_batch_1_oldest_time AND
           l_batch_4_oldest_time < l_batch_2_oldest_time AND
           l_batch_4_oldest_time < l_batch_3_oldest_time AND
           l_batch_4_oldest_time < l_batch_4_oldest_time) THEN

      l_oldest_batch_index := 5;

    END IF;

  RETURN l_oldest_batch_index;

END Find_Oldest_AG_Batch_Index;

----------------------------------------------------------------------

FUNCTION Do_AG_PKs_Match (
        p_attr_group_id                 IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
)
RETURN BOOLEAN
IS

  BEGIN

    RETURN (p_attr_group_metadata_obj.ATTR_GROUP_ID = p_attr_group_id OR
            (p_attr_group_metadata_obj.APPLICATION_ID = p_application_id AND
             p_attr_group_metadata_obj.ATTR_GROUP_TYPE = p_attr_group_type AND
             p_attr_group_metadata_obj.ATTR_GROUP_NAME = p_attr_group_name));

END Do_AG_PKs_Match;

----------------------------------------------------------------------

FUNCTION Find_Attr_Group_In_Batch (
        p_attr_group_id                 IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
       ,px_attr_group_batch_rec         IN OUT NOCOPY EGO_ATTR_GROUP_BATCH_REC
)
RETURN EGO_ATTR_GROUP_METADATA_OBJ
IS

    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;

  BEGIN

    IF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                       ,p_attr_group_type, p_attr_group_name
                       ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_1)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_1;
      px_attr_group_batch_rec.access_times_table(1) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_2)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_2;
      px_attr_group_batch_rec.access_times_table(2) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_3)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_3;
      px_attr_group_batch_rec.access_times_table(3) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_4)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_4;
      px_attr_group_batch_rec.access_times_table(4) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_5)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_5;
      px_attr_group_batch_rec.access_times_table(5) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_6)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_6;
      px_attr_group_batch_rec.access_times_table(6) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_7)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_7;
      px_attr_group_batch_rec.access_times_table(7) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_8)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_8;
      px_attr_group_batch_rec.access_times_table(8) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_9)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_9;
      px_attr_group_batch_rec.access_times_table(9) := SYSDATE;

    ELSIF (Do_AG_PKs_Match(p_attr_group_id, p_application_id
                          ,p_attr_group_type, p_attr_group_name
                          ,px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_10)) THEN

      l_attr_group_metadata_obj := px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_10;
      px_attr_group_batch_rec.access_times_table(10) := SYSDATE;

    END IF;

    RETURN l_attr_group_metadata_obj;  --It may still be null here, and that's OK

END Find_Attr_Group_In_Batch;

----------------------------------------------------------------------

FUNCTION Find_Attr_Group_In_Cache (
        p_attr_group_id                 IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_attr_group_type               IN   VARCHAR2
       ,p_attr_group_name               IN   VARCHAR2
)
RETURN EGO_ATTR_GROUP_METADATA_OBJ
IS

    l_attr_group_metadata_obj EGO_ATTR_GROUP_METADATA_OBJ;

  BEGIN

    l_attr_group_metadata_obj := Find_Attr_Group_In_Batch(p_attr_group_id
                                                         ,p_application_id
                                                         ,p_attr_group_type
                                                         ,p_attr_group_name
                                                         ,G_AG_METADATA_BATCH_1);
    IF (l_attr_group_metadata_obj IS NULL) THEN
      l_attr_group_metadata_obj := Find_Attr_Group_In_Batch(p_attr_group_id
                                                           ,p_application_id
                                                           ,p_attr_group_type
                                                           ,p_attr_group_name
                                                           ,G_AG_METADATA_BATCH_2);
      IF (l_attr_group_metadata_obj IS NULL) THEN
        l_attr_group_metadata_obj := Find_Attr_Group_In_Batch(p_attr_group_id
                                                             ,p_application_id
                                                             ,p_attr_group_type
                                                             ,p_attr_group_name
                                                             ,G_AG_METADATA_BATCH_3);
        IF (l_attr_group_metadata_obj IS NULL) THEN
          l_attr_group_metadata_obj := Find_Attr_Group_In_Batch(p_attr_group_id
                                                               ,p_application_id
                                                               ,p_attr_group_type
                                                               ,p_attr_group_name
                                                               ,G_AG_METADATA_BATCH_4);
          IF (l_attr_group_metadata_obj IS NULL) THEN
            l_attr_group_metadata_obj := Find_Attr_Group_In_Batch(p_attr_group_id
                                                                 ,p_application_id
                                                                 ,p_attr_group_type
                                                                 ,p_attr_group_name
                                                                 ,G_AG_METADATA_BATCH_5);
          END IF;
        END IF;
      END IF;
    END IF;

    RETURN l_attr_group_metadata_obj;

END Find_Attr_Group_In_Cache;

----------------------------------------------------------------------

PROCEDURE Add_Attr_Group_To_Batch (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
       ,p_replace_oldest_attr_group     IN   BOOLEAN
       ,px_attr_group_batch_rec         IN OUT NOCOPY EGO_ATTR_GROUP_BATCH_REC
) IS

    l_oldest_rec_index       NUMBER;
    l_dummy_time_variable    DATE;
    l_access_times_table     LOCAL_DATE_TABLE;

  BEGIN

    IF (p_replace_oldest_attr_group) THEN
      l_oldest_rec_index := Find_Oldest_Element_Info(px_attr_group_batch_rec.access_times_table, l_dummy_time_variable);
    END IF;

    IF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_1 IS NULL OR
        l_oldest_rec_index = 1) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_1 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(1) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_2 IS NULL OR
        l_oldest_rec_index = 2) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_2 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(2) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_3 IS NULL OR
        l_oldest_rec_index = 3) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_3 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(3) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_4 IS NULL OR
        l_oldest_rec_index = 4) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_4 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(4) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_5 IS NULL OR
        l_oldest_rec_index = 5) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_5 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(5) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_6 IS NULL OR
        l_oldest_rec_index = 6) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_6 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(6) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_7 IS NULL OR
        l_oldest_rec_index = 7) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_7 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(7) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_8 IS NULL OR
        l_oldest_rec_index = 8) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_8 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(8) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_9 IS NULL OR
        l_oldest_rec_index = 9) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_9 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(9) := SYSDATE;

    ELSIF (px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_10 IS NULL OR
        l_oldest_rec_index = 10) THEN

      px_attr_group_batch_rec.CACHED_ATTR_GROUP_METADATA_10 := p_attr_group_metadata_obj;
      px_attr_group_batch_rec.access_times_table(10) := SYSDATE;

    END IF;

END Add_Attr_Group_To_Batch;

----------------------------------------------------------------------

PROCEDURE Add_Attr_Group_To_Cache (
        p_attr_group_metadata_obj       IN   EGO_ATTR_GROUP_METADATA_OBJ
) IS

    l_index_of_batch_to_update NUMBER;

  BEGIN

    IF (Is_Room_In_AG_Batch(G_AG_METADATA_BATCH_1)) THEN

      Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                             ,FALSE
                             ,G_AG_METADATA_BATCH_1);

    ELSIF (Is_Room_In_AG_Batch(G_AG_METADATA_BATCH_2)) THEN

      Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                             ,FALSE
                             ,G_AG_METADATA_BATCH_2);

    ELSIF (Is_Room_In_AG_Batch(G_AG_METADATA_BATCH_3)) THEN

      Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                             ,FALSE
                             ,G_AG_METADATA_BATCH_3);

    ELSIF (Is_Room_In_AG_Batch(G_AG_METADATA_BATCH_4)) THEN

      Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                             ,FALSE
                             ,G_AG_METADATA_BATCH_4);

    ELSIF (Is_Room_In_AG_Batch(G_AG_METADATA_BATCH_5)) THEN

      Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                             ,FALSE
                             ,G_AG_METADATA_BATCH_5);

    ELSE

      l_index_of_batch_to_update := Find_Oldest_AG_Batch_Index();

      IF (l_index_of_batch_to_update = 1) THEN
        Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                               ,TRUE
                               ,G_AG_METADATA_BATCH_1);
      ELSIF (l_index_of_batch_to_update = 2) THEN
        Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                               ,TRUE
                               ,G_AG_METADATA_BATCH_2);
      ELSIF (l_index_of_batch_to_update = 3) THEN
        Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                               ,TRUE
                               ,G_AG_METADATA_BATCH_3);
      ELSIF (l_index_of_batch_to_update = 4) THEN
        Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                               ,TRUE
                               ,G_AG_METADATA_BATCH_4);
      ELSIF (l_index_of_batch_to_update = 5) THEN
        Add_Attr_Group_To_Batch(p_attr_group_metadata_obj
                               ,TRUE
                               ,G_AG_METADATA_BATCH_5);
      END IF;
    END IF;

END Add_Attr_Group_To_Cache;

----------------------------------------------------------------------

PROCEDURE Remove_OrderBy_Clause(
        px_where_clause                 IN OUT NOCOPY VARCHAR2
) IS

  l_search_ordby_clause      LONG;
  l_ord_index                NUMBER;
  l_by_index                 NUMBER;
  l_last_ord_index           NUMBER;
  --bug 5119374
  l_has_order_by             BOOLEAN := FALSE;

  BEGIN
    -- initialize variables

    l_search_ordby_clause := UPPER(px_where_clause);
    l_ord_index := INSTR(l_search_ordby_clause, 'ORDER ');

    IF l_ord_index <> 0 THEN
      l_last_ord_index := l_ord_index;
      --bug 5119374
      l_has_order_by :=TRUE;
    ELSE
      l_last_ord_index := length(px_where_clause);
    END IF;

    -- find the index of the last 'ORDER BY' clause

    WHILE (l_ord_index <> 0) LOOP
      l_by_index := INSTR(SUBSTR(l_search_ordby_clause, l_ord_index + 5), 'BY ');
      IF l_by_index <> 0 THEN
        l_search_ordby_clause := SUBSTR(l_search_ordby_clause, l_ord_index + 5 + l_by_index + 2);
        l_ord_index := INSTR(l_search_ordby_clause, 'ORDER ');

        -- if there are more 'ORDER BY' clauses, increment index:
        -- l_last_ord_index  += 5 letters for 'ORDER' +
        --                   +  index of 'BY' + 2 letters for 'BY'
        --                   +  (index of the next 'ORDER BY' - 1)

        IF l_ord_index <> 0 THEN
          l_last_ord_index := l_last_ord_index + 5 + l_by_index + 2 + l_ord_index - 1;
        END IF;
      ELSE
        l_ord_index := 0;
      END IF;
    END LOOP;

    -- if there is a close bracket: 'ORDER BY' clause is nested -> do nothing
    -- if no close bracket, remove 'ORDER BY' clause
    -- if after ORDER BY both '(' and also ')' exist then is not a subquery if and only if there is again no ')' after the previous
    -- checks. e.g. "ORDER BY TO_NUMBER()" or "ORDER BY TO_NUMBER(X) ) "
    --                                                                                                       ^ for closing the subquery
    IF (l_has_order_by
         AND ( INSTR(l_search_ordby_clause, ')') = 0
                   OR ( INSTR(l_search_ordby_clause, '(') <> 0
                          AND INSTR(l_search_ordby_clause, ')') <> 0
                          AND (
                                INSTR(l_search_ordby_clause,')')= length(l_search_ordby_clause)  --bug 12630681
                             OR INSTR(SUBSTR(l_search_ordby_clause, INSTR(l_search_ordby_clause,')') + 1 ), ')' ) = 0 )
                        )
                )
         ) THEN --bug 5119374
      px_where_clause := RTRIM(SUBSTR(px_where_clause, 0, l_last_ord_index - 1));
    END IF;

END Remove_OrderBy_Clause;

----------------------------------------------------------------------

PROCEDURE Build_Sql_Queries_For_Value (
        p_value_set_id                  IN   NUMBER
       ,p_validation_code               IN   VARCHAR2
       ,px_attr_group_metadata_obj      IN OUT NOCOPY EGO_ATTR_GROUP_METADATA_OBJ
       ,px_attr_metadata_obj            IN OUT NOCOPY EGO_ATTR_METADATA_OBJ
) IS

  l_validation_table_info_row EGO_VALIDATION_TABLE_INFO_V%ROWTYPE;
  l_column_name              VARCHAR2(4000); -- Bug 4030107
  l_where_clause             LONG;

  BEGIN

    IF (p_validation_code = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR p_validation_code = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE) THEN

      --------------------------------------------------------------------
      -- We only use this query, which has the Value Set ID hard-coded, --
      -- in Get_User_Attrs_Data; elsewhere we use a dynamic version of  --
      -- the query that uses a bind variable in place of the VS ID, so  --
      -- that the SQL engine doesn't have to re-parse for each VS ID    --
      --------------------------------------------------------------------
      px_attr_metadata_obj.INT_TO_DISP_VAL_QUERY := 'SELECT DISTINCT DISPLAY_NAME '||
                                                      'FROM EGO_VALUE_SET_VALUES_V '||
                                                     'WHERE VALUE_SET_ID = '||p_value_set_id||
                                                      ' AND ENABLED_CODE = ''Y'' '||
                                                       'AND (NVL(START_DATE, SYSDATE - 1) < SYSDATE) '||
                                                       'AND (NVL(END_DATE, SYSDATE + 1) > SYSDATE) '||
                                                       'AND INTERNAL_NAME = ';

    ELSIF (p_validation_code = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE) THEN
      SELECT APPLICATION_TABLE_NAME
            ,ID_COLUMN_NAME
            ,VALUE_COLUMN_NAME
            ,ADDITIONAL_WHERE_CLAUSE
        INTO l_validation_table_info_row.APPLICATION_TABLE_NAME
            ,l_validation_table_info_row.ID_COLUMN_NAME
            ,l_validation_table_info_row.VALUE_COLUMN_NAME
            ,l_validation_table_info_row.ADDITIONAL_WHERE_CLAUSE
        FROM FND_FLEX_VALIDATION_TABLES
       WHERE FLEX_VALUE_SET_ID = p_value_set_id;

      IF (l_validation_table_info_row.ID_COLUMN_NAME IS NOT NULL) THEN
        l_column_name := l_validation_table_info_row.ID_COLUMN_NAME;
      ELSE
        l_column_name := l_validation_table_info_row.VALUE_COLUMN_NAME;
      END IF;

      ---------------------------------
      -- Trim off any leading spaces --
      ---------------------------------
      l_where_clause := LTRIM(l_validation_table_info_row.ADDITIONAL_WHERE_CLAUSE);

      ---------------------------------------------
      -- Check whether the trimmed string starts --
      -- with 'WHERE'; if so, trim the 'WHERE'   --
      ---------------------------------------------
      IF (INSTR(UPPER(SUBSTR(l_where_clause, 1, 6)), 'WHERE') <> 0) THEN
        l_where_clause := SUBSTR(l_where_clause, 6);
      END IF;
      Remove_OrderBy_Clause(l_where_clause);
      -----------------------------------------------------
      -- Now, if where clause is non-empty, add an 'AND' --
      -- so that we can append our own where criteria    --
      -----------------------------------------------------
      IF (LENGTH(l_where_clause) > 0) THEN

        ------------------------------------------------------
        -- In case the where clause has new line or tabs    --
        -- we need to remove it BugFix:4101091              --
        ------------------------------------------------------
        SELECT REPLACE(l_where_clause,FND_GLOBAL.LOCAL_CHR(10),FND_GLOBAL.LOCAL_CHR(32)) INTO l_where_clause FROM dual; --replacing new line character
        SELECT REPLACE(l_where_clause,FND_GLOBAL.LOCAL_CHR(13),FND_GLOBAL.LOCAL_CHR(32)) INTO l_where_clause FROM dual; --removing carriage return
        -------------------------------------------------------------------------
        -- well if there is still some special character left we cant help it. --
        -------------------------------------------------------------------------

        ------------------------------------------------------
        -- In case the where clause starts with an Order By --
        -- we need to add a 1=1 before the order by         --
        ------------------------------------------------------
        IF ( INSTR(LTRIM(UPPER(l_where_clause)),'ORDER ') = 1 ) THEN
           IF (INSTR(UPPER(
                           SUBSTR(LTRIM(l_where_clause),INSTR(LTRIM(UPPER(l_where_clause)),'ORDER ')+6 )
                          ),'BY ') <> 0) THEN
            l_where_clause := ' 1=1   ' || l_where_clause ;
            END IF;
        END IF;

        l_where_clause := ' AND ' || l_where_clause ; --BugFix: 4101266 we need to have a wrapper select statement on top of
                                                      --the value set query and have our where clause on the outer select.
        ----------------------------------------------------------------------
        -- If the where clause has an Attribute bind value, set the flag so --
        -- we'll know to sort Attr values for the AG in Validate_Row (which --
        -- we need to do to ensure that all bind values have been replaced  --
        -- by the time they're needed as token replacements); also mark the --
        -- Attribute so that when we do sort, it will go at the end         --
        ----------------------------------------------------------------------
        IF (INSTR(UPPER(l_where_clause), ':$ATTRIBUTEGROUP$.') > 0) THEN

          px_attr_group_metadata_obj.SORT_ATTR_VALUES_FLAG := 'Y';

          IF (px_attr_metadata_obj.VS_BIND_VALUES_CODE = 'O') THEN
            px_attr_metadata_obj.VS_BIND_VALUES_CODE := 'B';
          ELSE
            px_attr_metadata_obj.VS_BIND_VALUES_CODE := 'A';
          END IF;

        ELSIF (INSTR(UPPER(l_where_clause), ':$OBJECT$.') > 0) THEN

          IF (px_attr_metadata_obj.VS_BIND_VALUES_CODE = 'A') THEN
            px_attr_metadata_obj.VS_BIND_VALUES_CODE := 'B';
          ELSE
            px_attr_metadata_obj.VS_BIND_VALUES_CODE := 'O';
          END IF;

        END IF;

      END IF;

      px_attr_metadata_obj.DISP_TO_INT_VAL_QUERY := 'SELECT DISTINCT '||l_column_name ||
                                                     ' FROM '||l_validation_table_info_row.APPLICATION_TABLE_NAME||
                                                    ' WHERE 1=1 '||l_where_clause||' AND '||
                                                     l_validation_table_info_row.VALUE_COLUMN_NAME ||' = ';

/***
TO DO: see if you can move the Additional Where Clause to the end (in case
the user passes something like a :1); wait, does that even matter?  Won't
it break anyway?
Investigate.
***/

      px_attr_metadata_obj.INT_TO_DISP_VAL_QUERY := 'SELECT DISTINCT '|| l_validation_table_info_row.VALUE_COLUMN_NAME||
                                                     ' FROM '||l_validation_table_info_row.APPLICATION_TABLE_NAME||
                                                    ' WHERE 1=1 '||l_where_clause||' AND '||
                                                    l_column_name||' = ';

    END IF;

END Build_Sql_Queries_For_Value;

----------------------------------------------------------------------

PROCEDURE Build_Attr_Metadata_Table (
        px_attr_group_metadata_obj      IN OUT NOCOPY EGO_ATTR_GROUP_METADATA_OBJ
) IS

    l_attr_metadata_table    EGO_ATTR_METADATA_TABLE := EGO_ATTR_METADATA_TABLE();
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;
    l_sql_query              LONG;

    CURSOR attrs_cursor (
        cp_application_id               IN   NUMBER
       ,cp_attr_group_type              IN   VARCHAR2
       ,cp_attr_group_name              IN   VARCHAR2
    ) IS
    -- 9478005, add hint for 10g optimizer issue, it has duplicate data at 10g
    SELECT /*+ OPTIMIZER_FEATURES_ENABLE('9.2.0') */ EXT.ATTR_ID,
           FLX_EXT.ATTR_GROUP_ID,
           A.END_USER_COLUMN_NAME,
           TL.FORM_LEFT_PROMPT,
           EXT.DATA_TYPE,
           FC.MEANING                   DATA_TYPE_MEANING,
           A.COLUMN_SEQ_NUM,
           EXT.UNIQUE_KEY_FLAG,
           A.DEFAULT_VALUE,
           EXT.INFO_1,
           VS.MAXIMUM_SIZE,
           A.REQUIRED_FLAG,
           A.APPLICATION_COLUMN_NAME,
           VS.FLEX_VALUE_SET_ID,
           VS.VALIDATION_TYPE,
           VS.MINIMUM_VALUE,
           VS.MAXIMUM_VALUE,
           EXT.UOM_CLASS,
           UOM.UOM_CODE,
           EXT.VIEW_IN_HIERARCHY_CODE,
           EXT.EDIT_IN_HIERARCHY_CODE
      FROM EGO_FND_DSC_FLX_CTX_EXT      FLX_EXT,
           FND_DESCR_FLEX_COLUMN_USAGES A,
           FND_DESCR_FLEX_COL_USAGE_TL  TL,
           EGO_FND_DF_COL_USGS_EXT      EXT,
           EGO_VS_FORMAT_CODES_V        FC,
           FND_FLEX_VALUE_SETS          VS,
           MTL_UNITS_OF_MEASURE         UOM
     WHERE FLX_EXT.APPLICATION_ID = cp_application_id
       AND FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND FLX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
       AND A.APPLICATION_ID = cp_application_id
       AND A.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND A.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
       AND TL.APPLICATION_ID = cp_application_id
       AND TL.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND TL.DESCRIPTIVE_FLEX_CONTEXT_CODE = cp_attr_group_name
       AND EXT.APPLICATION_ID = cp_application_id
       AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = cp_attr_group_type
       AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE  = cp_attr_group_name
       AND FC.LOOKUP_CODE(+) = EXT.DATA_TYPE
       AND A.ENABLED_FLAG = 'Y'
       AND TL.APPLICATION_COLUMN_NAME = A.APPLICATION_COLUMN_NAME
       AND TL.LANGUAGE = USERENV('LANG')
       AND EXT.APPLICATION_COLUMN_NAME = A.APPLICATION_COLUMN_NAME
       AND A.FLEX_VALUE_SET_ID = VS.FLEX_VALUE_SET_ID (+)
       AND UOM.UOM_CLASS(+) = EXT.UOM_CLASS
       AND UOM.BASE_UOM_FLAG(+) = 'Y'
       ORDER BY A.COLUMN_SEQ_NUM;

  BEGIN

    ----------------------------------------------------------------------------
    -- The SORT_ATTR_VALUES_FLAG flag records whether any Attributes in this  --
    -- collection have a Value Set of type "Table"; if so, we will need to    --
    -- sort the Attr values when we process a row in order to ensure that any --
    -- bind values needed by the Value Set are converted before the Value Set --
    -- is processed                                                           --
    ----------------------------------------------------------------------------

    -------------------------------------------------------
    -- The UNIQUE_KEY_ATTRS_COUNT records how many Attrs --
    -- in this Attribute Group are part of a Unique Key  --
    -------------------------------------------------------

    --------------------------------------------------------------------
    -- The TRANS_ATTRS_COUNT records how many translatable Attributes --
    -- this Attribute Group has; it will be used in Update_Row        --
    --------------------------------------------------------------------

    FOR attrs_rec IN attrs_cursor(px_attr_group_metadata_obj.APPLICATION_ID
                                 ,px_attr_group_metadata_obj.ATTR_GROUP_TYPE
                                 ,px_attr_group_metadata_obj.ATTR_GROUP_NAME)
    LOOP
      l_attr_metadata_obj := EGO_ATTR_METADATA_OBJ(
                               attrs_rec.ATTR_ID
                              ,attrs_rec.ATTR_GROUP_ID
                              ,px_attr_group_metadata_obj.ATTR_GROUP_NAME
                              ,attrs_rec.END_USER_COLUMN_NAME
                              ,attrs_rec.FORM_LEFT_PROMPT
                              ,attrs_rec.DATA_TYPE
                              ,attrs_rec.DATA_TYPE_MEANING
                              ,attrs_rec.COLUMN_SEQ_NUM
                              ,attrs_rec.UNIQUE_KEY_FLAG
                              ,attrs_rec.DEFAULT_VALUE
                              ,attrs_rec.INFO_1
                              ,attrs_rec.MAXIMUM_SIZE
                              ,attrs_rec.REQUIRED_FLAG
                              ,attrs_rec.APPLICATION_COLUMN_NAME
                              ,attrs_rec.FLEX_VALUE_SET_ID
                              ,attrs_rec.VALIDATION_TYPE
                              ,attrs_rec.MINIMUM_VALUE
                              ,attrs_rec.MAXIMUM_VALUE
                              ,attrs_rec.UOM_CLASS
                              ,attrs_rec.UOM_CODE
                              ,null -- DISP_TO_INT_VAL_QUERY
                              ,null -- INT_TO_DISP_VAL_QUERY
                              ,'N'
                              ,attrs_rec.VIEW_IN_HIERARCHY_CODE
                              ,attrs_rec.EDIT_IN_HIERARCHY_CODE
                              );

      IF (attrs_rec.UNIQUE_KEY_FLAG = 'Y') THEN

        px_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT :=
          px_attr_group_metadata_obj.UNIQUE_KEY_ATTRS_COUNT + 1;

      END IF;

      IF (attrs_rec.DATA_TYPE = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE) THEN

        px_attr_group_metadata_obj.TRANS_ATTRS_COUNT :=
          px_attr_group_metadata_obj.TRANS_ATTRS_COUNT + 1;

      END IF;

      IF (attrs_rec.VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_INDEPENDENT_VALIDATION_CODE OR
          attrs_rec.VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_TABLE_VALIDATION_CODE OR
          attrs_rec.VALIDATION_TYPE = EGO_EXT_FWK_PUB.G_TRANS_IND_VALIDATION_CODE) THEN--Bug fix 4645598

        -----------------------------------------------------------------
        -- If this Attribute has a Value Set with Internal and Display --
        -- Values, we build SQL to transform one into the other (and   --
        -- if the Value Set is of type "Table", we set the sort flag   --
        -- in our Attribute Group metadata object to 'Y')              --
        -----------------------------------------------------------------

        Build_Sql_Queries_For_Value(attrs_rec.FLEX_VALUE_SET_ID
                                   ,attrs_rec.VALIDATION_TYPE
                                   ,px_attr_group_metadata_obj
                                   ,l_attr_metadata_obj);
      END IF;

      ------------------------------------------------------------------
      -- For hierarchy security, we need to keep track of whether any --
      -- of the attributes requires propagation (EIH code of LP/AP)   --
            -- for leaf/all propagation                                     --
      ------------------------------------------------------------------
      IF (attrs_rec.EDIT_IN_HIERARCHY_CODE = 'LP' OR
                attrs_rec.EDIT_IN_HIERARCHY_CODE = 'AP') THEN

        px_attr_group_metadata_obj.HIERARCHY_PROPAGATE_FLAG := 'Y';
        code_debug('In Build_Attr_Metadata_Table, found LP/AP: '||px_attr_group_metadata_obj.ATTR_GROUP_NAME||' '||attrs_rec.ATTR_ID, 2);

      END IF;

      l_attr_metadata_table.EXTEND();
      l_attr_metadata_table(l_attr_metadata_table.LAST) := l_attr_metadata_obj;

    END LOOP;

    px_attr_group_metadata_obj.attr_metadata_table := l_attr_metadata_table;

END Build_Attr_Metadata_Table;

----------------------------------------------------------------------

FUNCTION Get_Attr_Group_Metadata (
        p_attr_group_id                 IN   NUMBER     DEFAULT NULL
       ,p_application_id                IN   NUMBER     DEFAULT NULL
       ,p_attr_group_type               IN   VARCHAR2   DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2   DEFAULT NULL
       ,p_pick_from_cache               IN   BOOLEAN    DEFAULT TRUE
)
RETURN EGO_ATTR_GROUP_METADATA_OBJ
IS

    l_table_index                       NUMBER;
    l_attr_group_metadata_obj           EGO_ATTR_GROUP_METADATA_OBJ;

  BEGIN

    IF (p_pick_from_cache) THEN
      l_attr_group_metadata_obj := Find_Attr_Group_In_Cache(p_attr_group_id
                                                           ,p_application_id
                                                           ,p_attr_group_type
                                                           ,p_attr_group_name);
    ELSE
      l_attr_group_metadata_obj := NULL;
    END IF;
code_debug('in Get_Attr_Group_Metadata 1');
    ---------------------------------------------------------
    -- If we don't have cached data, we query in order to  --
    -- build a record, which we then cache and also return --
    ---------------------------------------------------------
    IF (l_attr_group_metadata_obj IS NULL) THEN

      l_attr_group_metadata_obj := EGO_ATTR_GROUP_METADATA_OBJ(
                                     p_attr_group_id
                                    ,p_application_id
                                    ,p_attr_group_type
                                    ,p_attr_group_name
                                    ,null   -- ATTR_GROUP_DISP_NAME
                                    ,null   -- AGV_NAME
                                    ,null   -- MULTI_ROW_CODE
                                    ,null   -- VIEW_PRIVILEGE
                                    ,null   -- EDIT_PRIVILEGE
                                    ,null   -- EXT_TABLE_B_NAME
                                    ,null   -- EXT_TABLE_TL_NAME
                                    ,null   -- EXT_TABLE_VL_NAME
                                    ,'N'    -- SORT_ATTR_VALUES_FLAG
                                    ,0      -- UNIQUE_KEY_ATTRS_COUNT
                                    ,0      -- TRANS_ATTRS_COUNT
                                    ,null   -- attr_metadata_table
                                    ,null   -- ATTR_GROUP_ID_FLAG
                                    ,null   -- HIERARCHY_NODE_QUERY
                                    ,null   -- HIERARCHY_PROPAGATION_API
                                    ,null   -- HIERARCHY_PROPAGATE_FLAG
                                    ,null   -- ENABLED_DATA_LEVELS(EGO_DATA_LEVEL_TABLE)
                                    ,null   -- VARIANT_CODE
                                    );

      ---------------------------------------------------------
      -- We query only on Attribute Groups that are enabled. --
      -- If we have the three Attribute Group Primary Keys,  --
      -- we use them; otherwise, we assume the ATTR_GROUP_ID --
      -- was passed in, and we use it to query.              --
      ---------------------------------------------------------
      IF (l_attr_group_metadata_obj.APPLICATION_ID IS NOT NULL AND
          l_attr_group_metadata_obj.ATTR_GROUP_TYPE IS NOT NULL AND
          l_attr_group_metadata_obj.ATTR_GROUP_NAME IS NOT NULL) THEN

        SELECT EXT.ATTR_GROUP_ID
              ,FLX_TL.DESCRIPTIVE_FLEX_CONTEXT_NAME
              ,EXT.AGV_NAME
              ,EXT.MULTI_ROW
              ,VPF.FUNCTION_NAME
              ,EPF.FUNCTION_NAME
              ,FLX.APPLICATION_TABLE_NAME
              ,FLX_EXT.APPLICATION_TL_TABLE_NAME
              ,FLX_EXT.APPLICATION_VL_NAME
              ,FLX_EXT.HIERARCHY_NODE_QUERY
              ,FLX_EXT.HIERARCHY_PROPAGATION_API
              ,EXT.VARIANT
          INTO l_attr_group_metadata_obj.ATTR_GROUP_ID
              ,l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
              ,l_attr_group_metadata_obj.AGV_NAME
              ,l_attr_group_metadata_obj.MULTI_ROW_CODE
              ,l_attr_group_metadata_obj.VIEW_PRIVILEGE
              ,l_attr_group_metadata_obj.EDIT_PRIVILEGE
              ,l_attr_group_metadata_obj.EXT_TABLE_B_NAME
              ,l_attr_group_metadata_obj.EXT_TABLE_TL_NAME
              ,l_attr_group_metadata_obj.EXT_TABLE_VL_NAME
              ,l_attr_group_metadata_obj.HIERARCHY_NODE_QUERY
              ,l_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API
              ,l_attr_group_metadata_obj.VARIANT
          FROM EGO_FND_DSC_FLX_CTX_EXT    EXT
              ,FND_DESCRIPTIVE_FLEXS      FLX
              ,FND_FORM_FUNCTIONS         VPF
              ,FND_FORM_FUNCTIONS         EPF
              ,FND_DESCR_FLEX_CONTEXTS_TL FLX_TL
              ,EGO_FND_DESC_FLEXS_EXT     FLX_EXT
         WHERE EXT.APPLICATION_ID = p_application_id
           AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
           AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
           AND VPF.FUNCTION_ID(+) = EXT.VIEW_PRIVILEGE_ID
           AND EPF.FUNCTION_ID(+) = EXT.EDIT_PRIVILEGE_ID
           AND FLX_TL.APPLICATION_ID = EXT.APPLICATION_ID
           AND FLX_TL.DESCRIPTIVE_FLEXFIELD_NAME = EXT.DESCRIPTIVE_FLEXFIELD_NAME
           AND FLX_TL.DESCRIPTIVE_FLEX_CONTEXT_CODE = EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE
           AND FLX_TL.LANGUAGE = USERENV('LANG')
           AND FLX.APPLICATION_ID = EXT.APPLICATION_ID
           AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = EXT.DESCRIPTIVE_FLEXFIELD_NAME
           AND FLX_EXT.APPLICATION_ID(+) = EXT.APPLICATION_ID
           AND FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+) = EXT.DESCRIPTIVE_FLEXFIELD_NAME;

      ELSE

        SELECT EXT.APPLICATION_ID
              ,EXT.DESCRIPTIVE_FLEXFIELD_NAME
              ,EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE
              ,FLX_TL.DESCRIPTIVE_FLEX_CONTEXT_NAME
              ,EXT.AGV_NAME
              ,EXT.MULTI_ROW
              ,VPF.FUNCTION_NAME
              ,EPF.FUNCTION_NAME
              ,FLX.APPLICATION_TABLE_NAME
              ,FLX_EXT.APPLICATION_TL_TABLE_NAME
              ,FLX_EXT.APPLICATION_VL_NAME
              ,FLX_EXT.HIERARCHY_NODE_QUERY
              ,FLX_EXT.HIERARCHY_PROPAGATION_API
              ,EXT.VARIANT
          INTO l_attr_group_metadata_obj.APPLICATION_ID
              ,l_attr_group_metadata_obj.ATTR_GROUP_TYPE
              ,l_attr_group_metadata_obj.ATTR_GROUP_NAME
              ,l_attr_group_metadata_obj.ATTR_GROUP_DISP_NAME
              ,l_attr_group_metadata_obj.AGV_NAME
              ,l_attr_group_metadata_obj.MULTI_ROW_CODE
              ,l_attr_group_metadata_obj.VIEW_PRIVILEGE
              ,l_attr_group_metadata_obj.EDIT_PRIVILEGE
              ,l_attr_group_metadata_obj.EXT_TABLE_B_NAME
              ,l_attr_group_metadata_obj.EXT_TABLE_TL_NAME
              ,l_attr_group_metadata_obj.EXT_TABLE_VL_NAME
              ,l_attr_group_metadata_obj.HIERARCHY_NODE_QUERY
              ,l_attr_group_metadata_obj.HIERARCHY_PROPAGATION_API
              ,l_attr_group_metadata_obj.VARIANT
          FROM EGO_FND_DSC_FLX_CTX_EXT    EXT
              ,FND_FORM_FUNCTIONS         VPF
              ,FND_FORM_FUNCTIONS         EPF
              ,FND_DESCR_FLEX_CONTEXTS_TL FLX_TL
              ,FND_DESCRIPTIVE_FLEXS      FLX
              ,EGO_FND_DESC_FLEXS_EXT     FLX_EXT
         WHERE EXT.ATTR_GROUP_ID = l_attr_group_metadata_obj.ATTR_GROUP_ID
           AND VPF.FUNCTION_ID(+) = EXT.VIEW_PRIVILEGE_ID
           AND EPF.FUNCTION_ID(+) = EXT.EDIT_PRIVILEGE_ID
           AND EXT.APPLICATION_ID = FLX_TL.APPLICATION_ID
           AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = FLX_TL.DESCRIPTIVE_FLEXFIELD_NAME
           AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = FLX_TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
           AND FLX_TL.LANGUAGE = USERENV('LANG')
           AND FLX.APPLICATION_ID = FLX_TL.APPLICATION_ID
           AND FLX.DESCRIPTIVE_FLEXFIELD_NAME = FLX_TL.DESCRIPTIVE_FLEXFIELD_NAME
           AND FLX_EXT.APPLICATION_ID(+) = FLX_TL.APPLICATION_ID
           AND FLX_EXT.DESCRIPTIVE_FLEXFIELD_NAME(+) = FLX_TL.DESCRIPTIVE_FLEXFIELD_NAME;

      END IF;

      --------------------------------------------------------------
      -- Add the enabled data Level metadata to the AG object.
      --------------------------------------------------------------
code_debug('in Get_Attr_Group_Metadata before Get_Enabled_Data_Levels_For_AG');

      l_attr_group_metadata_obj.ENABLED_DATA_LEVELS := Get_Enabled_Data_Levels_For_AG(l_attr_group_metadata_obj.ATTR_GROUP_ID);
code_debug('in Get_Attr_Group_Metadata after Get_Enabled_Data_Levels_For_AG');
      -------------------------------------------------------------
      -- B/Tl table needn't have ATTR_GROUP_ID column.           --
      -- We look in FND_COLUMNS to determine if we need to       --
      -- use ATTR_GROUP_ID column. Going against B table as      --
      -- all Group Types neednt have TL table.                   --
      -- Assuming here that if B table doesnt have ATTR_GROUP_ID --
      -- then TL table will not have it too.                     --
      -------------------------------------------------------------

      IF (l_attr_group_metadata_obj.APPLICATION_ID IS NOT NULL) THEN
        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
        INTO l_attr_group_metadata_obj.ATTR_GROUP_ID_FLAG
        FROM FND_COLUMNS
        WHERE COLUMN_NAME = 'ATTR_GROUP_ID'
         AND APPLICATION_ID = l_attr_group_metadata_obj.APPLICATION_ID
         AND TABLE_ID = (SELECT TABLE_ID
                           FROM FND_TABLES
                          WHERE TABLE_NAME = l_attr_group_metadata_obj.EXT_TABLE_B_NAME
                            AND APPLICATION_ID = l_attr_group_metadata_obj.APPLICATION_ID);

      END IF;

      -----------------------------------------------------------------
      -- If the Attr Group has no specified privileges, then we try  --
      -- to use a default privilege for View and Edit; these default --
      -- privileges are hard-coded by Attr Group Type                --
      -----------------------------------------------------------------
      IF (l_attr_group_metadata_obj.VIEW_PRIVILEGE IS NULL) THEN

        IF (l_attr_group_metadata_obj.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP') THEN
          l_attr_group_metadata_obj.VIEW_PRIVILEGE := 'EGO_VIEW_ITEM';
        END IF;

      END IF;
      IF (l_attr_group_metadata_obj.EDIT_PRIVILEGE IS NULL) THEN

        IF (l_attr_group_metadata_obj.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP') THEN
          l_attr_group_metadata_obj.EDIT_PRIVILEGE := 'EGO_EDIT_ITEM';
        END IF;

      END IF;

      Build_Attr_Metadata_Table(l_attr_group_metadata_obj);

      Add_Attr_Group_To_Cache(l_attr_group_metadata_obj);

    END IF;

    RETURN l_attr_group_metadata_obj;

  EXCEPTION
    WHEN OTHERS THEN
code_debug('in Get_Attr_Group_Metadata EXCEPTION-'||SQLERRM);
      RETURN NULL;

END Get_Attr_Group_Metadata;

----------------------------------------------------------------------

FUNCTION Find_Metadata_For_Attr (
        p_attr_metadata_table           IN   EGO_ATTR_METADATA_TABLE
       ,p_attr_name                     IN   VARCHAR2   DEFAULT NULL
       ,p_attr_id                       IN   NUMBER     DEFAULT NULL
       ,p_db_column_name                IN   VARCHAR2   DEFAULT NULL
)
RETURN EGO_ATTR_METADATA_OBJ
IS

    l_table_index            NUMBER;
    l_attr_metadata_obj      EGO_ATTR_METADATA_OBJ;

  BEGIN

    code_debug('In Find_Metadata_For_Attr, starting for p_attr_name '||p_attr_name, 2);

    l_table_index := p_attr_metadata_table.FIRST;

    IF (p_attr_name IS NOT NULL OR
        p_attr_id IS NOT NULL OR
        p_db_column_name IS NOT NULL) THEN
      WHILE (l_table_index <= p_attr_metadata_table.LAST)
      LOOP
        EXIT WHEN (p_attr_metadata_table(l_table_index).ATTR_NAME = p_attr_name OR
                   p_attr_metadata_table(l_table_index).ATTR_ID = p_attr_id OR
                   p_attr_metadata_table(l_table_index).DATABASE_COLUMN = p_db_column_name);

        l_table_index := p_attr_metadata_table.NEXT(l_table_index);
      END LOOP;

      -----------------------------------------------
      -- Make sure we have the correct table index --
      -----------------------------------------------
      IF (l_table_index IS NOT NULL AND
          (p_attr_metadata_table(l_table_index).ATTR_NAME = p_attr_name OR
           p_attr_metadata_table(l_table_index).ATTR_ID = p_attr_id OR
           p_attr_metadata_table(l_table_index).DATABASE_COLUMN = p_db_column_name)) THEN
        l_attr_metadata_obj := p_attr_metadata_table(l_table_index);
      END IF;
    END IF;

    code_debug('In Find_Metadata_For_Attr, done', 2);
    code_debug('In Find_Metadata_For_Attr, ind: '||l_table_index||' name: '||l_attr_metadata_obj.ATTR_NAME, 2);
    code_debug('In Find_Metadata_For_Attr, id: '||l_attr_metadata_obj.ATTR_ID||' dbc: '||l_attr_metadata_obj.DATABASE_COLUMN, 2);
    RETURN l_attr_metadata_obj;

END Find_Metadata_For_Attr;

----------------------------------------------------------------------

FUNCTION Find_Ext_Table_In_Cache (
        p_object_id                     IN   NUMBER
)
RETURN EGO_EXT_TABLE_METADATA_OBJ
IS

    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;

  BEGIN

    IF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_1.OBJECT_ID = p_object_id) THEN

      l_ext_table_metadata_obj := G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_1;

    ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_2.OBJECT_ID = p_object_id) THEN

      l_ext_table_metadata_obj := G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_2;

    ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_3.OBJECT_ID = p_object_id) THEN

      l_ext_table_metadata_obj := G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_3;

    ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_4.OBJECT_ID = p_object_id) THEN

      l_ext_table_metadata_obj := G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_4;

    ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_5.OBJECT_ID = p_object_id) THEN

      l_ext_table_metadata_obj := G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_5;

    END IF;

    RETURN l_ext_table_metadata_obj;  --It may still be null here, and that's OK

END Find_Ext_Table_In_Cache;

----------------------------------------------------------------------

PROCEDURE Add_Ext_Table_To_Cache (
        p_ext_table_metadata_obj        IN   EGO_EXT_TABLE_METADATA_OBJ
) IS

    l_oldest_rec_index       NUMBER;
    l_dummy_time_variable    DATE;

  BEGIN

    IF (Is_Room_In_ET_Batch(G_EXT_TABLE_METADATA_BATCH_1)) THEN

      IF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_1 IS NULL) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_1 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(1) := SYSDATE;

      ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_2 IS NULL) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_2 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(2) := SYSDATE;

      ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_3 IS NULL) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_3 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(3) := SYSDATE;

      ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_4 IS NULL) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_4 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(4) := SYSDATE;

      ELSIF (G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_5 IS NULL) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_5 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(5) := SYSDATE;

      END IF;

    ELSE

      l_oldest_rec_index := Find_Oldest_Element_Info(G_EXT_TABLE_METADATA_BATCH_1.access_times_table, l_dummy_time_variable);

      IF (l_oldest_rec_index = 1) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_1 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(1) := SYSDATE;

      ELSIF (l_oldest_rec_index = 2) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_2 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(2) := SYSDATE;

      ELSIF (l_oldest_rec_index = 3) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_3 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(3) := SYSDATE;

      ELSIF (l_oldest_rec_index = 4) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_4 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(4) := SYSDATE;

      ELSIF (l_oldest_rec_index = 5) THEN

        G_EXT_TABLE_METADATA_BATCH_1.CACHED_EXT_TABLE_METADATA_5 := p_ext_table_metadata_obj;
        G_EXT_TABLE_METADATA_BATCH_1.access_times_table(5) := SYSDATE;

      END IF;

    END IF;

END Add_Ext_Table_To_Cache;

----------------------------------------------------------------------

--
-- this is retained only for backward compatibility to R12
-- must not be used from R12C and beyond
--
FUNCTION Get_Ext_Table_Metadata (
        p_object_id                     IN   NUMBER
)
RETURN EGO_EXT_TABLE_METADATA_OBJ
IS

    l_ext_table_metadata_obj EGO_EXT_TABLE_METADATA_OBJ;
    l_obj_name               FND_OBJECTS.OBJ_NAME%TYPE;-- 4105308 OBJ_NAME IN FND_OBJECTS LENGTH HAS BEEN INCREASED
    l_pk1_obj                EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_pk2_obj                EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_pk3_obj                EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_pk4_obj                EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_pk5_obj                EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_class_code_obj         EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_num_data_level_cols    NUMBER;
    l_data_level1_obj        EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_data_level2_obj        EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
    l_data_level3_obj        EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);

    CURSOR data_level_meanings_cursor (cp_obj_name VARCHAR2)
    IS
    SELECT MEANING
      FROM FND_LOOKUP_VALUES
     WHERE LOOKUP_TYPE = 'EGO_EF_DATA_LEVEL'
       AND ATTRIBUTE1 = cp_obj_name
       AND VIEW_APPLICATION_ID = 0
     ORDER BY ATTRIBUTE2;

  BEGIN

    l_ext_table_metadata_obj := Find_Ext_Table_In_Cache(p_object_id);

    IF (l_ext_table_metadata_obj IS NULL) THEN

      SELECT O.OBJ_NAME
            ,O.PK1_COLUMN_NAME
            ,O.PK2_COLUMN_NAME
            ,O.PK3_COLUMN_NAME
            ,O.PK4_COLUMN_NAME
            ,O.PK5_COLUMN_NAME
            ,O.PK1_COLUMN_TYPE
            ,O.PK2_COLUMN_TYPE
            ,O.PK3_COLUMN_TYPE
            ,O.PK4_COLUMN_TYPE
            ,O.PK5_COLUMN_TYPE
            ,E.CLASSIFICATION_COL_NAME
            ,E.CLASSIFICATION_COL_TYPE
            ,L.ATTRIBUTE2
            ,L.ATTRIBUTE3
            ,L.ATTRIBUTE4
            ,L.ATTRIBUTE5
            ,L.ATTRIBUTE6
            ,L.ATTRIBUTE7
            ,L.ATTRIBUTE8
        INTO l_obj_name
            ,l_pk1_obj.col_name
            ,l_pk2_obj.col_name
            ,l_pk3_obj.col_name
            ,l_pk4_obj.col_name
            ,l_pk5_obj.col_name
            ,l_pk1_obj.data_type
            ,l_pk2_obj.data_type
            ,l_pk3_obj.data_type
            ,l_pk4_obj.data_type
            ,l_pk5_obj.data_type
            ,l_class_code_obj.col_name
            ,l_class_code_obj.data_type
            ,l_num_data_level_cols
            ,l_data_level1_obj.col_name
            ,l_data_level1_obj.data_type
            ,l_data_level2_obj.col_name
            ,l_data_level2_obj.data_type
            ,l_data_level3_obj.col_name
            ,l_data_level3_obj.data_type
        FROM FND_OBJECTS                O
            ,EGO_FND_OBJECTS_EXT        E
            ,FND_LOOKUP_VALUES          L
       WHERE O.OBJECT_ID = p_object_id
         AND O.OBJ_NAME = E.OBJECT_NAME
         AND L.LOOKUP_TYPE(+) = 'EGO_EF_DATA_LEVEL'
         AND L.ATTRIBUTE1(+) = O.OBJ_NAME
         AND L.ATTRIBUTE2(+) > 0
         AND L.LANGUAGE(+) = USERENV('LANG');

      l_ext_table_metadata_obj := EGO_EXT_TABLE_METADATA_OBJ(
                                    p_object_id
                                   ,l_obj_name
                                   ,null -- DATA_LEVEL_MEANING_1
                                   ,null -- DATA_LEVEL_MEANING_2
                                   ,null -- DATA_LEVEL_MEANING_3
                                   ,null -- pk_column_metadata
                                   ,EGO_COL_METADATA_ARRAY(
                                      l_class_code_obj
                                    )
                                   ,null -- data_level_metadata
                                  );

      ------------------------------------------------------------
      -- Create an array for the primary key column information --
      -- and add the array to the ext table metadata object     --
      ------------------------------------------------------------
      IF (l_pk5_obj.COL_NAME IS NOT NULL) THEN
        l_ext_table_metadata_obj.pk_column_metadata := EGO_COL_METADATA_ARRAY(
                                                         l_pk1_obj
                                                        ,l_pk2_obj
                                                        ,l_pk3_obj
                                                        ,l_pk4_obj
                                                        ,l_pk5_obj
                                                       );
      ELSIF (l_pk4_obj.COL_NAME IS NOT NULL) THEN
        l_ext_table_metadata_obj.pk_column_metadata := EGO_COL_METADATA_ARRAY(
                                                         l_pk1_obj
                                                        ,l_pk2_obj
                                                        ,l_pk3_obj
                                                        ,l_pk4_obj
                                                       );
      ELSIF (l_pk3_obj.COL_NAME IS NOT NULL) THEN
        l_ext_table_metadata_obj.pk_column_metadata := EGO_COL_METADATA_ARRAY(
                                                         l_pk1_obj
                                                        ,l_pk2_obj
                                                        ,l_pk3_obj
                                                       );
      ELSIF (l_pk2_obj.COL_NAME IS NOT NULL) THEN
        l_ext_table_metadata_obj.pk_column_metadata := EGO_COL_METADATA_ARRAY(
                                                         l_pk1_obj
                                                        ,l_pk2_obj
                                                       );
      ELSE -- i.e., only l_pk1_obj.COL_NAME is not NULL
        l_ext_table_metadata_obj.pk_column_metadata := EGO_COL_METADATA_ARRAY(
                                                         l_pk1_obj
                                                       );
      END IF;

      -----------------------------------------------------------
      -- Create an array for the data level column information --
      -- and add the array to the ext table metadata object    --
      -----------------------------------------------------------
      IF (l_num_data_level_cols = 1) THEN
        l_ext_table_metadata_obj.data_level_metadata := EGO_COL_METADATA_ARRAY(
                                                          l_data_level1_obj
                                                        );
      ELSIF (l_num_data_level_cols = 2) THEN
        l_ext_table_metadata_obj.data_level_metadata := EGO_COL_METADATA_ARRAY(
                                                          l_data_level1_obj
                                                         ,l_data_level2_obj
                                                        );
      ELSIF (l_num_data_level_cols = 3) THEN
        l_ext_table_metadata_obj.data_level_metadata := EGO_COL_METADATA_ARRAY(
                                                          l_data_level1_obj
                                                         ,l_data_level2_obj
                                                         ,l_data_level3_obj
                                                        );
      END IF;

      ----------------------------------------
      -- Add the user-friendly names of the --
      -- data levels (for error-reporting)  --
      ----------------------------------------
      FOR data_level_rec IN data_level_meanings_cursor(l_obj_name)
      LOOP

        IF (data_level_meanings_cursor%ROWCOUNT = 1) THEN

          l_ext_table_metadata_obj.DATA_LEVEL_MEANING_1 := data_level_rec.MEANING;

        ELSIF (data_level_meanings_cursor%ROWCOUNT = 2) THEN

          l_ext_table_metadata_obj.DATA_LEVEL_MEANING_2 := data_level_rec.MEANING;

        ELSIF (data_level_meanings_cursor%ROWCOUNT = 3) THEN

          l_ext_table_metadata_obj.DATA_LEVEL_MEANING_3 := data_level_rec.MEANING;

        END IF;

      END LOOP;

      Add_Ext_Table_To_Cache(l_ext_table_metadata_obj);

    END IF;

    RETURN l_ext_table_metadata_obj;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

END Get_Ext_Table_Metadata;

        ---------------------------------------------------
        -- Miscellaneous Common Procedures and Functions --
        ---------------------------------------------------

----------------------------------------------------------------------

-- This function's allowable p_mode values are:
-- 'NAMES': returns a comma-delimited list of column names
-- 'VALUES': returns a comma-delimited list of column values
-- 'EQUALS': returns a list of the form 'Name1 = Value1 AND Name2 = Value2...'
-- 'VALUES_ALL_CC': as 'VALUES', but also has all *related* Classification Codes

-- Note: This function does not currently support 'DATE'-type columns.

FUNCTION Get_List_For_Table_Cols (
        p_col_metadata_array            IN   EGO_COL_METADATA_ARRAY
       ,p_col_name_value_pairs          IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_mode                          IN   VARCHAR2
       ,p_use_binds                     IN   BOOLEAN    DEFAULT FALSE
       ,p_prefix                        IN   VARCHAR2   DEFAULT NULL
)
RETURN VARCHAR2
IS

    l_separator              VARCHAR2(6);
    l_col_name               VARCHAR2(30);
    l_col_type               VARCHAR2(8);
    l_col_values_index       NUMBER;
    l_col_value              VARCHAR2(1000);
    l_col_string             VARCHAR2(1775) := '';
    l_prev_string_index      NUMBER;
    l_string_index           NUMBER;
    l_next_element           VARCHAR2(150);
    l_is_last_element        BOOLEAN;
    l_val_begin_pos          NUMBER;

  BEGIN

    code_debug('In Get_List_For_Table_Cols for mode - '||p_mode||' prefix - '||p_prefix||', starting', 2);
    IF p_use_binds THEN
      code_debug('In Get_List_For_Table_Cols using binds ', 2);
    ELSE
      code_debug('In Get_List_For_Table_Cols using NO binds ', 2);
    END IF;

    IF (p_col_name_value_pairs IS NOT NULL OR  p_mode = 'NAMES') THEN
      --------------------------------------------------------------
      -- Figure out the separator for this list based on the mode --
      --------------------------------------------------------------
      IF (UPPER(p_mode) = 'EQUALS') THEN
        l_separator := ' AND ';
      ELSE
        l_separator := ', ';
      END IF;

      IF (p_col_metadata_array IS NOT NULL AND p_col_metadata_array.COUNT > 0) THEN

        FOR i IN p_col_metadata_array.FIRST .. p_col_metadata_array.LAST
        LOOP
 code_debug('In Get_List_For_Table_Cols for col - '||i||' - '||p_col_metadata_array(i).COL_NAME);
          IF (p_col_metadata_array(i).COL_NAME IS NOT NULL) THEN
            --------------------------------------------------------
            -- Append the separator to the previous list element, --
            -- and prepend the prefix argument to the first list  --
            -- element.                                           --
            --------------------------------------------------------
            IF (i = p_col_metadata_array.FIRST) THEN
              IF (p_use_binds) THEN
                FND_DSQL.Add_Text(p_prefix);
              END IF;
              l_col_string := l_col_string || p_prefix;
            ELSE
              IF (p_use_binds) THEN
                FND_DSQL.Add_Text(l_separator);
              END IF;
              l_col_string := l_col_string || l_separator;
            END IF;

            ------------------------------------------------
            -- Loop for each column in the metadata array --
            ------------------------------------------------
            l_col_name := p_col_metadata_array(i).COL_NAME;
            l_col_value := NULL;
            -----------------------------------------------
            -- Get the column type for this column value --
            -----------------------------------------------
            l_col_type := p_col_metadata_array(i).DATA_TYPE;

            IF (UPPER(p_mode) <> 'NAMES') THEN

              ------------------------------------------------------
              -- Try to find the index for this column's value by --
              -- matching up the column name with l_col_name, and --
              -- then get the value itself (we may not find the   --
              -- value or it may be NULL, which will be fine).    --
              ------------------------------------------------------
              IF (p_col_name_value_pairs IS NOT NULL AND
                  p_col_name_value_pairs.COUNT > 0) THEN

                l_col_values_index := p_col_name_value_pairs.FIRST;
                WHILE (l_col_values_index <= p_col_name_value_pairs.LAST)
                LOOP
                  IF (p_col_name_value_pairs(l_col_values_index).NAME = l_col_name) THEN
                    l_col_value := p_col_name_value_pairs(l_col_values_index).VALUE;
                  END IF;
                  l_col_values_index := p_col_name_value_pairs.NEXT(l_col_values_index);
                END LOOP;
              END IF;
            END IF;  -- (UPPER(p_mode) <> 'NAMES')

            --------------------------------------------
            -- 4). Add this column's info to the list --
            --------------------------------------------
            IF (UPPER(p_mode) = 'NAMES') THEN
              IF (p_use_binds) THEN
                FND_DSQL.Add_Text(l_col_name);
              END IF;
              l_col_string := l_col_string || l_col_name;

            ELSIF (UPPER(p_mode) = 'VALUES' OR UPPER(p_mode) = 'VALUES_ALL_CC') THEN
              IF (l_col_value IS NULL) THEN
                IF (p_use_binds) THEN
                  FND_DSQL.Add_Text('NULL');
                END IF;
                l_col_string := l_col_string || 'NULL';
              ELSE
                IF (l_col_type = 'NUMBER' OR l_col_type = 'INTEGER') THEN
                  IF (p_use_binds) THEN
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind(p_value => TO_NUMBER(l_col_value));
                  END IF;
                  l_col_string := l_col_string || l_col_value;
                ELSIF (l_col_type = 'VARCHAR' OR l_col_type = 'VARCHAR2') THEN
                  IF (p_use_binds) THEN
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind(p_value => l_col_value);
                  END IF;
                  l_col_string := l_col_string ||''''|| l_col_value ||'''';
                END IF;
              END IF;

            ELSIF (UPPER(p_mode) = 'EQUALS') THEN
              IF (l_col_value IS NULL) THEN
                IF (p_use_binds) THEN
                  FND_DSQL.Add_Text(l_col_name || ' IS NULL');
                END IF;
                l_col_string := l_col_string || l_col_name || ' IS NULL';
              ELSE
                IF (l_col_type = 'NUMBER' OR l_col_type = 'INTEGER') THEN
                  IF (p_use_binds) THEN
                    FND_DSQL.Add_Text(l_col_name || ' = ');
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind(p_value => TO_NUMBER(l_col_value));
                  END IF;
                  l_col_string := l_col_string || l_col_name || ' = ' || l_col_value;
                ELSIF (l_col_type = 'VARCHAR' OR l_col_type = 'VARCHAR2') THEN
                  IF (p_use_binds) THEN
                    FND_DSQL.Add_Text(l_col_name || ' = ');
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind(p_value => l_col_value);
                  END IF;
                  l_col_string := l_col_string ||l_col_name || ' = ''' || l_col_value || '''';
                END IF;
              END IF;
            END IF;     -- (UPPER(p_mode) = 'EQUALS')
          END IF;      -- p_col_metadata_array(i).COL_NAME IS NOT NULL
        END LOOP;

        -------------------------------------------------------------------------
        -- 5). If the mode is 'VALUES_ALL_CC', append the related Class Codes  --
        -- by looping through the passed-in name/value pairs again to find all --
        -- elements starting with 'RELATED_CLASS_CODE_LIST'                    --
        -------------------------------------------------------------------------
        IF (UPPER(p_mode) = 'VALUES_ALL_CC' AND
            p_col_name_value_pairs IS NOT NULL AND
            p_col_name_value_pairs.COUNT > 0) THEN

          -------------------------------------------------------------------
          -- Assume the first element in the metadata array represents the --
          -- class code column.                                            --
          -------------------------------------------------------------------
          l_col_type := p_col_metadata_array(p_col_metadata_array.FIRST).DATA_TYPE;
          l_col_values_index := p_col_name_value_pairs.FIRST;
          WHILE (l_col_values_index <= p_col_name_value_pairs.LAST)
          LOOP

            IF (INSTR(UPPER(p_col_name_value_pairs(l_col_values_index).NAME), 'RELATED_CLASS_CODE_LIST') <> 0 AND
                p_col_name_value_pairs(l_col_values_index).VALUE IS NOT NULL AND
                LENGTH(p_col_name_value_pairs(l_col_values_index).VALUE) > 0) THEN

              -------------------------------------------------------
              -- Append the separator to the previous list element --
              -------------------------------------------------------
              IF (LENGTH(l_col_string) > 0) THEN
                IF (p_use_binds) THEN
                  FND_DSQL.Add_Text(l_separator);
                END IF;
                l_col_string := l_col_string || l_separator;
              ELSE
                IF (p_use_binds) THEN
                  FND_DSQL.Add_Text(p_prefix);
                END IF;
                l_col_string := l_col_string || p_prefix;
              END IF;

              -----------------------------------
              -- Append the related class code --
              -----------------------------------
              IF (p_use_binds) THEN

                -- in the case of using binds, we have to parse the value string to bind
                -- each individual value separately.
                l_prev_string_index := 1;
                l_is_last_element := FALSE;

                LOOP

                  l_string_index := INSTR(p_col_name_value_pairs(l_col_values_index).VALUE, ',', l_prev_string_index);

                  IF (l_string_index = 0) THEN
                    l_string_index := LENGTH(p_col_name_value_pairs(l_col_values_index).VALUE) + 1;
                    l_is_last_element := TRUE;
                  END IF;

                  l_next_element := SUBSTR(p_col_name_value_pairs(l_col_values_index).VALUE
                                          ,l_prev_string_index
                                          ,l_string_index - l_prev_string_index);
                  IF (l_col_type = 'NUMBER' OR l_col_type = 'INTEGER') THEN
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind(p_value => TO_NUMBER(l_next_element));
                  ELSIF (l_col_type = 'VARCHAR' OR l_col_type = 'VARCHAR2') THEN
                    l_val_begin_pos := INSTR(l_next_element, '''') + 1;
                    EGO_USER_ATTRS_DATA_PVT.Add_Bind( p_value =>
                          SUBSTR(l_next_element,l_val_begin_pos,
                                   INSTR(l_next_element, '''', -1, 1) - l_val_begin_pos)
                                                    );
                  END IF;

                  EXIT WHEN (l_is_last_element);

                  l_prev_string_index := l_string_index + 1;
                  FND_DSQL.Add_Text(', ');

                END LOOP;

              END IF;

              -- append the value string when binds aren't being considered
              l_col_string := l_col_string ||
                              p_col_name_value_pairs(l_col_values_index).VALUE;

            END IF;

            l_col_values_index := p_col_name_value_pairs.NEXT(l_col_values_index);
          END LOOP;

        END IF;
      END IF;
    END IF;

    code_debug('In Get_List_For_Table_Cols for mode '||p_mode||', done', 2);
    RETURN l_col_string;

END Get_List_For_Table_Cols;

----------------------------------------------------------------------

FUNCTION Create_DB_Col_Alias_If_Needed (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
) RETURN VARCHAR2
IS

    l_db_column_alias          VARCHAR2(90);

  BEGIN

    ----------------------------------------
    -- Start with just the DB column name --
    ----------------------------------------
    l_db_column_alias := p_attr_metadata_obj.DATABASE_COLUMN;

    -------------------------------------------------------------------------
    -- Set up an alias to convert Date, Number values to formatted strings --
    -------------------------------------------------------------------------
    IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

      l_db_column_alias := 'TO_CHAR('||p_attr_metadata_obj.DATABASE_COLUMN||')';

    ---------------------------------------------------------------
    -- In the Date and Date Time case, use SUBSTR to get around  --
    -- the strange PL/SQL behavior of adding an initial space to --
    -- Dates that have been TO_CHAR'ed                           --
    ---------------------------------------------------------------
    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN

      l_db_column_alias := 'SUBSTR(TO_CHAR(TRUNC('||p_attr_metadata_obj.DATABASE_COLUMN||'), '''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''), 2)';

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

      l_db_column_alias := 'SUBSTR(TO_CHAR('||p_attr_metadata_obj.DATABASE_COLUMN||', '''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''), 2)';

    END IF;

    RETURN l_db_column_alias;

END Create_DB_Col_Alias_If_Needed;

/*
* Bug:11854366
* Description:This function return database column alias with the table or view alias
*/
FUNCTION Create_DB_Col_Alias_If_Needed (
        p_attr_metadata_obj             IN   EGO_ATTR_METADATA_OBJ
        ,table_view_alias               IN   VARCHAR2
) RETURN VARCHAR2
IS

    l_db_column_alias          VARCHAR2(90);

  BEGIN

    ----------------------------------------
    -- Start with just the DB column name --
    ----------------------------------------
    l_db_column_alias := table_view_alias||'.'||p_attr_metadata_obj.DATABASE_COLUMN;

    -------------------------------------------------------------------------
    -- Set up an alias to convert Date, Number values to formatted strings --
    -------------------------------------------------------------------------
    IF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE) THEN

      l_db_column_alias := 'TO_CHAR('||table_view_alias||'.'||p_attr_metadata_obj.DATABASE_COLUMN||')';

    ---------------------------------------------------------------
    -- In the Date and Date Time case, use SUBSTR to get around  --
    -- the strange PL/SQL behavior of adding an initial space to --
    -- Dates that have been TO_CHAR'ed                           --
    ---------------------------------------------------------------
    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE) THEN

      l_db_column_alias := 'SUBSTR(TO_CHAR(TRUNC('||table_view_alias||'.'||p_attr_metadata_obj.DATABASE_COLUMN||'), '''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''), 2)';

    ELSIF (p_attr_metadata_obj.DATA_TYPE_CODE = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE) THEN

      l_db_column_alias := 'SUBSTR(TO_CHAR('||table_view_alias||'.'||p_attr_metadata_obj.DATABASE_COLUMN||', '''||EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT||'''), 2)';

    END IF;

    RETURN l_db_column_alias;

END Create_DB_Col_Alias_If_Needed;

----------------------------------------------------------------------
       --bug 5094087
-------------------------------------------------------------------------------------
--  API Name: Get_User_Pref_Date_Time_Val                                          --
--                                                                                 --
--  Description:This Function retruns the Formatted Date or Date Time Value        --
--  depending  on the type of the Attribute Passed in and the Value passed in     --
--  Parameters: The Value of date or DateTime and the Attribute Type with X for   --
--  Date  Type or Y for Date_time Type                                             --
-------------------------------------------------------------------------------------
FUNCTION Get_User_Pref_Date_Time_Val (
                             p_date           IN DATE
                            ,p_attr_type      IN VARCHAR2
                            ,x_return_status  OUT NOCOPY VARCHAR2
                            ,x_msg_count      OUT NOCOPY NUMBER
                            ,x_msg_data       OUT NOCOPY VARCHAR2
                             ) RETURN VARCHAR2 IS

  l_api_name               VARCHAR2(30):='Get_User_Pref_Date_Time_Val';
  l_attr_int_value         VARCHAR2(100);
  l_date_factor            VARCHAR2(30);
  l_time_factor            VARCHAR2(30);
  l_space_pos              NUMBER;
BEGIN
  -- check for valid parameters, return message if invalid.
  IF p_attr_type NOT IN ('X','Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_API_INVALID_PARAMS');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('PROC_NAME"', l_api_name);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN p_date;
  END IF;
--return the date as it is if it is null or ''
  IF (p_date IS NULL OR p_date = '') THEN
    RETURN p_date;
  END IF;

  --process only if the attribute is of type date or date time
  l_attr_int_value := TRIM(TO_CHAR(p_date,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT));
  l_space_pos := Instr(l_attr_int_value,' ');
  l_time_factor := SUBSTR(l_attr_int_value,l_space_pos+1);
  l_attr_int_value := TO_CHAR(p_date);
  IF p_attr_type = 'Y'  THEN
    l_attr_int_value := l_attr_int_value||' '||l_time_factor;
  END IF;
  RETURN l_attr_int_value;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ROUTINE',G_PKG_NAME||l_api_name);
    FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE);
    FND_MESSAGE.SET_TOKEN('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                              ,p_count   => x_msg_count
                              ,p_data    => x_msg_data);
    RETURN NULL;
END Get_User_Pref_Date_Time_Val;

----------------------------------------------------------------------

FUNCTION Find_Data_Level_In_Cache (
        p_data_level_id                     IN   NUMBER
)
RETURN EGO_DATA_LEVEL_METADATA_OBJ
IS

    l_data_level_metadata_obj   EGO_DATA_LEVEL_METADATA_OBJ := NULL;

  BEGIN
    IF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_1.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_1;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_2.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_2;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_3.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_3;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_4.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_4;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_5.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_5;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_6.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_6;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_7.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_7;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_8.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_8;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_9.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_9;
    ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_10.DATA_LEVEL_ID = p_data_level_id) THEN
      l_data_level_metadata_obj := G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_10;
    END IF;
    RETURN l_data_level_metadata_obj;  --It may still be null here, and that's OK

END Find_Data_Level_In_Cache;

----------------------------------------------------------------------
PROCEDURE Add_Data_Level_To_Cache (
        p_data_level_metadata_obj        IN   EGO_DATA_LEVEL_METADATA_OBJ
) IS

    l_oldest_rec_index       NUMBER;
    l_dummy_time_variable    DATE;

  BEGIN

    IF (Is_Room_In_DL_Batch(G_DATA_LEVEL_METADATA_BATCH_1)) THEN
      IF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_1 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_1 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(1) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_2 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_2 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(2) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_3 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_3 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(3) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_4 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_4 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(4) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_5 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_5 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(5) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_6 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_6 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(6) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_7 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_7 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(7) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_8 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_8 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(8) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_9 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_9 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(9) := SYSDATE;
      ELSIF (G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_10 IS NULL) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_10 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(10) := SYSDATE;
      END IF;
    ELSE
      l_oldest_rec_index := Find_Oldest_Element_Info(G_DATA_LEVEL_METADATA_BATCH_1.access_times_table, l_dummy_time_variable);
      IF (l_oldest_rec_index = 1) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_1 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(1) := SYSDATE;
      ELSIF (l_oldest_rec_index = 2) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_2 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(2) := SYSDATE;
      ELSIF (l_oldest_rec_index = 3) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_3 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(3) := SYSDATE;
      ELSIF (l_oldest_rec_index = 4) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_4 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(4) := SYSDATE;
      ELSIF (l_oldest_rec_index = 5) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_5 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(5) := SYSDATE;
      ELSIF (l_oldest_rec_index = 6) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_6 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(6) := SYSDATE;
      ELSIF (l_oldest_rec_index = 7) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_7 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(7) := SYSDATE;
      ELSIF (l_oldest_rec_index = 8) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_8 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(8) := SYSDATE;
      ELSIF (l_oldest_rec_index = 9) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_9 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(9) := SYSDATE;
      ELSIF (l_oldest_rec_index = 10) THEN
        G_DATA_LEVEL_METADATA_BATCH_1.CACHED_DATA_LEVEL_METADATA_10 := p_DATA_LEVEL_METADATA_obj;
        G_DATA_LEVEL_METADATA_BATCH_1.access_times_table(10) := SYSDATE;
      END IF;
    END IF;

END Add_Data_Level_To_Cache;

----------------------------------------------------------------------

FUNCTION Get_Data_Level_Metadata (p_data_level_id IN NUMBER)
RETURN EGO_DATA_LEVEL_METADATA_OBJ
IS

 l_data_level_mdata  EGO_DATA_LEVEL_METADATA_OBJ;

BEGIN
code_debug ('In Get_Data_Level_Metadata start ');
  l_data_level_mdata := Find_Data_Level_In_Cache(p_data_level_id);

  IF (l_data_level_mdata IS NULL) THEN
    code_debug ('In Get_Data_Level_Metadata creating new data level metadata ');
    l_data_level_mdata := EGO_DATA_LEVEL_METADATA_OBJ(null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    SELECT  DATA_LEVEL_ID
           ,DATA_LEVEL_NAME
           ,USER_DATA_LEVEL_NAME
           ,PK1_COLUMN_NAME
           ,PK2_COLUMN_NAME
           ,PK3_COLUMN_NAME
           ,PK4_COLUMN_NAME
           ,PK5_COLUMN_NAME
           ,PK1_COLUMN_TYPE
           ,PK2_COLUMN_TYPE
           ,PK3_COLUMN_TYPE
           ,PK4_COLUMN_TYPE
           ,PK5_COLUMN_TYPE
    INTO    l_data_level_mdata.DATA_LEVEL_ID
           ,l_data_level_mdata.DATA_LEVEL_NAME
           ,l_data_level_mdata.USER_DATA_LEVEL_NAME
           ,l_data_level_mdata.PK_COLUMN_NAME1
           ,l_data_level_mdata.PK_COLUMN_NAME2
           ,l_data_level_mdata.PK_COLUMN_NAME3
           ,l_data_level_mdata.PK_COLUMN_NAME4
           ,l_data_level_mdata.PK_COLUMN_NAME5
           ,l_data_level_mdata.PK_COLUMN_TYPE1
           ,l_data_level_mdata.PK_COLUMN_TYPE2
           ,l_data_level_mdata.PK_COLUMN_TYPE3
           ,l_data_level_mdata.PK_COLUMN_TYPE4
           ,l_data_level_mdata.PK_COLUMN_TYPE5
     FROM EGO_DATA_LEVEL_VL
    WHERE DATA_LEVEL_ID = p_data_level_id;

    IF(l_data_level_mdata.DATA_LEVEL_ID IS NOT NULL) THEN
       code_debug ('In Get_Data_Level_Metadata creating add data level metadata to cache ');
       Add_Data_Level_To_Cache(p_data_level_metadata_obj => l_data_level_mdata);
       RETURN l_data_level_mdata;
    ELSE
       code_debug ('In Get_Data_Level_Metadata cannot find data level metadata ');
       RETURN NULL;
    END IF;
  ELSE
    code_debug ('In Get_Data_Level_Metadata data level metadata observed in cache ');
    RETURN l_data_level_mdata;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    code_debug ('In Get_Data_Level_Metadata EXCEPTION ');
      RETURN l_data_level_mdata;

END Get_Data_Level_Metadata;

------------------------------------------------------------------------

FUNCTION Get_Enabled_Data_Levels_For_AG (p_attr_group_id IN NUMBER)
RETURN EGO_DATA_LEVEL_TABLE
IS
    CURSOR enabled_data_levels(p_attr_group_id IN NUMBER)
    IS
    SELECT DATA_LEVEL_ID, VIEW_PRIVILEGE_ID,EDIT_PRIVILEGE_ID,RAISE_PRE_EVENT,RAISE_POST_EVENT, DEFAULTING
    FROM EGO_ATTR_GROUP_DL
    WHERE ATTR_GROUP_ID = p_attr_group_id;

    l_data_level_table     EGO_DATA_LEVEL_TABLE := EGO_DATA_LEVEL_TABLE();
    l_data_level_obj       EGO_DATA_LEVEL_ROW_OBJ;
    l_data_level_rec       enabled_data_levels%ROWTYPE;
    l_data_level_mdata_obj EGO_DATA_LEVEL_METADATA_OBJ;
BEGIN
code_debug('in Get_Enabled_Data_Levels_For_AG');
    l_data_level_obj := EGO_DATA_LEVEL_ROW_OBJ(null,null,null,null,null,null,null,null);
    OPEN enabled_data_levels(p_attr_group_id);
    LOOP
      FETCH enabled_data_levels INTO l_data_level_rec;
      EXIT WHEN enabled_data_levels%NOTFOUND;
code_debug('in Get_Enabled_Data_Levels_For_AG in the LOOP -'||l_data_level_rec.DATA_LEVEL_ID);

        l_data_level_obj.DATA_LEVEL_ID         := l_data_level_rec.DATA_LEVEL_ID;
        l_data_level_obj.RAISE_PRE_EVENT       := l_data_level_rec.RAISE_PRE_EVENT;
        l_data_level_obj.RAISE_POST_EVENT      := l_data_level_rec.RAISE_POST_EVENT;
        l_data_level_obj.VIEW_PRIVILEGE_ID     := l_data_level_rec.VIEW_PRIVILEGE_ID;
        l_data_level_obj.EDIT_PRIVILEGE_ID     := l_data_level_rec.EDIT_PRIVILEGE_ID;
        l_data_level_obj.DEFAULTING            := l_data_level_rec.DEFAULTING;

        l_data_level_mdata_obj := Get_Data_Level_Metadata(l_data_level_obj.DATA_LEVEL_ID);

        l_data_level_obj.DATA_LEVEL_NAME      := l_data_level_mdata_obj.DATA_LEVEL_NAME;
        l_data_level_obj.USER_DATA_LEVEL_NAME := l_data_level_mdata_obj.USER_DATA_LEVEL_NAME;

        l_data_level_table.EXTEND();
        l_data_level_table(l_data_level_table.LAST) := l_data_level_obj;

    END LOOP;
    CLOSE enabled_data_levels;

  RETURN l_data_level_table;

END Get_Enabled_Data_Levels_For_AG;

-----------------------------------------------------------------------

FUNCTION Get_Data_Level_Col_Array( p_application_id  IN  NUMBER
                                  ,p_attr_group_type IN  VARCHAR2)
RETURN EGO_COL_METADATA_ARRAY
IS

CURSOR associated_dl_cursor(p_app_id IN NUMBER, p_ag_type IN VARCHAR2)
IS
SELECT DATA_LEVEL_ID
  FROM EGO_DATA_LEVEL_B
 WHERE APPLICATION_ID = p_app_id
   AND ATTR_GROUP_TYPE = p_ag_type;

 l_data_level_id    NUMBER;
 l_dl_mdata_obj     EGO_DATA_LEVEL_METADATA_OBJ;
 l_data_level_obj   EGO_COL_METADATA_OBJ := EGO_COL_METADATA_OBJ(null, null);
 l_dl_col_list      VARCHAR2(2000);
 l_dl_col_array     EGO_COL_METADATA_ARRAY;

BEGIN

  l_dl_col_array := EGO_COL_METADATA_ARRAY();
  code_debug('In Get_Data_Level_Col_Array starting: p_application_id-'||p_application_id||'   p_attr_group_type-'||p_attr_group_type);
  l_dl_col_list := ' ';
  OPEN associated_dl_cursor(p_application_id, p_attr_group_type);
  LOOP
  FETCH associated_dl_cursor INTO l_data_level_id;
  EXIT WHEN associated_dl_cursor%NOTFOUND;

      l_dl_mdata_obj := Get_Data_Level_Metadata(l_data_level_id);
      code_debug('In Get_Data_Level_Col_Array l_data_level_id ='||l_data_level_id||'   l_dl_col_list-'||l_dl_col_list||'  pk1-'||l_dl_mdata_obj.PK_COLUMN_NAME1);
      IF(l_dl_mdata_obj.PK_COLUMN_NAME5 IS NOT NULL AND INSTR(l_dl_col_list,l_dl_mdata_obj.PK_COLUMN_NAME5) = 0) THEN
        l_data_level_obj.COL_NAME := l_dl_mdata_obj.PK_COLUMN_NAME5;
        l_data_level_obj.DATA_TYPE := l_dl_mdata_obj.PK_COLUMN_TYPE5;
        l_dl_col_list := l_dl_col_list||' '||l_dl_mdata_obj.PK_COLUMN_NAME5||' ';
        l_dl_col_array.EXTEND();
        l_dl_col_array(l_dl_col_array.LAST) := EGO_COL_METADATA_OBJ(l_dl_mdata_obj.PK_COLUMN_NAME5, l_dl_mdata_obj.PK_COLUMN_TYPE5);
      END IF;
      IF(l_dl_mdata_obj.PK_COLUMN_NAME4 IS NOT NULL AND INSTR(l_dl_col_list,l_dl_mdata_obj.PK_COLUMN_NAME4) = 0) THEN
        l_data_level_obj.COL_NAME := l_dl_mdata_obj.PK_COLUMN_NAME4;
        l_data_level_obj.DATA_TYPE := l_dl_mdata_obj.PK_COLUMN_TYPE4;
        l_dl_col_list := l_dl_col_list||' '||l_dl_mdata_obj.PK_COLUMN_NAME4||' ';
        l_dl_col_array.EXTEND();
        l_dl_col_array(l_dl_col_array.LAST) := EGO_COL_METADATA_OBJ(l_dl_mdata_obj.PK_COLUMN_NAME4, l_dl_mdata_obj.PK_COLUMN_TYPE4);
      END IF;
      IF(l_dl_mdata_obj.PK_COLUMN_NAME3 IS NOT NULL AND INSTR(l_dl_col_list,l_dl_mdata_obj.PK_COLUMN_NAME3) = 0) THEN
        l_data_level_obj.COL_NAME := l_dl_mdata_obj.PK_COLUMN_NAME3;
        l_data_level_obj.DATA_TYPE := l_dl_mdata_obj.PK_COLUMN_TYPE3;
        l_dl_col_list := l_dl_col_list||' '||l_dl_mdata_obj.PK_COLUMN_NAME3||' ';
        l_dl_col_array.EXTEND();
        l_dl_col_array(l_dl_col_array.LAST) := EGO_COL_METADATA_OBJ(l_dl_mdata_obj.PK_COLUMN_NAME3, l_dl_mdata_obj.PK_COLUMN_TYPE3);
      END IF;
      IF(l_dl_mdata_obj.PK_COLUMN_NAME2 IS NOT NULL AND INSTR(l_dl_col_list,l_dl_mdata_obj.PK_COLUMN_NAME2) = 0) THEN
        l_data_level_obj.COL_NAME := l_dl_mdata_obj.PK_COLUMN_NAME2;
        l_data_level_obj.DATA_TYPE := l_dl_mdata_obj.PK_COLUMN_TYPE2;
        l_dl_col_list := l_dl_col_list||' '||l_dl_mdata_obj.PK_COLUMN_NAME2||' ';
        l_dl_col_array.EXTEND();
        l_dl_col_array(l_dl_col_array.LAST) := EGO_COL_METADATA_OBJ(l_dl_mdata_obj.PK_COLUMN_NAME2, l_dl_mdata_obj.PK_COLUMN_TYPE2);
      END IF;
      IF(l_dl_mdata_obj.PK_COLUMN_NAME1 IS NOT NULL AND INSTR(l_dl_col_list,l_dl_mdata_obj.PK_COLUMN_NAME1) = 0) THEN
        l_data_level_obj.COL_NAME := l_dl_mdata_obj.PK_COLUMN_NAME1;
        l_data_level_obj.DATA_TYPE := l_dl_mdata_obj.PK_COLUMN_TYPE1;
        l_dl_col_list := l_dl_col_list||' '||l_dl_mdata_obj.PK_COLUMN_NAME1||' ';
        l_dl_col_array.EXTEND();
        l_dl_col_array(l_dl_col_array.LAST) := EGO_COL_METADATA_OBJ(l_dl_mdata_obj.PK_COLUMN_NAME1, l_dl_mdata_obj.PK_COLUMN_TYPE1);
      END IF;
      code_debug('In Get_Data_Level_Col_Array ... for '||l_data_level_obj.COL_NAME||'   l_dl_col_list-'||l_dl_col_list);
  END LOOP;
code_debug('In Get_Data_Level_Col_Array l_dl_col_array.COUNT:'||l_dl_col_array.COUNT);
  IF(l_dl_col_array.COUNT <1) THEN
    RETURN NULL;
  ELSE
    RETURN l_dl_col_array;
  END IF;

END Get_Data_Level_Col_Array;

-------------------------------------------------------------------------------

FUNCTION Get_Data_Levels_For_AGType ( p_application_id   IN  NUMBER
                                     ,p_attr_group_type  IN  VARCHAR2
            )
  RETURN EGO_DATA_LEVEL_METADATA_TABLE
IS

CURSOR associated_data_levels ( p_application_id   IN  NUMBER
                               ,p_attr_group_type  IN  VARCHAR2
            )
  IS
 SELECT DATA_LEVEL_ID
   FROM EGO_DATA_LEVEL_VL
  WHERE APPLICATION_ID = p_application_id
    AND ATTR_GROUP_TYPE = p_attr_Group_type;

l_dl_mdata        EGO_DATA_LEVEL_METADATA_OBJ;
l_dl_id           NUMBER;
l_dl_mdata_table  EGO_DATA_LEVEL_METADATA_TABLE := EGO_DATA_LEVEL_METADATA_TABLE();

BEGIN

  OPEN associated_data_levels(p_application_id, p_attr_Group_type);
  LOOP
  FETCH associated_data_levels INTO l_dl_id;
  EXIT WHEN associated_data_levels%NOTFOUND;
       l_dl_mdata_table.EXTEND;
       l_dl_mdata_table(l_dl_mdata_table.LAST) := Get_Data_Level_Metadata(l_dl_id);
  END LOOP;

RETURN l_dl_mdata_table;

END Get_Data_Levels_For_AGType;

---------------------------------------------------------------------------------

FUNCTION Get_All_Data_Level_PK_Names ( p_application_id  IN  NUMBER
                                      ,p_attr_group_type IN  VARCHAR2)
RETURN VARCHAR2 IS

    CURSOR get_all_pk_names (cp_application_id  IN NUMBER
                            ,cp_attr_group_type IN VARCHAR2)
    IS
    SELECT DISTINCT pk1_column_name column_name
      FROM ego_data_level_b
     WHERE application_id=cp_application_id
       AND attr_group_type = cp_attr_group_type
       AND pk1_column_name IS NOT NULL
    UNION
    SELECT DISTINCT pk2_column_name column_name
      FROM ego_data_level_b
     WHERE application_id=cp_application_id
       AND attr_group_type = cp_attr_group_type
       AND pk2_column_name IS NOT NULL
    UNION
    SELECT DISTINCT pk3_column_name column_name
      FROM ego_data_level_b
     WHERE application_id=cp_application_id
       AND attr_group_type = cp_attr_group_type
       AND pk3_column_name IS NOT NULL
    UNION
    SELECT DISTINCT pk4_column_name column_name
      FROM ego_data_level_b
     WHERE application_id=cp_application_id
       AND attr_group_type = cp_attr_group_type
       AND pk4_column_name IS NOT NULL
    UNION
    SELECT DISTINCT pk5_column_name column_name
      FROM ego_data_level_b
     WHERE application_id=cp_application_id
       AND attr_group_type = cp_attr_group_type
       AND pk5_column_name IS NOT NULL;

  l_dl_col_list  VARCHAR2(1000) := null;

BEGIN
  FOR cr in get_all_pk_names (cp_application_id  => p_application_id
                             ,cp_attr_group_type => p_attr_group_type) LOOP
    IF l_dl_col_list IS NULL THEN
      l_dl_col_list := cr.column_name;
    ELSE
      l_dl_col_list := l_dl_col_list||', '||cr.column_name;
    END IF;
  END LOOP;
  return l_dl_col_list;
END Get_All_Data_Level_PK_Names;

---------------------------------------------------------------------------------

FUNCTION HAS_COLUMN_IN_TABLE (p_table_name  IN  VARCHAR2
                             ,p_column_name IN  VARCHAR2
                             )
RETURN VARCHAR2 IS
  l_dummy_number  NUMBER;
BEGIN

-- bug 7009188
   -- Add owner to the all_tab_columns query for better performance.
   -- Also cache the owner and table names to try to avoid doing the
   -- same query over and over.

     IF (g_tab_name = p_table_name) THEN
       NULL;  -- A hit in the cache, no need to query.
     ELSE
       -- Execute the following either if g_tab_name
       -- is not equal to p_table_name or if it is
       -- NULL (i.e. the first usage).
       --
         SELECT owner
         INTO   g_owner
         FROM   sys.all_tables
         WHERE  table_name = p_table_name;
      -- update cache
         g_tab_name := p_table_name;
     END IF;

   -- end bug 7009188

  SELECT 1
  INTO l_dummy_number
  FROM sys.all_tab_columns
  WHERE table_name = p_table_name
  AND column_name = p_column_name
  AND owner = g_owner; --bug10234840 added
  RETURN FND_API.G_TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END has_column_in_table;


END EGO_USER_ATTRS_COMMON_PVT;

/
