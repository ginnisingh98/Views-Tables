--------------------------------------------------------
--  DDL for Package Body AMS_PARTY_MKT_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PARTY_MKT_SEG_LOADER_PVT" AS
/* $Header: amsvldrb.pls 120.2 2005/10/11 00:04:06 aanjaria ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_Party_Mkt_Seg_Loader_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvldrb.pls';


/* variable to on-off the debug messages of the programe */
G_DEBUG_LEVEL   BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


-- yzhao: type definition for load_party_market... used internally
TYPE NUMBER_TBL_TYPE  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_TBL_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
-- yzhao: 05/07/2003 SQL bind variable compliance
TYPE BIND_VAR_TYPE     IS RECORD (
     BIND_INDEX        NUMBER,
     BIND_TYPE         VARCHAR2(1),
     BIND_CHAR         VARCHAR2(2000),
     BIND_NUMBER       NUMBER
  );
TYPE BIND_TBL_TYPE     IS TABLE OF BIND_VAR_TYPE INDEX BY BINARY_INTEGER;
G_BIND_TYPE_NUMBER     CONSTANT VARCHAR2(1) := 'N';
G_BIND_TYPE_CHAR       CONSTANT VARCHAR2(1) := 'C';
G_BIND_VAR_STRING      CONSTANT VARCHAR2(9) := ':AMS_BIND';


/*****************************************************************************/
-- Procedure
--   Write_Log
-- Purpose
--   writes the Messages for the Concurrent Program
--
-- History
--   05/05/2000    ptendulk    created
--   08/07/2000    ptendulk    Commented the procedure as this one is moved to
--                             AMS_Utility_Pvt .
-------------------------------------------------------------------------------
--PROCEDURE Write_Log
--(   p_text            IN     VARCHAR2 := NULL)
--IS
--    l_count NUMBER;
--    l_msg   VARCHAR2(2000);
--    l_cnt   NUMBER ;
--BEGIN
--   IF p_text IS NULL THEN
--       l_count := FND_MSG_PUB.count_msg;
--       FOR l_cnt IN 1 .. l_count LOOP
--           l_msg := FND_MSG_PUB.get(l_cnt, FND_API.g_false);
--           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '(' || l_cnt || ') ' || l_msg);
--       END LOOP;
--   ELSE
--       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_text );
--   END IF;
--
--END Write_Log ;


/*****************************************************************************/
-- Procedure
--   expire_inactive_party
-- Purpose
--   expire parties that no longer belong to the given mkt_seg_id
--
-- Note :
--   This Procedure will expire the party using Native SQL
--
-- History
--   01/21/2000    julou    created
--
-------------------------------------------------------------------------------
PROCEDURE Expire_Inactive_Party
(
    p_mkt_seg_id      IN     NUMBER
  , p_mkt_seg_flag    IN     VARCHAR2
  , p_sql_str         IN     VARCHAR2
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Expire_Inactive_Party';
  TYPE dyna_cur_type IS REF CURSOR;

  CURSOR c_old_party_id IS                          -- parties already in the table
    SELECT party_id
    FROM   ams_party_market_segments
    WHERE  market_segment_id = p_mkt_seg_id
    AND    market_segment_flag = p_mkt_seg_flag
    AND    end_date_active IS NULL
    ORDER BY party_id;

  c_new_party_id    dyna_cur_type;                  -- parties from execution of sql string

  l_old_party_id    NUMBER;
  l_new_party_id    NUMBER;
  l_expire_flag     VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c_old_party_id;

  LOOP

    FETCH c_old_party_id INTO l_old_party_id;
    EXIT WHEN c_old_party_id%NOTFOUND;
    l_expire_flag := 'Y';

    OPEN c_new_party_id FOR p_sql_str;
    LOOP

      FETCH c_new_party_id INTO l_new_party_id;
      EXIT WHEN c_new_party_id%NOTFOUND OR l_expire_flag = 'N';

      IF l_old_party_id = l_new_party_id THEN       -- this party will be still active

        l_expire_flag := 'N';

      END IF;

    END LOOP;
    CLOSE c_new_party_id ;

    IF l_expire_flag = 'Y' THEN                     -- this party is expired

      UPDATE AMS_PARTY_MARKET_SEGMENTS
      SET end_date_active = SYSDATE
      WHERE market_segment_flag = p_mkt_seg_flag
      AND market_segment_id = p_mkt_seg_id
      AND party_id = l_old_party_id;
    END IF;

  END LOOP;
  CLOSE c_old_party_id ;
-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
        AMS_Utility_Pvt.Debug_Message('Error in expire_inactive_party');
--
            IF(c_old_party_id%ISOPEN)then
              CLOSE c_old_party_id;
            END IF;
            IF(c_new_party_id%ISOPEN)then
              CLOSE c_new_party_id;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded        =>      FND_API.G_FALSE
            );

END Expire_Inactive_Party;


/*****************************************************************************/
-- Procedure
--   expire_changed_party
-- Purpose
--   expire parties that originally belong to other mkt_seg_id and currently
--   belong to the give mkt_seg_id
--
-- Note :
--   This Procedure will expire the changed party using Native SQL
--
-- History
--   01/21/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE Expire_Changed_Party
(
    p_mkt_seg_id      IN   NUMBER
  , p_mkt_seg_flag    IN   VARCHAR2
  , p_sql_str         IN   VARCHAR2
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'Expire_Changed_Party';
  TYPE dyna_cur_type IS REF CURSOR;

  CURSOR c_old_party_rec IS               -- party_id and mkt_seg_id of exsiting party
    SELECT market_segment_id, party_id FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_id <> p_mkt_seg_id
    AND market_segment_flag = p_mkt_seg_flag
    AND end_date_active IS NULL
    ORDER BY party_id;

  c_new_party_id    dyna_cur_type;        -- parties from execution of sql string

  l_old_party_id      NUMBER;
  l_new_party_id      NUMBER;
  l_old_mkt_seg_id    NUMBER;
  l_expire_flag       VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c_old_party_rec;

  LOOP

    FETCH c_old_party_rec INTO l_old_mkt_seg_id, l_old_party_id;
    EXIT WHEN c_old_party_rec%NOTFOUND;

    l_expire_flag := 'N';

    OPEN c_new_party_id FOR p_sql_str;

    LOOP

      FETCH c_new_party_id INTO l_new_party_id;
      EXIT WHEN c_new_party_id%NOTFOUND OR l_expire_flag = 'Y';

      IF l_old_party_id = l_new_party_id THEN   -- party belongs to new market segment

        l_expire_flag := 'Y';

      END IF;

    END LOOP;
    CLOSE c_new_party_id ;

    IF l_expire_flag = 'Y' THEN

      UPDATE ams_party_market_segments
      SET end_date_active = SYSDATE
      WHERE market_segment_flag = p_mkt_seg_flag
      AND market_segment_id = l_old_mkt_seg_id
      AND party_id = l_old_party_id;
    END IF;

  END LOOP;
  CLOSE c_old_party_rec ;
-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
            AMS_Utility_Pvt.Debug_Message('Error in expire_changed_party');
--
            IF(c_old_party_rec%ISOPEN)then
              CLOSE c_old_party_rec;
            END IF;
            IF(c_new_party_id%ISOPEN)then
              CLOSE c_new_party_id;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
            );

END Expire_Changed_Party;


/*****************************************************************************/
-- Procedure
--   insert_new_party
-- Purpose
--   insert a new party if it is not there, update it if it is expired
--   do nothing if it is active
--
-- Note :
--   This Procedure will Insert the party using Native SQL
--
-- History
--   01/21/2000    julou    created
-------------------------------------------------------------------------------
PROCEDURE Insert_New_Party
(
    p_mkt_seg_id      IN    NUMBER
  , p_mkt_seg_flag    IN    VARCHAR2
  , p_sql_str         IN    VARCHAR2
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'insert_new_party';
  TYPE dyna_cur_type IS REF CURSOR;

  CURSOR c_party_count(id IN NUMBER) IS             -- check if party is already in table
    SELECT count(*) FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_flag = p_mkt_seg_flag
    AND market_segment_id = p_mkt_seg_id
    AND party_id = id;

  CURSOR c_expire_party_count(id IN NUMBER) IS      -- check if party expired
    SELECT count(*) FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_flag = p_mkt_seg_flag
    AND market_segment_id = p_mkt_seg_id
    AND party_id = id
    AND end_date_active IS NOT NULL;

  CURSOR c_party_mkt_seg_seq IS                     -- generate an ID
   SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
   FROM DUAL;

  CURSOR c_party_mkt_seg_count(party_mkt_seg_id IN NUMBER) IS  -- check if ID is unique
    SELECT count(*)
    FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE ams_party_market_segment_id = party_mkt_seg_id;

  c_party_id    dyna_cur_type;

  l_party_id              NUMBER;
  l_party_count           NUMBER;
  l_expire_party_count    NUMBER;
  l_party_mkt_seg_id      NUMBER;
  l_count                 NUMBER;

BEGIN

AMS_Utility_Pvt.Debug_Message('String : '||p_sql_str) ;
--
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c_party_id FOR p_sql_str;

  LOOP

    FETCH c_party_id INTO l_party_id;
    EXIT WHEN c_party_id%NOTFOUND;

    OPEN c_party_count(l_party_id);
    FETCH c_party_count INTO l_party_count;
    CLOSE c_party_count;
AMS_Utility_Pvt.Debug_Message('Insert        ');
--
    IF l_party_count = 0 THEN             -- new party is not in the table

      LOOP                                -- generate an unique ID for the record

        OPEN c_party_mkt_seg_seq;
        FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id;
        CLOSE c_party_mkt_seg_seq;

        OPEN c_party_mkt_seg_count(l_party_mkt_seg_id);
        FETCH c_party_mkt_seg_count INTO l_count;
        CLOSE c_party_mkt_seg_count;

        EXIT WHEN l_count = 0;

      END LOOP;
AMS_Utility_Pvt.Debug_Message('Insert        ');
--
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
      )

      VALUES

      (
          l_party_mkt_seg_id
        , SYSDATE
        , FND_GLOBAL.user_id
        , SYSDATE
        , FND_GLOBAL.user_id
        , FND_GLOBAL.conc_login_id
        , 1
        , p_mkt_seg_id
        , p_mkt_seg_flag
        , l_party_id
        , SYSDATE
        , NULL
      );


    ELSE
AMS_Utility_Pvt.Debug_Message('Update        ');
--
      OPEN c_expire_party_count(l_party_id);
      FETCH c_expire_party_count INTO l_expire_party_count;
      CLOSE c_expire_party_count;

      IF l_expire_party_count > 0 THEN              -- party expired

        UPDATE AMS_PARTY_MARKET_SEGMENTS SET
            last_update_date = SYSDATE
          , last_updated_by = FND_GLOBAL.user_id
          , last_update_login = FND_GLOBAL.conc_login_id
          , object_version_number = object_version_number + 1
          , market_segment_id = p_mkt_seg_id
          , market_segment_flag = p_mkt_seg_flag
          , party_id = l_party_id
          , start_date_active =SYSDATE
          , end_date_active = NULL
        WHERE market_segment_id = p_mkt_seg_id
        AND market_segment_flag = p_mkt_seg_flag
        AND party_id = l_party_id;


      END IF;

    END IF;

  END LOOP;
-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Insert/Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
                AMS_Utility_Pvt.Debug_Message('Error in insert_new_party'||sqlerrm);
--
            IF(c_party_count%ISOPEN)then
              CLOSE c_party_count;
            END IF;
            IF(c_expire_party_count%ISOPEN)then
              CLOSE c_expire_party_count;
            END IF;
            IF(c_party_mkt_seg_seq%ISOPEN)then
              CLOSE c_party_mkt_seg_seq;
            END IF;
            IF(c_party_mkt_seg_count%ISOPEN)then
              CLOSE c_party_mkt_seg_count;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
            );

END Insert_New_Party;


/*****************************************************************************/
-- Procedure
--   Expire_Inactive_Party_Dbms
-- Purpose
--   expire parties that no longer belong to the given mkt_seg_id
--
-- Note :
--   This Procedure will expire the party using DBMS SQL
--
-- History
--   05/03/2000    ptendulk    created
--
-------------------------------------------------------------------------------
PROCEDURE Expire_Inactive_Party_Dbms
(
    p_mkt_seg_id      IN     NUMBER
  , p_mkt_seg_flag    IN     VARCHAR2
  , p_sql_tbl         IN     t_party_tab
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'expire_inactive_party';
   l_full_name        CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
   CURSOR c_old_party_id IS                          -- parties already in the table
    SELECT party_id FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_id = p_mkt_seg_id
    AND market_segment_flag = p_mkt_seg_flag
    AND end_date_active IS NULL
    ORDER BY party_id;

    l_old_party_id    NUMBER;
    l_expire_flag     VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  AMS_Utility_PVT.debug_message(l_full_name||': PARSE SQL start');
--

  OPEN c_old_party_id;
  LOOP
      FETCH c_old_party_id INTO l_old_party_id;
      EXIT WHEN c_old_party_id%NOTFOUND;
      l_expire_flag := 'Y';

      FOR i IN p_sql_tbl.FIRST..p_sql_tbl.last
      LOOP
          IF l_old_party_id = p_sql_tbl(i) THEN
              l_expire_flag := 'N';
              EXIT;
          END IF;
      END LOOP;

      IF l_expire_flag = 'Y' THEN                     -- this party is expired

         UPDATE AMS_PARTY_MARKET_SEGMENTS
         SET end_date_active = SYSDATE
         WHERE market_segment_flag = p_mkt_seg_flag
         AND market_segment_id = p_mkt_seg_id
         AND party_id = l_old_party_id;

      END IF;

  END LOOP;
  CLOSE c_old_party_id ;
-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
        AMS_Utility_Pvt.Debug_Message('Error in expire_inactive_party');
--
                IF(c_old_party_id%ISOPEN)then
                    CLOSE c_old_party_id;
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

              IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
            );

