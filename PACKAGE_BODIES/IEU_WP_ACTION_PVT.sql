--------------------------------------------------------
--  DDL for Package Body IEU_WP_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_ACTION_PVT" AS
/* $Header: IEUACFB.pls 120.3 2007/12/17 11:39:21 svidiyal ship $ */


--===================================================================
-- NAME
--   CREATE_action_map
--
-- PURPOSE
--    Private api to create action map
--
-- NOTES
--    1. UWQ Admin will use this procedure to create action map
--
--
-- HISTORY
--   8-may-2002     dolee   Created

--===================================================================


PROCEDURE CREATE_action_map (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ
) AS

    l_action_map_id     NUMBER(15);
    sql_stmt   varchar2(2000);
    l_count  number:=0;
    l_responsibility_id  number;
    l_application_id number;
BEGIN
  l_responsibility_id := rec_obj.responsibility_id;
  l_application_id := rec_obj.application_id;
  fnd_msg_pub.delete_msg();
  x_return_status := fnd_api.g_ret_sts_success;
  FND_MSG_PUB.initialize;
  x_msg_data := '';

  if (rec_obj.responsibility_id is  null) then
     l_responsibility_id := -2;
  end if;

  EXECUTE IMMEDIATE 'select count(wp_action_map_id) from ieu_wp_action_maps where responsibility_id = :1 '||
  ' and application_id =: 2 and action_param_set_id = :3 and action_map_code= :4 and action_map_type_code = :5 '
  INTO l_count USING l_responsibility_id, l_application_id, rec_obj.action_param_set_id,
  rec_obj.action_map_code, rec_obj.action_map_type_code;

  IF (l_count = 0) then
        select IEU_wp_action_maps_S1.NEXTVAL into l_action_map_id from sys.dual;
        x_msg_data :=x_msg_data || ' , INSERT INTO maps table with id '|| l_action_map_id;
        sql_stmt := 'insert INTO IEU_wp_action_mapS'||
        ' (WP_ACTION_MAP_ID,'||
        ' OBJECT_VERSION_NUMBER,'||
        ' CREATED_BY,'||
        ' CREATION_DATE,'||
        ' LAST_UPDATED_BY,'||
        ' LAST_UPDATE_DATE,'||
        ' LAST_UPDATE_LOGIN,'||
        ' ACTION_PARAM_SET_ID,'||
        ' APPLICATION_ID,'||
        ' RESPONSIBILITY_ID,'||
        ' ACTION_MAP_TYPE_CODE,'||
        ' ACTION_MAP_CODE,'||
        ' ACTION_MAP_SEQUENCE,'||
        ' PANEL_SEC_CAT_CODE,'||
        ' NOT_VALID_FLAG,'||
        ' DEV_DATA_FLAG '||
        ' )'||
        ' values ('||
        ' :1,'||
        ' :2,'||
        ' :3,'||
        ' :4,'||
        ' :5,'||
        ' :6,'||
        ' :7,'||
        ' :8,'||
        ' :9,'||
        ' :10,'||
        ' :11,'||
        ' :12,'||
        ' :13,'||
        ' :14,'||
        ' :15,'||
        ' :16 '||
        ' )';
        EXECUTE IMMEDIATE sql_stmt USING l_action_map_id, '1',FND_GLOBAL.USER_ID, SYSDATE,
        FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.LOGIN_ID, rec_obj.action_param_set_id, rec_obj.application_id,
        rec_obj.responsibility_id,rec_obj.action_map_type_code,rec_obj.action_map_code,
        rec_obj.action_map_sequence, rec_obj.panel_sec_cat_code,       rec_obj.not_valid_flag,
        rec_obj.dev_data_flag;
        else if (l_count >0 ) then
            EXECUTE IMMEDIATE 'update ieu_wp_action_maps set responsibility_id = null '||
            ' where responsibility_id = -2 and action_param_set_id = :2 '||
            ' and action_map_code= :3 and action_map_type_code = :4 '
            USING rec_obj.action_param_set_id,
            rec_obj.action_map_code, rec_obj.action_map_type_code;
        end if ;

      END if;
x_msg_data := x_msg_data || ' , after insert table ';

   COMMIT;

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

END CREATE_action_map;
PROCEDURE DELETE_Actions (x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data  OUT NOCOPY VARCHAR2,
                          r_param_set_id IN ieu_wp_act_param_sets_b.action_param_set_id%type
                          ) is

media_count    NUMBER(15);
temp_svr_type_id    NUMBER(15);
l_action_param_set_id NUMBER(15);
v_label  VARCHAR2(500);
v_SelectStmt  Varchar2(500);
v_CursorID   INTEGER;
v_Dummy   INTEGER;
v_param_set_id ieu_wp_act_param_sets_b.action_param_set_id%type;

CURSOR c_cursor IS
  SELECT param_property_id
  FROM ieu_wp_param_props_b
  WHERE action_param_set_id =  v_param_set_id;
cur_rec   c_cursor%ROWTYPE;
begin
  fnd_msg_pub.delete_msg();
  x_return_status := fnd_api.g_ret_sts_success;
  FND_MSG_PUB.initialize;
  x_msg_data := '';

  v_param_set_id := r_param_set_id;
  OPEN c_cursor;
  Loop
     FETCH c_cursor INTO cur_rec;
     EXIT WHEN c_cursor%NOTFOUND;
     delete from IEU_WP_PARAM_PROPS_B
     where param_property_id = cur_rec.param_property_id;

     delete from IEU_WP_PARAM_PROPS_TL
     where param_property_id = cur_rec.param_property_id;
  end LOOP;
  CLOSE c_cursor;


  EXECUTE IMMEDIATE
  ' delete from IEU_WP_ACT_PARAM_SETS_B '||
  ' where action_param_set_id = :1 '
  USING r_param_set_id;

  EXECUTE IMMEDIATE 'delete from IEU_WP_ACT_PARAM_SETS_TL where action_param_set_id = :1 '
  USING r_param_set_id;

  EXECUTE IMMEDIATE ' delete from IEU_wp_action_mapS where action_param_set_id  = :1 '
  USING r_param_set_id;


  if (sql%notfound) then
      null;
  end if;
  COMMIT;

  EXCEPTION

        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN NO_DATA_FOUND THEN
            null;

        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_SQL.CLOSE_CURSOR(v_CursorID);
            x_return_status := fnd_api.g_ret_sts_unexp_error;


commit;
END DELETE_Actions;

--===================================================================
-- NAME
--   Update_MAction
--
-- PURPOSE
--    Private api to update media type
--
-- NOTES
--    1. UWQ  Work Panel Admin will use this procedure to update an action
--
--
-- HISTORY
--   08-MAY-2002     GPAGADAL   Created

--===================================================================
PROCEDURE Update_MAction ( x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           r_MACTION_DEF_ID IN NUMBER,
                           r_action_user_label IN VARCHAR2,
                           r_action_description IN VARCHAR2,
                           r_param_set_id IN NUMBER)
AS
l_language             VARCHAR2(4);
l_source_lang          VARCHAR2(4);
v_SelectStmt  Varchar2(500);
v_CursorID   INTEGER;
v_Dummy   INTEGER;

BEGIN
  fnd_msg_pub.delete_msg();
  x_return_status := fnd_api.g_ret_sts_success;
  FND_MSG_PUB.initialize;
  l_language := FND_GLOBAL.CURRENT_LANGUAGE;
  l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
  x_msg_data := '';
  execute immediate ' update  IEU_WP_ACT_PARAM_SETS_TL           ' ||
                  '   set                                        ' ||
                  '      LAST_UPDATED_BY = FND_GLOBAL.USER_ID,    ' ||
                  '      LAST_UPDATE_DATE = SYSDATE,               '||
                  '      LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,   '||
                  '      ACTION_PARAM_SET_LABEL = :1 , '||
                  '      ACTION_PARAM_SET_DESC  = :2  ' ||
                  '    where ACTION_PARAM_SET_ID = :3 ' ||
                  '    and language IN (:4 , :5 )'
   using r_action_user_label, r_action_description,r_param_set_id, l_language,l_source_lang ;


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
END Update_MAction;

