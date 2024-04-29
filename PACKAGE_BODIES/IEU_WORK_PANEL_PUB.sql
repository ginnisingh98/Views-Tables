--------------------------------------------------------
--  DDL for Package Body IEU_WORK_PANEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORK_PANEL_PUB" AS
/* $Header: IEUDELB.pls 120.0 2005/06/02 15:46:23 appldev noship $ */

--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteActionPackage
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_action_key     IN   VARCHAR2(32)    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DeleteAction(x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY  VARCHAR2,
                              r_action_key IN ieu_uwq_maction_defs_b.maction_def_key%type)
As
v_cursor1               NUMBER;
v_cursor               NUMBER;
v_numrows1              NUMBER;
sql_stmt             varchar2(2000);
l_property_id ieu_wp_param_props_b.property_id%type;
l_delete_param_property_id IEU_WP_PARAM_PROPS_B.param_property_id%type;
l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
l_enumID  ieu_uwq_sel_enumerators.sel_enum_id%type;
l_applId  ieu_wp_action_maps.application_id%type;
l_panel   ieu_uwq_maction_defs_b.maction_def_type_flag%type;
TYPE c_cursor5 IS REF CURSOR;
c_ref c_cursor5;
-- find enough information for reordering later after delete
CURSOR c_cursor2 is
SELECT DISTINCT a.sel_enum_id, b.application_id, c.maction_def_type_flag
FROM ieu_uwq_sel_enumerators a, ieu_wp_action_maps b, ieu_uwq_maction_defs_b c
WHERE a.enum_type_uuid = b.action_map_code
AND c.maction_def_key = LTRIM(RTRIM(r_action_key))
AND b.action_param_set_id IN (SELECT action_param_set_id
                              FROM ieu_wp_act_param_sets_b
                              WHERE wp_action_def_id  IN (SELECT maction_def_id
                                                            FROM ieu_uwq_maction_defs_b
                                                            WHERE maction_def_key = LTRIM(RTRIM(r_action_key))
                                                            )
                              );

-- this cursor is to find outall action_param_set_id
--which wp_action_def_id is related to x_action_key
cursor c_cursor is
select distinct a.action_param_set_id
from ieu_wp_act_param_sets_b a, ieu_uwq_maction_defs_b b
where b.MACTION_DEF_KEY = LTRIM(RTRIM(r_action_key))
and b.maction_def_id = a.wp_action_def_id;

cursor c_cursor1 is
select maction_def_id
from ieu_uwq_maction_defs_b
where MACTION_DEF_KEY = r_action_key;

begin
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    x_msg_data := '';
    --DBMS_OUTPUT.Put_Line('before cursor loop');
 -- find enumId, applicationId, and panel for
 FOR cur_rec IN c_cursor
    LOOP
    --DBMS_OUTPUT.Put_Line('going to delete action_param_set_id is '||cur_rec.action_param_set_id);
    --v_cursor := DBMS_SQL.OPEN_CURSOR;
      sql_stmt :=' select param_property_id, property_id'||
                 ' from ieu_wp_param_props_b '||
                 ' where action_param_set_id = :id';
   Open c_ref FOR sql_stmt USING cur_rec.action_param_set_id;
   -- DBMS_SQL.parse(v_cursor, sql_stmt, DBMS_SQL.V7);
   -- DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_delete_param_property_id);
   -- DBMS_SQL.DEFINE_COLUMN(v_cursor, 2, l_property_id);
   -- v_numrows1 := DBMS_SQL.EXECUTE(v_cursor);
   --v_numrows1 := DBMS_SQL.FETCH_ROWS(v_cursor);
    LOOP
        --if DBMS_SQL.FETCH_ROWS(v_cursor) = 0 then
        --   exit;
        --end if;
        --DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_delete_param_property_id);
        --DBMS_SQL.COLUMN_VALUE(v_cursor, 2, l_property_id);
        FETCH c_ref INTO l_delete_param_property_id, l_property_id;
        EXIT WHEN c_ref%NOTFOUND;

        select VALUE_TRANSLATABLE_FLAG into l_trans_flag
        from ieu_wp_properties_b
        where property_id = l_property_id;

       if (l_trans_flag = 'Y') then
       delete from ieu_wp_param_props_tl where param_property_id = l_delete_param_property_id;
       --DBMS_OUTPUT.Put_Line(' delete ieu_wp_param_props_tl for id '|| l_delete_param_property_id);
       end if ;

       delete from ieu_wp_param_props_b where param_property_id = l_delete_param_property_id;
       --DBMS_OUTPUT.Put_Line(' delete ieu_wp_param_props_b for id '|| l_delete_param_property_id);

     end LOOP;
    --DBMS_SQL.CLOSE_CURSOR(v_cursor);
    Close c_ref;

    delete from ieu_wp_act_param_sets_b where action_param_set_id = cur_rec.action_param_set_id;
    delete from ieu_wp_act_param_sets_tl where action_param_set_id = cur_rec.action_param_set_id;
    delete from ieu_wp_action_maps where action_param_set_id = cur_rec.action_param_set_id;
    --DBMS_OUTPUT.Put_Line(' delete 3 tables for id '|| cur_rec.action_param_set_id);
 end LOOP;