END Expire_Inactive_Party_Dbms;


/*****************************************************************************/
-- Procedure
--   expire_changed_party
-- Purpose
--   expire parties that originally belong to other mkt_seg_id and currently
--   belong to the give mkt_seg_id
--
-- Note :
--   This Procedure will expire the party using DBMS SQL
--
-- History
--   05/03/2000    ptendulk    created
-------------------------------------------------------------------------------
PROCEDURE Expire_Changed_Party_Dbms
(
    p_mkt_seg_id      IN   NUMBER
  , p_mkt_seg_flag    IN   VARCHAR2
  , p_sql_tbl         IN   t_party_tab
  , x_return_status   OUT NOCOPY  VARCHAR2
  , x_msg_count       OUT NOCOPY  NUMBER
  , x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'expire_changed_party';

  CURSOR c_old_party_rec IS               -- party_id and mkt_seg_id of exsiting party
    SELECT market_segment_id, party_id
    FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_id <> p_mkt_seg_id
    AND market_segment_flag = p_mkt_seg_flag
    AND end_date_active IS NULL
    ORDER BY party_id;

  l_old_party_id      NUMBER;
  l_old_mkt_seg_id    NUMBER;
  l_expire_flag       VARCHAR2(1);

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

      UPDATE AMS_PARTY_MARKET_SEGMENTS
      SET end_date_active = SYSDATE
      WHERE market_segment_flag = p_mkt_seg_flag
      AND market_segment_id = l_old_mkt_seg_id
      AND party_id = l_old_party_id;


    END IF;

  END LOOP;
  CLOSE c_old_party_rec ;
-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
                AMS_Utility_Pvt.Debug_Message('Error in expire_changed_party');
 --
            IF(c_old_party_rec%ISOPEN)then
              CLOSE c_old_party_rec;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
            );

END Expire_Changed_Party_Dbms;


/*****************************************************************************/
-- Procedure
--   insert_new_party
-- Purpose
--   insert a new party if it is not there, update it if it is expired
--   do nothing if it is active
--
-- Note :
--   This Procedure will expire the party using Native SQL
--
-- History
--   05/03/2000    ptendulk    created
-------------------------------------------------------------------------------
PROCEDURE Insert_New_Party_Dbms
(
    p_mkt_seg_id      IN    NUMBER
  , p_mkt_seg_flag    IN    VARCHAR2
  , p_sql_tbl         IN    t_party_tab
  , x_return_status   OUT NOCOPY   VARCHAR2
  , x_msg_count       OUT NOCOPY   NUMBER
  , x_msg_data        OUT NOCOPY   VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'insert_new_party';

  CURSOR c_party_count(id IN NUMBER) IS             -- check if party is already in table
    SELECT count(*) FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_flag = p_mkt_seg_flag
    AND market_segment_id = p_mkt_seg_id
    AND party_id = id;

  CURSOR c_expire_party_count(id IN NUMBER) IS      -- check if party expired
    SELECT count(*) FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE market_segment_flag = p_mkt_seg_flag
    AND market_segment_id = p_mkt_seg_id
    AND party_id = id
    AND end_date_active IS NOT NULL;

  CURSOR c_party_mkt_seg_seq IS                     -- generate an ID
   SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
   FROM DUAL;

  CURSOR c_party_mkt_seg_count(party_mkt_seg_id IN NUMBER) IS  -- check if ID is unique
    SELECT count(*)
    FROM AMS_PARTY_MARKET_SEGMENTS
    WHERE ams_party_market_segment_id = party_mkt_seg_id;


  l_party_id              NUMBER;
  l_party_count           NUMBER;
  l_expire_party_count    NUMBER;
  l_party_mkt_seg_id      NUMBER;
  l_count                 NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN p_sql_tbl.FIRST..p_sql_tbl.last
  LOOP
    l_party_id  := p_sql_tbl(i)   ;

     OPEN c_party_count(l_party_id);
     FETCH c_party_count INTO l_party_count;
     CLOSE c_party_count;

     AMS_Utility_Pvt.Debug_Message('Insert        ');
--
     IF l_party_count = 0 THEN             -- new party is not in the table

         LOOP                                -- generate an unique ID for the record

             OPEN c_party_mkt_seg_seq;
             FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id;
             CLOSE c_party_mkt_seg_seq;

             OPEN c_party_mkt_seg_count(l_party_mkt_seg_id);
             FETCH c_party_mkt_seg_count INTO l_count;
             CLOSE c_party_mkt_seg_count;

             EXIT WHEN l_count = 0;

         END LOOP;

         AMS_Utility_Pvt.Debug_Message('Insert        ');
--
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
         )
         VALUES
        (
           l_party_mkt_seg_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , p_mkt_seg_id
           , p_mkt_seg_flag
           , l_party_id
           , SYSDATE
           , NULL
        );


     ELSE
AMS_Utility_Pvt.Debug_Message('Update        ');
--
        OPEN c_expire_party_count(l_party_id);
        FETCH c_expire_party_count INTO l_expire_party_count;
        CLOSE c_expire_party_count;

        IF l_expire_party_count > 0 THEN              -- party expired

           UPDATE AMS_PARTY_MARKET_SEGMENTS SET
               last_update_date = SYSDATE
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.conc_login_id
             , object_version_number = object_version_number + 1
             , market_segment_id = p_mkt_seg_id
             , market_segment_flag = p_mkt_seg_flag
             , party_id = l_party_id
             , start_date_active =SYSDATE
             , end_date_active = NULL
           WHERE market_segment_id = p_mkt_seg_id
           AND market_segment_flag = p_mkt_seg_flag
           AND party_id = l_party_id;


        END IF;

     END IF;

  END LOOP;

-- =============================================================================================
-- Following Exception block is added by ptendulk on May02-2000 to handle Insert/Update Exception
-- =============================================================================================
EXCEPTION
        WHEN OTHERS THEN
                AMS_Utility_Pvt.Debug_Message('Error in insert_new_party'||sqlerrm);
   --
            IF(c_party_count%ISOPEN)then
              CLOSE c_party_count;
            END IF;
            IF(c_expire_party_count%ISOPEN)then
              CLOSE c_expire_party_count;
            END IF;
            IF(c_party_mkt_seg_seq%ISOPEN)then
              CLOSE c_party_mkt_seg_seq;
            END IF;
            IF(c_party_mkt_seg_count%ISOPEN)then
              CLOSE c_party_mkt_seg_count;
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
            );

END Insert_New_Party_Dbms;


