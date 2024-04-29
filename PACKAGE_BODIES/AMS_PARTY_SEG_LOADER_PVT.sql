--------------------------------------------------------
--  DDL for Package Body AMS_PARTY_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PARTY_SEG_LOADER_PVT" AS
/* $Header: amsvcecb.pls 120.2 2005/07/28 00:36:17 appldev ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_Party_Seg_Loader_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvldrb.pls';

/*****************************************************************************/
-- Procedure
--   Expire_Inactive_Party_Dbms
--
-- Purpose
--   expire parties that no longer belong to the given mkt_seg_id
--
-- Note :
--   This Procedure will expire the party using DBMS SQL
--
-- History
--   05/03/2000    ptendulk    created
--   02/02/2001    yxliu       Modified. Removed market_seg_flag since this is
--                             no longer valid in Hornet.
--
--   08/30/2001    yxliu       Modified, use buck update
-------------------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Get_Party_Tab
(
    p_cell_id       IN           NUMBER,
    x_party_tab     OUT NOCOPY   jtf_number_table,
    x_party_count   OUT NOCOPY   NUMBER,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Get_Party_Tab';
   l_sql_tbl       DBMS_SQL.varchar2s ;
   l_cell_id       NUMBER  := p_cell_id;
   l_cell_name     VARCHAR2 (120);
   -- Define the table type to store the party ids
   l_temp          NUMBER ;
   l_party_cur     NUMBER ;
   l_dummy         NUMBER ;
   l_count         NUMBER ;
   l_party_tab     jtf_number_table := jtf_number_table();
   l_party_count   NUMBER;

BEGIN
  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Create the Savepoint
  SAVEPOINT Get_Party_Tab;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' get comp sql for cell ');
  END IF;

  AMS_CELL_PVT.get_comp_sql(
        p_api_version        => 1,
        p_init_msg_list      => NULL,
        p_validation_level   => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_cell_id            => l_cell_id,
        p_party_id_only      => FND_API.g_true,
        x_sql_tbl            => l_sql_tbl
  );

  IF x_return_status = FND_API.g_ret_sts_error THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.Debug_Message(l_api_name||' error on getting cell sql statement, please check if the workbook or sql string is valid or not');
     END IF;

     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.Debug_Message(l_api_name||' unexpected error on get cell sql statement, please check if the workbook or sql string is valid or not');
     END IF;

     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  l_count := 1 ;
  --  Open the cursor and parse it
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.Debug_Message(l_api_name||' Parse the comp sql ');
  END IF;
  IF (DBMS_SQL.Is_Open(l_party_cur) = FALSE) THEN
     l_party_cur := DBMS_SQL.Open_Cursor ;
  END IF;
  DBMS_SQL.Parse(l_party_cur ,
                 l_sql_tbl,
                 l_sql_tbl.first,
                 l_sql_tbl.last,
                 FALSE,
                 DBMS_SQL.Native) ;

  DBMS_SQL.DEFINE_COLUMN(l_party_cur,1,l_temp);
  l_dummy :=  DBMS_SQL.Execute(l_party_cur);
  LOOP
     IF DBMS_SQL.FETCH_ROWS(l_party_cur)>0 THEN
        -- get column values of the row
        DBMS_SQL.COLUMN_VALUE(l_party_cur,1, l_temp);
	l_party_tab.extend;
        l_party_tab(l_count) := l_temp ;
        l_count := l_count + 1 ;
     ELSE
        -- No more rows to copy:
        EXIT;
     END IF;
  END LOOP;

  l_party_count := l_count - 1;

  DBMS_SQL.Close_Cursor(l_party_cur);

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' party_count = ' || l_party_count);
  END IF;

  x_party_tab := l_party_tab;
  x_party_count := l_party_count;

EXCEPTION
   WHEN OTHERS THEN
      IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
           DBMS_SQL.Close_Cursor(l_party_cur) ;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.Debug_Message('Error in Get_Party_Tab '||sqlerrm);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
	  p_encoded         =>      FND_API.G_FALSE
	);