FOR cur_rec IN c_cursor1
  LOOP
    delete from ieu_uwq_maction_defs_b where maction_def_id = cur_rec.maction_def_id;
    delete from ieu_uwq_maction_defs_tl where maction_def_id = cur_rec.maction_def_id;
--    --DBMS_OUTPUT.Put_Line(' delete 2 tables for id '|| cur_rec.maction_def_id);
    end loop;

 FOR cur_rec IN c_cursor2
  LOOP
       IEU_WP_ACTION_PVT.ReOrdering(x_return_status ,x_msg_count , x_msg_data
            , cur_rec.sel_enum_id, cur_rec.application_id, cur_rec.maction_def_type_flag);
    end loop;
  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
           ROLLBACK;
           x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

commit;
end DeleteAction;
--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteCloneAction
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_Lang    IN  ieu_wp_act_param_sets_tl.language%type Required,
--  r_Action_LABEL IN ieu_wp_act_param_sets_tl.ACTION_PARAM_SET_LABEL%type   Required
--   End of Comments
-- ===============================================================

PROCEDURE DeleteCloneAction (x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY  VARCHAR2,
                              r_Lang    IN  ieu_wp_act_param_sets_tl.language%type,
                              r_Action_Label IN ieu_wp_act_param_sets_tl.ACTION_PARAM_SET_LABEL%type,
                              r_node_id IN ieu_uwq_sel_enumerators.sel_enum_id%type)
As
v_cursor1               NUMBER;
v_cursor               NUMBER;
v_numrows1              NUMBER;
sql_stmt             varchar2(2000);
l_property_id ieu_wp_param_props_b.property_id%type;
l_delete_param_property_id IEU_WP_PARAM_PROPS_B.param_property_id%type;
l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
l_language             VARCHAR2(4);

l_action_param_set_id  IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type;
l_maction_def_id       IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_ID%type;
l_num_map_entries      NUMBER;
l_num_set_entries      NUMBER;
TYPE c_cursor5 IS REF CURSOR;
c_ref c_cursor5;
-- this cursor is to find outall action_param_set_id
--which wp_action_def_id is related to x_action_key
cursor c_cursor is
select  action_param_set_id
from ieu_wp_act_param_sets_tl
where LANGUAGE = r_Lang
      AND ACTION_PARAM_SET_LABEL = LTRIM(RTRIM(r_Action_Label))
      AND action_param_set_id IN (SELECT action_param_set_id
                                  FROM ieu_wp_action_maps
                                  WHERE action_map_code IN (SELECT enum_type_uuid
                                                            FROM ieu_uwq_sel_enumerators
                                                            WHERE sel_enum_id = LTRIM(RTRIM(r_node_id))
                                                            )
                                  );