--===================================================================
-- NAME
--   UPDATE_action_map
--
-- PURPOSE
--    Private api to update action map
--
-- NOTES
--    1. UWQ work panel will use this procedure to update action map
--
--
-- HISTORY
--   8-may-2002     dolee   Created

--===================================================================



PROCEDURE UPDATE_action_map (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ
) AS

   l_cur_obj_versn NUMBER;

BEGIN

   fnd_msg_pub.delete_msg();
   x_return_status := fnd_api.g_ret_sts_success;
   FND_MSG_PUB.initialize;
   x_msg_data := '';

   execute immediate 'select unique(object_version_number) from ieu_wp_action_maps where wp_action_map_ID = :1'
   into l_cur_obj_versn using rec_obj.wp_action_map_id;


    EXECUTE IMMEDIATE
    ' update IEU_WP_ACTION_MAPS   '||
    ' set                         ' ||
    '  OBJECT_VERSION_NUMBER = l_cur_obj_versn+1, '||
    '  LAST_UPDATED_BY = FND_GLOBAL.USER_ID,  '||
    '  LAST_UPDATE_DATE = SYSDATE,  '||
    '  LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID, '||
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
   -- '  ACTION_MAP_SEQUENCE   = :1, '||
    '  ACTION_MAP_SEQUENCE   = :1 '||
/*********************************************************************************/

    '  NOT_VALID_FLAG  = :2 '||
    ' where WP_ACTION_MAP_ID = :3 '
    USING rec_obj.action_map_sequence, rec_obj.not_valid_flag ,rec_obj.wp_action_map_id;

   commit;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN NO_DATA_FOUND THEN
            null;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
commit;

END UPDATE_action_map;


--===================================================================
-- NAME
--   UPDATE_action_map_sequence
--
-- PURPOSE
--    Private api to update action map sequence
--
-- NOTES
--    1. UWQ work panel will use this procedure to update action map sequence
--
--
-- HISTORY
--   14-aug-2002     dolee   Created

--===================================================================



PROCEDURE UPDATE_action_map_sequence (x_return_status  OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT NOCOPY NUMBER,
                                      x_msg_data  OUT NOCOPY VARCHAR2,
                                      r_action_param_set_id IN IEU_WP_ACTION_MAPS.action_param_set_id%type,
                                      r_MACTION_DEF_TYPE_FLAG IN IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_TYPE_FLAG %type,
                                      r_application_id IN IEU_WP_ACTION_MAPS.application_id%type,
                                      r_sel_enum_id IN IEU_UWQ_SEL_ENUMERATORS.sel_enum_id%type,
                                      r_action_map_sequence IN IEU_WP_ACTION_MAPS.action_map_sequence%type,
                                      r_not_valid_flag IN IEU_WP_ACTION_MAPS.not_valid_flag%type
) AS

   l_cur_obj_versn NUMBER;
   v_type_code varchar2(100);
   v_ver_number  ieu_wp_action_maps.object_version_number%type;
   v_MACTION_DEF_TYPE_FLAG ieu_uwq_maction_defs_b.MACTION_DEF_TYPE_FLAG%type;
   v_action_param_set_id ieu_wp_action_maps.action_param_set_id%type;
   v_application_id ieu_wp_action_maps.application_id%type;
   v_sel_enum_id ieu_uwq_sel_enumerators.sel_enum_id%type;
CURSOR c_cursor is
  select m.WP_ACTION_MAP_ID, m.object_version_number
  from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db,
       ieu_wp_act_param_sets_b sb
  where  m.action_map_type_code = v_type_code
        --and m.application_id = db.application_id
        and db.maction_def_type_flag= v_MACTION_DEF_TYPE_FLAG
        and db.maction_def_id = sb.wp_action_def_id
        and sb.action_param_set_id= m.action_param_set_id
        and m.action_param_set_id = v_action_param_set_id
        --and m.APPLICATION_ID = v_application_id
        and m.ACTION_MAP_CODE = (select ENUM_TYPE_UUID
                                 FROM ieu_uwq_sel_enumerators
                                 where sel_enum_id = v_sel_enum_id);
c_rec   c_cursor%ROWTYPE;
CURSOR c_cursor2 is
  select m.WP_ACTION_MAP_ID, m.object_version_number
  from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db,
       ieu_wp_act_param_sets_b sb, ieu_uwq_node_ds ds
  where  m.action_map_type_code = v_type_code
        --and m.application_id = db.application_id
        and db.maction_def_type_flag= 'F'
        and db.maction_def_id = sb.wp_action_def_id
        and sb.action_param_set_id= m.action_param_set_id
        and m.action_param_set_id =v_action_param_set_id
        --and m.APPLICATION_ID = v_application_id
        and m.ACTION_MAP_CODE = to_char(ds.NODE_DS_ID)
        and ds.ENUM_TYPE_UUID = (select ENUM_TYPE_UUID
                                 FROM ieu_uwq_sel_enumerators
                                 where sel_enum_id = v_sel_enum_id);
c_rec2   c_cursor2%ROWTYPE;
BEGIN
   fnd_msg_pub.delete_msg();
   x_return_status := fnd_api.g_ret_sts_success;
   FND_MSG_PUB.initialize;
   x_msg_data := '';

   if(r_MACTION_DEF_TYPE_FLAG <> 'F') then
      v_type_code := 'NODE';
      v_MACTION_DEF_TYPE_FLAG := r_MACTION_DEF_TYPE_FLAG;
      v_action_param_set_id := r_action_param_set_id;
      v_application_id := r_application_id;
      v_sel_enum_id := r_sel_enum_id;
      OPEN c_cursor;
      loop
        FETCH c_cursor INTO c_rec;
        EXIT WHEN c_cursor%NOTFOUND;
	   if (c_rec.object_version_number is null) then v_ver_number := 1;
	   else
        v_ver_number := c_rec.object_version_number+1 ;
	   end if;
        IF r_not_valid_flag IS NOT NULL then
          EXECUTE immediate
          ' update IEU_WP_ACTION_MAPS  '||
          ' set                        ' ||
          '   OBJECT_VERSION_NUMBER = :1, '||
          '   LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
          '   LAST_UPDATE_DATE = SYSDATE, '||
          ' LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID, '||
          '  ACTION_MAP_SEQUENCE   = :2 , '||
          '  NOT_VALID_FLAG  =  :3 '||
          ' where WP_ACTION_MAP_ID = :4  '
          USING v_ver_number, r_action_map_sequence, r_not_valid_flag,  c_rec.wp_action_map_id;
        else
          EXECUTE immediate
          ' update IEU_WP_ACTION_MAPS  ' ||
          ' set                        ' ||
          '  OBJECT_VERSION_NUMBER = :1 , '||
          '  LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
          '  LAST_UPDATE_DATE = SYSDATE, '||
          '  LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID, '||
          '  ACTION_MAP_SEQUENCE   = :2'||
          '  where WP_ACTION_MAP_ID =  :3 '
          USING v_ver_number, r_action_map_sequence, c_rec.wp_action_map_id;
        END if;
      END loop;
      CLOSE c_cursor;
   elsif(r_MACTION_DEF_TYPE_FLAG = 'F') then
     v_type_code := 'NODE_DS';
     v_action_param_set_id := r_action_param_set_id;
     v_application_id := r_application_id;
     v_sel_enum_id := r_sel_enum_id;
     OPEN c_cursor2;
     loop
       FETCH c_cursor2 INTO c_rec2;
       EXIT WHEN c_cursor2%NOTFOUND;
	  if (c_rec.object_version_number is null) then v_ver_number := 1;
	  else
        v_ver_number := c_rec.object_version_number+1 ;
	   end if;
        IF r_not_valid_flag IS NOT NULL then
              EXECUTE immediate
              ' update IEU_WP_ACTION_MAPS   '||
              ' SET '||
              ' OBJECT_VERSION_NUMBER = :1 , '||
              '  LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
              '  LAST_UPDATE_DATE = SYSDATE, '||
              '  LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID, '||
              '  ACTION_MAP_SEQUENCE   = :2 , '||
              '  NOT_VALID_FLAG  =  :3 '||
              '  where WP_ACTION_MAP_ID =  :4 '
              USING v_ver_number,  r_action_map_sequence, r_not_valid_flag, c_rec2.wp_action_map_id;
        else
              EXECUTE immediate
              ' update IEU_WP_ACTION_MAPS  '||
              ' SET '||
              '   OBJECT_VERSION_NUMBER = :1 , '||
              '   LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
              '   LAST_UPDATE_DATE = SYSDATE, '||
              '   LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID, '||
              '   ACTION_MAP_SEQUENCE   = :2 '||
              '  where WP_ACTION_MAP_ID =  :3 '
              USING v_ver_number, r_action_map_sequence, c_rec2.wp_action_map_id;
        END if;
      END loop;
      CLOSE c_cursor2;
   end if;
   commit;

   EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN NO_DATA_FOUND THEN
            null;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