/*****************************************************************************/
-- Procedure
--   load_mkt_seg
-- Purpose
--   handle parties belonging to market segment, i.e., flag = 'Y'
--
--  Note
--  The process will take the sql query in to variable if it is Native SQL
--  Or it will take the sql query into table to use DBMS_SQL to execute it
-- History
--   01/21/2000    julou      created
--   05/02/2000    ptendulk   Modified , 1. Added Routines to execute sql as
--                            Native SQL or DBMS sql
-------------------------------------------------------------------------------
PROCEDURE Load_Mkt_Seg
(
    p_mkt_seg_id    IN    NUMBER
  , p_query         IN    sql_rec_type
  , p_type          IN    VARCHAR2
  , x_return_status OUT NOCOPY   VARCHAR2
  , x_msg_count     OUT NOCOPY   NUMBER
  , x_msg_data      OUT NOCOPY   VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'Load_Mkt_Seg';

   l_sql_str       VARCHAR2(32767) := '' ;
   l_sql_tbl       DBMS_SQL.varchar2s ;
   l_tmp_str       VARCHAR2(2000)  := '' ;

   l_count         NUMBER ;
   l_str_copy      VARCHAR2(2000);

   l_length        NUMBER ;

   -- Define the table type to store the party ids if the sql is DBMS_SQL
   l_party_tab     t_party_tab ;
   l_temp          NUMBER;
   l_party_cur     NUMBER ;
   l_dummy         NUMBER ;
BEGIN
  AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
--
  IF p_type = 'NATIVE' THEN
      -- Get the query in to VAriable
      FOR i IN p_query.FIRST..p_query.LAST
      LOOP
         l_tmp_str := p_query(i) ;
         l_sql_str := l_sql_str || l_tmp_str ;
      END LOOP;

      -- expires parties that no longer belong to the given market segment
      Expire_Inactive_Party
          (
           p_mkt_seg_id,
           'Y',
           l_sql_str,
           x_return_status,
           x_msg_count    ,
           x_msg_data
           );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


     -- expires parties that originally belong to other marekt segments
     -- and currently belong to the given market segment
      Expire_Changed_Party
          (
          p_mkt_seg_id,
          'Y',
          l_sql_str,
          x_return_status,
          x_msg_count    ,
          x_msg_data
          );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- insert new parties that do not exist in the table
      Insert_New_Party
          (
          p_mkt_seg_id,
          'Y',
          l_sql_str,
          x_return_status,
          x_msg_count    ,
          x_msg_data
          );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

  ELSIF p_type = 'DBMS' THEN
--
      -- Get the query in to Table
        l_count := 0 ;
        FOR j IN p_query.FIRST..p_query.LAST
        LOOP
        -- Copy Current String
            l_str_copy :=  p_query(j) ;
            LOOP
               -- Get the length of the current string
               l_length := length(l_str_copy) ;
               l_count := l_count + 1 ;
               IF l_length < 255 THEN
               -- If length is < 255 char we can exit loop after copying
               -- current contents into DBMS_SQL PL/SQL table
                    l_sql_tbl(l_count):=  l_str_copy ;
                    EXIT;
               ELSE
        -- Copy 255 Characters and copy next 255 to the next row
                    l_sql_tbl(l_count):=  substr(l_str_copy,1,255) ;
                    l_str_copy        :=  substr(l_str_copy,256)   ;
               END IF;

            END LOOP ;
        END LOOP ;


        l_count := 1 ;
       --  Open the cursor and parse it
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
            l_party_tab(l_count) := l_temp ;
            l_count := l_count + 1 ;
          ELSE
            -- No more rows to copy:
            EXIT;
          END IF;
       END LOOP;

       DBMS_SQL.Close_Cursor(l_party_cur);

--

      -- expires parties that no longer belong to the given market segment
      Expire_Inactive_Party_Dbms
          (
           p_mkt_seg_id,
           'Y',
           l_party_tab,
           x_return_status,
           x_msg_count    ,
           x_msg_data
           );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     -- expires parties that originally belong to other marekt segments
     -- and currently belong to the given market segment
      Expire_Changed_Party_Dbms
          (
          p_mkt_seg_id,
          'Y',
          l_party_tab,
          x_return_status,
          x_msg_count    ,
          x_msg_data
          );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- insert new parties that do not exist in the table
      Insert_New_Party_Dbms
          (
          p_mkt_seg_id,
          'Y',
          l_party_tab,
          x_return_status,
          x_msg_count    ,
          x_msg_data
          );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


  END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
--
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Load_Mkt_Seg;


/*****************************************************************************/
-- Procedure
--   Load_Tgt_Seg
-- Purpose
--   handle parties belonging to  target segment, i.e., flag = 'N'
-- History
--   01/21/2000    julou    created
--   05/02/2000    ptendulk   Modified , 1. Added Routines to execute sql as
--                            Native SQL or DBMS sql
-------------------------------------------------------------------------------
PROCEDURE Load_Tgt_Seg
(
    p_mkt_seg_id    IN    NUMBER
  , p_query         IN    sql_rec_type
  , p_type          IN    VARCHAR2
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_count       OUT NOCOPY    NUMBER
  , x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)  := 'load_tgt_seg';

   l_sql_str       VARCHAR2(32767) := '' ;
   l_sql_tbl       DBMS_SQL.varchar2s ;
   l_tmp_str       VARCHAR2(2000)  := '' ;

   l_count         NUMBER ;
   l_str_copy      VARCHAR2(2000);
   -- Define the table type to store the party ids if the sql is DBMS_SQL
   l_party_tab     t_party_tab ;
   l_length        NUMBER ;
   l_party_cur     NUMBER ;
   l_dummy         NUMBER ;
BEGIN

  AMS_Utility_PVT.Debug_Message(l_api_name||' Start ');
--
  IF p_type = 'NATIVE' THEN
      -- Get the query in to VAriable
      FOR i IN p_query.first..p_query.last
      LOOP
         l_tmp_str := p_query(i) ;
         l_sql_str := l_sql_str || l_tmp_str ;
      END LOOP;

      -- expires parties that no longer belong to the given target segment
      Expire_Inactive_Party
      (
          p_mkt_seg_id,
          'N',
          l_sql_str,
          x_return_status,
          x_msg_count    ,
          x_msg_data
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- insert new parties that do not exist in the table
      Insert_New_Party
      (
          p_mkt_seg_id,
          'N',
          l_sql_str,
          x_return_status,
          x_msg_count    ,
          x_msg_data
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

  ELSIF p_type = 'DBMS' THEN
      -- Get the query in to Table
        l_count := 0 ;
        FOR j IN p_query.first..p_query.last
        LOOP
        -- Copy Current String
            l_str_copy :=  p_query(j) ;
            LOOP
               -- Get the length of the current string
               l_length := length(l_str_copy) ;
               l_count := l_count + 1 ;
               IF l_length < 255 THEN
               -- If length is < 255 char we can exit loop after copying
               -- current contents into DBMS_SQL PL/SQL table
                    l_sql_tbl(l_count):=  l_str_copy ;
                    EXIT;
               ELSE
        -- Copy 255 Characters and copy next 255 to the next row
                    l_sql_tbl(l_count):=  substr(l_str_copy,1,255) ;
                    l_str_copy        :=  substr(l_str_copy,256)   ;
               END IF;

            END LOOP ;
        END LOOP ;

        l_count := 0 ;
        --  Open the cursor and parse it
        IF (DBMS_SQL.Is_Open(l_party_cur) = FALSE) THEN
            l_party_cur := DBMS_SQL.Open_Cursor ;
        END IF;
        DBMS_SQL.Parse(l_party_cur ,
                      l_sql_tbl,
                      l_sql_tbl.first,
                      l_sql_tbl.last,
                      FALSE,
                      DBMS_SQL.Native) ;

        l_dummy :=  DBMS_SQL.Execute(l_party_cur);

        LOOP
          IF DBMS_SQL.FETCH_ROWS(l_party_cur)>0 THEN
            -- get column values of the row
            DBMS_SQL.COLUMN_VALUE(l_party_cur, 1, l_party_tab(l_count));
            l_count := l_count + 1 ;
          ELSE
            -- No more rows to copy:
            EXIT;
          END IF;
        END LOOP;

        DBMS_SQL.Close_Cursor(l_party_cur);

      -- expires parties that no longer belong to the given market segment
      Expire_Inactive_Party_Dbms
          (
           p_mkt_seg_id,
           'N',
           l_party_tab,
           x_return_status,
           x_msg_count    ,
           x_msg_data
           );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- insert new parties that do not exist in the table
      Insert_New_Party_Dbms
          (
          p_mkt_seg_id,
          'N',
          l_party_tab,
          x_return_status,
          x_msg_count    ,
          x_msg_data
          );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


  END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
       IF (DBMS_SQL.Is_Open(l_party_cur) = TRUE) THEN
            DBMS_SQL.Close_Cursor(l_party_cur) ;
       END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );




END Load_Tgt_Seg;





/*****************************************************************************/
-- Procedure
--   load_party_mkt_seg
-- Purpose
--   load ams_party_market_segments
-- History
--   01/16/2000    julou       created
--   05/05/2000    ptendulk    Modified 1.Added out parameter to capture error
--                             2. Added input parameter to get the Cell id
--                             If the cell id is sent then Only that cell and
--                             all the Target child cells of that cell will be
--                             refreshed or else all the cells will be refreshed.
--
-- Note :
--    If the cell is is passed to the program then if the error occurs it will
--    rollback everything
--    If the cell id is not passed it will do commmit per cell.
-------------------------------------------------------------------------------
PROCEDURE Load_Party_Mkt_Seg
(   p_cell_id       IN  NUMBER  DEFAULT NULL,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  )
IS
  l_api_name      CONSTANT VARCHAR2(30)  := 'Load_Party_Mkt_Seg';
  TYPE dyna_cur_type IS REF CURSOR;                 -- cursor for dynamic SQL
  l_type                 VARCHAR2(10);
  l_query                sql_rec_type ;
  l_cell_id              NUMBER;
  l_mkt_seg_flag         VARCHAR2(1);
  l_sql_str              VARCHAR2(2000);
  l_wb_owner             VARCHAR2(15) ;
  l_wb_name              VARCHAR2(254);
  l_ws_name              VARCHAR2(254);
  l_cell_name            VARCHAR2(120);

  CURSOR c_cell_rec(l_cell_id NUMBER) IS
    SELECT cell_id, market_segment_flag,cell_name
    FROM   ams_cells_vl
    WHERE  cell_id = l_cell_id
    OR     (parent_cell_id = l_cell_id
    AND    market_segment_flag = 'N' );

  CURSOR c_all_cell_rec IS
    SELECT cell_id, market_segment_flag ,cell_name
    FROM   ams_cells_vl   ;

  CURSOR c_sql_id(cell_id IN NUMBER) IS
    SELECT workbook_name,workbook_owner,worksheet_name
    FROM   ams_act_discoverer_all
    WHERE  act_discoverer_used_by_id = cell_id
    AND    arc_act_discoverer_used_by = 'CELL';

--  CURSOR c_sql_str(WB_NAME IN VARCHAR2,WB_OWNER IN VARCHAR2) IS
--    SELECT sql_string FROM AMS_DISCOVERER_SQL
--    WHERE workbook_name = wb_name
--    AND   workbook_owner_name = wb_owner ;

BEGIN
  AMS_Utility_Pvt.Debug_Message('Start Loading ');
--
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check the cells If the p_cell_id is null then Refresh all the cells
  -- Else refresh only the given cell and the Target sells which are
  -- children of the current cells
  IF p_cell_id IS NOT NULL
  THEN
      -- Create the Savepoint
      SAVEPOINT Load_Party_Mkt_Seg;

      -- Refresh only particular Cell
      OPEN c_cell_rec(p_cell_id);
      LOOP                                    -- the loop for all CELL_IDs

        FETCH c_cell_rec INTO l_cell_id, l_mkt_seg_flag,l_cell_name;
        EXIT WHEN c_cell_rec%NOTFOUND;
        -- initalize
        l_sql_str := NULL;

        -- Get the Workbook sqls attached to that cell
        OPEN c_sql_id(l_cell_id);
        FETCH c_sql_id INTO l_wb_name,l_wb_owner,l_ws_name;
        CLOSE c_sql_id;

        AMS_Utility_Pvt.Debug_Message('WB : '||l_wb_name||'Owner : '||l_wb_owner);
 --

        Validate_Sql
            (p_workbook_name    => l_wb_name ,
            p_workbook_owner   => l_wb_owner,
            p_worksheet_name   => l_ws_name,
            p_cell_name        => l_cell_name ,
            x_query            => l_query,
            x_sql_type         => l_type,

            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count ,
            x_msg_data         => x_msg_data ) ;

        IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;


        IF  l_mkt_seg_flag = 'Y' THEN

            AMS_Utility_Pvt.Debug_Message('Load MKt ');
--

             Load_Mkt_Seg(l_cell_id,
                       l_query,
                       l_type,
                       x_return_status ,
                       x_msg_count ,
                       x_msg_data);

        ELSE
          AMS_Utility_Pvt.Debug_Message('Load Target  ');
 --
          Load_Tgt_Seg(l_cell_id,
                       l_query,
                       l_type,
                       x_return_status ,
                       x_msg_count ,
                       x_msg_data);

        END IF;

      END LOOP;                               -- end: the loop for all CELL_IDs
      CLOSE c_cell_rec;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

--    If No Errors , Commit the work
      COMMIT WORK;

  ELSE
      -- Get All The cells
      OPEN c_all_cell_rec;
      LOOP                                    -- the loop for all CELL_IDs
        FETCH c_all_cell_rec INTO l_cell_id, l_mkt_seg_flag,l_cell_name;
        EXIT WHEN c_all_cell_rec%NOTFOUND;
        -- Create the Savepoint
        SAVEPOINT Load_Party_Mkt_Seg;

        -- initalize
        l_sql_str := NULL;

        -- Get the Workbook sqls attached to that cell
        OPEN c_sql_id(l_cell_id);
        FETCH c_sql_id INTO l_wb_name,l_wb_owner,l_ws_name;
        CLOSE c_sql_id;

        AMS_Utility_Pvt.Debug_Message('WB : '||l_wb_name||'Owner : '||l_wb_owner);
--

        Validate_Sql
            (p_workbook_name   => l_wb_name ,
            p_workbook_owner   => l_wb_owner,
            p_worksheet_name   => l_ws_name,
            p_cell_name          => l_cell_name,
            x_query            => l_query,
            x_sql_type         => l_type,

            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count ,
            x_msg_data         => x_msg_data ) ;


        IF x_return_status = FND_API.g_ret_sts_success THEN
            -- Load the Segments

            IF  l_mkt_seg_flag = 'Y' THEN

               AMS_Utility_Pvt.Debug_Message('Load MKt ');
--

               Load_Mkt_Seg(l_cell_id,
                       l_query,
                       l_type,
                       x_return_status ,
                       x_msg_count ,
                       x_msg_data);

            ELSE
               AMS_Utility_Pvt.Debug_Message('Load Target  ');
 --
               Load_Tgt_Seg(l_cell_id,
                       l_query,
                       l_type,
                       x_return_status ,
                       x_msg_count ,
                       x_msg_data);

            END IF;

            IF x_return_status = FND_API.g_ret_sts_success THEN
               COMMIT WORK ;
            END IF;
        END IF;
      END LOOP;                               -- end: the loop for all CELL_IDs
      CLOSE c_cell_rec;
  END IF;



EXCEPTION
   WHEN FND_API.g_exc_error THEN
      IF(c_cell_rec%ISOPEN)then
           CLOSE c_cell_rec;
      END IF;
      IF(c_sql_id%ISOPEN)then
            CLOSE c_sql_id;
      END IF;
      IF(c_all_cell_rec%ISOPEN)then
           CLOSE c_all_cell_rec;
      END IF;
      ROLLBACK TO Load_Party_Mkt_Seg;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      IF(c_cell_rec%ISOPEN)then
           CLOSE c_cell_rec;
      END IF;
      IF(c_sql_id%ISOPEN)then
            CLOSE c_sql_id;
      END IF;
      IF(c_all_cell_rec%ISOPEN)then
           CLOSE c_all_cell_rec;
      END IF;
      ROLLBACK TO Load_Party_Mkt_Seg;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      IF(c_cell_rec%ISOPEN)then
           CLOSE c_cell_rec;
      END IF;
      IF(c_sql_id%ISOPEN)then
            CLOSE c_sql_id;
      END IF;
      IF(c_all_cell_rec%ISOPEN)then
           CLOSE c_all_cell_rec;
      END IF;
      ROLLBACK TO Load_Party_Mkt_Seg;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END load_party_mkt_seg;


-- Start of Comments
--
-- NAME
--   Refresh_Party_Market_Segment
--
-- PURPOSE
--   This procedure is created to as a concurrent program which
--   will call the load_party_mkt_seg and will return errors if any
--
-- NOTES
--
--
-- HISTORY
--   05/02/1999      ptendulk    created
-- End of Comments

PROCEDURE Refresh_Party_Market_Segment
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER,
                         p_cell_id     IN     NUMBER DEFAULT NULL)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
BEGIN
FND_MSG_PUB.initialize;
-- Call the procedure to refresh the Market Segment
-- Call procedure in new package to refresh the segments

AMS_Party_Seg_Loader_PVT.Load_Party_Seg
   (   p_cell_id         =>  p_cell_id,
       x_return_status   =>  l_return_status,
       x_msg_count       =>  l_msg_count,
       x_msg_data        =>  l_msg_data);

--Load_Party_Mkt_Seg
--(   p_cell_id         =>  p_cell_id ,
--    x_return_status   =>  l_return_status ,
--    x_msg_count       =>  l_msg_count ,
--    x_msg_data        =>  l_msg_data  ) ;

-- Write_log ;
Ams_Utility_Pvt.Write_Conc_log ;
IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
      retcode :=0;
ELSE
      retcode  :=1;
      errbuf  := l_msg_data ;
END IF;
END Refresh_Party_Market_Segment ;





-- Start of Comments
--
-- NAME
--   Format_Party_Id
--
-- PURPOSE
--   This procedure is created to contruct the party id with the alias
--   present in the Discoverer workbook
--   It will get the SQL String input which will be from SELECT to FROM in
--   the sql query and will return the party Id with the alias.
--
-- NOTES
--  This parsing is based on the assumption that discoverer always
--  creates the Alias
--
-- HISTORY
--   05/02/1999      ptendulk    created
-- End of Comments

PROCEDURE Format_Party_Id
           (P_sql_str          IN   VARCHAR2,
            x_party_str        OUT NOCOPY  VARCHAR2)
IS
   l_sql_str    VARCHAR2(32767);
   l_party_str  VARCHAR2(2000);
--   l_tmp        NUMBER;
BEGIN

   l_party_str := SUBSTR(P_sql_str,INSTR(p_sql_str,' ',-1,1) + 1)  ;

   l_party_str := 'SELECT '||SUBSTR(l_party_str,INSTR(l_party_str,',',-1,1) +1 )||' FROM ' ;


   x_party_str := l_party_str ;


END Format_Party_Id ;

-- Start of Comments
--
-- NAME
--   Validate_Sql
--
-- PURPOSE
--   This procedure is created to validate the discoverer sql created for
--   the Cells . It will follow the following steps :
--   1. Check If the sql length is less than 32k , If it's less than 32k
--      process and execute it as native sql or use dbms sql
--   2. Check for the party id between SELECT and FROM of the SQL string
--   3. Substitue the party id for every thing between select and from
--   4. Execute the query
--
--   It will return the Parameters as
--   1. x_query : This table will have the discoverer sql query
--   2. x_sql_type : It will return 'NATIVE' if the sql is Native SQL
--                   or it will return 'DBMS'
-- NOTES
--
--
-- HISTORY
--   05/02/1999      ptendulk    created
-- End of Comments

PROCEDURE Validate_Sql
           (p_workbook_name    IN   VARCHAR2,
            p_workbook_owner   IN   VARCHAR2,
            p_worksheet_name   IN   VARCHAR2,
            p_cell_name        IN   VARCHAR2,
            x_query            OUT NOCOPY  sql_rec_type,
            x_sql_type         OUT NOCOPY  VARCHAR2,

            x_return_status    OUT NOCOPY  VARCHAR2,
            x_msg_count        OUT NOCOPY  NUMBER,
            x_msg_data         OUT NOCOPY  VARCHAR2)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
   l_workbook_sql     sql_rec_type ;
   l_api_name         CONSTANT VARCHAR2(30)  := 'Validate_Sql';
   l_full_name        CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

-- Define the cursor to find the first worksheet
   CURSOR c_ws_name IS
   SELECT 1
   FROM   ams_discoverer_sql
   WHERE  workbook_name  = p_workbook_name
   AND    workbook_owner_name = p_workbook_owner
   AND    worksheet_name      = p_worksheet_name ;

-- Define the cursor to get the sql between SELECT and first Party ID
   CURSOR c_till_from_sql(l_sequence_order NUMBER ) IS
   SELECT sql_string
   FROM   ams_discoverer_sql
   WHERE  workbook_name       =  p_workbook_name
   AND    worksheet_name      =  p_worksheet_name
   AND    workbook_owner_name =  p_workbook_owner
   AND    sequence_order     <=  l_sequence_order
   ORDER BY Sequence_Order;

-- Define the cursor to get the sql string after from
   CURSOR c_sql_str(l_sequence_order NUMBER ) IS
   SELECT sql_string
   FROM   ams_discoverer_sql
   WHERE  workbook_name       =  p_workbook_name
   AND    worksheet_name      =  p_worksheet_name
   AND    workbook_owner_name =  p_workbook_owner
   AND    sequence_order     >=  l_sequence_order
   ORDER BY sequence_order;


   l_count           NUMBER := 0 ;
   l_size            NUMBER := 0 ;
   l_tmp_size        NUMBER := 0 ;
   -- Size constraint to Use Native dynamic sql
   l_dbms_size     NUMBER  := 32767 ;
   -- The PL/SQL table which stores 255 character length strings to be passed
   -- to DBMS_SQL package
--   l_sql_str     DBMS_SQL.varchar2s ;

l_found              VARCHAR2(1) := FND_API.G_FALSE;
l_found_in_str       NUMBER      := 0 ;
l_position           NUMBER      := 0 ;
l_overflow           NUMBER      := 0 ;

l_max_search_len     NUMBER      := 0 ;
l_from_found_in_str  NUMBER      := 0 ;
l_from_position      NUMBER      := 0 ;
l_from_overflow      NUMBER      := 0 ;

l_str                VARCHAR2(32767) := '' ;
l_tmp_str            VARCHAR2(2000)  := '' ;
l_counter            NUMBER ;
l_dummy              NUMBER ;
BEGIN

   AMS_Utility_PVT.debug_message(l_full_name||': start');
--

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    -- Take the sql query into PLSQL table
    -- Check the Size of the query depending on the Size Execute
    -- the query as Native SQL or DBMS_SQL
    l_count := 0 ;
    --
    OPEN  c_ws_name ;
    FETCH c_ws_name INTO l_dummy ;
    IF c_ws_name%NOTFOUND THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           -- Invalid SQL for the Discoverer
           FND_MESSAGE.set_name('AMS', 'AMS_MKS_NO_WB');
           FND_MESSAGE.Set_Token('WORKBOOK', p_workbook_name);
           FND_MESSAGE.Set_Token('CELL', p_cell_name);
           FND_MSG_PUB.Add;
           CLOSE c_ws_name ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF ;
    CLOSE c_ws_name ;



    -- Search for the from in the discoverer SQL
    AMS_DiscovererSQL_PVT.search_sql_string(p_search_string        =>  'FROM',
                                            p_workbook_name        =>  p_workbook_name,
                                            p_worksheet_name       =>  p_worksheet_name,
                                            x_found                =>  l_found,
                                            x_found_in_str         =>  l_found_in_str,
                                            x_position             =>  l_position,
                                            x_overflow             =>  l_overflow);


    IF (l_found = FND_API.G_FALSE) THEN
        AMS_Utility_PVT.debug_message(l_full_name||': Invalid SQL');
--
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           -- Invalid SQL for the Discoverer
           FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_WB');
           FND_MESSAGE.Set_Token('CELL', p_cell_name);
           FND_MSG_PUB.Add;
           CLOSE c_ws_name ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF(l_found = FND_API.G_TRUE)THEN

        --calculating the max. number of chars to be searched when searching for master and subtypes.
        l_max_search_len := (l_found_in_str ) * 2000 + l_position;

        --recording the sql string where the first character of FROM was found.
        l_from_found_in_str := l_found_in_str;

        --recording the position where the first character of FROM was found.
        l_from_position     := l_position;

        --recording the overflow amount into the next string if this occured.
        l_from_overflow     := nvl(l_overflow,0);

 --
        -- Now Find out the position of the first party_id from the SELECT to FROM
        -- ===================Assumption ====================
        -- The Discoverer generates the alias for the column name
        -- ==================================================
        AMS_DiscovererSQL_PVT.search_sql_string(p_search_string        =>  '.PARTY_ID',
                                                p_workbook_name        =>  p_workbook_name,
                                                p_worksheet_name       =>  p_worksheet_name,
                                                p_max_search_len       =>  l_max_search_len,
                                                x_found                =>  l_found,
                                                x_found_in_str         =>  l_found_in_str,
                                                x_position             =>  l_position,
                                                x_overflow             =>  l_overflow);

       IF (l_found = FND_API.G_FALSE) THEN
           AMS_Utility_PVT.debug_message(l_full_name||': No party ID in the SQL');
--
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               -- Invalid SQL for the Discoverer
               FND_MESSAGE.set_name('AMS', 'AMS_MKS_BAD_WB');
               FND_MESSAGE.Set_Token('CELL', p_cell_name);
               FND_MSG_PUB.Add;
               CLOSE c_ws_name ;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
       ELSIF(l_found = FND_API.G_TRUE)THEN
           AMS_Utility_PVT.debug_message(l_full_name||': Party ID in the SQL');
--

           -- Get the sql string form "SELECT" to "FROM" into the string and
           OPEN c_till_from_sql(l_found_in_str) ;
           LOOP
              FETCH c_till_from_sql INTO l_tmp_str ;
              EXIT WHEN c_till_from_sql%NOTFOUND ;
              l_str := l_str ||l_tmp_str ;
           END LOOP ;
           CLOSE c_till_from_sql ;
           -- We Have the String like 'select ........ AMS.Party_id' or 'select ........ AMS.Pa'
           -- Now Get the string before party Id and concatenate it with party Id
           -- to format the String (It will format e.g2 to e.g1)
           l_str := SUBSTR(l_str,1,((l_found_in_str ) * 2000 + l_position) ) ;
           l_str := SUBSTR(l_str,1,INSTR(l_str,'.',-1,1)-1)||'.PARTY_ID' ;

           -- We Have String like 'select ........ AMS.Party_id'

           --Pass it to get the formated select clause till form
           Format_Party_Id(l_str,l_str) ;


           AMS_UTILITY_PVT.Debug_Message('Sql String : '||l_str);
--
           -- So We Have String like 'Select AMS.Party_id FROM'
           -- Store it in PLSQL table as first row and then Store the other
           -- Rows of the sql as neft rows
           l_workbook_sql(1) := l_str ;

           l_counter := 3 ;
           l_tmp_str := '' ;



           OPEN c_sql_str(l_from_found_in_str) ;
           FETCH c_sql_str INTO l_tmp_str ;

           IF  l_from_overflow = 0 THEN
               l_workbook_sql(2) := SUBSTR(l_tmp_str,l_from_position+5) ;
           ELSE
               FETCH c_sql_str INTO l_tmp_str ;
               l_workbook_sql(2) := SUBSTR(l_tmp_str,l_from_overflow+1);
           END IF;



           LOOP
                FETCH c_sql_str INTO l_tmp_str ;
                EXIT WHEN c_sql_str%NOTFOUND ;
                l_workbook_sql(l_counter) := l_tmp_str ;
                l_counter := l_counter + 1 ;
           END LOOP;
           CLOSE c_sql_str ;

       END IF;
    END IF ;

    -- We Have the query in PLSQL table now Find out the length of the query
    -- And decide if it is Native sql or DBMS SQL
    FOR i in l_workbook_sql.first..l_workbook_sql.last
    LOOP
       l_tmp_size := lengthb(l_workbook_sql(i)) ;
       l_size     := l_size + l_tmp_size ;
    END LOOP ;

    IF l_size < l_dbms_size THEN
    AMS_Utility_PVT.debug_message(l_full_name||': DBMS_SQL');

       x_sql_type := 'DBMS' ;
    ELSE
    AMS_Utility_PVT.debug_message(l_full_name||': NATIVE_SQL');

       x_sql_type := 'NATIVE' ;
    END IF;
    x_query    := l_workbook_sql ;

    AMS_Utility_PVT.debug_message(l_full_name||': End');

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
                p_encoded            =>      FND_API.G_FALSE
            );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
                p_encoded            =>      FND_API.G_FALSE
            );


        WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

              IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
                p_encoded            =>      FND_API.G_FALSE
            );