-- find enough information for reordering later after delete
CURSOR c_cursor2 is
SELECT DISTINCT  b.application_id, c.maction_def_type_flag
FROM ieu_uwq_sel_enumerators a, ieu_wp_action_maps b, ieu_uwq_maction_defs_b c
WHERE a.enum_type_uuid = b.action_map_code
AND a.sel_enum_id = r_node_id
AND c.maction_def_id IN (SELECT wp_action_def_id
                         FROM ieu_wp_act_param_sets_b
                         WHERE action_param_set_id IN (SELECT action_param_set_id
                                                       FROM ieu_wp_act_param_sets_tl
                                                       WHERE action_param_set_label = LTRIM(RTRIM(r_Action_Label))
                                                       AND LANGUAGE = r_Lang
                                                       )
                         )
AND b.action_param_set_id IN (SELECT action_param_set_id
                              FROM ieu_wp_act_param_sets_tl
                              WHERE action_param_set_label = LTRIM(RTRIM(r_Action_Label))
                              );

begin
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    x_msg_data := '';
    --DBMS_OUTPUT.Put_Line('before cursor loop');



 FOR cur_rec IN c_cursor
  LOOP
 --   v_cursor := DBMS_SQL.OPEN_CURSOR;
 --   sql_stmt :=' select param_property_id, property_id'||
 --                ' from ieu_wp_param_props_b '||
 --                ' where action_param_set_id = :id';
    --DBMS_SQL.parse(v_cursor, sql_stmt, DBMS_SQL.V7);
    --DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_delete_param_property_id);
    --DBMS_SQL.DEFINE_COLUMN(v_cursor, 2, l_property_id);
    --v_numrows1 := DBMS_SQL.EXECUTE(v_cursor);
    --v_numrows1 := DBMS_SQL.FETCH_ROWS(v_cursor);
    --DBMS_OUTPUT.Put_Line(' delete record  from ieu_wp_param_props_b for action_param_set_id '||l_temp||', property id is 10003 is '|| v_numrows1 );
 --   OPEN c_ref FOR sql_stmt USING cur_rec.action_param_set_id;
 --   LOOP
 --       FETCH c_ref INTO l_delete_param_property_id, l_property_id;
 --       EXIT WHEN c_ref%NOTFOUND;

        --if DBMS_SQL.FETCH_ROWS(v_cursor) = 0 then
        --   exit;
        --end if;
        --DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_delete_param_property_id);
        --DBMS_SQL.COLUMN_VALUE(v_cursor, 2, l_property_id);

 --      select VALUE_TRANSLATABLE_FLAG into l_trans_flag
 --       from ieu_wp_properties_b
 --       where property_id = l_property_id;
 --       if (l_trans_flag = 'Y') then
 --      delete from ieu_wp_param_props_tl where param_property_id = l_delete_param_property_id;
       --DBMS_OUTPUT.Put_Line(' delete ieu_wp_param_props_tl for id '|| l_delete_param_property_id);
 --      end if ;

 --      delete from ieu_wp_param_props_b where param_property_id = l_delete_param_property_id;
       --DBMS_OUTPUT.Put_Line(' delete ieu_wp_param_props_b for id '|| l_delete_param_property_id);

 --    end LOOP;
    --DBMS_SQL.CLOSE_CURSOR(v_cursor);
 --    Close c_ref;

 --   delete from ieu_wp_act_param_sets_b where action_param_set_id = cur_rec.action_param_set_id;
 --   delete from ieu_wp_act_param_sets_tl where action_param_set_id = cur_rec.action_param_set_id;
 --   delete from ieu_wp_action_maps where action_param_set_id = cur_rec.action_param_set_id;
    --DBMS_OUTPUT.Put_Line(' delete 3 tables for id '|| cur_rec.action_param_set_id);

     --1. determine if this action has 1:1 for action_maps to action_param_sets
  --2. delete from maps
  --3. if 1:1 in 1,
  --a. delete from action_param_sets and param_props

  --1.
  SELECT count(unique(action_map_code))
  INTO l_num_map_entries
  FROM ieu_wp_action_maps
  WHERE action_map_type_code = 'NODE' AND
        action_param_set_id = cur_rec.action_param_set_id;

  --2.
  DELETE FROM ieu_wp_action_maps
  WHERE action_param_set_id = cur_rec.action_param_set_id AND
        action_map_type_code = 'NODE' AND
        action_map_code IN
          (SELECT enum_type_uuid FROM ieu_uwq_sel_enumerators
           WHERE sel_enum_id = r_node_id);

  --3.
  IF (l_num_map_entries = 1) THEN
  --a.
    DELETE FROM ieu_wp_param_props_tl
    WHERE param_property_id IN
            (SELECT param_property_id FROM ieu_wp_param_props_b
             WHERE
             action_param_set_id = cur_rec.action_param_set_id);

    DELETE FROM ieu_wp_param_props_b
    WHERE action_param_set_id = cur_rec.action_param_set_id;

    DELETE FROM ieu_wp_act_param_sets_tl
    WHERE action_param_set_id = cur_rec.action_param_set_id;

    DELETE FROM ieu_wp_act_param_sets_b
    WHERE action_param_set_id = cur_rec.action_param_set_id;
  END if;
 end LOOP;
 FOR cur_rec IN c_cursor2
  LOOP
       IEU_WP_ACTION_PVT.ReOrdering(x_return_status ,x_msg_count , x_msg_data
            , r_node_id, cur_rec.application_id, cur_rec.maction_def_type_flag);
  end loop;
  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
           ROLLBACK;
           x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