commit;

END UPDATE_action_map_sequence;

--===================================================================
-- NAME
--   DELETE_action_map
--
-- PURPOSE
--    Private api to delete action map
--
-- NOTES
--    1. UWQ Admin will use this procedure to delete action map
--
--
-- HISTORY
--   8-may-2002     DOLEE   Created

--===================================================================


PROCEDURE DELETE_action_map (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY  VARCHAR2,
                             r_action_map_id IN NUMBER
    ) is

media_count    NUMBER(15);
temp_svr_type_id    NUMBER(15);
l_count    NUMBER(15) :=0;
BEGIN
fnd_msg_pub.delete_msg();
x_return_status := fnd_api.g_ret_sts_success;
FND_MSG_PUB.initialize;
x_msg_data := '';
execute immediate ' select count(*) '||
' from ieu_wp_action_maps where wp_action_map_id = :1  '||
' and responsibility_id is null'
into l_count
using r_action_map_id;
x_msg_data := x_msg_data || ' count is '|| l_count;
if (l_count <> 1) then
EXECUTE immediate
' delete from IEU_wp_action_mapS '||
' where wp_action_map_ID = :1  '
USING r_action_map_id;
else
  execute immediate
  ' update ieu_wp_action_maps set responsibility_id = -2 ' ||
  ' where wp_action_map_id = :1 '
  using r_action_map_id;
end if;


if (sql%notfound) then
    null;
end if;
COMMIT;

    EXCEPTION

        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN NO_DATA_FOUND THEN
            null;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

commit;

 END DELETE_action_map;




-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           CreateFromAction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_wp_action_key VARCHAR2
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================
PROCEDURE CreateFromAction(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 r_wp_action_key IN VARCHAR2,
                                 r_language  IN VARCHAR2,
                                 r_label  IN VARCHAR2,
                                 r_desc   IN VARCHAR2,
                                  r_param_set_id IN NUMBER,
                                  r_enumId IN VARCHAR2)
 AS

l_wp_maction_def_id     NUMBER(15);
l_param_set_id          NUMBER(15);
l_language             VARCHAR2(4);
l_source_lang          VARCHAR2(4);
l_msg_count            NUMBER(2);

l_msg_data             VARCHAR2(2000);

l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;

v_cursor1               NUMBER;
sql_stmt             varchar2(2000);
sql_stmt1             varchar2(2000);
l_param_id              NUMBER(15);
l_property_id           NUMBER(15);
l_property_value        varchar(4000);
l_not_valid_flag        varchar(5);
l_value_override_flag    varchar(5);
v_numrows1             NUMBER;
l_new_param_set_id     NUMBER(15);
l_wp_action_map_id     NUMBER(15);
l_temp_map_sequence ieu_wp_action_maps.action_map_sequence%type;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


     IEU_WP_ACTION_PVT.CreateFromAction2( x_return_status, x_msg_count,
                                     x_msg_data, r_wp_action_key,
                                     r_language,
                                     r_label,
                                     r_desc,
                                     r_param_set_id,
                                     r_enumId,
                                     null);


commit;
end CreateFromAction;


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           CreateFromAction2
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_wp_action_key VARCHAR2
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


 PROCEDURE CreateFromAction2( x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             r_wp_action_key IN VARCHAR2,
                             r_language  IN VARCHAR2,
                             r_label  IN VARCHAR2,
                             r_desc   IN VARCHAR2,
                            r_param_set_id IN NUMBER,
                             r_enumId IN VARCHAR2,
                             r_dev_data_flag IN VARCHAR2)


 AS

l_wp_maction_def_id     NUMBER(15);
l_param_set_id          NUMBER(15);
l_language             VARCHAR2(4);
l_source_lang          VARCHAR2(4);
l_msg_count            NUMBER(2);
v_wp_action_key        varchar2(500);
l_msg_data             VARCHAR2(2000);

l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;

v_cursor1               NUMBER;
sql_stmt             varchar2(2000);
sql_stmt1             varchar2(2000);
l_param_id              NUMBER(15);
l_property_id           NUMBER(15);
l_property_value        varchar(4000);
l_not_valid_flag        varchar(5);
l_value_override_flag    varchar(5);
v_numrows1             NUMBER;
l_new_param_set_id     NUMBER(15);
l_wp_action_map_id     NUMBER(15);
l_temp_map_sequence ieu_wp_action_maps.action_map_sequence%type;
param_sets_rec         IEU_WP_ACT_PARAM_SETS_SEED_PKG.WP_ACT_PARAM_SETS_rec_type;
param_props_rec        IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type;
v_SelectStmt  Varchar2(500);
v_CursorID   INTEGER;
v_Dummy   INTEGER;
v_param_set_id  ieu_wp_param_props_b.action_param_set_id%type;
v_language ieu_wp_param_props_tl.language%type;
v_enumId ieu_uwq_sel_enumerators.sel_enum_id%type;
v_responsibility_id ieu_wp_action_maps.responsibility_id%type;
cursor c_cur is
SELECT
   PARAM_ID, PROPERTY_ID,property_value
   , value_override_flag,not_valid_flag
    FROM ieu_wp_param_props_b
     WHERE action_param_set_id in
        (select a.action_param_set_id
        from ieu_wp_act_param_sets_b a, ieu_wp_act_param_sets_tl b, ieu_uwq_maction_defs_b c
        where a.action_param_set_id = b.action_param_set_id(+)
        and b.action_param_set_id = v_param_set_id
        and c.maction_def_key =  LTRIM(RTRIM(v_wp_action_key))
        and b.language = v_language
        and c.maction_def_id = a.wp_action_def_id
        and a.action_param_set_id in (select action_param_set_id
                                      from ieu_wp_action_maps
                                      where action_map_code in (select enum_type_uuid from ieu_uwq_sel_enumerators
                                                           where sel_enum_id =v_enumId
                                                           )
                                     )
        );