END Validate_Sql ;

/*****************************************************************************/
-- Procedure
--   Refresh_Segment_Size
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the update_segment_size and will return errors if any
--
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
--   06/20/2001      yxliu    moved from package AMS_Cell_PVT
------------------------------------------------------------------------------

PROCEDURE Refresh_Segment_Size
(   errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    p_cell_id     IN     NUMBER DEFAULT NULL
)
IS
   l_return_status    VARCHAR2(1) ;
   l_msg_count        NUMBER ;
   l_msg_data         VARCHAR2(2000);
BEGIN
   FND_MSG_PUB.initialize;
   -- Call the procedure to refresh Segment size
   AMS_Cell_PVT.Update_Segment_Size
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
END Refresh_Segment_Size ;

PROCEDURE write_conc_log
(
        p_text IN VARCHAR2
) IS
BEGIN
  IF G_DEBUG_LEVEL THEN
     Ams_Utility_pvt.Write_Conc_log (p_text);
  END IF;
END write_conc_log;

/*
PROCEDURE write_conc_log(p_text VARCHAR2)
IS
  i   number  := 1;
  j   number;
BEGIN
  ams_utility_pvt.write_conc_log(p_text);

  j := length(p_text);
  while (i <= j) loop
     dbms_output.put_line(substr(p_text, i, 200));
     i := i + 200;
  end loop;

END;
*/


/*****************************************************************************
 * NAME
 *   compose_qualifier_values
 *
 * PURPOSE
 *   This procedure is a private procedure used by get_territory_qualifiers
 *     to compose qualifier expression
 *
 * NOTES
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   05/07/2003      yzhao    SQL bind variable project
 *****************************************************************************/

PROCEDURE compose_qualifier_values
(
      p_value_rec     IN    JTF_TERRITORY_GET_PUB.Terr_Values_Rec_Type,
      p_bindvar_index IN    NUMBER,
      p_bind_vars     IN    BIND_TBL_TYPE,
      x_cond_str      OUT NOCOPY   VARCHAR2,
      x_bind_vars     OUT NOCOPY   BIND_TBL_TYPE
) IS
  l_temp_index          NUMBER;
  l_index               NUMBER;
  l_value_str           VARCHAR2(2000);
  l_bind_vars           BIND_TBL_TYPE;
BEGIN
  l_bind_vars := p_bind_vars;
  l_index := p_bindvar_index + p_bind_vars.COUNT;
  write_conc_log('D: compose_qualifier_values: bindvar_index=' || l_index);
  IF p_value_rec.COMPARISON_OPERATOR = '=' OR
     p_value_rec.COMPARISON_OPERATOR = '<>' OR
     p_value_rec.COMPARISON_OPERATOR = '<' OR
     p_value_rec.COMPARISON_OPERATOR = '>' OR
     p_value_rec.COMPARISON_OPERATOR = 'LIKE' OR
     p_value_rec.COMPARISON_OPERATOR = 'NOT LIKE' THEN
     IF p_value_rec.ID_USED_FLAG = 'Y' THEN
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ' || p_value_rec.LOW_VALUE_CHAR_ID;
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_NUMBER;
        l_bind_vars(l_index).bind_number := p_value_rec.LOW_VALUE_CHAR_ID;
        l_index := l_index + 1;
     ELSE
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ''' || p_value_rec.LOW_VALUE_CHAR || '''';
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.LOW_VALUE_CHAR;
        l_index := l_index + 1;
     END IF;
  ELSIF p_value_rec.COMPARISON_OPERATOR = 'BETWEEN' OR
        p_value_rec.COMPARISON_OPERATOR = 'NOT BETWEEN' THEN
     IF p_value_rec.ID_USED_FLAG = 'N' THEN
        -- l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ''' || p_value_rec.LOW_VALUE_CHAR || ''' AND ''' || p_value_rec.HIGH_VALUE_CHAR || '''';

        l_temp_index := l_index + 1;
/*
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index
                       || ' AND ' || G_BIND_VAR_STRING || l_index + 1;
*/
        l_value_str := p_value_rec.COMPARISON_OPERATOR || G_BIND_VAR_STRING || l_index
                       || ' AND ' || G_BIND_VAR_STRING || l_temp_index ;
        l_bind_vars(l_index).bind_index := l_index;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.LOW_VALUE_CHAR;
        l_index := l_index + 1;
        -- l_bind_vars(l_index).bind_index := l_index + 1;
        l_bind_vars(l_index).bind_index := l_index ;
        l_bind_vars(l_index).bind_type := G_BIND_TYPE_CHAR;
        l_bind_vars(l_index).bind_char := p_value_rec.HIGH_VALUE_CHAR;
        l_index := l_index + 1;
     /*  yzhao: between numbers is not supported? or use LOW_VALUE_NUMBER, HIGH_VALUE_NUMBER?
     ELSE
        l_value_str := p_value_rec.COMPARISON_OPERATOR || ' ' || p_value_rec.LOW_VALUE_CHAR_ID || ' AND ' || p_value_rec.HIGH_VALUE_CHAR_ID;
      */
     END IF;
  END IF;
  x_cond_str := l_value_str;
  x_bind_vars := l_bind_vars;