END Get_Party_Tab;

PROCEDURE Expire_Inactive_Party_Dbms
(
    p_mkt_seg_id      IN     NUMBER
  , p_party_tbl       IN     jtf_number_table
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
   l_api_name         CONSTANT VARCHAR2(30)  := 'expire_inactive_party_dbms';
   l_full_name        CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

   l_party_tbl       jtf_number_table;

   TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_exp_party_tbl num_tab;

   --Cursor to select expired parties which are active in segments table
   CURSOR C_expired_party_ids IS
       SELECT party_id FROM AMS_PARTY_MARKET_SEGMENTS
        WHERE market_segment_id = p_mkt_seg_id
          AND end_date_active IS NULL
       MINUS
       SELECT column_value party_id FROM TABLE(CAST(p_party_tbl AS jtf_number_table));

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_full_name||': Start');
  END IF;

--  l_party_tbl := p_party_tbl;

  OPEN  C_expired_party_ids;
  FETCH C_expired_party_ids BULK COLLECT INTO l_exp_party_tbl;
  CLOSE C_expired_party_ids;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_full_name||': Total record expired: '||l_exp_party_tbl.count);
  END IF;

  IF l_exp_party_tbl.count > 0 THEN

   FORALL i in l_exp_party_tbl.FIRST..l_exp_party_tbl.LAST
        UPDATE AMS_PARTY_MARKET_SEGMENTS
           SET end_date_active = SYSDATE
             , last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.conc_login_id
         WHERE market_segment_id = p_mkt_seg_id
           AND party_id = l_exp_party_tbl(i);
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_full_name||': End');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_Message('Error in expire_inactive_party_dbms');
      END IF;

      IF C_expired_party_ids%ISOPEN THEN
         CLOSE C_expired_party_ids;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
	   p_data            =>      x_msg_data,
	   p_encoded	     =>      FND_API.G_FALSE
	 );

END Expire_Inactive_Party_Dbms;


/*****************************************************************************/
-- Procedure
--   expire_changed_party_Dbms
--
-- Purpose
--   expire parties that originally belong to other mkt_seg_id and currently
--   belong to the give mkt_seg_id
--
-- Note :
--   This Procedure will expire the party using DBMS SQL
--
-- History
--   05/03/2000    ptendulk    created
--   02/02/2001    yxliu       Modified. Removed market_segment_flag
--   08/30/2001    yxliu       Modified, use bulk update
-------------------------------------------------------------------------------
PROCEDURE Expire_Changed_Party_Dbms
(
    p_mkt_seg_id      IN   NUMBER
  , p_sql_tbl         IN   t_party_tab
  , x_return_status   OUT NOCOPY  VARCHAR2
  , x_msg_count       OUT NOCOPY  NUMBER
  , x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'expire_changed_party_dbms';

  CURSOR c_old_party_rec IS               -- party_id and mkt_seg_id of exsiting party
    SELECT market_segment_id, party_id
      FROM AMS_PARTY_MARKET_SEGMENTS
     WHERE market_segment_id <> p_mkt_seg_id
       AND end_date_active IS NULL
     ORDER BY party_id;

  l_old_party_id      NUMBER;
  l_old_mkt_seg_id    NUMBER;
  l_expire_flag       VARCHAR2(1);
  l_sql_tbl           t_party_tab;
  l_iterator          NUMBER := 1;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c_old_party_rec;

  LOOP

    FETCH c_old_party_rec INTO l_old_mkt_seg_id, l_old_party_id;
    EXIT WHEN c_old_party_rec%NOTFOUND;

    l_expire_flag := 'N';

    FOR i IN p_sql_tbl.FIRST..p_sql_tbl.last
    LOOP
       IF l_old_party_id = p_sql_tbl(i) THEN
          l_expire_flag := 'Y';
          EXIT;
       END IF;
    END LOOP;

    IF l_expire_flag = 'Y' THEN
       l_sql_tbl(l_iterator) := l_old_party_id;
       l_iterator := l_iterator + 1;
    END IF;

  END LOOP;
  CLOSE c_old_party_rec ;

  -- Do bulk update
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.Debug_Message(l_api_name||' expire changed parties ');
  END IF;
  IF l_iterator > 1 THEN
     FORALL i in l_sql_tbl.first .. l_sql_tbl.last
        UPDATE AMS_PARTY_MARKET_SEGMENTS
           SET end_date_active = SYSDATE
             , last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.conc_login_id
         WHERE market_segment_id = l_old_mkt_seg_id
           AND party_id = l_sql_tbl(i);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_Pvt.Debug_Message('Error in expire_changed_party_dbms');
      END IF;

      IF(c_old_party_rec%ISOPEN)then
          CLOSE c_old_party_rec;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
	   p_data            =>      x_msg_data,
	   p_encoded	     =>      FND_API.G_FALSE
	 );