-- this c_cur2 will NOT get responsibility information FROM original action
cursor c_cur2 is
SELECT
   object_version_number, application_id, action_map_type_code,
   action_map_code, panel_sec_cat_code, not_valid_flag
    FROM ieu_wp_action_maps
     WHERE responsibility_id = v_responsibility_id
     AND action_param_set_id in
        (select a.action_param_set_id
        from ieu_wp_act_param_sets_b a, ieu_wp_act_param_sets_tl b, ieu_uwq_maction_defs_b c
        where a.action_param_set_id = b.action_param_set_id(+)
        and b.action_param_set_id = v_param_set_id
        and c.maction_def_key =  LTRIM(RTRIM(v_wp_action_key))
        and b.language = v_language
        and c.maction_def_id = a.wp_action_def_id)
        and action_map_code in (select enum_type_uuid from ieu_uwq_Sel_enumerators
                               where sel_enum_id =v_enumId);


c_rec   c_cur%ROWTYPE;
c_rec2  c_cur2%ROWTYPE;
null_string varchar2(200) := null;
BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


   execute immediate ' select  a.wp_action_def_id  ' ||
                  ' from ieu_wp_act_param_sets_b a, ieu_uwq_maction_defs_b c ' ||
                  ' where a.action_param_set_id = :1  ' ||
                  ' and c.maction_def_key =  :2  ' ||
                  ' and c.maction_def_id = a.wp_action_def_id '
   into l_wp_maction_def_id using r_param_set_id, r_wp_action_key;



   if  l_wp_maction_def_id is not null then
       select IEU_wp_act_param_sets_b_S1.NEXTVAL into l_new_param_set_id from sys.dual;
       /* TYPE IEU_WP_ACT_PARAM_SETS_SEED_PKG.WP_ACT_PARAM_SETS_rec_type IS RECORD (
                      ACTION_PARAM_SET_ID          NUMBER(15),
                      WP_ACTION_DEF_ID  NUMBER(15),
                      ACTION_PARAM_SET_LABEL  VARCHAR2(128),
                      ACTION_PARAM_SET_DESC VARCHAR2(500),
                      created_by NUMBER(15),
                      creation_date DATE,
                      last_updated_by NUMBER(15),
                      last_update_date DATE,
                      last_update_login NUMBER(15),
                      owner VARCHAR2(15) );
       */
       param_sets_rec.ACTION_PARAM_SET_ID := l_new_param_set_id;
       param_sets_rec.WP_ACTION_DEF_ID := l_wp_maction_def_id;
       param_sets_rec.ACTION_PARAM_SET_LABEL := LTRIM(RTRIM(r_label));
       param_sets_rec.ACTION_PARAM_SET_DESC := LTRIM(RTRIM(r_desc));
       param_sets_rec.created_by := FND_GLOBAL.USER_ID;
       param_sets_rec.creation_date := SYSDATE;
       param_sets_rec.last_updated_by := FND_GLOBAL.USER_ID;
       param_sets_rec.last_update_date := SYSDATE;
       param_sets_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
       param_sets_rec.owner := 1;
       IEU_WP_ACT_PARAM_SETS_SEED_PKG.Insert_Row(p_WP_ACT_PARAM_SETS_rec=>param_Sets_rec);
   end if ;


   v_wp_action_key := r_wp_action_key;
   v_param_set_id := r_param_set_id;
   v_language := r_language;
   v_enumId := r_enumId;

   OPEN c_cur;
   Loop
       FETCH c_cur INTO c_rec;
       EXIT WHEN c_cur%NOTFOUND;
       select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
       /*TYPE IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type IS RECORD (
                    PARAM_PROPERTY_ID NUMBER(15),
                    ACTION_PARAM_SET_ID     NUMBER,
                    PARAM_ID          NUMBER,
                    PROPERTY_ID       NUMBER,
                    PROPERTY_VALUE    VARCHAR(4000),
                    PROPERTY_VALUE_TL VARCHAR(4000),
                    VALUE_OVERRIDE_FLAG   VARCHAR2(5),
                    created_by NUMBER(15),
                    creation_date DATE,
                    last_updated_by NUMBER(15),
                    last_update_date DATE,
                    last_update_login NUMBER(15),
                    not_valid_flag     VARCHAR(4000),
                    owner VARCHAR2(15) );
       */
       param_props_rec.PARAM_PROPERTY_ID := l_param_property_id;
       param_props_rec.ACTION_PARAM_SET_ID := l_new_param_set_id;
       param_props_rec.PARAM_ID := c_rec.param_id;
       param_props_rec.PROPERTY_ID := c_rec.property_id;
       param_props_rec.PROPERTY_VALUE := c_rec.property_value;
       param_props_rec.PROPERTY_VALUE_TL := c_rec.property_value;
       param_props_rec.VALUE_OVERRIDE_FLAG := c_rec.value_override_flag;
       param_props_rec.created_by := FND_GLOBAL.USER_ID;
       param_props_rec.creation_date := SYSDATE;
       param_props_rec.last_updated_by := FND_GLOBAL.USER_ID;
       param_props_rec.last_update_date := SYSDATE;
       param_props_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
       param_props_rec.NOT_VALID_FLAG := c_rec.not_valid_flag;
       param_props_rec.owner := 1;
       IEU_WP_PARAM_PROPS_SEED_PKG.Insert_Row(p_wp_param_props_rec => param_props_rec);
       end LOOP;
   CLOSE c_cur;



   v_responsibility_id := '-1' ;
   OPEN c_cur2;
   Loop
     FETCH c_cur2 INTO c_rec2;
     EXIT WHEN c_cur2%NOTFOUND;
     ReOrdering(x_return_status,x_msg_count,x_msg_data,r_enumId ,c_rec2.application_id ,'W');
     EXECUTE immediate
     ' select max(m.action_map_sequence) '||
     ' from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db, '||
     '     ieu_wp_act_param_sets_b sb '||
     -- ' where m.application_id  =  :1 '||
     '      where m.action_map_type_code = :1  '||
     '      and m.action_map_code = :2 '||
     '      and db.maction_def_type_flag = :3 '||
     '      and db.maction_def_id = sb.wp_action_def_id  '||
     '      and sb.action_param_set_id = m.action_param_set_id  '||
     '      and m.responsibility_id = -1 '
      into l_temp_map_sequence USING c_rec2.action_map_type_code,  c_rec2.action_map_code, 'W';

     if (l_temp_map_sequence is null) then
           l_temp_map_sequence := 1;
     else l_temp_map_sequence := l_temp_map_sequence+1;
     END if;


      --INSERT one RECORD WITH responsibility_id = -1
       select IEU_WP_ACTION_MAPS_S1.NEXTVAL into  l_wp_action_map_id from sys.dual;
       EXECUTE immediate
       ' insert INTO IEU_WP_ACTION_MAPS ' ||
       '    (WP_ACTION_MAP_ID, '||
       '     CREATED_BY, '||
       '     CREATION_DATE, '||
       '     LAST_UPDATED_BY, '||
       '     LAST_UPDATE_DATE, '||
       '     LAST_UPDATE_LOGIN, '||
       '     ACTION_PARAM_SET_ID, '||
       '     APPLICATION_ID, '||
       '     RESPONSIBILITY_ID, '||
       '     ACTION_MAP_TYPE_CODE, '||
       '     ACTION_MAP_CODE, '||
       '     PANEL_SEC_CAT_CODE, '||
       '     NOT_VALID_FLAG, '||
       '     OBJECT_VERSION_NUMBER, '||
       '     action_map_sequence, '||
       '     DEV_DATA_FLAG '||
       '  ) VALUES ( '||
       '      :1 , '||
       '      :2, '||
       '      :3, '||
       '      :4, '||
       '      :5, '||
       '     :6, '||
       '      :7 , '||
       '      :8 , '||
       '      :9, '||
       '      :10 , '||
       '      :11, '||
       '      :12, '||
       '      :13, '||
       '      :14, '||
       '      :15, '||
       '      :16 '||
       '  ) '
         USING l_wp_action_map_id,FND_GLOBAL.USER_ID,SYSDATE, FND_GLOBAL.USER_ID, SYSDATE,
         FND_GLOBAL.LOGIN_ID, l_new_param_set_id, c_rec2.application_id, '-1', c_rec2.action_map_type_code,
         c_rec2.action_map_code, c_rec2.panel_sec_cat_code, c_rec2.not_valid_flag, c_rec2.object_version_number,
         l_temp_map_sequence, r_dev_data_flag;


         --INSERT one RECORD WITH responsibility_id IS null
         select IEU_WP_ACTION_MAPS_S1.NEXTVAL into  l_wp_action_map_id from sys.dual;
         v_responsibility_id := null;
         EXECUTE immediate
         ' insert INTO IEU_WP_ACTION_MAPS '||
         '  (WP_ACTION_MAP_ID, '||
         '   CREATED_BY, '||
         '   CREATION_DATE, '||
         '   LAST_UPDATED_BY, '||
         '   LAST_UPDATE_DATE, '||
         '   LAST_UPDATE_LOGIN, '||
         '   ACTION_PARAM_SET_ID, '||
         '   APPLICATION_ID, '||
         '   ACTION_MAP_TYPE_CODE, '||
         '   ACTION_MAP_CODE, '||
         '   PANEL_SEC_CAT_CODE, '||
         '   NOT_VALID_FLAG, '||
         '   OBJECT_VERSION_NUMBER, '||
         '   action_map_sequence, '||
         '   DEV_DATA_FLAG '||
         ' ) VALUES ( '||
         '    :1, '||
         '    :2, '||
         '    :3, '||
         '    :4, '||
         '    :5, '||
         '    :6, '||
         '    :7 , '||
         '    :8, '||
         '    :9, '||
         '    :10, '||
         '    :11 , '||
         '    :12 , '||
         '    :13 , '||
         '    :14 , '||
          '   :15 )'
         USING l_wp_action_map_id,FND_GLOBAL.USER_ID, SYSDATE,FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.LOGIN_ID,
         l_new_param_set_id,  c_rec2.application_id, c_rec2.action_map_type_code,
         c_rec2.action_map_code, c_rec2.panel_sec_cat_code, c_rec2.not_valid_flag, c_rec2.object_version_number,
         l_temp_map_sequence, r_dev_data_flag;
   end loop;
   CLOSE c_cur2;
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
end CreateFromAction2;