END compose_qualifier_values;


/*****************************************************************************
 * NAME
 *   get_territory_qualifiers
 *
 * PURPOSE
 *   This procedure is a private procedure called by generate_party_for_territory
 *     to get qualifier information of a territory
 *
 * NOTES
 *   1. currently JTF territory has no public api for getting territory detail information
 *      JTF_TERRITORY_GET_PUB.Get_Territory_Details() is not publicly supported. Change it when api is public
 *   2. I'm concerned about the sql buffer size. As territory qualifier combination grows,
 *      it may exceed the limit?
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   04/09/2003      niprakas Fixed the bug#2833114.
 *****************************************************************************/

PROCEDURE get_territory_qualifiers
(
      p_terr_id             IN    NUMBER,
      p_bindvar_index       IN    NUMBER,
      x_terr_pid            OUT NOCOPY   NUMBER,
      x_terr_child_table    OUT NOCOPY   NUMBER_TBL_TYPE,
      x_hzsql_table         OUT NOCOPY   VARCHAR2_TBL_TYPE,
      x_bind_vars           OUT NOCOPY   BIND_TBL_TYPE
) IS
   l_api_version            CONSTANT NUMBER := 1.0;
   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_tmp_str                VARCHAR2(2000);
   J                        NUMBER;
   l_hzsql_table            VARCHAR2_TBL_TYPE;
   l_terr_qual_id           NUMBER;
   l_terr_rec               JTF_TERRITORY_GET_PUB.Terr_Rec_Type;
   l_terr_type_rec          JTF_TERRITORY_GET_PUB.Terr_Type_Rec_Type;
   l_terr_child_table       JTF_TERRITORY_GET_PUB.Terr_Tbl_Type;
   l_terr_usgs_table        JTF_TERRITORY_GET_PUB.Terr_Usgs_Tbl_Type;
   l_terr_qtype_usgs_table  JTF_TERRITORY_GET_PUB.Terr_QType_Usgs_Tbl_Type;
   l_terr_qual_table        JTF_TERRITORY_GET_PUB.Terr_Qual_Tbl_Type;
   l_terr_values_table      JTF_TERRITORY_GET_PUB.Terr_Values_Tbl_Type;
   l_terr_rsc_table         JTF_TERRITORY_GET_PUB.Terr_Rsc_Tbl_Type;
   -- This one is required ....
   l_hzparty_sql            VARCHAR2(32000) := null;
   l_hzpartyacc_sql         VARCHAR2(32000) := null;
   -- This is required ....
   l_hzpartyrel_sql         VARCHAR2(32000) := null;
   -- This is no more required ...
   --   l_hzpartysite_sql        VARCHAR2(2000) := null;
   l_hzpartysiteuse_sql    VARCHAR2(32000) := null;
   -- This is required ..
   l_hzcustprof_sql         VARCHAR2(32000) := null;
   -- This is new field ...
   l_hzlocations_sql        VARCHAR2(32000) := null;
  /* -- l_hzcustname_sql handles customer name
   l_hzcustname_sql         VARCHAR2(2000) := null;
   -- l_hzcustcat_sql handles the customer category
   l_hzcustcat_sql        VARCHAR2(2000) := null;
   -- l_saleschannel_sql handles the sales channel
   l_hzsaleschannel_sql        VARCHAR2(2000) := null; */
   l_out_child_table        NUMBER_TBL_TYPE;
   l_out_hzsql_table        VARCHAR2_TBL_TYPE;
   l_bind_vars              BIND_TBL_TYPE;
   l_child_bind_vars        BIND_TBL_TYPE;
   l_index                  NUMBER;