END Expire_Changed_Party_Dbms;


/*****************************************************************************/
-- Procedure
--   insert_new_party_dbms
--
-- Purpose
--   insert a new party if it is not there, update it if it is expired
--   do nothing if it is active
--
-- Note :
--   This Procedure will expire the party using DBMS sql
--
-- History
--   05/03/2000    ptendulk    created
--   02/02/2001    yxliu       modified, removed market_segment_flag.
--   06/21/2001    yxliu       modified, populate org_id.
-------------------------------------------------------------------------------
PROCEDURE Insert_New_Party_Dbms
(
    p_mkt_seg_id      IN    NUMBER
  , p_party_tbl         IN    jtf_number_table
  , x_return_status   OUT NOCOPY   VARCHAR2
  , x_msg_count       OUT NOCOPY   NUMBER
  , x_msg_data        OUT NOCOPY   VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'insert_new_party';

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_party_tbl num_tab;

 --Cursor to select new parties which only available in with the seg query, not in segments table
 CURSOR C_new_parties IS
        SELECT column_value party_id FROM TABLE(CAST(p_party_tbl AS jtf_number_table))
          MINUS
        SELECT party_id FROM AMS_PARTY_MARKET_SEGMENTS
         WHERE market_segment_id = p_mkt_seg_id;

 --Cursor to select inactive parties from segments table which are also returned by seg query
 CURSOR C_activate_parties IS
        SELECT seg.party_id FROM AMS_PARTY_MARKET_SEGMENTS seg,
	(SELECT column_value party_id FROM TABLE(CAST(p_party_tbl AS jtf_number_table))) tbl
	WHERE seg.party_id = tbl.party_id
	  AND seg.end_date_active IS NOT NULL; --Inactive parties

BEGIN

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN C_new_parties;
  FETCH C_new_parties BULK COLLECT INTO l_party_tbl;
  CLOSE C_new_parties;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Bulk insert '||l_party_tbl.count);
  END IF;

  IF l_party_tbl.count > 0 then

  FORALL i IN l_party_tbl.FIRST..l_party_tbl.LAST
        INSERT INTO AMS_PARTY_MARKET_SEGMENTS
         (
             ams_party_market_segment_id
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , object_version_number
           , market_segment_id
           , market_segment_flag
           , party_id
           , start_date_active
           , end_date_active
           , org_id
         )
         select
           AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , p_mkt_seg_id
           , 'Y' -- always put true for market_segment_flag
           , l_party_tbl(i)
           , SYSDATE
           , NULL
           , TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10))
          from dual;
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Get inactive parties ');
  END IF;

  OPEN C_activate_parties;
  FETCH C_activate_parties BULK COLLECT INTO l_party_tbl;
  CLOSE C_activate_parties;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Bulk update '||l_party_tbl.count);
  END IF;

  IF l_party_tbl.count > 0 THEN
  FORALL i IN l_party_tbl.FIRST..l_party_tbl.LAST
        UPDATE AMS_PARTY_MARKET_SEGMENTS SET
               last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.conc_login_id
             , object_version_number = object_version_number + 1
             , market_segment_id = p_mkt_seg_id
             , party_id = l_party_tbl(i)
             , start_date_active =SYSDATE
             , end_date_active = NULL
         WHERE market_segment_id = p_mkt_seg_id
           AND party_id = l_party_tbl(i);
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' End');
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.Debug_Message('Error in insert_new_party'||sqlerrm);
      END IF;

      IF(C_new_parties%ISOPEN)then
         CLOSE C_new_parties;
      END IF;
      IF(C_activate_parties%ISOPEN)then
         CLOSE C_activate_parties;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
	  p_encoded         =>      FND_API.G_FALSE
	);