-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           UpdtateParamProps
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
-- GPAGADAL updated on 2/21/2003
-- Update the param_props table instead of deleting when the data type is DATE
--   End of Comments
-- ===============================================================

PROCEDURE UpdateParamProps( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT  NOCOPY NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            r_applId    IN  NUMBER)

AS
l_user_param_set_id IEU_WP_ACT_PARAM_SETS_B.action_param_set_id%type;
l_original_param_set_id IEU_WP_ACT_PARAM_SETS_B.action_param_set_id%type;
v_cursor1               NUMBER;
v_cursor2               NUMBER;
v_cursor               NUMBER;
l_param_property_id     NUMBER;
l_param_id             NUMBER;
l_property_id           NUMBER;
l_property_value        VARCHAR2(4000);
l_value_override_flag   VARCHAR2(5);
l_not_valid_flag        VARCHAR2(5);
v_numrows1              NUMBER;
v_numrows             NUMBER;
sql_stmt             varchar2(2000);
sql_stmt1             varchar2(2000);
sql_stmt2           varchar2(2000);
l_count             NUMBER :=0;
l_language             VARCHAR2(4);
l_source_lang          VARCHAR2(4);
l_delete_param_property_id IEU_WP_PARAM_PROPS_B.param_property_id%type;
l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
l_temp  IEU_WP_PARAM_PROPS_B.action_param_set_id%type;
l_ptemp IEU_WP_PARAM_PROPS_B.param_id%type;

l_action_param_set_id IEU_WP_ACT_PARAM_SETS_B.action_param_set_id%type;
l_action_temp_id IEU_WP_ACT_PARAM_SETS_B.action_param_set_id%type;
l_index NUMBER:=0;
l_my_count NUMBER:=0;
l_max_property  NUMBER :=0;
l_max_action_param_set_id  IEU_WP_ACT_PARAM_SETS_B.action_param_set_id%type;
l_param_property_key  ieu_wp_param_props_b.param_property_id%type;
param_props_rec IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type;
param_sets_rec  IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type;
v_applId ieu_wp_param_defs_b.application_id%type;
TYPE c_cursor5 IS REF CURSOR;
c_ref c_cursor5;

TYPE c_cursor6 IS REF CURSOR;
c_ref2 c_cursor6;

cursor c_cur is
select WP_ACTION_DEF_ID, param_id
from ieu_wp_action_params
WHERE param_id IN (SELECT param_id FROM ieu_wp_param_defs_b
                   WHERE application_id =v_applId);
c_rec   c_cur%ROWTYPE;

-- this cursor is for those properties which component id has been changed 'DATE'
-- In that case, the default value property should not be existed if there is.
v_data_type  ieu_wp_param_defs_b.data_type%type;
cursor c_cur2 is
select distinct action_param_set_id, param_id
from ieu_wp_param_props_b
where param_id in (select param_id from ieu_wp_param_defs_b
                   where DATA_TYPE = v_data_type
                   AND application_id(+) = v_applId)
order by action_param_set_id;
c_rec2  c_cur2%ROWTYPE;