BEGIN
   JTF_TERRITORY_GET_PUB.Get_Territory_Details(
            p_Api_Version          => l_api_version,
            p_Init_Msg_List        => FND_API.G_FALSE,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_terr_id              => p_terr_id,
            x_terr_rec             => l_terr_rec,
            x_terr_type_rec        => l_terr_type_rec,
            x_terr_sub_terr_tbl    => l_terr_child_table,
            x_terr_usgs_tbl        => l_terr_usgs_table,
            x_terr_qtype_usgs_tbl  => l_terr_qtype_usgs_table,
            x_terr_qual_tbl        => l_terr_qual_table,
            x_terr_values_tbl      => l_terr_values_table,
            x_terr_rsc_tbl         => l_terr_rsc_table);
   -- dbms_output.put_line('get_territory_details(terr_id=' || p_terr_id || ') returns ' || l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.g_exc_error;
   END IF;

   J := l_terr_values_table.FIRST;
   l_index := p_bindvar_index;
   write_conc_log('D: territory=' || p_terr_id || ' qualifier count=' || l_terr_qual_table.COUNT
                  || ' first=' || NVL(l_terr_qual_table.FIRST, -100) || ' LAST=' || NVL(l_terr_qual_table.LAST, -200));
   FOR I IN NVL(l_terr_qual_table.FIRST, 1) .. NVL(l_terr_qual_table.LAST, 0) LOOP
       /* only processing OFFER's qualifiers at this time
          one qualifier may have multiple values. The relationship is 'OR' between these values
             it is assumed that qualifier table and qualifier value table are of the same order
             for example,  qualifier table          qualifier value table
                              q1                       value1 for q1
                              q2                       value1 for q2
                                                       value2 for q2
                              q3                       value1 for q3
        */
      l_terr_qual_id := l_terr_qual_table(I).TERR_QUAL_ID;
      IF l_terr_qual_table(I).QUALIFIER_TYPE_NAME = 'OFFER' AND
         J <= l_terr_values_table.LAST AND
         l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id THEN

         write_conc_log('D: before compose_qualifier_values(' || I || ') index=' || l_index);
         -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
         compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
         l_bind_vars := l_child_bind_vars;

         IF l_terr_qual_table(I).QUALIFIER_NAME = 'City' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.CITY ' || l_tmp_str;
            J := J + 1;
            write_conc_log('D: In the City ' || l_hzlocations_sql);
            write_conc_log('D: before compose_qualifier_values(' || I || ') index=' || l_index);
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.CITY ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            write_conc_log('D: After the City ' || l_hzlocations_sql);
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'Country' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.COUNTRY ' || l_tmp_str;
            J := J + 1;
            write_conc_log('D: In the country ' || l_hzlocations_sql);
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.COUNTRY ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            write_conc_log('D: After the country ' || l_hzlocations_sql);
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'County' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.COUNTY ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.COUNTY ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';


     ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Customer Category' THEN
               l_hzparty_sql :=    l_hzparty_sql || '(hzp.CATEGORY_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzparty_sql := l_hzparty_sql || ' OR hzp.CATEGORY_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzparty_sql := l_hzparty_sql || ') AND ';

     ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Customer Name' THEN
            l_hzparty_sql := l_hzparty_sql || '(hzp.PARTY_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzparty_sql := l_hzparty_sql || ' OR hzp.PARTY_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzparty_sql := l_hzparty_sql || ') AND ';


         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'Postal Code' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.POSTAL_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.POSTAL_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'Province' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.PROVINCE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.PROVINCE ' || l_terr_values_table(J).COMPARISON_OPERATOR || '''' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'State' THEN
            l_hzlocations_sql := l_hzlocations_sql || '(hzloc.STATE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzlocations_sql := l_hzlocations_sql || ' OR hzloc.STATE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzlocations_sql := l_hzlocations_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Account Classification' THEN
            l_hzpartyacc_sql := l_hzpartyacc_sql || '(hzca.CUSTOMER_CLASS_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql := l_hzpartyacc_sql || ' OR hzca.CUSTOMER_CLASS_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyacc_sql := l_hzpartyacc_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'Sales Channel' THEN
             l_hzpartyacc_sql :=  l_hzpartyacc_sql || '(hzca.SALES_CHANNEL_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql :=  l_hzpartyacc_sql || ' OR hzca.SALES_CHANNEL_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
             l_hzpartyacc_sql :=  l_hzpartyacc_sql || ') AND ';

     ELSIF l_terr_qual_table(I).QUALIFIER_NAME =  'Party Relation' THEN
            l_hzpartyrel_sql := l_hzpartyrel_sql || '(hzpr.RELATIONSHIP_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyrel_sql := l_hzpartyrel_sql || ' OR hzpr.RELATIONSHIP_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyrel_sql := l_hzpartyrel_sql || ') AND ';
          -- 10/25 newly added

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Account Hierarchy' THEN

            l_hzpartyrel_sql := l_hzpartyrel_sql || '(hzpr.OBJECT_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyrel_sql := l_hzpartyrel_sql || ' OR hzpr.OBJECT_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyrel_sql := l_hzpartyrel_sql || ') AND ';

    ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Site Classification' THEN
            l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || '(hzcsua.SITE_USE_CODE ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || ' OR hzcsua.SITE_USE_CODE ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || ') AND ';


         ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Account Code' THEN
            l_hzpartyacc_sql := l_hzpartyacc_sql || '(hzps.PARTY_SITE_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzpartyacc_sql := l_hzpartyacc_sql || ' OR hzps.PARTY_SITE_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzpartyacc_sql := l_hzpartyacc_sql || ') AND ';

         ELSIF l_terr_qual_table(I).QUALIFIER_NAME = 'Customer Profile' THEN
            l_hzcustprof_sql := l_hzcustprof_sql || '(hzcp.PROFILE_CLASS_ID ' || l_tmp_str;
            J := J + 1;
            WHILE (J <= l_terr_values_table.LAST AND l_terr_values_table(J).TERR_QUAL_ID = l_terr_qual_id) LOOP
               -- compose_qualifier_values(l_terr_values_table(J), l_tmp_str);
               compose_qualifier_values( p_value_rec       => l_terr_values_table(J)
                                 , p_bindvar_index   => l_index
                                 , p_bind_vars       => l_bind_vars
                                 , x_cond_str        => l_tmp_str
                                 , x_bind_vars       => l_child_bind_vars
                                 );
               l_bind_vars := l_child_bind_vars;
               l_hzcustprof_sql := l_hzcustprof_sql || ' OR hzcp.PROFILE_CLASS_ID ' || l_tmp_str;
               J := J + 1;
            END LOOP;
            l_hzcustprof_sql := l_hzcustprof_sql || ') AND ';
         END IF;
      END IF;    -- IF qualifier_type_name='OFFER'
      /* to do claim qualifiers: 'Claim Type' 'Claim Class' 'Reasons' 'Vendor'
         add ' AND VENDOR=' to PO_VENDORS, AMS_TRADE_PROFILE sql
       */
   END LOOP;  -- FOR I IN l_terr_qual_table.FIRST .. (l_terr_qual_table.LAST-1) LOOP
   /* It's important to maintain the same order as get_territory_qualifiers() returns */
   J := 1;
   l_out_hzsql_table(J) := l_hzparty_sql;
   --l_out_hzsql_table(J+1) := l_hzpartyacc_sql;
   l_out_hzsql_table(J+1) := l_hzpartyrel_sql;
   -- l_out_hzsql_table(J+3) := l_hzpartysite_sql;
   -- l_out_hzsql_table(J+4) := l_hzpartysiteuse_sql;
   l_out_hzsql_table(J+2) := l_hzcustprof_sql;
   -- l_out_hzsql_table(J+6) := l_hzcustname_sql;
   --  l_out_hzsql_table(J+7) := l_hzcustcat_sql;
   -- l_out_hzsql_table(J+8) := l_hzsaleschannel_sql;
   l_out_hzsql_table(J+3) := l_hzlocations_sql;
   l_out_hzsql_table(J+4) := l_hzpartyacc_sql;
   l_out_hzsql_table(J+5) := l_hzpartysiteuse_sql;
   x_hzsql_table := l_out_hzsql_table;
   FOR J IN l_terr_child_table.FIRST .. (l_terr_child_table.LAST-1) LOOP
      l_out_child_table(J) := l_terr_child_table(J).terr_id;
   END LOOP;
   x_terr_child_table := l_out_child_table;
   x_terr_pid := l_terr_rec.parent_territory_id;
   x_bind_vars := l_bind_vars;
   write_conc_log('get_territory_qualifiers(' || p_terr_id || '): ends  binds=' || l_bind_vars.COUNT);
END get_territory_qualifiers;


/*****************************************************************************
 * NAME
 *   generate_party_for_territory
 *
 * PURPOSE
 *   This procedure is a private procedure used by LOAD_PARTY_MARKET_QUALIFIER
 *     to generate party list for a territory and its children
 *     recusive call
 *
 * NOTES
 *
 * HISTORY
 *   10/14/2001      yzhao    created
 *   04/09/2003      niprakas Fix for the bug#2833114. The dynamic SQL are
 *                   changed. The insert statement for AMS_PARTY_MARKET_SEGMENTS
 *                   is changed. It now inserts cust_account_id,cust_acct_site_id
 *             and cust_site_use_code.
 ******************************************************************************/
PROCEDURE generate_party_for_territory
(     p_errbuf              OUT NOCOPY    VARCHAR2,
      p_retcode             OUT NOCOPY    NUMBER,
      p_terr_id             IN     NUMBER,
      p_getparent_flag      IN     VARCHAR2 := 'N',
      p_bind_vars           IN     BIND_TBL_TYPE,
      p_hzparty_sql         IN     VARCHAR2 := null,
      p_hzpartyacc_sql      IN     VARCHAR2 := null,
      p_hzpartyrel_sql      IN     VARCHAR2 := null,
      -- p_hzpartysite_sql     IN   VARCHAR2 := null,
      p_hzpartysiteuse_sql  IN     VARCHAR2 := null,
      p_hzcustprof_sql      IN     VARCHAR2 := null,
      p_hzlocations_sql     IN     VARCHAR2 := null
      --  p_hzcustname_sql      IN   VARCHAR2 := null,
      --  p_hzcustcat_sql        IN   VARCHAR2 := null,
      --  p_hzsaleschannel_sql  IN   VARCHAR2 := null
)
IS
   l_full_name              CONSTANT VARCHAR2(60) := 'GENERATE_PARTY_FOR_TERRITORY';
   l_err_msg                VARCHAR2(2000);
   /* redefine these buffer sizes so they can fit all qualifier combinations */
   l_final_sql              VARCHAR2(32000);
   l_party_select_sql       VARCHAR2(32000) := null;
   l_party_where_sql        VARCHAR2(32000) := null;
   l_party_join_sql         VARCHAR2(32000) := null;
   l_hzparty_sql            VARCHAR2(32000) := p_hzparty_sql;
   l_hzpartyacc_sql         VARCHAR2(32000) := p_hzpartyacc_sql;
   l_hzpartyrel_sql         VARCHAR2(32000) := p_hzpartyrel_sql;
-- l_hzpartysite_sql        VARCHAR2(10000) := p_hzpartysite_sql;
   l_hzpartysiteuse_sql     VARCHAR2(32000) := p_hzpartysiteuse_sql;
   l_hzcustprof_sql         VARCHAR2(32000) := p_hzcustprof_sql;
   l_hzlocations_sql        VARCHAR2(32000) := p_hzlocations_sql;
 --  l_hzcustname_sql        VARCHAR2(10000) := p_hzcustname_sql;
 --  l_hzcustcat_sql       VARCHAR2(10000) := p_hzcustcat_sql;
  -- l_hzsaleschannel_sql    VARCHAR2(10000) := p_hzsaleschannel_sql;
   l_hzsql_table            VARCHAR2_TBL_TYPE;
   l_terr_id                NUMBER;
   l_terr_pid               NUMBER;
   l_terr_child_table       NUMBER_TBL_TYPE;
   l_tmp_child_table        NUMBER_TBL_TYPE;
   -- TYPE PartyCurTyp         IS REF CURSOR;  -- define weak REF CURSOR type
   -- l_party_cv               PartyCurTyp;    -- declare cursor variable
   l_party_mkt_seg_id       NUMBER;
   l_party_id               NUMBER;
   l_index                  NUMBER;
   l_client_info            NUMBER;
   l_cust_account_id        NUMBER;
   l_cust_acct_site_id      NUMBER;
   l_cust_site_use_code     VARCHAR2(30);
   flag                     VARCHAR2(2) := 'F';
   l_bindvar_index          NUMBER;
   l_bind_vars              BIND_TBL_TYPE;
   l_final_bind_vars        BIND_TBL_TYPE;
   l_denorm_csr             INTEGER;

   /*
   CURSOR c_party_mkt_seg_seq IS            -- generate an ID for INSERT
      SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
      FROM DUAL;
    */
BEGIN
   p_retcode := 0;
   FND_MSG_PUB.initialize;
   Ams_Utility_pvt.Write_Conc_log(l_full_name || ': START for territory ' || p_terr_id);
   l_terr_id := p_terr_id;
   l_client_info := TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'), 1, 10));
   l_final_bind_vars := p_bind_vars;
   LOOP
     l_bindvar_index := l_final_bind_vars.COUNT + 1;
     get_territory_qualifiers
     (
          p_terr_id             => l_terr_id,
          p_bindvar_index       => l_bindvar_index,
          x_terr_pid            => l_terr_pid,
          x_terr_child_table    => l_tmp_child_table,
          x_hzsql_table         => l_hzsql_table,
          x_bind_vars           => l_bind_vars
     );
     write_conc_log(l_full_name || ' after get_territory_qualifiers(terr_id=' || l_terr_id || ') bindvar_count=' || l_bind_vars.count);
     /* it's important to be of exactly the same order as get_territory_qualifiers() returns */

     l_index := 1;
     l_hzparty_sql := l_hzparty_sql || l_hzsql_table(l_index);

     l_hzpartyrel_sql := l_hzpartyrel_sql || l_hzsql_table(l_index+1);
    -- l_hzpartysite_sql := l_hzpartysite_sql || l_hzsql_table(l_index+3);

     l_hzcustprof_sql := l_hzcustprof_sql || l_hzsql_table(l_index+2);
     l_hzlocations_sql := l_hzlocations_sql || l_hzsql_table(l_index+3);
     l_hzpartyacc_sql := l_hzpartyacc_sql || l_hzsql_table(l_index+4);
     l_hzpartysiteuse_sql := l_hzpartysiteuse_sql || l_hzsql_table(l_index+5);


     write_conc_log(' l_hzparty_sql  ' || l_hzparty_sql);
     --    write_conc_log('l_hzcustname_sql   '  || l_hzcustname_sql);
     --    write_conc_log(' l_hzcustcat_sql  ' ||l_hzcustcat_sql);
     write_conc_log(' l_hzpartyacc_sql   ' ||l_hzpartyacc_sql);
     --    write_conc_log(' l_hzpartyacc_sql   ' || l_hzpartyacc_sql);
     --    write_conc_log(' l_hzsaleschannel_sql  ' || l_hzsaleschannel_sql);
     write_conc_log('   l_hzpartyrel_sql  ' ||   l_hzpartyrel_sql);
     -- write_conc_log('   l_hzpartysite_sql ' ||    l_hzpartysite_sql);
     write_conc_log('   l_hzpartysiteuse_sql ' ||   l_hzpartysiteuse_sql);
     write_conc_log(' l_hzcustprof_sql  ' || l_hzcustprof_sql);
     write_conc_log(' l_hzlocations_sql  ' || l_hzlocations_sql);

    -- l_hzcustname_sql := l_hzcustname_sql || l_hzsql_table(l_index+6);
    -- l_hzcustcat_sql :=  l_hzcustcat_sql || l_hzsql_table(l_index+7) ;
    -- l_hzsaleschannel_sql := l_hzsaleschannel_sql || l_hzsql_table(l_index+8);

     -- yzhao: 05/08/2003 append this node's bind variable
     l_index := l_final_bind_vars.COUNT + 1;
     FOR i IN NVL(l_bind_vars.FIRST, 1) .. NVL(l_bind_vars.LAST, 0) LOOP
       l_final_bind_vars(l_index) := l_bind_vars(i);
       l_index := l_index + 1;
     END LOOP;
     l_bindvar_index := l_index;

     -- remember the current node's children for later recursion
     IF (p_terr_id = l_terr_id) THEN
         l_terr_child_table := l_tmp_child_table;
     END IF;
     -- get the territory ancestors's qualifier information if it's required and if it is not root territory
     IF (p_getparent_flag = 'N' OR l_terr_pid = 1) THEN
         EXIT;
     END IF;
     l_terr_id := l_terr_pid;
   END LOOP;



   IF l_hzparty_sql IS NOT NULL THEN
      l_party_select_sql := 'select DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id,hzcsua.site_use_code';
      l_party_select_sql := l_party_select_sql || ' from  hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa,hz_cust_accounts hzca, ';
      l_party_select_sql := l_party_select_sql || ' hz_party_sites hzps, hz_locations hzloc, hz_parties hzp ' ;
      l_party_where_sql := ' WHERE ' ;
      l_party_where_sql :=  l_party_where_sql || ' hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'')';
      l_party_where_sql :=  l_party_where_sql  || ' AND hzcsua.status = ''A'' and hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id';
      l_party_where_sql :=  l_party_where_sql  || ' AND hzcasa.cust_account_id = hzca.cust_account_id AND ' ;
      l_party_where_sql :=  l_party_where_sql || ' hzcasa.party_site_id = hzps.party_site_id AND hzps.location_id = hzloc.location_id ';

      l_party_where_sql := l_party_where_sql || ' AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
      l_party_where_sql := l_party_where_sql || ' AND hzca.party_id = hzp.party_id and ' || l_hzparty_sql;
      write_conc_log('l_hzparty_sql ' || l_party_select_sql || l_party_where_sql);
      flag := 'T';

   END IF;




    IF l_hzpartysiteuse_sql IS NOT NULL THEN
    IF l_party_select_sql IS NULL THEN
     l_party_select_sql := 'SELECT DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id, hzcsua.site_use_code ' ;
     l_party_select_sql := l_party_select_sql || ' FROM hz_cust_accounts hzca, hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa ';
     l_party_where_sql := ' WHERE ' ;
     l_party_where_sql :=  l_party_where_sql || '( hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') OR ';
     l_party_where_sql :=  l_party_where_sql || substr(l_hzpartysiteuse_sql, 1, length(l_hzpartysiteuse_sql)-4) || ') AND ' ;
     l_party_where_sql :=  l_party_where_sql || 'hzcsua.status = ''A'' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id AND ' ;
     l_party_where_sql :=  l_party_where_sql || ' hzcasa.cust_account_id = hzca.cust_account_id AND ';
      write_conc_log('IF l_hzpartysiteuse_sql ' || l_party_select_sql || l_party_where_sql);
    ELSE
          l_party_where_sql := null;
          l_party_where_sql := ' WHERE ' ;
      l_party_where_sql :=  l_party_where_sql || ' ( hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') OR ';
      l_party_where_sql :=  l_party_where_sql || substr(l_hzpartysiteuse_sql, 1, length(l_hzpartysiteuse_sql)-4) || ') AND ' ;
          l_party_where_sql :=  l_party_where_sql  || ' hzcsua.status = ''A'' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
      l_party_where_sql :=  l_party_where_sql  || 'AND hzcasa.cust_account_id = hzca.cust_account_id AND ';
      l_party_where_sql :=  l_party_where_sql  || 'hzcasa.party_site_id = hzps.party_site_id AND hzps.location_id = hzloc.location_id ';
          l_party_where_sql := l_party_where_sql || ' AND hzcasa.cust_account_id = hzca.cust_account_id ' ;
          l_party_where_sql := l_party_where_sql || ' AND hzca.party_id = hzp.party_id AND ' || l_hzparty_sql;
       write_conc_log('Else  l_hzpartysiteuse_sql ' || l_party_select_sql || l_party_where_sql);


    END IF;
    END IF;



  IF l_hzpartyacc_sql IS NOT NULL THEN
      IF l_party_select_sql IS NULL THEN
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id, hzcsua.site_use_code FROM ';
         l_party_select_sql := l_party_select_sql || 'hz_cust_accounts hzca, hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa, ';
         l_party_select_sql := l_party_select_sql || ' hz_party_sites hzps ';
         l_party_where_sql := ' WHERE ' ;
         l_party_where_sql :=  l_party_where_sql || '  hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'')';
         -- For the Account Classification
         l_party_where_sql := l_party_where_sql || ' AND hzcsua.status = ''A'' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql := l_party_where_sql || 'AND hzcasa.cust_account_id = hzca.cust_account_id AND ' ||  l_hzpartyacc_sql;
         write_conc_log('IF  l_hzpartyacc_sql ' || l_party_select_sql || l_party_where_sql);

      ELSE
        -- l_party_select_sql := l_party_select_sql || ', hz_cust_accounts hzca';
        --  l_party_where_sql := l_party_where_sql || 'hzca.party_id AND ' || l_hzpartyacc_sql;
        IF (flag = 'F') THEN
            l_party_select_sql := l_party_select_sql || ' ,hz_party_sites hzps ';
        END IF;
        l_party_where_sql := l_party_where_sql || l_hzpartyacc_sql;
        write_conc_log('ELSE  l_hzpartyacc_sql ' || l_party_select_sql || l_party_where_sql);
      END IF;
   END IF;




   IF l_hzpartyrel_sql IS NOT NULL THEN
      IF l_party_select_sql IS NULL THEN
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id,hzcsua.site_use_code from ';
         l_party_select_sql := l_party_select_sql || ' hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa, hz_cust_accounts hzca, ';
         l_party_select_sql := l_party_select_sql || ' hz_relationships hzpr ';
         l_party_where_sql := ' WHERE ' ;
         l_party_where_sql :=  l_party_where_sql || ' hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'')';
         l_party_where_sql := l_party_where_sql || ' AND hzcsua.status = ''A'' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql := l_party_where_sql || ' AND hzcasa.cust_account_id = hzca.cust_account_id AND hzpr.subject_id = hzca.party_id ';
         l_party_where_sql := l_party_where_sql || '  AND hzpr.start_date <= SYSDATE AND NVL(hzpr.end_date, SYSDATE) >= SYSDATE ';
         l_party_where_sql := l_party_where_sql || ' AND hzpr.relationship_code = ''SUBSIDIARY_OF'' ' ;
         l_party_where_sql := l_party_where_sql || ' AND hzpr.status = ''A'' AND ' || l_hzpartyrel_sql;
         write_conc_log('IF l_hzpartyrel_sql ' || l_party_select_sql || l_party_where_sql);

      ELSE
         l_party_select_sql := l_party_select_sql || ', hz_relationships hzpr';
         l_party_where_sql := l_party_where_sql || ' hzpr.subject_id = hzca.party_id AND hzpr.start_date <= SYSDATE ' ;
         l_party_where_sql := l_party_where_sql || ' AND NVL(hzpr.end_date, SYSDATE) >= SYSDATE ' ;
         l_party_where_sql := l_party_where_sql || ' AND hzpr.relationship_code = ''SUBSIDIARY_OFF'' ';
         l_party_where_sql := l_party_where_sql || ' AND hzpr.status = ''A'' AND ' || l_hzpartyrel_sql;
         write_conc_log('Else l_hzpartyrel_sql ' || l_party_select_sql || l_party_where_sql);

      END IF;
   END IF;



   /* it is important to check l_hzcustprof_sql AFTER l_hzpartyacc_sql
      so table hz_cust_accounts does not show twice
    */
    IF l_hzcustprof_sql IS NOT NULL THEN
      IF l_party_select_sql IS NULL THEN
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id, ';
         l_party_select_sql := l_party_select_sql || ' hzcsua.site_use_code FROM hz_cust_accounts hzca, hz_cust_site_uses_all hzcsua, ';
         l_party_select_sql := l_party_select_sql || ' hz_cust_acct_sites_all hzcasa, hz_customer_profiles hzcp';
         l_party_where_sql := ' WHERE ' || l_hzcustprof_sql;
         l_party_where_sql :=  l_party_where_sql || ' hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'')';
         l_party_where_sql :=  l_party_where_sql || 'AND hzcsua.status = ''A'' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql :=  l_party_where_sql || ' AND hzcasa.cust_account_id = hzca.cust_account_id AND ';
         l_party_where_sql :=  l_party_where_sql || ' hzca.cust_account_id = hzcp.cust_account_id AND ';
         write_conc_log(' If l_hzcustprof_sql  ' || l_party_select_sql || l_party_where_sql);
      ELSE
         IF l_hzpartyacc_sql IS NOT NULL THEN
            l_party_select_sql := l_party_select_sql || ', hz_customer_profiles hzcp';
            l_party_where_sql := l_party_where_sql || ' hzca.cust_account_id = hzcp.cust_account_id AND ' || l_hzcustprof_sql;
            write_conc_log(' If Else If l_hzcustprof_sql  ' || l_party_select_sql || l_party_where_sql);
         ELSE
            l_party_select_sql := l_party_select_sql || ', hz_customer_profiles hzcp ';
           -- l_party_where_sql := l_party_where_sql || l_party_join_sql || 'hzca.party_id AND hzca.cust_account_id = hzcp.cust_account_id AND ' || l_hzcustprof_sql;
            l_party_where_sql := l_party_where_sql || '  hzca.cust_account_id = hzcp.cust_account_id AND ' || l_hzcustprof_sql;
            write_conc_log(' If Else else l_hzcustprof_sql  ' || l_party_select_sql || l_party_where_sql);
        END IF;
      END IF;
   END IF;


   IF l_hzlocations_sql IS NOT NULL THEN

      IF l_party_select_sql IS NULL THEN
         l_party_select_sql := 'SELECT DISTINCT hzca.party_id, hzca.cust_account_id, hzcsua.cust_acct_site_id,hzcsua.site_use_code ';
         l_party_select_sql := l_party_select_sql || ' from hz_cust_site_uses_all hzcsua, hz_cust_acct_sites_all hzcasa, hz_cust_accounts hzca, ';
         l_party_select_sql := l_party_select_sql || ' hz_relationships hzpr, hz_party_sites hzps, hz_locations hzloc ';
         l_party_where_sql := ' WHERE ' || l_hzlocations_sql;
         l_party_where_sql :=  l_party_where_sql || ' hzcsua.site_use_code in (''BILL_TO'',''SHIP_TO'') and hzcsua.status = ''A'' ';
         l_party_where_sql :=  l_party_where_sql || ' AND hzcsua.cust_acct_site_id = hzcasa.cust_acct_site_id ';
         l_party_where_sql :=  l_party_where_sql || ' AND hzcasa.cust_account_id = hzca.cust_account_id AND ' ;
         l_party_where_sql :=  l_party_where_sql || ' hzcasa.party_site_id = hzps.party_site_id AND hzps.location_id = hzloc.location_id AND' ;
         write_conc_log(' If l_hzloactions_sql  ' || l_party_select_sql || l_party_where_sql);

      ELSE
        -- l_party_select_sql := l_party_select_sql || ', hz_party_sites hzps, hz_locations hzloc';
         IF(flag = 'F') THEN
         l_party_select_sql := l_party_select_sql || ', hz_locations hzloc, hz_party_sites hzps ';
         END IF;
         l_party_where_sql := l_party_where_sql || ' hzcasa.party_site_id = hzps.party_site_id AND hzps.location_id = hzloc.location_id  AND ';
         l_party_where_sql := l_party_where_sql || l_hzlocations_sql;
         write_conc_log(' Else l_hzloactions_sql  ' || l_party_select_sql || l_party_where_sql);

      END IF;
   END IF;
   /*
   DBMS_OUTPUT.PUT_LINE(' final from sql(' || length(l_party_select_sql) || '): ' || l_party_select_sql);
   DBMS_OUTPUT.PUT_LINE(' final where sql length=' || length(l_party_where_sql));
   l_index := 1;
   WHILE l_index < (length(l_party_where_sql)-4) LOOP
      DBMS_OUTPUT.PUT_LINE( substr(l_party_where_sql, l_index, 240));
      l_index := l_index + 240;
   END LOOP;
   */
   DELETE FROM AMS_PARTY_MARKET_SEGMENTS
     WHERE market_qualifier_type = 'TERRITORY'
     AND   market_qualifier_reference = p_terr_id;
   -- remove 'AND ' at the end of the where clause
   --      write_conc_log('Before opening the cursor ');
   write_conc_log('D: The dynamic SQL '  || l_party_select_sql ||substr(l_party_where_sql, 1, length(l_party_where_sql)-4));


   IF l_party_select_sql IS NOT NULL THEN
      -- yzhao: 05/08/2003 SQL bind variable project
      l_final_sql := 'INSERT INTO AMS_PARTY_MARKET_SEGMENTS(ams_party_market_segment_id, last_update_date, last_updated_by';
      l_final_sql := l_final_sql || ', creation_date, created_by, last_update_login, object_version_number, market_segment_id';
      l_final_sql := l_final_sql || ', market_segment_flag, party_id, start_date_active, end_date_active, org_id';
      l_final_sql := l_final_sql || ', market_qualifier_type, market_qualifier_reference, cust_account_id, cust_acct_site_id, site_use_code)';
      l_final_sql := l_final_sql || ' SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL, SYSDATE, FND_GLOBAL.user_id';
      l_final_sql := l_final_sql || ', SYSDATE, FND_GLOBAL.user_id, FND_GLOBAL.conc_login_id, 1, 0';
      l_final_sql := l_final_sql || ', ''N'', party_id, SYSDATE, NULL, :org_id org_id';
      l_final_sql := l_final_sql || ', ''TERRITORY'', :terr_id market_qualifier_reference, cust_account_id, cust_acct_site_id, site_use_code FROM (';
      l_final_sql := l_final_sql ||  l_party_select_sql || substr(l_party_where_sql, 1, length(l_party_where_sql)-4) || ')';
      l_denorm_csr := DBMS_SQL.open_cursor;

      DBMS_SQL.parse(l_denorm_csr, l_final_sql, DBMS_SQL.native);
      DBMS_SQL.BIND_VARIABLE (l_denorm_csr, ':org_id', l_client_info);
      DBMS_SQL.BIND_VARIABLE (l_denorm_csr, ':terr_id', p_terr_id);
      FOR i IN NVL(l_final_bind_vars.FIRST, 1) .. NVL(l_final_bind_vars.LAST, 0) LOOP
        write_conc_log('D: bind vars ' || i || ' index=' || l_final_bind_vars(i).bind_index
               || ' type=' || l_final_bind_vars(i).bind_type );
        IF l_final_bind_vars(i).bind_type = G_BIND_TYPE_CHAR THEN
           write_conc_log('D: bind vars ' || i || ' char=' || l_final_bind_vars(i).bind_char);
           DBMS_SQL.BIND_VARIABLE (l_denorm_csr, G_BIND_VAR_STRING || l_final_bind_vars(i).bind_index, l_final_bind_vars(i).bind_char);
        ELSIF l_final_bind_vars(i).bind_type = G_BIND_TYPE_NUMBER THEN
           write_conc_log('D: bind vars ' || i || ' number=' || l_final_bind_vars(i).bind_number);
           DBMS_SQL.BIND_VARIABLE (l_denorm_csr, G_BIND_VAR_STRING || l_final_bind_vars(i).bind_index, l_final_bind_vars(i).bind_number);
        END IF;
      END LOOP;

      l_index := dbms_sql.execute(l_denorm_csr);
      write_conc_log('D: After executing ');
      dbms_sql.close_cursor(l_denorm_csr);
        /*
             OPEN l_party_cv FOR l_party_select_sql || substr(l_party_where_sql, 1, length(l_party_where_sql)-4);
             LOOP
                FETCH l_party_cv INTO l_party_id,l_cust_account_id,l_cust_acct_site_id,l_cust_site_use_code;
                write_conc_log('l_party_id '  || l_party_id);
                write_conc_log('l_cust_account_id '  || l_cust_account_id);
                write_conc_log('l_cust_acct_site_id ' || l_cust_acct_site_id);
                write_conc_log('l_cust_site_use_code ' || l_cust_site_use_code);
                EXIT WHEN l_party_cv%NOTFOUND;
                -- dbms_output.put_line(l_full_name || ': INSERT: party_id=' || l_party_id || ' territory_id=' || p_terr_id);
           OPEN c_party_mkt_seg_seq;
           FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id;
           CLOSE c_party_mkt_seg_seq;

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
               , market_qualifier_type
               , market_qualifier_reference
               , cust_account_id
               , cust_acct_site_id
               , site_use_code
           )
           VALUES
           (
                 l_party_mkt_seg_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , FND_GLOBAL.conc_login_id
               , 1
               , 0
               , 'N'
               , l_party_id
               , SYSDATE
               , NULL
               , l_client_info
               , 'TERRITORY'
               , p_terr_id
               ,l_cust_account_id
               ,l_cust_acct_site_id
               ,l_cust_site_use_code
           );
           END LOOP;
           CLOSE l_party_cv;
            */

   END IF;


   Ams_Utility_pvt.Write_Conc_log(l_full_name || ': Success for territory ' || p_terr_id);

   /* recursively generate party list for the territory's children
      passing in parent's qualifier directly so don't need to calculate again
    */
   l_index := l_terr_child_table.FIRST;
   WHILE l_index IS NOT NULL LOOP
       generate_party_for_territory
       (  p_errbuf              => p_errbuf
        , p_retcode             => p_retcode
        , p_terr_id             => l_terr_child_table(l_index)
        , p_getparent_flag      => 'N'
        , p_bind_vars           => l_final_bind_vars
        , p_hzparty_sql         => l_hzparty_sql
        , p_hzpartyacc_sql      => l_hzpartyacc_sql
        , p_hzpartyrel_sql      => l_hzpartyrel_sql
        -- , p_hzpartysite_sql     => l_hzpartysite_sql
        , p_hzpartysiteuse_sql  => l_hzpartysiteuse_sql
        , p_hzcustprof_sql      => l_hzcustprof_sql
          --, p_hzcustname_sql      => l_hzcustname_sql
        --, p_hzcustcat_sql       => l_hzcustcat_sql
        --, p_hzsaleschannel_sql  => l_hzsaleschannel_sql
        , p_hzlocations_sql  => l_hzlocations_sql
       );
       l_index := l_terr_child_table.NEXT(l_index);
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
   /* Let the master procdure handle exception */
   Ams_Utility_pvt.Write_Conc_log('Exception in get_party_territory ' || sqlerrm);
      p_retcode := 1;
      l_err_msg := 'Exception while generating parties for territory id=' || p_terr_id || ' - ' || sqlerrm;
      p_errbuf := l_err_msg;
      raise;
END generate_party_for_territory;


/*****************************************************************************
 * NAME
 *   generate_party_for_buyinggroup
 *
 * PURPOSE
 *   This procedure is a private procedure used by LOAD_PARTY_MARKET_QUALIFIER
 *     to generate buying groups information
 *
 * NOTES
 *
 * HISTORY
 *   11/09/2001      yzhao    created
 *   02/07/2003      yzhao    to handle non-directional relationship like 'PARTNER_OF',
 *                            add directional_flag in c_get_object_ids
 ******************************************************************************/
PROCEDURE generate_party_for_buyinggroup
(         p_errbuf       OUT NOCOPY    VARCHAR2,
          p_retcode      OUT NOCOPY    NUMBER,
          p_bg_id        IN     NUMBER,
          p_direction    IN     VARCHAR2    := NULL,
          p_obj_list     OUT NOCOPY    NUMBER_TBL_TYPE
)
IS
   l_full_name              CONSTANT VARCHAR2(60) := 'generate_party_for_buyinggroup';
   l_err_msg                VARCHAR2(2000);
   l_obj_list               NUMBER_TBL_TYPE;
   l_child_obj_list         NUMBER_TBL_TYPE;
   l_all_obj_list           NUMBER_TBL_TYPE;
   l_party_mkt_seg_id       NUMBER_TBL_TYPE;
   l_client_info            NUMBER;
   l_index                  NUMBER;

   CURSOR c_get_object_ids IS
      SELECT subject_id
      FROM   hz_relationships
      WHERE  relationship_code = fnd_profile.VALUE('AMS_PARTY_RELATIONS_TYPE')
      AND    subject_type = 'ORGANIZATION'
      AND    subject_table_name = 'HZ_PARTIES'
      AND    object_type = 'ORGANIZATION'
      AND    object_table_name = 'HZ_PARTIES'
      AND    start_date <= SYSDATE AND NVL(end_date, SYSDATE) >= SYSDATE
      AND    status = 'A'
      AND    object_id = p_bg_id
      /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI */
      AND    directional_flag = NVL(p_direction, directional_flag);

   CURSOR c_party_mkt_seg_seq IS                     -- generate an ID
      SELECT AMS_PARTY_MARKET_SEGMENTS_S.NEXTVAL
      FROM DUAL;

BEGIN
   Ams_Utility_pvt.Write_Conc_log(l_full_name || ': Start buyinggroup_id=' || p_bg_id);
   p_errbuf := null;
   p_retcode := 0;

   -- delete all buying group records for this subject_id
   DELETE FROM AMS_PARTY_MARKET_SEGMENTS
   WHERE  market_qualifier_type = 'BG'
   AND    market_qualifier_reference = p_bg_id;

   l_client_info := TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10));
   OPEN c_party_mkt_seg_seq;
   FETCH c_party_mkt_seg_seq INTO l_index;
   CLOSE c_party_mkt_seg_seq;

   -- 03/26/2002 always return the party itself as part of the buying group
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
           , market_qualifier_type
           , market_qualifier_reference
   )
   VALUES
   (
             l_index
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , 0
           , 'N'
           , p_bg_id
           , SYSDATE
           , NULL
           , l_client_info
           , 'BG'
           , p_bg_id
   );

   OPEN c_get_object_ids;
   FETCH c_get_object_ids BULK COLLECT INTO l_obj_list;
   CLOSE c_get_object_ids;

   -- dbms_output.put_line('buy(' || p_bg_id || '): object count=' || l_obj_list.count);

   IF l_obj_list.count = 0 THEN
      -- return. Leaf node.
      p_obj_list := l_obj_list;
      Ams_Utility_pvt.Write_Conc_log(l_full_name || ': END buyinggroup_id=' || p_bg_id);
      return;
   END IF;

   FOR I IN l_obj_list.FIRST .. l_obj_list.LAST LOOP
       OPEN c_party_mkt_seg_seq;
       FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(I);
       CLOSE c_party_mkt_seg_seq;
   END LOOP;

   l_all_obj_list := l_obj_list;
   l_index := l_all_obj_list.LAST;
   -- get buying groups for all subject_ids of p_bg_id
   FOR I IN l_obj_list.FIRST .. l_obj_list.LAST LOOP
      generate_party_for_buyinggroup
      (   p_errbuf       => p_errbuf,
          p_retcode      => p_retcode,
          p_bg_id        => l_obj_list(I),
          p_direction    => p_direction,
          p_obj_list     => l_child_obj_list
      );

      -- append l_child_obj_list to l_all_obj_list
      IF l_child_obj_list.COUNT > 0 THEN
         FOR J IN l_child_obj_list.FIRST .. l_child_obj_list.LAST LOOP
             l_index := l_index + 1;
             l_all_obj_list(l_index) := l_child_obj_list(J);
             OPEN c_party_mkt_seg_seq;
             FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(l_index);
             CLOSE c_party_mkt_seg_seq;
         END LOOP;
      END IF;
   END LOOP;
   -- DBMS_OUTPUT.PUT_LINE(l_full_name || ': INSERT buying group: buyinggroup_id='
   --        || p_bg_id || ' count=' || l_all_obj_list.COUNT);

   FORALL I IN l_all_obj_list.FIRST .. l_all_obj_list.LAST
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
           , market_qualifier_type
           , market_qualifier_reference
       )
       VALUES
       (
             l_party_mkt_seg_id(I)
           , SYSDATE
           , FND_GLOBAL.user_id
           , SYSDATE
           , FND_GLOBAL.user_id
           , FND_GLOBAL.conc_login_id
           , 1
           , 0
           , 'N'
           , l_all_obj_list(I)
           , SYSDATE
           , NULL
           , l_client_info
           , 'BG'
           , p_bg_id
       );

   /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
             for non-directional records, always insert a row pair of (A, B) and (B, A) */
   IF (p_direction IS NOT NULL AND l_all_obj_list.FIRST IS NOT NULL) THEN

       FOR I IN l_all_obj_list.FIRST .. l_all_obj_list.LAST LOOP
           OPEN c_party_mkt_seg_seq;
           FETCH c_party_mkt_seg_seq INTO l_party_mkt_seg_id(I);
           CLOSE c_party_mkt_seg_seq;
       END LOOP;

       FORALL I IN l_all_obj_list.FIRST .. l_all_obj_list.LAST
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
               , market_qualifier_type
               , market_qualifier_reference
           )
           VALUES
           (
                 l_party_mkt_seg_id(I)
               , SYSDATE
               , FND_GLOBAL.user_id
               , SYSDATE
               , FND_GLOBAL.user_id
               , FND_GLOBAL.conc_login_id
               , 1
               , 0
               , 'N'
               , p_bg_id
               , SYSDATE
               , NULL
               , l_client_info
               , 'BG'
               , l_all_obj_list(I)
           );
   END IF;

   p_obj_list := l_all_obj_list;
   Ams_Utility_pvt.Write_Conc_log(l_full_name || ': END buyinggroup_id=' || p_bg_id);

EXCEPTION
  WHEN OTHERS THEN
    /* Let the master procdure handle exception */
    p_retcode := 1;
    l_err_msg := 'Exception while generating buying group buyinggroup_id=' || p_bg_id || ' - ' || sqlerrm;
    p_errbuf := l_err_msg;
    -- dbms_output.put_line('Exception: ' || substr(l_err_msg, 1, 220));
    RAISE;
END;


/*****************************************************************************
 * NAME
 *   LOAD_PARTY_MARKET_QUALIFIER
 *
 * PURPOSE
 *   This procedure is a concurrent program to
 *     generate buying groups recursively
 *     generate party list that matches a given territory's qualifiers
 *     it also recursively generates party list for the territory's children
 *
 * NOTES
 *
 * HISTORY
 *   10/04/2001      yzhao    created
 *   11/14/2001      yzhao    add buying group
 ******************************************************************************/

PROCEDURE LOAD_PARTY_MARKET_QUALIFIER
(         errbuf        OUT NOCOPY    VARCHAR2,
          retcode       OUT NOCOPY    NUMBER,
          p_terr_id     IN     NUMBER := NULL,
          p_bg_id       IN     NUMBER := NULL
)
IS
  l_full_name              CONSTANT VARCHAR2(60) := 'LOAD_PARTY_FOR_MARKET_QUALIFIERS';
  l_terr_id                NUMBER;
  l_bg_id                  NUMBER;
  l_rel_profile            VARCHAR2(30);
  l_rel_type               VARCHAR2(30);
  l_obj_list               NUMBER_TBL_TYPE;
  l_direction_code         VARCHAR2(1);
  l_bind_vars              BIND_TBL_TYPE;

  CURSOR c_get_all_territories IS                -- get all root territories of trade management
      /*
      SELECT distinct terr_id
      FROM   jtf_terr_overview_v jtov
      WHERE  jtov.source_id = -1003
      AND    parent_territory_id = 1;
      */
  -- Fix for the bug#3158378
     select distinct JTR.terr_id
     FROM JTF_TERR_ALL JTR ,
     JTF_TERR_USGS_ALL JTU ,
     JTF_SOURCES_ALL JSE
     WHERE
     JTU.TERR_ID = JTR.TERR_ID
     AND JTU.SOURCE_ID = JSE.SOURCE_ID
     AND JTU.SOURCE_ID = -1003
     AND JTR.PARENT_TERRITORY_ID = 1
     AND NVL(JTR.ORG_ID, -99) = NVL(JTU.ORG_ID, NVL(JTR.ORG_ID, -99))
     AND JSE.ORG_ID IS NULL
     AND NVL(JTR.ORG_ID, NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ' ,
     NULL, SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)) =
     NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',
     NULL, SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99);

  CURSOR c_get_relationship_type(p_relationship_code VARCHAR2) IS
     SELECT relationship_type, direction_code
     FROM   hz_relationship_types
     WHERE (forward_rel_code = p_relationship_code
       OR   backward_rel_code = p_relationship_code)
     AND    subject_type = 'ORGANIZATION'
     AND    object_type = 'ORGANIZATION'
     /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
            P - Parent  C - Child   N - non-directional
            e.g. 'PARTNER_OF' is non-directional relationship
     AND    direction_code = 'P'
      */
     AND    direction_code IN ('P', 'N')
     AND    status = 'A';

  /* yzhao: 08/07/2002 fix performance issue. Use index on relationship_type */
  CURSOR c_get_all_bgroots(p_relationship_code VARCHAR2, p_relationship_type VARCHAR2, p_direction_code VARCHAR2) IS
  -- get all root object_ids
      SELECT distinct r1.object_id
      FROM   hz_relationships r1
      WHERE  r1.relationship_type = p_relationship_type
      AND    r1.relationship_code = p_relationship_code
      AND    r1.subject_type = 'ORGANIZATION'
      AND    r1.subject_table_name = 'HZ_PARTIES'
      AND    r1.object_type = 'ORGANIZATION'
      AND    r1.object_table_name = 'HZ_PARTIES'
      AND    r1.start_date <= SYSDATE AND NVL(r1.end_date, SYSDATE) >= SYSDATE
      AND    r1.status = 'A'
      /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF
       */
      AND    r1.directional_flag = NVL(p_direction_code, r1.directional_flag)
      AND    NOT EXISTS
            (SELECT 1
             FROM   hz_relationships r2
             WHERE  r1.object_id = r2.subject_id
             AND    r2.relationship_type = p_relationship_type
             AND    r2.relationship_code = p_relationship_code
             AND    r2.subject_type = 'ORGANIZATION'
             AND    r2.subject_table_name = 'HZ_PARTIES'
             AND    r2.object_type = 'ORGANIZATION'
             AND    r2.object_table_name = 'HZ_PARTIES'
             AND    r2.start_date <= SYSDATE AND NVL(r2.end_date, SYSDATE) >= SYSDATE
             AND    r2.status = 'A'
             /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                    handle non-directional relationship e.g. PARTNER_OF
              */
             AND    r2.directional_flag = NVL(p_direction_code, r2.directional_flag)
            );

BEGIN
  Ams_Utility_pvt.Write_Conc_log(l_full_name || ': Start ');
  -- SAVEPOINT LOAD_PARTY_MARKET_QUALIFIER;

  errbuf := null;
  retcode := 0;

  /* yzhao: 08/07/2002 fix bug 2503141 performance issue. Use index on relationship_type */
  l_direction_code := NULL;
  l_rel_profile :=  fnd_profile.VALUE('AMS_PARTY_RELATIONS_TYPE');
  OPEN c_get_relationship_type(l_rel_profile);
  FETCH c_get_relationship_type INTO l_rel_type, l_direction_code;
  CLOSE c_get_relationship_type;

  IF p_bg_id IS NOT NULL THEN
     IF (l_direction_code = 'N') THEN
         /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF, so search forward and backward relationship
          */
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => 'F',
                                        p_obj_list     => l_obj_list);
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => 'B',
                                        p_obj_list     => l_obj_list);
     ELSE
         generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                        p_retcode      => retcode,
                                        p_bg_id        => p_bg_id,
                                        p_direction    => NULL,
                                        p_obj_list     => l_obj_list);
     END IF;
  ELSE
     -- no buying group id parameter means generate party pair list for all buying groups
     DELETE FROM AMS_PARTY_MARKET_SEGMENTS
     WHERE  market_qualifier_type = 'BG';

     IF (l_direction_code = 'N') THEN
         /* yzhao: fix bug 2789492 - MKTF1R9:1159.0203:FUNC-BUDGET WITH MARKET ELIGIBILITY BUYING GROUP DOES NOT VALI
                handle non-directional relationship e.g. PARTNER_OF, so search forward and backward relationship
          */
         l_direction_code := 'F';
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
           -- dbms_output.put_line('root: id= ' || l_bg_id || ' forward count=' || l_obj_list.count);
         END LOOP;
         CLOSE c_get_all_bgroots;

         l_direction_code := 'B';
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
           -- dbms_output.put_line('root: id= ' || l_bg_id || ' backward count=' || l_obj_list.count);
         END LOOP;
         CLOSE c_get_all_bgroots;
      ELSE
         l_direction_code := NULL;
         OPEN c_get_all_bgroots(l_rel_profile, l_rel_type, l_direction_code);
         LOOP
           FETCH c_get_all_bgroots INTO l_bg_id;
           EXIT WHEN c_get_all_bgroots%NOTFOUND;
           generate_party_for_buyinggroup(p_errbuf       => errbuf,
                                          p_retcode      => retcode,
                                          p_bg_id        => l_bg_id,
                                          p_direction    => l_direction_code,
                                          p_obj_list     => l_obj_list);
         END LOOP;
         CLOSE c_get_all_bgroots;
      END IF;
  END IF;

  --
  COMMIT;
  --
  Ams_Utility_pvt.Write_Conc_log(' ----- ');
  Ams_Utility_pvt.Write_Conc_log(l_full_name || ': Committed Buying Groups');
  Ams_Utility_pvt.Write_Conc_log(' ----- ');

  IF p_terr_id IS NOT NULL THEN
     generate_party_for_territory(errbuf, retcode, p_terr_id, 'Y', l_bind_vars);
  ELSE
     -- no territory id parameter means generate party list for all territories
     DELETE FROM AMS_PARTY_MARKET_SEGMENTS
     WHERE market_qualifier_type = 'TERRITORY';
     OPEN c_get_all_territories;
     LOOP
       FETCH c_get_all_territories INTO l_terr_id;
       EXIT WHEN c_get_all_territories%NOTFOUND;
       generate_party_for_territory(errbuf, retcode, l_terr_id, 'N', l_bind_vars);
     END LOOP;
     CLOSE c_get_all_territories;
  END IF;

  Ams_Utility_pvt.Write_Conc_log;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK TO LOAD_PARTY_MARKET_QUALIFIER;
    retcode := 1;
    Ams_Utility_pvt.Write_Conc_log(l_full_name || ': Exception ' || sqlerrm);
    Ams_Utility_pvt.Write_Conc_log;
END LOAD_PARTY_MARKET_QUALIFIER;


END AMS_Party_Mkt_Seg_Loader_PVT;

/