END Insert_New_Party_Dbms;

/*****************************************************************************/
-- Procedure
--   load_party_seg_one
-- Purpose
--   load ams_party_market_segments for one segment
--
--  Note
--     1. The process will execute the ams_cell_pvt.get_comp_sql for a given
--        cell_id to get its sql and its ancestors, then use DBMS SQL to excute
--        the returned SQL table to get parties that belong to that sql.
--     2. If cell_id is passed into, then only that cell will be refreshed or
--        else all the cells will be refreshed.
-- History
--   01/26/2001    yxliu      created
--   06/22/2001    yxliu      modified, add logic to update segment size
-------------------------------------------------------------------------------
PROCEDURE Load_Party_Seg_One
(
    p_cell_id       IN    NUMBER ,--DEFAULT NULL,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Load_Party_Seg_One';

   l_cell_id       NUMBER  := p_cell_id;
   l_cell_name     VARCHAR2 (120);
   -- Define the table type to store the party ids
   l_party_tab     jtf_number_table ;
   l_party_count   NUMBER;
   l_last_size     NUMBER;

CURSOR c_last_size (p_cell_id IN number)
   IS
   select act_size
   from ams_act_sizes
   where arc_act_size_used_by = 'CELL'
   and act_size_used_by_id = p_cell_id
   order by last_update_date desc, activity_size_id desc;


BEGIN
  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Create the Savepoint
  SAVEPOINT Load_Party_Seg;

  -- execute the segment sql and get parties in pl/sql table
  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Get_Party_Tab ');
  END IF;
  Get_Party_Tab
         (
           l_cell_id,
           l_party_tab,
           l_party_count,
           x_return_status,
           x_msg_count,
           x_msg_data
           );
  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- expires parties that no longer belong to the given market segment
  IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.Debug_Message(l_api_name||' Expire_Inactive_Party_Dbms ');
  END IF;
  Expire_Inactive_Party_Dbms
          (
           l_cell_id,
           l_party_tab,
           x_return_status,
           x_msg_count,
           x_msg_data
           );
  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- expires parties that originally belong to other marekt segments
  -- and currently belong to the given market segment
  --IF (AMS_DEBUG_HIGH_ON) THENAMS_Utility_PVT.Debug_Message(l_api_name||' Expire_Changed_Party_Dbms ');END IF;
  --Expire_Changed_Party_Dbms
  --     (
  --     l_cell_id,
  --     l_party_tab,
  --     x_return_status,
  --     x_msg_count,
  --     x_msg_data
  --     );
  --IF x_return_status = FND_API.g_ret_sts_error THEN
  --   RAISE FND_API.g_exc_error;
  --ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
  --   RAISE FND_API.g_exc_unexpected_error;
  --END IF;

  IF l_party_count > 0 THEN
     -- insert new parties that do not exist in the table
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.Debug_Message(l_api_name||' Insert_New_Party_Dbms ');
     END IF;
     Insert_New_Party_Dbms
             (
             l_cell_id,
             l_party_tab,
             x_return_status,
             x_msg_count,
             x_msg_data
             );
     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  -- Update size for this cell
  UPDATE ams_cells_all_b
     SET original_size = l_party_count,
         object_version_number = object_version_number + 1,
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.conc_login_id
   WHERE cell_id = l_cell_id;

  -- Keep size history
  OPEN C_last_size(l_cell_id);
  FETCH C_last_size INTO l_last_size;
  CLOSE C_last_size;

  IF l_last_size is null THEN
     l_last_size := 0;
  END IF;

  INSERT INTO ams_act_sizes
     (
                   activity_size_id,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   act_size_used_by_id,
                   arc_act_size_used_by,
                   act_size,
                   description,
		   size_delta
     )
     VALUES
     (
                   ams_act_sizes_s.nextval,
                   SYSDATE,
                   fnd_global.user_id,
                   SYSDATE,
                   fnd_global.user_id,
                   fnd_global.conc_login_id,
                   l_cell_id,
                   'CELL',
                   l_party_count,
                   'SUCCESSED',
		   l_party_count - l_last_size
     );

  -- If no errors, commit the work
  COMMIT WORK;

EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Load_Party_Seg;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Load_Party_Seg;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Load_Party_Seg_One;

/*****************************************************************************/
-- Procedure
--   load_party_seg
-- Purpose
--   load ams_party_market_segments
--
--  Note
--     1. If cell_id is passed into, then only that cell will be refreshed or
--        else all the cells will be refreshed.
-- History
--   01/26/2001    yxliu      created
--   06/22/2001    yxliu      modified. Call load_party_seg_one.
-------------------------------------------------------------------------------
PROCEDURE Load_Party_Seg
(
    p_cell_id       IN    NUMBER ,--DEFAULT NULL,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Load_Party_Seg';

   l_cell_id        NUMBER := p_cell_id;
   l_cell_name      VARCHAR2(120);

   CURSOR c_all_cell_rec IS
   SELECT cell_id, cell_name
     FROM ams_cells_vl;

   failed_flag     VARCHAR2(1) := 'N';

BEGIN
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check the cells if the p_cell_id is null then refresh all the cells
  -- Else refresh only the given cell
  IF p_cell_id IS NOT NULL
  THEN
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.Debug_Message(l_api_name||': Refresh party segment for cell_id ' || p_cell_id);
    END IF;
    Load_Party_Seg_One
      (
           p_cell_id => l_cell_id,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data
      );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         x_return_status := FND_API.g_ret_sts_error ;
         FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data
        );
        failed_flag := 'Y';
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false,
             p_count   => x_msg_count,
             p_data    => x_msg_data
        );
        failed_flag := 'Y';
      END IF;
  ELSE
     -- Get all the cells
     OPEN c_all_cell_rec;
     LOOP                                  -- the loop for all CELL_IDs
       FETCH c_all_cell_rec INTO l_cell_id, l_cell_name;
       EXIT WHEN c_all_cell_rec%NOTFOUND;

       IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.Debug_Message(l_api_name||': Refresh party segment for cell_id ' || l_cell_id);

       END IF;
       Load_Party_Seg_One
         (
              p_cell_id => l_cell_id,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data
         );

       IF x_return_status = FND_API.g_ret_sts_error THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
          );
          failed_flag := 'Y';
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.count_and_get (
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
          );
          failed_flag := 'Y';
       END IF;
     END LOOP;                               -- end: the loop for all CELL_IDs

     CLOSE c_all_cell_rec;

     IF failed_flag = 'Y' THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
     END IF;
  END IF;

END Load_Party_Seg;

/*****************************************************************************/
-- Procedure
--   Refresh_Party_Segment
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the load_party_mkt_seg and will return errors if any
--
-- Notes
--
--
-- History
--   01/26/2001      yxliu    created
------------------------------------------------------------------------------

PROCEDURE Refresh_Party_Segment
(   errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    p_cell_id     IN     NUMBER --DEFAULT NULL
)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
BEGIN
   FND_MSG_PUB.initialize;
   -- Call the procedure to refresh Segment
   Load_Party_Seg
   (   p_cell_id         =>  p_cell_id,
       x_return_status   =>  l_return_status,
       x_msg_count       =>  l_msg_count,
       x_msg_data        =>  l_msg_data);

   -- Write_log ;
   Ams_Utility_Pvt.Write_Conc_log ;
   IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode :=0;
   ELSE
      retcode  :=1;
      errbuf  := l_msg_data ;
   END IF;
END Refresh_Party_Segment ;

END AMS_Party_Seg_Loader_PVT;

/