Begin

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';

   --delete param props if param has been deleted by some actions
    delete from ieu_wp_param_props_b where param_property_id in
    (   select param_property_id
        from ieu_wp_param_props_b
        where param_id not in (select param_id from ieu_wp_param_defs_b));

   delete from ieu_wp_param_props_tl where param_property_id in
   (    select param_property_id
        from ieu_wp_param_props_b
        where param_id not in (select param_id from ieu_wp_param_defs_b));

   --DBMS_OUTPUT.Put_Line('before for loop');

   -- this loop is for action_param_set_id which missing param_id

    v_applId := r_applId;
    OPEN c_cur;
    LOOP
    FETCH c_cur INTO c_rec;
    EXIT WHEN c_cur%NOTFOUND;
        sql_stmt1 := 'select action_param_set_id '||
                     ' from ieu_wp_act_param_sets_b '||
                     ' where action_param_set_id in (select distinct action_param_set_id '||
                                                    ' from ieu_wp_act_param_sets_b '||
                                                    ' where wp_action_def_id = :action_id '||
                                                    ' ) '||
                     ' and action_param_set_id  not IN '||
                                                    ' (select distinct action_param_set_id '||
                                                    ' from ieu_wp_param_props_b '||
                                                    ' where param_id = :param_id)';

        OPEN c_ref FOR sql_stmt1 USING c_rec.wp_action_def_id, c_rec.param_id;

        LOOP
            FETCH c_ref INTO l_action_param_set_id;
            EXIT WHEN c_ref%NOTFOUND;
            l_index :=0; --initialize
            sql_stmt := 'select action_param_set_id '||
                        ' from ieu_wp_act_param_sets_b '||
                        ' where action_param_set_id in (select distinct action_param_set_id '||
                                                    ' from ieu_wp_act_param_sets_b '||
                                                    ' where wp_action_def_id = :action_id '||
                                                    ') '||
                        ' and action_param_set_id   IN '||
                                               ' (select distinct action_param_set_id '||
                                               ' from ieu_wp_param_props_b '||
                                               ' where param_id = :param_id)';

            OPEN c_ref2 FOR sql_stmt USING c_rec.wp_action_def_id, c_rec.param_id;

            LOOP
                FETCH c_ref2 INTO l_action_temp_id;
                EXIT WHEN c_ref2%NOTFOUND;
                select count(property_id) into l_index
                from ieu_wp_param_props_b
                where action_param_set_id = l_action_temp_id
                and param_id =  c_rec.param_id;

                if l_max_property < l_index then
                    l_max_property := l_index;
                    l_max_action_param_set_id := l_action_temp_id;
                end if;

            end loop; --for v_cursor
            --DBMS_SQL.CLOSE_CURSOR(v_cursor);
            CLOSE c_ref2;

            --get property_id, property_value, VALUE_OVERRIDE_FLAG, NOT_VALID_FLAG
            If l_max_action_param_set_id IS NOT NULL then
                sql_stmt2 := 'select property_id, property_value, VALUE_OVERRIDE_FLAG, NOT_VALID_FLAG '||
                             '  from ieu_wp_param_props_b '||
                             '  where param_id = :param_id '||
                             ' and action_param_set_id = :max_set_id ';
                OPEN c_ref2 FOR sql_stmt2 USING c_rec.param_id, l_max_action_param_set_id;
                LOOP
                    FETCH c_ref2 INTO l_property_id, l_property_value,l_value_override_flag,l_not_valid_flag;
                    EXIT WHEN c_ref2%NOTFOUND;

                    select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
                    /*TYPE IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type IS RECORD (
                    PARAM_PROPERTY_ID NUMBER(15),
                    ACTION_PARAM_SET_ID     NUMBER,
                    PARAM_ID          NUMBER,
                    PROPERTY_ID       NUMBER,
                    PROPERTY_VALUE    VARCHAR(4000),
                    PROPERTY_VALUE_TL VARCHAR(4000),
                    VALUE_OVERRIDE_FLAG   VARCHAR2(5),
                    created_by NUMBER(15),
                    creation_date DATE,
                    last_updated_by NUMBER(15),
                    last_update_date DATE,
                    last_update_login NUMBER(15),
                    not_valid_flag     VARCHAR(4000),
                    owner VARCHAR2(15) );
                     */
                     param_props_rec.PARAM_PROPERTY_ID := l_param_property_id;
                     param_props_rec.ACTION_PARAM_SET_ID := l_action_param_set_id;
                     param_props_rec.PARAM_ID := c_rec.param_id;
                     param_props_rec.PROPERTY_ID := l_property_id;
                     param_props_rec.PROPERTY_VALUE := l_property_value;
                     param_props_rec.PROPERTY_VALUE_TL := l_property_value;
                     param_props_rec.VALUE_OVERRIDE_FLAG := l_value_override_flag;
                     param_props_rec.created_by := FND_GLOBAL.USER_ID;
                     param_props_rec.creation_date := SYSDATE;
                     param_props_rec.last_updated_by := FND_GLOBAL.USER_ID;
                     param_props_rec.last_update_date := SYSDATE;
                     param_props_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
                     param_props_rec.NOT_VALID_FLAG :=l_not_valid_flag;
                     param_props_rec.owner := 1;
                     IEU_WP_PARAM_PROPS_SEED_PKG.Insert_Row(p_wp_param_props_rec => param_props_rec);
                end loop;-- for v_cursor2
                --DBMS_SQL.CLOSE_CURSOR(v_cursor2);
                CLOSE c_ref2;
            END IF ; -- for max action param set is not null
            end LOOP;-- for v_cursor1
            -- DBMS_SQL.CLOSE_CURSOR(v_cursor1);
        CLOSE c_ref;


    end LOOP; -- for c_cur
    CLOSE c_cur;

    --DBMS_OUTPUT.Put_Line('beore delete data type loop');
    v_data_type := 'DATE';
    OPEN c_cur2;
    loop
    FETCH c_cur2 INTO c_rec2;
    EXIT WHEN c_cur2%NOTFOUND;
        l_temp := c_rec2.action_param_set_id;
        l_ptemp := c_rec2.param_id;
        --v_cursor := DBMS_SQL.OPEN_CURSOR;
        sql_stmt1 :=' select param_property_id '||
                      ' from ieu_wp_param_props_b '||
                      ' where action_param_set_id = :temp '||
                      ' and property_id = 10003'||
                      ' and param_id = :ptemp ';
        OPEN c_ref2 FOR sql_stmt1 USING l_temp, l_ptemp;
        LOOP
            FETCH c_ref2 INTO l_delete_param_property_id;
            EXIT WHEN c_ref2%NOTFOUND;
            select VALUE_TRANSLATABLE_FLAG into l_trans_flag
            from ieu_wp_properties_b
            where property_id = 10003;

            if (l_delete_param_property_id is not null ) then
                if (l_trans_flag = 'Y') then
                    update  ieu_wp_param_props_tl set
                    PROPERTY_VALUE = null
                    where param_property_id = l_delete_param_property_id;
                end if ;

                update  ieu_wp_param_props_b set
                PROPERTY_ID =10022,
                PROPERTY_VALUE = null
                where param_property_id = l_delete_param_property_id;

            end if;

        end LOOP;
        CLOSE c_ref2;
    end LOOP; -- for c_cur2
    CLOSE c_cur2;
commit;
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

end UpdateParamProps;



PROCEDURE ReOrdering(    x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count OUT  NOCOPY NUMBER,
                         x_msg_data  OUT  NOCOPY VARCHAR2,
                         r_enumId   IN NUMBER,
                         r_applId   IN NUMBER,
                         r_panel    IN VARCHAR2)
As

v_enumId   ieu_uwq_Sel_enumerators.sel_enum_id%type;
v_applId   ieu_wp_action_maps.application_id%type;
v_panel    ieu_uwq_maction_defs_b.maction_def_type_flag%type;

cursor c_cur is
select  d.action_param_set_label, b.action_map_sequence,
        d.action_param_set_desc , e.action_user_label, b.not_valid_flag,c.action_param_set_id
from ieu_uwq_Sel_enumerators a, ieu_wp_action_maps b,
     ieu_wp_act_param_sets_b c, ieu_wp_act_param_sets_tl d,
     ieu_uwq_maction_defs_tl e , ieu_uwq_maction_defs_b f
where  a.sel_enum_id =v_enumId
and f.maction_def_type_flag = v_panel
and e.language = FND_GLOBAL.CURRENT_LANGUAGE
and a.enum_type_uuid = b.action_map_code
and c.action_param_set_id = b.action_param_set_id
-- and b.application_id = v_applId bug#5585922
and c.wp_action_def_id = e.maction_def_id
and b.responsibility_id = -1
and d.action_param_set_id = c.action_param_set_id
and e.maction_def_id =f.maction_def_id
AND d.language=FND_GLOBAL.CURRENT_LANGUAGE
order by b.action_map_sequence;

c_rec c_cur%ROWTYPE;

v_action_map_type_code  ieu_wp_action_maps.action_map_type_code%type;

cursor c_cur2 is
select d.action_param_set_label, b.action_map_sequence,
       d.action_param_set_desc , e.action_user_label, b.not_valid_flag,c.action_param_set_id
from ieu_uwq_Sel_enumerators a, ieu_wp_action_maps b,
     ieu_wp_act_param_sets_b c, ieu_wp_act_param_sets_tl d,
     ieu_uwq_maction_defs_tl e , ieu_uwq_maction_defs_b f, ieu_uwq_node_ds ds
where  a.sel_enum_id =v_enumId
and f.maction_def_type_flag = v_panel
and e.language = FND_GLOBAL.CURRENT_LANGUAGE
AND d.language=FND_GLOBAL.CURRENT_LANGUAGE
and a.enum_type_uuid = ds.enum_type_uuid
AND b.ACTION_MAP_TYPE_CODE = v_action_map_type_code
AND to_char(ds.NODE_DS_ID) = b.ACTION_MAP_CODE
and c.action_param_set_id = b.action_param_set_id
-- and b.application_id = v_applId bug#5585922
and c.wp_action_def_id = e.maction_def_id
and b.responsibility_id = -1
and d.action_param_set_id = c.action_param_set_id
and e.maction_def_id =f.maction_def_id
order by b.action_map_sequence;