commit;
end DeleteCloneAction;

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteParam
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_PARAM_NAME     IN   ieu_wp_param_defs_b.param_id%type    Required
--  r_ACTION_KEY     IN   ieu_uwq_maction_defs-b.maction_def_key%type --- Requried
--   End of Comments
-- ===============================================================

PROCEDURE DeleteActionParam(x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY  NUMBER,
                             x_msg_data  OUT NOCOPY  VARCHAR2,
                            r_PARAM_NAME IN ieu_wp_param_defs_b.param_name%type,
                            r_ACTION_KEY IN ieu_uwq_maction_defs_b.maction_def_key%type)
As
v_cursor1               NUMBER;
v_cursor               NUMBER;
v_numrows1              NUMBER;
sql_stmt1             varchar2(2000);
l_property_id ieu_wp_param_props_b.property_id%type;
l_delete_param_property_id IEU_WP_PARAM_PROPS_B.param_property_id%type;
l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
l_count NUMBER := 0;
l_param_property_id     NUMBER;
l_property_value        VARCHAR2(4000);
TYPE c_cursor5 IS REF CURSOR;
c_ref c_cursor5;
--this cursor is used for parameter reording
CURSOR c_cursor3 is
SELECT action_param_set_id
FROM ieu_wp_act_param_sets_b
WHERE wp_action_def_id IN (SELECT maction_def_id
                           FROM ieu_uwq_maction_defs_b
                           WHERE maction_def_key = LTRIM(RTRIM(r_action_key))
                           );


-- this cursor is to find outall action_param_set_id
--which wp_action_def_id is related to x_action_key
cursor c_cursor is
select param_id
from ieu_wp_param_defs_b
where param_name = LTRIM(RTRIM(r_param_name))
AND param_id IN (SELECT param_id
                 FROM ieu_wp_action_params
                 WHERE WP_ACTION_DEF_ID IN (SELECT maction_def_id
                                            FROM ieu_uwq_maction_defs_b
                                            WHERE MACTION_DEF_KEY = LTRIM(RTRIM(r_ACTION_KEY))
                                            )
                 );

