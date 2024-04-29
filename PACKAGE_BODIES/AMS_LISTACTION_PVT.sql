--------------------------------------------------------
--  DDL for Package Body AMS_LISTACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTACTION_PVT" as
/* $Header: amsvlsab.pls 120.3 2006/04/28 03:59:39 bmuthukr ship $ */
------------------------------------------------------------------
--             Copyright (c) 1999 Oracle Corporation            --
--                Redwood Shores, California, USA               --
--                     All rights reserved.                     --
------------------------------------------------------------------
-- Start of Comments
--
-- PACKAGE
--   AMS_ListAction_PVT

--   Procedures:

--   Create_ListAction
--   Update_ListAction
--   Delete_ListAction
--   Lock_ListAction
--   Validate_ListAction

--   check_action_req_items
--   check_action_uk_items
--   check_action_fk_items
--   check_action_lookup_items
--
--   check_action_items
--   check_action_record
--   complete_action_rec
--   init_action_rec
-- HISTORY
-- 19-Apr-2001 choang   Excluded MODL and SCOR from rank validation
-- 13-Sep-2001 choang   Modified validation of ARC_INCL_OBJECT_FROM to use
--                      AMS_DM_SOURCE_TYPE for lookup validation if the
--                      arc used by is MODL or SCOR.
-- 14-Oct-2002 nyostos  Added callout to Model/Score code to INVALIDATE
--                      Model/Scoring Run when list select actions records
--                      are added, deleted or updated.

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ListAction_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvlsab.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);