c_rec2 c_cur2%ROWTYPE;

l_count  NUMBER:=1;
begin
fnd_msg_pub.delete_msg();
x_return_status := fnd_api.g_ret_sts_success;
FND_MSG_PUB.initialize;

x_msg_data := '';
if (r_panel = 'F') then
   v_enumId := r_enumId;
   v_panel := r_panel;
   v_applId := r_applId;
   v_action_map_type_code := 'NODE_DS';
   OPEN c_cur2;
   loop
     FETCH c_cur2 INTO c_rec2;
     EXIT WHEN c_cur2%NOTFOUND;
     if (c_rec2.action_map_sequence IS NULL OR l_count <> c_rec2.action_map_sequence) then

         IF (c_rec2.action_map_sequence IS null) THEN
            EXECUTE immediate
            ' update ieu_wp_action_maps '||
            '  set action_map_sequence = :1 '||
            '  where action_map_sequence IS null '||
            '  and ACTION_MAP_TYPE_CODE = :2 '||
            '  and action_param_set_id = :3  '||
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
            --'  and action_param_set_id = :4  '||
/*********************************************************************************/
            '  and action_map_code in (select to_char(node_ds_id) ' ||
            '                          from ieu_uwq_node_ds ' ||
            '                          where enum_type_uuid in (select enum_type_uuid '||
            '                                                    from ieu_uwq_sel_enumerators '||
            '                                                    where sel_enum_id = :5 '||
            '                                                  ) '||
            '                          ) '
            --USING l_count, r_applId,'NODE_DS', c_rec2.action_param_set_id, r_enumId ;
            USING l_count, 'NODE_DS', c_rec2.action_param_set_id, r_enumId ;
          ELSE
            EXECUTE immediate
            ' update ieu_wp_action_maps '||
            '  set action_map_sequence = :1 '||
            '  where action_map_sequence = :2 '||
            '  and ACTION_MAP_TYPE_CODE = :3  ' ||
            '  and action_param_set_id = :4 '||
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
            --'  and action_param_set_id = :5 '||
/*********************************************************************************/
            '  and action_map_code in (select to_char(node_ds_id) '||
            '                          from ieu_uwq_node_ds '||
            '                          where enum_type_uuid in (select enum_type_uuid '||
            '                                                    from ieu_uwq_sel_enumerators '||
            '                                                    where sel_enum_id = :6'||
            '                                                  ) '||
            '                          )'
            --USING l_count, r_applId, c_rec2.action_map_sequence,'NODE_DS', c_rec2.action_param_set_id,
            USING l_count, c_rec2.action_map_sequence,'NODE_DS', c_rec2.action_param_set_id,
            c_rec2.action_param_set_id;
          END IF ;
     end if;
     l_count :=l_count+1;
   end loop;
   CLOSE c_cur2;
else
   v_enumId := r_enumId;
   v_panel := r_panel;
   v_applId := r_applId;
   OPEN c_cur;
   loop
     FETCH c_cur INTO c_rec;
     EXIT WHEN c_cur%NOTFOUND;
     if (c_rec.action_map_sequence IS NULL OR l_count <> c_rec.action_map_sequence) then
         IF (c_rec.action_map_sequence IS null) THEN
            EXECUTE immediate
            ' update ieu_wp_action_maps  '||
            '  set action_map_sequence = :1  '||
            '  where action_map_sequence IS null '||
            '  and action_param_set_id = :2 '||
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
           --'  and action_param_set_id = :3 '||
/*********************************************************************************/
            '  and action_map_code in (select enum_type_uuid '||
            '                          from ieu_uwq_sel_enumerators '||
            '                          where sel_enum_id = :3) '
            --USING l_count,r_applId, c_rec.action_param_set_id, r_enumId ;
            USING l_count, c_rec.action_param_set_id, r_enumId ;
         ELSE
            EXECUTE immediate
            ' update ieu_wp_action_maps '||
            '  set action_map_sequence = :1'||
            '  where action_map_sequence = :2 '||
            '  and action_param_set_id = :3 '||
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
           -- '  and action_param_set_id = :4 '||
/*********************************************************************************/
            '  and action_map_code in (select enum_type_uuid '||
            '                          from ieu_uwq_sel_enumerators '||
            '                          where sel_enum_id = :4) '
            --USING l_count , r_applId, c_rec.action_map_sequence, c_rec.action_param_set_id, r_enumId;
            USING l_count , c_rec.action_map_sequence, c_rec.action_param_set_id, r_enumId;
         END IF ;
     end if;
     l_count :=l_count+1;
   end loop;
   CLOSE c_cur;
end if ;
commit;
end ReOrdering;




PROCEDURE CreateFromQFilter( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY  NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            r_wp_action_key IN VARCHAR2,
                            r_language  IN VARCHAR2,
                            r_label  IN VARCHAR2,
                            r_desc   IN VARCHAR2,
                            r_param_set_id IN NUMBER,
                            r_enumId IN VARCHAR2,
                            r_dev_data_flag IN VARCHAR2)

 AS

l_wp_maction_def_id     NUMBER(15);
v_wp_action_key        varchar2(500);
l_param_set_id          NUMBER(15);
l_language             VARCHAR2(4);
l_source_lang          VARCHAR2(4);
l_msg_count            NUMBER(2);

l_msg_data             VARCHAR2(2000);

l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;

v_cursor1               NUMBER;
sql_stmt             varchar2(2000);
sql_stmt1             varchar2(2000);
l_param_id              NUMBER(15);
l_property_id           NUMBER(15);
l_property_value        varchar(4000);
l_not_valid_flag        varchar(5);
l_value_override_flag    varchar(5);
v_numrows1             NUMBER;
l_new_param_set_id     NUMBER(15);
l_wp_action_map_id     NUMBER(15);
l_temp_map_sequence ieu_wp_action_maps.action_map_sequence%type;
param_sets_rec    IEU_WP_ACT_PARAM_SETS_SEED_PKG.WP_ACT_PARAM_SETS_rec_type;
param_props_rec   IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type;
v_SelectStmt  Varchar2(500);
v_CursorID   INTEGER;
v_Dummy   INTEGER;
v_param_set_id ieu_wp_act_param_sets_tl.action_param_set_id%type;
v_language ieu_wp_act_param_sets_tl.language%type;
v_enumId ieu_uwq_sel_enumerators.sel_enum_id%type;
l_security_group_id  NUMBER(15);

cursor c_cur is
SELECT
   PARAM_ID, PROPERTY_ID,property_value
   , value_override_flag,not_valid_flag
    FROM ieu_wp_param_props_b
     WHERE action_param_set_id in
        (select a.action_param_set_id
        from ieu_wp_act_param_sets_b a, ieu_wp_act_param_sets_tl b, ieu_uwq_maction_defs_b c
        where a.action_param_set_id = b.action_param_set_id(+)
        and b.action_param_set_id = v_param_set_id
        and c.maction_def_key =  LTRIM(RTRIM(v_wp_action_key))
        and b.language = v_language
        and c.maction_def_id = a.wp_action_def_id
        and a.action_param_set_id in (select action_param_set_id
                                      from ieu_wp_action_maps
                                      where action_map_code in (SELECT to_char(ds.NODE_DS_ID) FROM ieu_uwq_sel_enumerators e,
                                                                                          ieu_uwq_node_ds ds
                                                                          WHERE e.sel_enum_id = v_enumId
                                                                          and e.ENUM_TYPE_UUID = ds.ENUM_TYPE_UUID)
                                     )
        )
;