cursor c_cursor1 is
select a.param_property_id, a.property_id
from ieu_wp_param_props_b a, ieu_wp_param_defs_b b
where a.param_id = b.param_id
and b.param_name = LTRIM(RTRIM(r_param_name))
AND a.param_id  IN (SELECT param_id
                 FROM ieu_wp_action_params
                 WHERE WP_ACTION_DEF_ID IN (SELECT maction_def_id
                                            FROM ieu_uwq_maction_defs_b
                                            WHERE MACTION_DEF_KEY = LTRIM(RTRIM(r_ACTION_KEY))
                                            )
                 );

cursor c_cursor2 is
select a.ACTION_PARAM_MAP_ID
from ieu_wp_action_params a, ieu_wp_param_defs_b b
where a.param_id = b.param_id
and b.param_name = LTRIM(RTRIM(r_param_name))
AND a.param_id  IN (SELECT param_id
                 FROM ieu_wp_action_params
                 WHERE WP_ACTION_DEF_ID IN (SELECT maction_def_id
                                            FROM ieu_uwq_maction_defs_b
                                            WHERE MACTION_DEF_KEY = LTRIM(RTRIM(r_ACTION_KEY))
                                            )
                 );
begin
fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    x_msg_data := '';
FOR cur_rec IN c_cursor1
    LOOP
        select VALUE_TRANSLATABLE_FLAG into l_trans_flag
        from ieu_wp_properties_b
        where property_id = cur_rec.property_id;

       if (l_trans_flag = 'Y') then
       delete from ieu_wp_param_props_tl where param_property_id = cur_rec.param_property_id;
       end if ;

       delete from ieu_wp_param_props_b where param_property_id = cur_rec.param_property_id;

 end LOOP;
 FOR cur_rec IN c_cursor2
    LOOP
       delete from ieu_wp_action_params where ACTION_PARAM_MAP_ID= cur_rec.ACTION_PARAM_MAP_ID;
 end LOOP;

 FOR cur_rec IN c_cursor
    LOOP
       delete from ieu_wp_param_defs_b where param_ID= cur_rec.param_ID;
       delete from ieu_wp_param_defs_tl where param_ID= cur_rec.param_ID;
 end LOOP;
 FOR cur_rec IN c_cursor3
 loop
    l_count :=1;
    v_cursor1 := DBMS_SQL.OPEN_CURSOR;
    --find out the action_param_set_id which does not have param_id
    sql_stmt1 := ' SELECT param_property_id, property_value '||
                 ' FROM ieu_wp_param_props_b '||
                 ' WHERE property_id = 10000 '||
                 ' AND action_param_set_id = :id ' ||
                 ' order by property_value';

    Open c_ref FOR sql_stmt1 USING cur_rec.action_param_set_id;
    --DBMS_SQL.parse(v_cursor1, sql_stmt1, DBMS_SQL.V7);
    --DBMS_SQL.DEFINE_COLUMN(v_cursor1, 1, l_param_property_id);
    --DBMS_SQL.DEFINE_COLUMN(v_cursor1, 2, l_property_value,4000);
    --v_numrows1 := DBMS_SQL.EXECUTE(v_cursor1);

    LOOP
        FETCH c_ref INTO l_param_property_id, l_property_value;
        EXIT WHEN c_ref%NOTFOUND;

        --if DBMS_SQL.FETCH_ROWS(v_cursor1) = 0 then
        --   exit;
        --end if;
        --DBMS_SQL.COLUMN_VALUE(v_cursor1, 1, l_param_property_id);
        --DBMS_SQL.COLUMN_VALUE(v_cursor1, 2, l_property_value);
        IF l_property_value <> l_count then
          UPDATE ieu_wp_param_props_b
          SET PROPERTY_VALUE = l_count,
              last_update_date = sysdate,
              last_update_login = 0
          WHERE PARAM_PROPERTY_ID = l_param_property_id;


        END if;
        l_count := l_count +1;

     end loop; --for v_cursor
     --DBMS_SQL.CLOSE_CURSOR(v_cursor1);
     CLOSE c_ref;
 END loop;
  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
           ROLLBACK;
           x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;



 commit;
end DeleteActionParam;

END IEU_WORK_PANEL_PUB;

/