---------------------------------------------------------------------
-- PROCEDURE
--    check_list_action_changes
--
-- HISTORY
--    14-Oct-2002  nyostos  Check if the list select action has changed
--                          and then make a callout to Model/Score code
--                          to Invalidate if appropraite.
---------------------------------------------------------------------
PROCEDURE check_list_action_changes(
   p_action_rec     IN  action_rec_type,
   x_rec_changed    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_action_record
--
-- HISTORY
--    01/22/2001  vbhandar  modified to check whether action is INCLUDE
--                           for the lowest order number.
---------------------------------------------------------------------
PROCEDURE check_action_record(
   p_action_rec     IN  action_rec_type,
   p_complete_rec   IN  action_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   --Checking that the same incl_object_name and arc_incl_object_from
   --is not included more than once in the set of list actions.

   Cursor C_Is_Source_Unique IS
   SELECT count(*)
   FROM   ams_list_select_actions
   WHERE  action_used_by_id      = p_action_rec.action_used_by_id
   AND    arc_action_used_by     = p_action_rec.arc_action_used_by
   AND    list_select_action_id <> p_action_rec.list_select_action_id
   AND    incl_object_id         =  p_action_rec.incl_object_id
   AND    arc_incl_object_from   = p_action_rec.arc_incl_object_from;

    --stores the result of C_Is_Source_Unique cursor.
   l_source_count number;

    --Checking that the same order number does not exist among the set of list actions for the list.
    Cursor C_Is_Ord_No_Unique Is
    SELECT Count(*)
    FROM   ams_list_select_actions
    WHERE  action_used_by_id     =  p_action_rec.action_used_by_id
    AND    arc_action_used_by    =  p_action_rec.arc_action_used_by
    AND    list_select_action_id <> p_action_rec.list_select_action_id
    AND    order_number          =  p_action_rec.order_number;

    --stores the result of the C_Is_Ord_No_Unique cursor.
    l_ord_no_count number;


    --Getting The Count of Actions excluding the current one for this list.
    Cursor C_Actions_Exist IS
    SELECT count(*)
    FROM   ams_list_select_actions
    WHERE  action_used_by_id = p_action_rec.action_used_by_id
    AND    arc_action_used_by    =  p_action_rec.arc_action_used_by
    AND    list_select_action_id <> p_action_rec.list_select_action_id;


    l_min_Order number;
    cursor c_min_order is
    SELECT nvl(Min(order_number),-1)
    FROM   ams_list_select_actions
    WHERE  action_used_by_id     = p_action_rec.action_used_by_id
    AND    arc_action_used_by    = p_action_rec.arc_action_used_by
    AND    list_select_action_id <> p_action_rec.list_select_action_id;

    --Getting list select action type where order num is min .
    Cursor C_Min_List_Selection_Type IS
    SELECT list_action_type
    FROM   ams_list_select_actions
    WHERE  action_used_by_id     = p_action_rec.action_used_by_id
    AND    arc_action_used_by    = p_action_rec.arc_action_used_by
    and    order_number = l_min_order;
    l_action_type varchar2(30);

    --stores the count of C_Actions_Exist
    l_action_count number;


BEGIN
   x_return_status := FND_API.g_ret_sts_success;
    --getting the count of actions for the list.
   open   c_actions_exist;
   fetch  c_actions_exist into l_action_count;
   close  c_actions_exist;

  IF  p_action_rec.ORDER_NUMBER <> FND_API.G_MISS_NUM
  AND p_action_rec.ORDER_NUMBER IS NOT NULL THEN
    IF(l_action_count >0 ) THEN
      open  c_is_ord_no_unique;
      fetch c_is_ord_no_unique into l_ord_no_count;
      close  c_is_ord_no_unique;

      IF(l_ord_no_count > 0 ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_BAD_ORD_NUM');
          FND_MSG_PUB.Add;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;
       -- If any errors happen abort API/Procedure.
       RAISE FND_API.G_EXC_ERROR;

     ELSE
       x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;
   ELSE
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;
   END IF;

   --checking that the action with lowest order number is INCLUDE
   open   c_min_order;
   fetch  c_min_order into l_min_Order;
   close  c_min_order;

   if (l_min_Order <> -1 ) and  (l_min_Order < p_action_rec.order_number ) then
      OPEN  C_Min_List_Selection_Type;
      FETCH C_Min_List_Selection_Type INTO l_action_type;
      CLOSE C_Min_List_Selection_Type;
   else
      l_action_type := p_action_rec.list_action_type;
   end if;
   IF  l_action_type <> FND_API.G_MISS_CHAR
   AND l_action_type IS NOT NULL THEN
      IF(l_action_type <>'INCLUDE')THEN
         IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_FIRST_INCLUDE');
             FND_MSG_PUB.Add;
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
      END IF;   --end if l_action_type <>'INCLUDE'
   END IF;-- end  IF  l_action_type <> FND_API.G_MISS_CHAR

   --checking that the same action source is not included more than once in the list.
   IF ( p_action_rec.ARC_INCL_OBJECT_FROM <> FND_API.G_MISS_CHAR AND p_action_rec.ARC_INCL_OBJECT_FROM IS NOT NULL)
   AND
      ( p_action_rec.INCL_OBJECT_ID <> FND_API.G_MISS_NUM AND p_action_rec.INCL_OBJECT_ID IS NOT NULL )  THEN

          IF(l_action_count >0 ) THEN
             OPEN c_is_source_unique;
             FETCH  c_is_source_unique into l_source_count;
             CLOSE  c_is_source_unique;

             IF(l_source_count = 0 )THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
             ELSE
                -- Error, check the msg level and added an error message to the
                -- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DUPE_ACTION');
                   FND_MESSAGE.set_token('ACT_SOURCE', p_action_rec.arc_incl_object_from ||'-->'|| p_action_rec.incl_object_id );
                   FND_MSG_PUB.Add;
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;
                -- If any errors happen abort API/Procedure.
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          ELSE
             x_return_status := FND_API.G_RET_STS_SUCCESS;
          END IF;
   END IF;

   IF(p_action_rec.DISTRIBUTION_PCT IS NOT NULL AND p_action_rec.DISTRIBUTION_PCT <> FND_API.G_MISS_NUM )  THEN
      IF (p_action_rec.DISTRIBUTION_PCT > 100 )THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DIST_PCT_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_action_rec.DISTRIBUTION_PCT <= 0 )THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DIST_PCT_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

  IF(p_action_rec.list_action_type  <> 'INCLUDE' )  THEN
     IF(p_action_rec.DISTRIBUTION_PCT IS NOT NULL AND p_action_rec.DISTRIBUTION_PCT <> FND_API.G_MISS_NUM )  THEN
           FND_MESSAGE.set_name('AMS', 'AMS_DIST_PCT_NULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;


   -- do other record level checkings

END check_action_record;



---------------------------------------------------------------------
-- PROCEDURE
--    check_action_uk_items
--
-- HISTORY
--    10/14/99  tdonohoe  Created.
--    01/22/01  vbhandar  modified to change list header id to action
--                        used by id and arc action used by
--                        check uniqueness of rank
---------------------------------------------------------------------
PROCEDURE check_action_uk_items(
   p_action_rec      IN  action_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   -- For create_action, when action_id is passed in, we need to
   -- check if this action_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_action_rec.list_select_action_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
          'ams_list_select_actions',
           'list_select_action_id = ' || p_action_rec.list_select_action_id
             ) = FND_API.g_false
          THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DUPE_ACTION');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

   IF  p_validation_mode = JTF_PLSQL_API.g_create
   AND p_action_rec.order_number IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
             'ams_list_select_actions',
                'order_number = ' || p_action_rec.order_number||
                ' and action_used_by_id = '||p_action_rec.action_used_by_id
                ||' and arc_action_used_by = '||p_action_rec.arc_action_used_by
                        ) = FND_API.g_false
      THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_BAD_ORD_NUM');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

   IF  p_validation_mode = JTF_PLSQL_API.g_create
   AND p_action_rec.rank IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
                      'ams_list_select_actions',
                          'rank = ' || p_action_rec.rank||
                          ' and action_used_by_id = '||
                            p_action_rec.action_used_by_id
                           ||' and arc_action_used_by = '||
                            p_action_rec.arc_action_used_by
                        ) = FND_API.g_false
      THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_RANK_NUM');
             FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

END check_action_uk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_action_fk_items
--
-- HISTORY
--    10/14/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_action_fk_items(
   p_action_rec       IN action_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

 l_arc_incl_object_from   varchar2(30);
 l_table_name varchar2(100);
 l_pk_name    varchar2(100);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_action_rec.arc_action_used_by <> FND_API.g_miss_char THEN

      AMS_Utility_PVT.get_qual_table_name_and_pk(
      p_sys_qual        => p_action_rec.arc_action_used_by,
      x_return_status   => x_return_status,
      x_table_name      => l_table_name,
      x_pk_name         => l_pk_name
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
      END IF;

      IF p_action_rec.action_used_by_id <> FND_API.g_miss_num THEN
         IF ( AMS_Utility_PVT.Check_FK_Exists(l_table_name
                                              , l_pk_name
                                              , p_action_rec.action_used_by_id)
                                              = FND_API.G_TRUE)
         THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

         ELSE
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_LIST_ID_MISSING');
                       FND_MSG_PUB.Add;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
         END IF; -- end AMS_Utility_PVT.Check_FK_Exists
      END IF; -- end p_action_rec.action_used_by_id
   END IF; --end p_action_rec.arc_action_used_by <> FND_API.g_miss_char

   IF p_action_rec.arc_incl_object_from <> FND_API.g_miss_char THEN

      if p_action_rec.arc_incl_object_from = 'STANDARD' then
         l_arc_incl_object_from   :=  'LIST';
      elsif p_action_rec.arc_incl_object_from = 'MANUAL' then
         l_arc_incl_object_from   :=  'LIST';
      else
         l_arc_incl_object_from   :=  p_action_rec.arc_incl_object_from;
      end if;
      AMS_Utility_PVT.get_qual_table_name_and_pk(
      p_sys_qual        => l_arc_incl_object_from,
      x_return_status   => x_return_status,
      x_table_name      => l_table_name,
      x_pk_name         => l_pk_name
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
      END IF;

      IF  p_action_rec.incl_object_id <> FND_API.g_miss_num THEN
         IF ( AMS_Utility_PVT.Check_FK_Exists(l_table_name
                                              , l_pk_name
                                              , p_action_rec.incl_object_id)
                                              = FND_API.G_TRUE)
         THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

         ELSE
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_SRC_INVALID');
                       FND_MESSAGE.set_token('LIST_SOURCE', p_action_rec.arc_incl_object_from ||'-->'|| p_action_rec.incl_object_id );
                       FND_MSG_PUB.Add;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
         END IF; -- end AMS_Utility_PVT.Check_FK_Exists
      END IF; --  p_action_rec.incl_object_id <> FND_API.g_miss_num
    END IF; --end p_action_rec.arc_incl_object_from <> FND_API.g_miss_char
   -- check other fk items
END check_action_fk_items;

PROCEDURE check_action_other_items(
   p_action_rec       IN action_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

 l_table_name varchar2(100);
 l_pk_name    varchar2(100);

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_action_rec.order_number <> FND_API.g_miss_num  THEN
      if p_action_rec.order_number < 1 then
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ORDER_NUMBER_RANK');
         FND_MESSAGE.set_token('FIELD', 'ORDER_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;
      if trunc(p_action_rec.order_number) <> p_action_rec.order_number then
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ORDER_NUMBER_RANK');
         FND_MESSAGE.set_token('FIELD', 'ORDER_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;

   END IF;


   IF p_action_rec.rank <> FND_API.g_miss_num AND p_action_rec.arc_action_used_by NOT IN ('MODL', 'SCOR') THEN
      if p_action_rec.rank < 1 then
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ORDER_NUMBER_RANK');
         FND_MESSAGE.set_token('FIELD', 'RANK');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;
      if trunc(p_action_rec.rank) <> p_action_rec.rank then
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ORDER_NUMBER_RANK');
         FND_MESSAGE.set_token('FIELD', 'RANK');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;

   END IF;

   IF (p_action_rec.list_action_type = 'INCLUDE' AND p_action_rec.arc_action_used_by NOT IN ('MODL', 'SCOR')) THEN
      IF (p_action_rec.rank = FND_API.g_miss_num  ) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_RANK_MISSING');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;
      IF (p_action_rec.rank is null ) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_RANK_MISSING');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         return ;
      end if;


   END IF;

   IF p_action_rec.incl_control_group <> FND_API.g_miss_char
     AND p_action_rec.incl_control_group IS NOT NULL THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_action_rec.incl_control_group) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_BAD_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- check other other items
END check_action_other_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_action_lookup_items
--
-- HISTORY
--    10/14/99  tdonohoe  Created.
--    01/22/01  vbhandar  check lookup for AMS_SELECT_ACTION_USED_BY
---------------------------------------------------------------------
PROCEDURE check_action_lookup_items(
   p_action_rec       IN action_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

    ----------------------- arc_action_used_by  ------------------------
   IF p_action_rec.arc_action_used_by <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_SELECT_ACTION_USED_BY',
            p_lookup_code => p_action_rec.arc_action_used_by
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACTION_USEDBY_INVALID');
            FND_MESSAGE.set_token('ACTION_USED_BY', p_action_rec.arc_action_used_by);
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- list_action_type ------------------------
   IF p_action_rec.list_action_type <> FND_API.g_miss_char THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_LIST_SELECT_ACTION',
            p_lookup_code => p_action_rec.list_action_type
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_BAD_TYPE');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- arc_incl_object_type  ------------------------
   IF p_action_rec.arc_incl_object_from <> FND_API.g_miss_char THEN
      IF p_action_rec.arc_action_used_by NOT IN ('MODL', 'SCOR') THEN
         IF AMS_Utility_PVT.check_lookup_exists(
               p_lookup_type => 'AMS_LIST_SELECT_TYPE',
               p_lookup_code => p_action_rec.arc_incl_object_from
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_SRC_INVALID');
               FND_MESSAGE.set_token('LIST_SOURCE', p_action_rec.arc_incl_object_from);
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      ELSE  -- use different lookup for model and score
         -- CSCH included in the lookup breaks the rendering
         -- of the loyalty selection screen.
         IF p_action_rec.arc_incl_object_from <> 'CSCH' THEN
            IF AMS_Utility_PVT.check_lookup_exists(
                  p_lookup_type => 'AMS_DM_SOURCE_TYPE',
                  p_lookup_code => p_action_rec.arc_incl_object_from
               ) = FND_API.g_false
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_SRC_INVALID');
                  FND_MESSAGE.set_token('LIST_SOURCE', p_action_rec.arc_incl_object_from);
                  FND_MSG_PUB.add;
               END IF;

               x_return_status := FND_API.g_ret_sts_error;
            END IF;
         END IF;
      END IF;
   END IF;



   -- check other lookup codes

END check_action_lookup_items;


-- Start of Comments
--
-- NAME
--   check_action_req_items
--
-- PURPOSE
--   This procedure is to check required parameters that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/13/1999    tdonohoe   created
--   01/22/2001    vbhandar   modified
--                            check for action_used_by_id instead of list header id
--                            check for arc_action_used_by
--                            remove incl_object_name as required column
-- End of Comments
PROCEDURE check_action_req_items
( p_action_rec              IN     action_rec_type,
  x_return_status           OUT NOCOPY    VARCHAR2
) IS

BEGIN
        --Initialize API/Procedure return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_action_rec.arc_action_used_by IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_ACTION_USEDBY_MISSING');
              FND_MSG_PUB.Add;
           END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              return;
        END IF;

        IF (p_action_rec.action_used_by_id IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_USEDBY_ID_MISSING');
              FND_MSG_PUB.Add;
           END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              return;
        END IF;

        IF (p_action_rec.order_number IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ACT_ORDNO_MISSING');
                         FND_MSG_PUB.Add;
           END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              return;
        END IF;

        IF (p_action_rec.list_action_type IS NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ACT_TYPE_MISSING');
             FND_MSG_PUB.Add;
          END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             return;
        END IF;

    --    IF(p_action_rec.incl_object_name IS NULL) THEN
    --      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    --         FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ACT_SRC_NAME_MISSING');
    --         FND_MSG_PUB.Add;
    --      END IF;
    --         x_return_status := FND_API.G_RET_STS_ERROR;
    --         return;
    --    END IF;

        IF (p_action_rec.arc_incl_object_from IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ARC_INCLUDE_FROM');
                          FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
        END IF;

        IF (p_action_rec.incl_object_id IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ARC_INCLUDE_FROM_ID');
                          FND_MSG_PUB.Add;
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
        END IF;


        EXCEPTION
        WHEN OTHERS THEN
           NULL;

END check_action_req_items;



---------------------------------------------------------------------
-- PROCEDURE
--    check_action_items
--
-- HISTORY
--    10/14/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_action_items(
   p_action_rec      IN  action_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_action_req_items(
      p_action_rec       => p_action_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   check_action_lookup_items(
      p_action_rec        => p_action_rec,
      x_return_status   => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_action_fk_items(
      p_action_rec       => p_action_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_action_other_items(
      p_action_rec       => p_action_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_action_uk_items(
      p_action_rec        => p_action_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;



END check_action_items;


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListAction
--
-- PURPOSE
--    Validate a List Action.
--
-- PARAMETERS
--    p_action_rec: the list action record to be validated
--
-- NOTES
--    1. p_action_rec should be the complete list action record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Validate_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     action_rec_type
) IS

     l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_ListAction';
     l_api_version         CONSTANT NUMBER        := 1.0;

     -- Status Local Variables
     l_return_status                VARCHAR2(1);  -- Return value from procedures




BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

        -- Debug Message
   /* ckapoor IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
   THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListAction_Record: Start', TRUE);
      FND_MSG_PUB.Add;
   END IF; */

         IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message(l_api_name||': Start ');
      END IF;



   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ---------------------- validate ------------------------
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_action_items(
         p_action_rec        => p_action_rec,
         p_validation_mode   => JTF_PLSQL_API.g_create,
         x_return_status     => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_action_record(
         p_action_rec     => p_action_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF(p_action_rec.DISTRIBUTION_PCT IS NOT NULL) THEN
      IF (p_action_rec.DISTRIBUTION_PCT > 100 )THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DIST_PCT_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_action_rec.DISTRIBUTION_PCT <= 0 )THEN
           FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_DIST_PCT_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


   -- Success Message
   -- MMSG
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
   THEN
        FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
	-- bmuthukr changes for bug 5185128. Implemented changes as suggested in bug 5191606.
        -- FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListAction_Record', TRUE);
	FND_MESSAGE.Set_Token('ROW', 'AMS_ListHeader_PVT.Validate_ListAction_Record', FALSE);
        FND_MSG_PUB.Add;
   END IF;


/* ckapoor   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
   THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW',
                    'AMS_ListHeader_PVT.Validate_ListAction_Record: END', TRUE);
        FND_MSG_PUB.Add;
   END IF; */


      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message(l_api_name||': End ');
      END IF;


   -- Standard call to get message count AND IF count is 1, get message info.
   FND_MSG_PUB.Count_AND_Get
   ( p_count           =>      x_msg_count,
     p_data            =>      x_msg_data,
     p_encoded         =>      FND_API.G_FALSE
   );



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
       );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data,
        p_encoded         =>      FND_API.G_FALSE
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
        p_encoded     =>      FND_API.G_FALSE
      );

END Validate_ListAction;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_ListAction
--
-- PURPOSE
--    Create a new List Select Action.
--
-- PARAMETERS
--    p_action_rec: the new record to be inserted
--    x_action_id: return the campaign_id of the new campaign
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If action_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If action_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     action_rec_type,
  x_action_id                            OUT NOCOPY    NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_action_rec                   action_rec_type := p_action_rec;

        l_list_select_action_id       AMS_LIST_SELECT_ACTIONS.list_select_action_id%TYPE;
        l_action_count  number;

        l_sqlerrm varchar2(600);
        l_sqlcode varchar2(100);

        CURSOR c_action_seq IS
        SELECT ams_list_select_actions_s.NEXTVAL
        FROM DUAL;

        CURSOR c_action_count(action_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM ams_list_select_actions
        WHERE list_select_action_id = action_id;

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Create_ListAction_PVT;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

                -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
/*ckapoor        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW','AMS_ListAction_PVT.Create_ListAction: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF; */

                     IF (AMS_DEBUG_HIGH_ON) THEN
	     AMS_Utility_PVT.debug_message(l_api_name||': Start ');
	   END IF;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --
        -- API body
        --

        -- Perform the database operation

        IF l_action_rec.list_select_action_id IS NULL OR
         l_action_rec.list_select_action_id = FND_API.g_miss_num THEN
        LOOP
               OPEN c_action_seq;
               FETCH c_action_seq INTO l_action_rec.list_select_action_id;
               CLOSE c_action_seq;

               OPEN c_action_count(l_action_rec.list_select_action_id);
               FETCH c_action_count INTO l_action_count;
               CLOSE c_action_count;
               EXIT WHEN l_action_count = 0;
        END LOOP;
        END IF;


        Validate_ListAction
        (  p_api_version            => 1.0
          ,p_init_msg_list          => p_init_msg_list
          ,p_validation_level       => p_validation_level
          ,x_return_status          => l_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_action_rec             => l_action_rec
        );


        -- If any errors happen abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;




    INSERT into AMS_LIST_SELECT_ACTIONS
    (LIST_SELECT_ACTION_ID
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN
    ,OBJECT_VERSION_NUMBER
    ,ORDER_NUMBER
    ,LIST_ACTION_TYPE
    --,INCL_OBJECT_NAME
    ,ARC_INCL_OBJECT_FROM
    ,INCL_OBJECT_ID
    --,INCL_OBJECT_WB_SHEET
    --,INCL_OBJECT_WB_OWNER
    --,INCL_OBJECT_CELL_CODE
    ,RANK
    ,NO_OF_ROWS_AVAILABLE
    ,NO_OF_ROWS_REQUESTED
    ,NO_OF_ROWS_USED
    ,DISTRIBUTION_PCT
    ,RESULT_TEXT
    ,DESCRIPTION
    ,ARC_ACTION_USED_BY
    ,ACTION_USED_BY_ID
    , incl_control_group
    ,NO_OF_ROWS_TARGETED
    )

    VALUES
    (  l_action_rec.list_select_action_id

      -- standard who columns
      ,sysdate
      ,FND_GLOBAL.User_Id
      ,sysdate
      ,FND_GLOBAL.User_Id
      ,FND_GLOBAL.Conc_Login_Id
      ,1--object_version_number
      ,l_action_rec.order_number
      ,l_action_rec.list_action_type
     -- ,l_action_rec.incl_object_name
      ,l_action_rec.arc_incl_object_from
      ,l_action_rec.incl_object_id
     -- ,l_action_rec.incl_object_wb_sheet
     -- ,l_action_rec.incl_object_wb_owner
     -- ,l_action_rec.incl_object_cell_code
      ,l_action_rec.rank
      ,NVL(l_action_rec.no_of_rows_available,0)
      ,NVL(l_action_rec.no_of_rows_requested,0)
      ,NVL(l_action_rec.no_of_rows_used,0)
      ,l_action_rec.distribution_pct
      ,l_action_rec.result_text
      ,l_action_rec.description
      ,l_action_rec.arc_action_used_by
      ,l_action_rec.action_used_by_id
      ,l_action_rec.incl_control_group
      ,l_action_rec.no_of_rows_targeted
    );


     -- set OUT value
     x_action_id := l_action_rec.list_select_action_id;


    -- Added by nyostos on Oct 14, 2002
    -- Adding List Select Action record to a Model/Scoring Run data sets
    -- may INVALIDATE the Model if it has already been built or the Scoring
    -- Run if it has already run. Call the appropriate procedure to check.
    IF l_action_rec.arc_action_used_by = 'MODL' THEN
      AMS_DM_MODEL_PVT.handle_data_selection_changes(l_action_rec.action_used_by_id);
    ELSIF l_action_rec.arc_action_used_by = 'SCOR' THEN
      AMS_DM_SCORE_PVT.handle_data_selection_changes(l_action_rec.action_used_by_id);
    END IF;
    -- End of addition by nyostos.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Success Message
    -- MMSG
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Create_ListAction', TRUE);
        FND_MSG_PUB.Add;
    END IF;

    /*ckapoor IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
    THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Create_ListAction: END', TRUE);
        FND_MSG_PUB.Add;
    END IF; */


    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count           =>      x_msg_count,
      p_data            =>      x_msg_data,
      p_encoded         =>      FND_API.G_FALSE
    );

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO Create_ListAction_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;

        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO Create_ListAction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;

        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

     WHEN OTHERS THEN

        ROLLBACK TO Create_ListAction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

END Create_ListAction;

-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Update_ListAction
--
-- PURPOSE
--    Update a List Action.
--
-- PARAMETERS
--    p_action_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Update_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     action_rec_type
) IS

   l_api_name                    CONSTANT VARCHAR2(30)  := 'Update_ListAction';
   l_api_version                 CONSTANT NUMBER        := 1.0;

   -- Status Local Variables
   l_return_status               VARCHAR2(1);  -- Return value from procedures
   l_action_rec                  action_rec_type := p_action_rec;

   l_sqlerrm                     varchar2(600);
   l_sqlcode                     varchar2(100);
   l_rec_changed                 varchar2(1) := 'N';

Begin

   -- Standard Start of API savepoint
   SAVEPOINT Update_ListAction_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  /* ckapoor IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
  THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW','AMS_ListAction_PVT.Update_ListAction: Start', TRUE);
        FND_MSG_PUB.Add;
  END IF; */


  IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message(l_api_name||': Start ');
     END IF;


   init_action_rec(x_action_rec  =>  l_action_rec);
   complete_action_rec(p_action_rec, l_action_rec);

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
  check_action_items(
                      p_action_rec      => l_action_rec,
                      p_validation_mode => JTF_PLSQL_API.g_update,
                      x_return_status   => l_return_status);

  IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
        END IF;
   END IF;


   -- replace g_miss_char/num/date with current column values

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_action_record(
         p_action_rec       => l_action_rec,
         p_complete_rec   => l_action_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   -- Perform the database operation

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
   -------------------------------------------
   -- choang 07-jan-2000
   -- Replace the dbms_output with create_log
   -- due to problem with adchkdrv.
   -------------------------------------------
      AMS_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'LISTACTION',
            p_log_used_by_id  => TO_CHAR(l_action_rec.list_select_action_id),
            p_msg_data => G_PKG_NAME || ' - Update ams_list_actions'
      );

   END IF;

    -- Added by nyostos on Oct 14, 2002
    -- Check if the record has changed before updating and set a flag
    -- that will be used later to make a callout to Model/Score code.
    IF l_action_rec.arc_action_used_by IN ('MODL', 'SCOR') THEN
      l_rec_changed := 'N';
      check_list_action_changes(l_action_rec, l_rec_changed);
    END IF;

    UPDATE ams_list_select_actions
    SET
     last_update_date              = sysdate
    ,last_updated_by               = FND_GLOBAL.User_Id
    ,last_update_login             = FND_GLOBAL.Conc_Login_Id
    ,object_version_number         = l_action_rec.object_version_number + 1
    ,order_number                  = l_action_rec.order_number
    ,list_action_type              = l_action_rec.list_action_type
 --   ,incl_object_name              = l_action_rec.incl_object_name
    ,arc_incl_object_from          = l_action_rec.arc_incl_object_from
    ,incl_object_id                = l_action_rec.incl_object_id
  --  ,incl_object_wb_sheet          = l_action_rec.incl_object_wb_sheet
  -- ,incl_object_wb_owner          = l_action_rec.incl_object_wb_owner
    ,rank                          = l_action_rec.rank
    ,no_of_rows_available          = l_action_rec.no_of_rows_available
    ,no_of_rows_requested          = l_action_rec.no_of_rows_requested
    ,no_of_rows_used               = l_action_rec.no_of_rows_used
    ,distribution_pct              = l_action_rec.distribution_pct
    ,result_text                   = l_action_rec.result_text
    ,description                   = l_action_rec.description
    ,incl_control_group            = l_action_rec.incl_control_group
    ,no_of_rows_targeted           = l_action_rec.no_of_rows_targeted
     WHERE
     list_select_action_id    = l_action_rec.list_select_action_id
     AND
     object_version_number      = l_action_rec.object_version_number;


     IF (SQL%NOTFOUND) THEN
        -- Error, check the msg level and added an error message to the
        -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN -- MMSG
           FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
           FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Update_ListAction API', TRUE);
           FND_MSG_PUB.Add;
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Added by nyostos on Oct 14, 2002
    -- If the Select Action record changed, Call the appropriate Model/Score
    -- procedure to check as this may may INVALIDATE the Model if it has
    -- already been built or the Scoring Run if it has already run.
    IF (l_action_rec.arc_action_used_by IN ('MODL', 'SCOR')) AND l_rec_changed = 'Y' THEN

       IF l_action_rec.arc_action_used_by = 'MODL' THEN
         AMS_DM_MODEL_PVT.handle_data_selection_changes(l_action_rec.action_used_by_id);
       ELSIF l_action_rec.arc_action_used_by = 'SCOR' THEN
         AMS_DM_SCORE_PVT.handle_data_selection_changes(l_action_rec.action_used_by_id);
       END IF;

    END IF;
    -- End of addition by nyostos.


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
      COMMIT WORK;
    END IF;



    -- Success Message
    -- MMSG
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Update_ListAction', TRUE);
      FND_MSG_PUB.Add;
    END IF;


/* ckapoor    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
    THEN
       FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Update_ListAction: END', TRUE);
       FND_MSG_PUB.Add;
    END IF; */


    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_AND_Get
    ( p_count           =>      x_msg_count,
      p_data            =>      x_msg_data,
      p_encoded         =>      FND_API.G_FALSE
    );

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO Update_ListAction_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       l_sqlerrm := SQLERRM;
       l_sqlcode := SQLCODE;
       --dbms_output.put_line('AMS_ListAction_PVT.Update_listaction:'||l_sqlerrm||l_sqlcode);

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO Update_ListAction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;
        --dbms_output.put_line('AMS_ListAction_PVT.Update_listaction:'||l_sqlerrm||l_sqlcode);

        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );


     WHEN OTHERS THEN

        ROLLBACK TO Update_ListAction_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_sqlerrm := SQLERRM;
        l_sqlcode := SQLCODE;
        --dbms_output.put_line('AMS_ListAction_PVT.Update_listaction:'||l_sqlerrm||l_sqlcode);

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

End Update_ListAction;

-- Start of Comments
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListAction
--
-- PURPOSE
--    Delete a List Action.
--
-- PARAMETERS
--    p_action_id:      the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Delete_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                            IN     NUMBER
) IS

        l_api_name                     CONSTANT VARCHAR2(30)  := 'Delete_ListAction';
        l_api_version                  CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_init_action_rec              action_rec_type;
        l_complete_action_rec          action_rec_type;
        l_init_list_header_rec         AMS_ListHeader_PVT.list_header_rec_type;
        l_complete_list_header_rec     AMS_ListHeader_PVT.list_header_rec_type;
  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Delete_ListAction_PVT;

                -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        /* ckapoor IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Delete_ListAction: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF; */

                      IF (AMS_DEBUG_HIGH_ON) THEN
	     AMS_Utility_PVT.debug_message(l_api_name||': Start ');
	   END IF;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Perform the database operation

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
          THEN
               NULL;
                --dbms_output.put_line('AMS_List_SelectAction_PVT - DELETE FROM ams_list_select_actions');
      END IF;

   /*   Delete from ams_list_entries
      where  list_select_action_id =  p_action_id;
    */


     init_action_rec(x_action_rec  =>  l_init_action_rec);
     l_init_action_rec.list_select_action_id :=  p_action_id;

      -- replace g_miss_char/num/date with current column values
     complete_action_rec(l_init_action_rec, l_complete_action_rec);

     IF (l_complete_action_rec.arc_action_used_by='LIST')
     THEN

        AMS_ListHeader_PVT.Init_ListHeader_rec(x_listheader_rec   =>  l_init_list_header_rec);
        l_init_list_header_rec.list_header_id:=l_complete_action_rec.action_used_by_id;

        -- replace g_miss_char/num/date with current column values
        AMS_ListHeader_PVT.Complete_ListHeader_rec(l_init_list_header_rec, l_complete_list_header_rec);

        -- allow delete only if list header status is Draft/ Scheduled/Available/Cancelled
        -- donot allow delete if list header status is generating,locked,archived,expired
        -- call reset_status in listheader pvt this will cancel the workflow and change the staus to draft

        IF (l_complete_list_header_rec.status_code='CANCELLED') OR
            (l_complete_list_header_rec.status_code='DRAFT') OR
            (l_complete_list_header_rec.status_code='AVAILABLE')OR
            (l_complete_list_header_rec.status_code='SCHEDULED')
        THEN
             DELETE FROM ams_list_select_actions
             WHERE  list_select_action_id = p_action_id;

           --  AMS_ListHeader_PVT.Reset_Status(l_complete_list_header_rec.action_used_by_id,)

        ELSIF(l_complete_list_header_rec.status_code='GENERATING') OR
             (l_complete_list_header_rec.status_code='LOCKED') OR
             (l_complete_list_header_rec.status_code='ARCHIVED') OR
             (l_complete_list_header_rec.status_code='EXPIRED')
        THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
              THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACTION_NO_DEL');
                 FND_MSG_PUB.add;
              END IF;

              x_return_status := FND_API.g_ret_sts_error;
              RAISE FND_API.G_EXC_ERROR;
            --  RETURN;
        END IF;

     ELSIF (l_complete_action_rec.arc_action_used_by='MODL')
     THEN

             DELETE FROM ams_list_select_actions
             WHERE  list_select_action_id = p_action_id;

             -- Added on Oct 14, 2002 by nyostos
             -- call the plugin to update the model status
             AMS_DM_MODEL_PVT.handle_data_selection_changes(l_complete_action_rec.action_used_by_id);

     ELSIF (l_complete_action_rec.arc_action_used_by='SCOR')
     THEN
             /* call the plugin to update the model status ??*/
             DELETE FROM ams_list_select_actions
             WHERE  list_select_action_id = p_action_id;

             -- Added on Oct 14, 2002 by nyostos
             -- call the plugin to update the model status
             AMS_DM_SCORE_PVT.handle_data_selection_changes(l_complete_action_rec.action_used_by_id);

     END IF; --l_complete_action_rec.arc_action_used_by='LIST'

     --
     -- END of API body.
     --

      -- Standard check of p_commit.
      IF FND_API.To_Boolean ( p_commit )
      THEN
           COMMIT WORK;
      END IF;

      -- Success Message
      -- MMSG
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
          FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
          FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Delete_ListAction', TRUE);
          FND_MSG_PUB.Add;
      END IF;


   /* ckapoor     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Delete_ListAction: END', TRUE);
            FND_MSG_PUB.Add;
        END IF; */


        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO Delete_ListAction_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                      p_encoded     =>      FND_API.G_FALSE
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO Delete_ListAction_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


        WHEN OTHERS THEN

                ROLLBACK TO Delete_ListAction_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );


END Delete_ListAction;

-- Start of Comments
-------------------------------------------------------------------
-- PROCEDURE
--     Lock_ListAction
--
-- PURPOSE
--    Lock a List Action.
--
-- PARAMETERS
--    p_action_id: the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Lock_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                            IN     NUMBER,
  p_object_version                       IN     NUMBER
) IS


        l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures

        CURSOR c_list_actions IS
        SELECT list_select_action_id
        FROM ams_list_select_actions
        WHERE list_select_action_id = p_action_id
        AND object_version_number = p_object_version
        FOR UPDATE OF list_select_action_id NOWAIT;

        l_list_select_action_id number;

  BEGIN


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;


        -- Debug Message
  /* ckapoor      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
                FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListAction_PVT.Lock_ListAction: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF; */

                  IF (AMS_DEBUG_HIGH_ON) THEN
	     AMS_Utility_PVT.debug_message(l_api_name||': Start ');
   END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_list_actions;
        FETCH c_list_actions INTO l_list_select_action_id;
        IF (c_list_actions%NOTFOUND) THEN
            CLOSE c_list_actions;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
          RAISE FND_API.g_exc_error;
       END IF;
       CLOSE c_list_actions;


        -- Success Message
        -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
                FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
                FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Lock_ListAction', TRUE);
                FND_MSG_PUB.Add;
        END IF;


        /* ckapoor IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH)
        THEN
                FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listheader_PVT.Lock_ListAction: END', TRUE);
            FND_MSG_PUB.Add;
        END IF; */

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count       =>      x_msg_count,
          p_data        =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

        WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN -- MMSG
                        FND_MESSAGE.SET_NAME('AMS','API_RESOURCE_LOCKED');
                        FND_MSG_PUB.Add;
           END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
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
                  p_encoded     =>      FND_API.G_FALSE
                );

END Lock_ListAction;

---------------------------------------------------------------------
-- PROCEDURE
--    init_action_rec
--
-- HISTORY
--    10/01/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE init_action_rec(
   x_action_rec  OUT NOCOPY  action_rec_type
)
IS
BEGIN

  x_action_rec.list_select_action_id := FND_API.g_miss_num;
  x_action_rec.last_update_date      := FND_API.g_miss_date;
  x_action_rec.last_updated_by       := FND_API.g_miss_num;
  x_action_rec.creation_date         := FND_API.g_miss_date;
  x_action_rec.created_by            := FND_API.g_miss_num;
  x_action_rec.last_update_login     := FND_API.g_miss_num;
  x_action_rec.object_version_number := FND_API.g_miss_num;
  x_action_rec.order_number          := FND_API.g_miss_num;
  x_action_rec.list_action_type      := FND_API.g_miss_char;
  x_action_rec.arc_incl_object_from  := FND_API.g_miss_char;
  x_action_rec.incl_object_id        := FND_API.g_miss_num;
/*  x_action_rec.INCL_OBJECT_NAME      := FND_API.g_miss_char;
  x_action_rec.INCL_OBJECT_WB_SHEET  := FND_API.g_miss_char;
  x_action_rec.INCL_OBJECT_WB_OWNER  := FND_API.g_miss_num;
  x_action_rec.INCL_OBJECT_CELL_CODE := FND_API.g_miss_char;
 */
  x_action_rec.rank                  := FND_API.g_miss_num;
  x_action_rec.no_of_rows_available  := FND_API.g_miss_num;
  x_action_rec.no_of_rows_requested  := FND_API.g_miss_num;
  x_action_rec.no_of_rows_used       := FND_API.g_miss_num;
  x_action_rec.distribution_pct      := FND_API.g_miss_num;
  x_action_rec.result_text           := FND_API.g_miss_char;
  x_action_rec.description           := FND_API.g_miss_char;
  x_action_rec.arc_action_used_by        := FND_API.g_miss_char;
  x_action_rec.action_used_by_id     := FND_API.g_miss_num;
  x_action_rec.incl_control_group    := FND_API.g_miss_char;
  x_action_rec.no_of_rows_targeted     := FND_API.g_miss_num;


End Init_Action_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_action_rec
--
-- HISTORY
--    10/01/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE complete_action_rec(
   p_action_rec      IN  action_rec_type,
   x_complete_rec  OUT NOCOPY action_rec_type
)
IS

   CURSOR c_action IS
   SELECT *
   FROM ams_list_select_actions
   WHERE list_select_action_id = p_action_rec.list_select_action_id;

   l_action_rec  c_action%ROWTYPE;

BEGIN

   x_complete_rec := p_action_rec;

   OPEN c_action;
   FETCH c_action INTO l_action_rec;
   IF c_action%NOTFOUND THEN
      CLOSE c_action;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_action;


   IF p_action_rec.list_select_action_id = FND_API.g_miss_num THEN
    x_complete_rec.list_select_action_id   := l_action_rec.list_select_action_id;
   END IF;

   IF p_action_rec.last_update_date = FND_API.g_miss_date THEN
     x_complete_rec.last_update_date        := l_action_rec.last_update_date;
   END IF;

   IF p_action_rec.last_updated_by = FND_API.g_miss_num THEN
     x_complete_rec.last_updated_by         := l_action_rec.last_updated_by;
   END IF;

   IF p_action_rec.creation_date = FND_API.g_miss_date THEN
     x_complete_rec.creation_date           := l_action_rec.creation_date;
   END IF;

   IF p_action_rec.created_by = FND_API.g_miss_num THEN
    x_complete_rec.created_by              := l_action_rec.created_by;
   END IF;

   IF p_action_rec.last_update_login  = FND_API.g_miss_num THEN
    x_complete_rec.last_update_login       := l_action_rec.last_update_login;
   END IF;

   IF p_action_rec.object_version_number = FND_API.g_miss_num THEN
    x_complete_rec.object_version_number   := l_action_rec.object_version_number;
   END IF;


   IF p_action_rec.order_number = FND_API.g_miss_num THEN
     x_complete_rec.order_number            := l_action_rec.order_number;
   END IF;

   IF p_action_rec.list_action_type = FND_API.g_miss_char THEN
    x_complete_rec.list_action_type        := l_action_rec.list_action_type;
   END IF;


   IF p_action_rec.arc_incl_object_from = FND_API.g_miss_char THEN
     x_complete_rec.arc_incl_object_from    := l_action_rec.arc_incl_object_from;
   END IF;

   IF p_action_rec.incl_object_id = FND_API.g_miss_num THEN
    x_complete_rec.incl_object_id          := l_action_rec.incl_object_id;
   END IF;

 /*
   IF p_action_rec.INCL_OBJECT_NAME = FND_API.g_miss_char THEN
    x_complete_rec.INCL_OBJECT_NAME        := l_action_rec.INCL_OBJECT_NAME;
   END IF;

   IF p_action_rec.INCL_OBJECT_WB_SHEET = FND_API.g_miss_char THEN
    x_complete_rec.INCL_OBJECT_WB_SHEET    := l_action_rec.INCL_OBJECT_WB_SHEET;
   END IF;

   IF p_action_rec.INCL_OBJECT_WB_OWNER =  FND_API.g_miss_num THEN
     x_complete_rec.INCL_OBJECT_WB_OWNER    := l_action_rec.INCL_OBJECT_WB_OWNER;
   END IF;

   IF p_action_rec.INCL_OBJECT_CELL_CODE = FND_API.g_miss_char THEN
    x_complete_rec.INCL_OBJECT_CELL_CODE   := l_action_rec.INCL_OBJECT_CELL_CODE;
   END IF;
*/
   IF p_action_rec.rank = FND_API.g_miss_num THEN
    x_complete_rec.rank                    := l_action_rec.rank ;
   END IF;

   IF p_action_rec.no_of_rows_available = FND_API.g_miss_num THEN
    x_complete_rec.no_of_rows_available    := l_action_rec.no_of_rows_available;
   END IF;

   IF p_action_rec.no_of_rows_requested = FND_API.g_miss_num THEN
    x_complete_rec.no_of_rows_requested    := l_action_rec.no_of_rows_requested;
   END IF;

   IF p_action_rec.no_of_rows_used = FND_API.g_miss_num THEN
    x_complete_rec.no_of_rows_used         := l_action_rec.no_of_rows_used;
   END IF;

   IF p_action_rec.distribution_pct = FND_API.g_miss_num THEN
     x_complete_rec.distribution_pct        := l_action_rec.distribution_pct;
   END IF;

   IF p_action_rec.result_text = FND_API.g_miss_char THEN
    x_complete_rec.result_text             := l_action_rec.result_text;
   END IF;

   IF p_action_rec.description = FND_API.g_miss_char THEN
    x_complete_rec.description             := l_action_rec.description;
   END IF;


   IF p_action_rec.arc_action_used_by  =  FND_API.g_miss_char THEN
     x_complete_rec.arc_action_used_by          := l_action_rec.arc_action_used_by;
   END IF;

   IF p_action_rec.action_used_by_id  =  FND_API.g_miss_num THEN
     x_complete_rec.action_used_by_id          := l_action_rec.action_used_by_id;
   END IF;

   IF p_action_rec.incl_control_group=  FND_API.g_miss_char THEN
     x_complete_rec.incl_control_group:= l_action_rec.incl_control_group;
   END IF;
   IF p_action_rec.no_of_rows_targeted  =  FND_API.g_miss_num THEN
     x_complete_rec.no_of_rows_targeted          := l_action_rec.no_of_rows_targeted;
   END IF;


END complete_action_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    check_list_action_changes
--
-- HISTORY
--    14-Oct-2002  nyostos  Check if the list select action has changed
--                          and then make a callout to Model/Score code
--                          to Invalidate if appropraite.
---------------------------------------------------------------------
PROCEDURE check_list_action_changes(
   p_action_rec     IN  action_rec_type,
   x_rec_changed    OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_action IS
   SELECT *
   FROM ams_list_select_actions
   WHERE list_select_action_id = p_action_rec.list_select_action_id;

   l_ref_action            c_action%ROWTYPE;

BEGIN

   -- Initialize record changed flag to 'N'
   x_rec_changed := 'N';

   -- Open cursor to get the reference action record.
   OPEN c_action;
   FETCH c_action INTO l_ref_action;
   CLOSE c_action;

   -- order_number
   IF (l_ref_action.order_number IS NULL AND p_action_rec.order_number IS NOT NULL) OR
      (l_ref_action.order_number <> p_action_rec.order_number) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- list_action_type
   IF (l_ref_action.list_action_type IS NULL AND p_action_rec.list_action_type IS NOT NULL) OR
      (l_ref_action.list_action_type <> p_action_rec.list_action_type) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- arc_incl_object_from
   IF (l_ref_action.arc_incl_object_from IS NULL AND p_action_rec.arc_incl_object_from IS NOT NULL) OR
      (l_ref_action.arc_incl_object_from <> p_action_rec.arc_incl_object_from) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

   -- incl_object_id
   IF (l_ref_action.incl_object_id IS NULL AND p_action_rec.incl_object_id IS NOT NULL) OR
      (l_ref_action.incl_object_id <> p_action_rec.incl_object_id) THEN
      x_rec_changed := 'Y';
      RETURN;
   END IF;

END check_list_action_changes;

END AMS_ListAction_PVT;

/