-- this c_cur2 will NOT get responsibility information FROM original action
cursor c_cur2 is
SELECT
   object_version_number, application_id, action_map_type_code,
   action_map_code, panel_sec_cat_code, not_valid_flag
    FROM ieu_wp_action_maps
     WHERE responsibility_id = -1
     AND action_param_set_id in
        (select a.action_param_set_id
        from ieu_wp_act_param_sets_b a, ieu_wp_act_param_sets_tl b, ieu_uwq_maction_defs_b c
        where a.action_param_set_id = b.action_param_set_id(+)
        and b.action_param_set_id = v_param_set_id
        and c.maction_def_key =  LTRIM(RTRIM(v_wp_action_key))
        and b.language = v_language
        and c.maction_def_id = a.wp_action_def_id)
        and action_map_code in (SELECT to_char(ds.NODE_DS_ID) FROM ieu_uwq_sel_enumerators e,  ieu_uwq_node_ds ds
                                                                          WHERE e.sel_enum_id = v_enumId
                                                                          and e.ENUM_TYPE_UUID = ds.ENUM_TYPE_UUID);
c_rec  c_cur%ROWTYPE;
c_rec2 c_cur2%ROWTYPE;

BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';

   execute immediate ' select  a.wp_action_def_id  ' ||
                  ' from ieu_wp_act_param_sets_b a, ieu_uwq_maction_defs_b c ' ||
                  ' where a.action_param_set_id = :1  ' ||
                  ' and c.maction_def_key =  :2  ' ||
                  ' and c.maction_def_id = a.wp_action_def_id '
   into l_wp_maction_def_id using r_param_set_id, r_wp_action_key;


   if  l_wp_maction_def_id is not null then
       select IEU_wp_act_param_sets_b_S1.NEXTVAL into l_new_param_set_id from sys.dual;
      /* TYPE IEU_WP_ACT_PARAM_SETS_SEED_PKG.WP_ACT_PARAM_SETS_rec_type IS RECORD (
                      ACTION_PARAM_SET_ID          NUMBER(15),
                      WP_ACTION_DEF_ID  NUMBER(15),
                      ACTION_PARAM_SET_LABEL  VARCHAR2(128),
                      ACTION_PARAM_SET_DESC VARCHAR2(500),
                      created_by NUMBER(15),
                      creation_date DATE,
                      last_updated_by NUMBER(15),
                      last_update_date DATE,
                      last_update_login NUMBER(15),
                      owner VARCHAR2(15) );
       */
       param_sets_rec.ACTION_PARAM_SET_ID := l_new_param_set_id;
       param_sets_rec.WP_ACTION_DEF_ID := l_wp_maction_def_id;
       param_sets_rec.ACTION_PARAM_SET_LABEL := LTRIM(RTRIM(r_label));
       param_sets_rec.ACTION_PARAM_SET_DESC := LTRIM(RTRIM(r_desc));
       param_sets_rec.created_by := FND_GLOBAL.USER_ID;
       param_sets_rec.creation_date := SYSDATE;
       param_sets_rec.last_updated_by := FND_GLOBAL.USER_ID;
       param_sets_rec.last_update_date := SYSDATE;
       param_sets_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
       param_sets_rec.owner := 1;
       IEU_WP_ACT_PARAM_SETS_SEED_PKG.Insert_Row(p_WP_ACT_PARAM_SETS_rec=>param_Sets_rec);
   end if ;

   v_wp_action_key := r_wp_action_key;
   v_param_set_id := r_param_set_id;
   v_language := r_language;
   v_enumId := r_enumId;

   OPEN c_cur;
   Loop
       FETCH c_cur INTO c_rec;
       EXIT WHEN c_cur%NOTFOUND;
      select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
      /*TYPE IEU_WP_PARAM_PROPS_SEED_PKG.wp_param_props_rec_type IS RECORD (
                    PARAM_PROPERTY_ID NUMBER(15),
                    ACTION_PARAM_SET_ID     NUMBER,
                    PARAM_ID          NUMBER,
                    PROPERTY_ID       NUMBER,
                    PROPERTY_VALUE    VARCHAR(4000),
                    PROPERTY_VALUE_TL VARCHAR(4000),
                    VALUE_OVERRIDE_FLAG   VARCHAR2(5),
                    created_by NUMBER(15),
                    creation_date DATE,
                    last_updated_by NUMBER(15),
                    last_update_date DATE,
                    last_update_login NUMBER(15),
                    not_valid_flag     VARCHAR(4000),
                    owner VARCHAR2(15) );
       */
       param_props_rec.PARAM_PROPERTY_ID := l_param_property_id;
       param_props_rec.ACTION_PARAM_SET_ID := l_new_param_set_id;
       param_props_rec.PARAM_ID := c_rec.param_id;
       param_props_rec.PROPERTY_ID := c_rec.property_id;
       param_props_rec.PROPERTY_VALUE := c_rec.property_value;
       param_props_rec.PROPERTY_VALUE_TL := c_rec.property_value;
       param_props_rec.VALUE_OVERRIDE_FLAG := c_rec.value_override_flag;
       param_props_rec.created_by := FND_GLOBAL.USER_ID;
       param_props_rec.creation_date := SYSDATE;
       param_props_rec.last_updated_by := FND_GLOBAL.USER_ID;
       param_props_rec.last_update_date := SYSDATE;
       param_props_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
       param_props_rec.NOT_VALID_FLAG := c_rec.not_valid_flag;
       param_props_rec.owner := 1;
       IEU_WP_PARAM_PROPS_SEED_PKG.Insert_Row(p_wp_param_props_rec => param_props_rec);
   end loop;
   CLOSE c_cur;


   OPEN c_cur2;
   Loop
       FETCH c_cur2 INTO c_rec2;
       EXIT WHEN c_cur2%NOTFOUND;
       l_temp_map_sequence := 1;
       --INSERT one RECORD WITH responsibility_id = -1
       select IEU_WP_ACTION_MAPS_S1.NEXTVAL into  l_wp_action_map_id from sys.dual;
       EXECUTE immediate
       ' insert INTO IEU_WP_ACTION_MAPS '||
       ' (WP_ACTION_MAP_ID, '||
       ' CREATED_BY, '||
       ' CREATION_DATE, '||
       ' LAST_UPDATED_BY, '||
       ' LAST_UPDATE_DATE, '||
       ' LAST_UPDATE_LOGIN, '||
       ' ACTION_PARAM_SET_ID, '||
       ' APPLICATION_ID, '||
       ' RESPONSIBILITY_ID, '||
       ' ACTION_MAP_TYPE_CODE, '||
       ' ACTION_MAP_CODE, '||
       ' PANEL_SEC_CAT_CODE, '||
       ' NOT_VALID_FLAG, '||
       ' OBJECT_VERSION_NUMBER, '||
       ' Security_group_id, '||
       ' action_map_sequence, '||
       ' DEV_DATA_FLAG '||
       ' ) VALUES ( '||
       ' :1, '||
       '  :2, '||
       '  :3, '||
       '  :4, '||
       '  :5, '||
       '  :6, '||
       '  :7 , '||
       '  :8 , '||
       '  :9, '||
       '  :10 , '||
       '  :11, '||
       '  :12, '||
       '  :13, '||
       '  :14, '||
       '  :15 , '||
       '  :16 , '||
       '  :17 '||
       '  ) '
       USING l_wp_action_map_id, FND_GLOBAL.USER_ID, SYSDATE,FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.LOGIN_ID,
       l_new_param_set_id, c_rec2.application_id,'-1', c_rec2.action_map_type_code,
       c_rec2.action_map_code,c_rec2.panel_sec_cat_code, c_rec2.not_valid_flag, c_rec2.object_version_number,
       l_security_group_id, l_temp_map_sequence, r_dev_data_flag;


   end loop;
   CLOSE c_cur2;
   commit;
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


end CreateFromQFilter;


END ieu_wp_action_pvt;

/
