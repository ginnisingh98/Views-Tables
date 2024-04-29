--------------------------------------------------------
--  DDL for Package Body IEU_WORK_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORK_ACTION_PVT" AS
/* $Header: IEUWACB.pls 120.1 2007/12/17 11:41:58 svidiyal ship $ */


PROCEDURE Node_Mapping(   x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count OUT  NOCOPY NUMBER,
                          x_msg_data  OUT  NOCOPY VARCHAR2,
                          p_enum_id IN NUMBER,
                          p_mapping_application IN NUMBER,
                          p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                          p_maction_def_type_flag IN VARCHAR2,
                          p_act_application IN NUMBER
                    ) as

    l_language             VARCHAR2(4);
    l_source_lang          VARCHAR2(4);
    l_return_status             VARCHAR2(4);
    l_msg_count            NUMBER(2);
    l_msg_data             VARCHAR2(2000);
    act_map_obj  SYSTEM.IEU_wp_action_maps_OBJ;
    act_map_obj1  SYSTEM.IEU_wp_action_maps_OBJ;
    l_enum_uuid IEU_UWQ_SEL_ENUMERATORS.ENUM_TYPE_UUID%type;
    l_temp_map_sequence IEU_WP_ACTION_MAPS.action_map_sequence%type;
    l_map_sequence IEU_WP_ACTION_MAPS.action_map_sequence%type;
    l_panel_sec_cat_code   IEU_WP_ACTION_MAPS.PANEL_SEC_CAT_CODE%type;
    l_section_id  IEU_WP_NODE_SECTION_MAPS.SECTION_ID%type;
    l_section_map_sequence IEU_WP_NODE_SECTION_MAPS.SECTION_MAP_SEQUENCE%type;
    l_action_map_type_code  IEU_WP_ACTION_MAPS.ACTION_MAP_TYPE_CODE%type;
    l_count NUMBER(5);
    l_duplicate NUMBER(5);
    l_wp_node_section_map_id IEU_WP_NODE_SECTION_MAPS.WP_NODE_SECTION_MAP_ID%type;
    name_fail_exception        EXCEPTION;

BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';



    select enum_type_uuid into l_enum_uuid
    from ieu_uwq_sel_enumerators
    where sel_enum_id = p_enum_id;

    -- check if this node already have a action with same label
    SELECT count(*) INTO l_duplicate
    FROM ieu_wp_action_maps
    where action_param_set_id = p_param_set_id
 /*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/

   --and application_id = p_mapping_application
/*********************************************************************************/
    AND responsibility_id = -1
    AND action_map_code = l_enum_uuid;

    IF l_duplicate > 0 then
        RAISE name_fail_exception;
    else
        select max(m.action_map_sequence) into l_temp_map_sequence
        from ieu_wp_action_maps m,
             ieu_uwq_maction_defs_b db,
             ieu_wp_act_param_sets_b sb
        -- where m.application_id = p_mapping_application
        where m.action_map_type_code = 'NODE'
        and m.action_map_code = l_enum_uuid
        -- and m.application_id = db.application_id
        and db.maction_def_type_flag = p_maction_def_type_flag
        and db.maction_def_id = sb.wp_action_def_id
        and sb.action_param_set_id = m.action_param_set_id
        and m.responsibility_id = -1;



       if (l_temp_map_sequence IS NULL) then
            l_map_sequence := 1;
       else
            l_map_sequence := l_temp_map_sequence +1;
       end if;

       if (upper(p_maction_def_type_flag) ='W') then
                l_section_id := 10002;
                l_section_map_sequence := 2;
                l_panel_sec_cat_code := null;
                l_action_map_type_code := 'NODE';

        elsif (upper(p_maction_def_type_flag) ='I') then
                l_section_id := 10001;
                l_section_map_sequence := 1;
                l_panel_sec_cat_code := 'NOTES';
                l_action_map_type_code := 'NODE';
        elsif (upper(p_maction_def_type_flag) ='G') then
                l_panel_sec_cat_code := null;
                l_action_map_type_code := 'NODE';
        elsif (upper(p_maction_def_type_flag) ='F') then
                l_panel_sec_cat_code := null;
        end if;



        act_map_obj := SYSTEM.IEU_wp_action_maps_OBJ(null, p_param_set_id,
                                          p_mapping_application, null, 'NODE',
                                          l_enum_uuid, l_map_sequence, l_panel_sec_cat_code,
                                          'N', 'Y');

        CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj);


        act_map_obj1 := SYSTEM.IEU_wp_action_maps_OBJ(null, p_param_set_id,
                                              p_mapping_application, -1, 'NODE',
                                              l_enum_uuid, l_map_sequence, l_panel_sec_cat_code,
                                              'N', 'Y');

        CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj1);

       update IEU_UWQ_SEL_ENUMERATORS set
       LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
       WORK_PANEL_REGISTERED_FLAG = 'Y'
       where SEL_ENUM_ID = p_enum_id;

       if (upper(p_maction_def_type_flag) <> 'G' ) then

            select count(*) into l_count
            from IEU_WP_NODE_SECTION_MAPS
            where ENUM_TYPE_UUID = l_enum_uuid
            and APPLICATION_ID = p_mapping_application
            AND SECTION_ID = l_section_id;

            if (l_count > 0) then

              update IEU_WP_NODE_SECTION_MAPS set
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
              RESPONSIBILITY_ID = null,
              SECTION_MAP_SEQUENCE = l_section_map_sequence
              where ENUM_TYPE_UUID = l_enum_uuid
              and APPLICATION_ID = p_mapping_application
              and SECTION_ID = l_section_id;


            else

              select  IEU_WP_NODE_SECTION_MAPS_S1.nextval into l_wp_node_section_map_id from sys.dual;

              insert INTO IEU_WP_NODE_SECTION_MAPS
              (WP_NODE_SECTION_MAP_ID,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
		    SECURITY_GROUP_ID,
              APPLICATION_ID,
              RESPONSIBILITY_ID,
              ENUM_TYPE_UUID,
              SECTION_ID,
              SECTION_MAP_SEQUENCE,
		    NOT_VALID_FLAG
              ) values
              (l_wp_node_section_map_id,
              0,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.LOGIN_ID,
		    NULL,
              p_mapping_application,
              null,
              l_enum_uuid,
              l_section_id,
              l_section_map_sequence,
		    null);

            end if;
       end if;


       x_return_status := fnd_api.g_ret_sts_success;
       COMMIT;
   END if;

   EXCEPTION
         WHEN name_fail_exception THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            fnd_message.set_name ('IEU', 'IEU_PROV_WP_LABLE_UNIQUE');
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (
              p_count => x_msg_count,
              p_data => x_msg_data
            );

         WHEN fnd_api.g_exc_error THEN
        --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);

             ROLLBACK;
             x_return_status := fnd_api.g_ret_sts_error;

         WHEN fnd_api.g_exc_unexpected_error THEN
         --dbms_outPUT.PUT_LINE('unexpected Error : '||sqlerrm);

             ROLLBACK;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

         WHEN OTHERS THEN
         --dbms_outPUT.PUT_LINE('other Error : '||sqlerrm);

             ROLLBACK;
             x_return_status := fnd_api.g_ret_sts_unexp_error;


END   Node_Mapping;

PROCEDURE Validate_Action_Label( x_return_status  OUT  NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                        x_msg_data  OUT NOCOPY  VARCHAR2,
                        p_label IN VARCHAR2,
                         p_param_set_id IN NUMBER
                       )
AS

    l_language             VARCHAR2(4);
    l_act_usr_lbl_count  NUMBER(10);
    l_temp_count NUMBER;
    l_msg_count            NUMBER(10);
    l_msg_data             VARCHAR2(2000);
    temp_act_user_label IEU_UWQ_MACTION_DEFS_TL.action_user_label%type;
    l_set_id_count NUMBER(10);


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_set_id_count :=0;
    temp_act_user_label := LTRIM(RTRIM(p_label));
    select count(b.maction_def_id) into l_act_usr_lbl_count
    from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl,
    ieu_wp_act_param_sets_b s
    where
    b.maction_def_id = tl.maction_def_id
    and b.maction_def_type_flag = (select maction_def_type_flag
                                   from ieu_uwq_maction_defs_b
                                   where maction_def_id = (select wp_action_def_id
                                                           from ieu_wp_act_param_sets_b
				                                                   where action_param_set_id = p_param_set_id))
    and s.wp_action_def_id = b.maction_def_id
    and tl.language = l_language
    and lower(tl.action_user_label) = lower(temp_act_user_label);

    select count(b.maction_def_id) into l_set_id_count
    from ieu_uwq_maction_defs_b b,
    ieu_wp_act_param_sets_b s,
    ieu_wp_act_param_sets_tl stl
    where
    b.maction_def_type_flag = (select maction_def_type_flag
                               from ieu_uwq_maction_defs_b
                               where maction_def_id = (select wp_action_def_id
                                                       from ieu_wp_act_param_sets_b
				                                               where action_param_set_id = p_param_set_id))
    and s.wp_action_def_id = b.maction_def_id

    and s.action_param_set_id = stl.action_param_set_id
    and stl.language = l_language
    and lower(stl.action_param_set_label) =  lower(temp_act_user_label);


    --DBMS_OUTPUT.PUT_LINE(' set  lable count : '|| l_set_id_count);

    if (l_act_usr_lbl_count <> 0 or l_set_id_count <> 0) then
        FND_MESSAGE.set_name('IEU', 'IEU_PROV_WP_LABLE_UNIQUE');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    end if;

   -- x_return_status := fnd_api.g_ret_sts_success;

    x_msg_count := fnd_msg_pub.COUNT_MSG();

    FOR i in 1..x_msg_count LOOP
        l_msg_data := '';
        l_msg_count := 0;
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count := fnd_msg_pub.COUNT_MSG();

           FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
           END LOOP;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;
        WHEN OTHERS THEN
            --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := fnd_msg_pub.COUNT_MSG();

            FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;

END Validate_Action_Label;

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
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ
) AS

    l_action_map_id     NUMBER(15);
BEGIN

        select IEU_wp_action_maps_S1.NEXTVAL into l_action_map_id from sys.dual;

        insert INTO IEU_wp_action_mapS
        (WP_ACTION_MAP_ID,
         OBJECT_VERSION_NUMBER,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ACTION_PARAM_SET_ID,
         APPLICATION_ID,
         RESPONSIBILITY_ID,
         ACTION_MAP_TYPE_CODE,
         ACTION_MAP_CODE,
         ACTION_MAP_SEQUENCE,
         PANEL_SEC_CAT_CODE,
         NOT_VALID_FLAG,
         DEV_DATA_FLAG
        )
        values (
        l_action_map_id,
        1,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        rec_obj.action_param_set_id,
        rec_obj.application_id,
        rec_obj.responsibility_id,
        rec_obj.action_map_type_code,
        rec_obj.action_map_code,
        rec_obj.action_map_sequence,
        rec_obj.panel_sec_cat_code,
	      rec_obj.not_valid_flag,
        rec_obj.dev_data_flag
        );

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

PROCEDURE Create_Work_Action (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2)
                             AS

    l_language             VARCHAR2(4);
    l_source_lang          VARCHAR2(4);
    l_return_status             VARCHAR2(4);
    l_msg_count            NUMBER(2);
    l_msg_data             VARCHAR2(2000);
    l_maction_def_id          IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_ID%TYPE;
    l_action_param_set_id     IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%TYPE;
    l_enum_uuid IEU_UWQ_SEL_ENUMERATORS.ENUM_TYPE_UUID%type;
    l_temp_map_sequence IEU_WP_ACTION_MAPS.action_map_sequence%type;
    l_map_sequence IEU_WP_ACTION_MAPS.action_map_sequence%type;
    l_wp_node_section_map_id IEU_WP_NODE_SECTION_MAPS.WP_NODE_SECTION_MAP_ID%type;
    act_map_obj  SYSTEM.IEU_wp_action_maps_OBJ;
    act_map_obj1  SYSTEM.IEU_wp_action_maps_OBJ;
    l_count NUMBER(5);
    l_section_id  IEU_WP_NODE_SECTION_MAPS.SECTION_ID%type;
    l_section_map_sequence IEU_WP_NODE_SECTION_MAPS.SECTION_MAP_SEQUENCE%type;
    l_panel_sec_cat_code   IEU_WP_ACTION_MAPS.PANEL_SEC_CAT_CODE%type;
    l_action_map_type_code  IEU_WP_ACTION_MAPS.ACTION_MAP_TYPE_CODE%type;
BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';
    l_count := 0;
    l_section_id := 0;
    l_section_map_sequence := 0;

   IEU_WorkPanel_PVT.Validate_Action ( l_return_status,
                                       l_msg_count,
                                       l_msg_data,
                                       rec_obj, 'Y', p_maction_def_type_flag, null);

    if (l_return_status = 'S') then
        select IEU_UWQ_MACTION_DEFS_B_S1.NEXTVAL into l_maction_def_id from sys.dual;
        if ( p_maction_def_type_flag = 'M' ) then
	     insert INTO IEU_UWQ_MACTION_DEFS_B
          (MACTION_DEF_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          ACTION_PROC,
          APPLICATION_ID,
          MACTION_DEF_TYPE_FLAG,
          MACTION_DEF_KEY,
          OBJECT_VERSION_NUMBER,
          MULTI_SELECT_FLAG
          )
          values(
          l_maction_def_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          LTRIM(RTRIM(rec_obj.action_proc)),
          rec_obj.application_id,
          null,
          LTRIM(RTRIM(rec_obj.maction_def_key)),
          0,
          rec_obj.multi_select_flag
          );
	   else
	     insert INTO IEU_UWQ_MACTION_DEFS_B
          (MACTION_DEF_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
	     LAST_UPDATE_LOGIN,
          ACTION_PROC,
          APPLICATION_ID,
          MACTION_DEF_TYPE_FLAG,
	     MACTION_DEF_KEY,
	     OBJECT_VERSION_NUMBER,
          MULTI_SELECT_FLAG
          )
          values(
          l_maction_def_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          LTRIM(RTRIM(rec_obj.action_proc)),
          rec_obj.application_id,
          p_maction_def_type_flag,
          LTRIM(RTRIM(rec_obj.maction_def_key)),
          0,
          rec_obj.multi_select_flag
          );
	   end if ;

        insert INTO IEU_UWQ_MACTION_DEFS_TL
        (MACTION_DEF_ID,
         LANGUAGE,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ACTION_USER_LABEL,
         SOURCE_LANG,
         ACTION_DESCRIPTION,
         OBJECT_VERSION_NUMBER
         ) values (
         l_maction_def_id,
         l_language,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         LTRIM(RTRIM(rec_obj.action_user_label)),
         l_source_lang,
         LTRIM(RTRIM(rec_obj.action_description)),
         0
         );

         if (p_maction_def_type_flag <> 'N' and p_maction_def_type_flag <> 'M') then
        select IEU_WP_ACT_PARAM_SETS_B_S1.NEXTVAL into l_action_param_set_id from sys.dual;
        insert INTO IEU_WP_ACT_PARAM_SETS_B
        (ACTION_PARAM_SET_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         WP_ACTION_DEF_ID,
         OBJECT_VERSION_NUMBER
         ) values (
         l_action_param_set_id,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         l_maction_def_id,
         0
         );
        insert INTO IEU_WP_ACT_PARAM_SETS_TL
        (ACTION_PARAM_SET_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ACTION_PARAM_SET_LABEL,
         LANGUAGE,
         SOURCE_LANG,
         ACTION_PARAM_SET_DESC,
         OBJECT_VERSION_NUMBER
         ) values (
         l_action_param_set_id,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         LTRIM(RTRIM(rec_obj.action_user_label)),
         l_language,
         l_source_lang,
         LTRIM(RTRIM(rec_obj.action_description)),
         0
         );
         end if;
         if (p_maction_def_type_flag <> 'F') then

                         select max(m.action_map_sequence) into l_temp_map_sequence
                         from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db,
                                  ieu_wp_act_param_sets_b sb
                         --where m.application_id  = rec_obj.application_id
                         where m.action_map_type_code = 'NODE'
                         --and m.application_id = db.application_id
                         and db.maction_def_type_flag = p_maction_def_type_flag
                         and db.maction_def_id = sb.wp_action_def_id
                         and sb.action_param_set_id = m.action_param_set_id
                         and m.responsibility_id = -1;

                         if (l_temp_map_sequence IS NULL) then
                                l_map_sequence := 1;
                         else
                                l_map_sequence := l_temp_map_sequence +1;
                         end if;

         end if;
/*
         if (p_maction_def_type_flag ='W') then
              l_section_id := 10002;
              l_section_map_sequence := 2;
              l_panel_sec_cat_code := null;
              l_action_map_type_code := 'NODE';
         elsif (p_maction_def_type_flag ='I') then
              l_section_id := 10001;
              l_section_map_sequence := 1;
              l_panel_sec_cat_code := 'NOTES';
              l_action_map_type_code := 'NODE';
         elsif (p_maction_def_type_flag ='G') then
              l_panel_sec_cat_code := null;
              l_action_map_type_code := 'NODE';
         elsif (p_maction_def_type_flag = 'F') then
              l_action_map_type_code := 'NODE_DS';
              l_map_sequence := 1;
              l_panel_sec_cat_code := null;
         end if;
*/
         if (p_maction_def_type_flag <> 'F') then
              update IEU_UWQ_SEL_ENUMERATORS set
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
              WORK_PANEL_REGISTERED_FLAG = 'Y'
              where SEL_ENUM_ID = rec_obj.enum_id;

        end if;


        x_return_status := fnd_api.g_ret_sts_success;
    else
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
    end if;


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

END Create_Work_Action;
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
PROCEDURE CreateFromAction(      x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 r_maction_def_id IN NUMBER,
                                 r_language  IN VARCHAR2,
                                 r_label  IN VARCHAR2,
                                 r_desc   IN VARCHAR2,
                                 r_param_set_id IN NUMBER)
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


cursor c_cur is
SELECT
   PARAM_ID, PROPERTY_ID,property_value, value_override_flag,not_valid_flag
FROM ieu_wp_param_props_b
WHERE action_param_set_id in
        (select a.action_param_set_id
        from ieu_wp_act_param_sets_b a, ieu_wp_act_param_sets_tl b, ieu_uwq_maction_defs_b c
        where a.action_param_set_id = b.action_param_set_id(+)
        and b.action_param_set_id = r_param_set_id
        and c.maction_def_id =  r_maction_def_id
        and b.language = r_language
        and c.maction_def_id = a.wp_action_def_id
        );
BEGIN

   fnd_msg_pub.delete_msg();
   x_return_status := fnd_api.g_ret_sts_success;
   FND_MSG_PUB.initialize;
   l_language := FND_GLOBAL.CURRENT_LANGUAGE;
   l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
   x_msg_data := '';

   Validate_Action_Label( x_return_status  ,
                          x_msg_count ,
                          x_msg_data  ,
                          r_label,  r_param_set_id);
  if x_return_status = 'S' then
   select IEU_wp_act_param_sets_b_S1.NEXTVAL into l_new_param_set_id from sys.dual;

   insert into IEU_WP_ACT_PARAM_SETS_B
     ( ACTION_PARAM_SET_ID,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       WP_ACTION_DEF_ID,
       OBJECT_VERSION_NUMBER)
   values( l_new_param_set_id,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.LOGIN_ID,
       r_maction_def_id,
       1);

   INSERT INTO ieu_WP_ACT_PARAM_SETS_tl
     ( ACTION_PARAM_SET_ID,
       language,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       ACTION_PARAM_SET_LABEL,
       ACTION_PARAM_SET_DESC,
       source_lang,
       OBJECT_VERSION_NUMBER)
    values(  l_new_param_set_id,
       r_language,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.LOGIN_ID,
       LTRIM(RTRIM(r_label)),
       LTRIM(RTRIM(r_desc)),
       l_source_lang,
       1);

   FOR c_rec in c_cur LOOP
   begin
       select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
       insert INTO IEU_WP_PARAM_PROPS_B
         (PARAM_PROPERTY_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          ACTION_PARAM_SET_ID,
          PARAM_ID,
          PROPERTY_ID,
          PROPERTY_VALUE,
          VALUE_OVERRIDE_FLAG,
          NOT_VALID_FLAG,
          OBJECT_VERSION_NUMBER)
      VALUES (l_param_property_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          l_new_param_set_id,
          c_rec.param_id,
          c_rec.property_id,
          c_rec.property_value,
          c_rec.value_override_flag,
          c_rec.not_valid_flag,
          1
         );
       select VALUE_TRANSLATABLE_FLAG into l_trans_flag
       from ieu_wp_properties_b
       where property_id = c_rec.property_id;

       if l_trans_flag = 'Y' then

         insert INTO IEU_WP_PARAM_PROPS_TL
         (PARAM_PROPERTY_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          PROPERTY_VALUE,
          LANGUAGE,
          SOURCE_LANG,
          OBJECT_VERSION_NUMBER
         ) VALUES (
          l_param_property_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          c_rec.property_value,
          l_language,
          l_source_lang,
          1
         );
       end if;



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
       end;

   end loop;
  end if ;
commit;
end CreateFromAction;


PROCEDURE Delete_Action_From_Node (
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT  NOCOPY NUMBER,
                                    x_msg_data  OUT  NOCOPY VARCHAR2,
                                    x_param_set_id IN NUMBER,
                                    x_node_id IN NUMBER,
                                    x_maction_id IN NUMBER,
                                    x_maction_def_flag IN VARCHAR2
    ) is

    l_language             VARCHAR2(4);
    l_action_param_set_id  IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type;
    l_maction_def_id       IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_ID%type;
    l_num_map_entries      NUMBER;
    l_num_set_entries      NUMBER;
    l_count_map NUMBER;
    l_def_type_flag  IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_TYPE_FLAG%type;
    l_mact_def_id    IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_ID%type;
    l_section_id number;

BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;
  x_msg_data := '';

  l_language := FND_GLOBAL.CURRENT_LANGUAGE;
  -- I. get the maction_def_type_flag
  --1. determine if this action has 1:1 for action_maps to action_param_sets
  --2. delete from maps
  --3. if 1:1 in 1,
  --a. query if 1:1 between action_param_sets and maction_defs
  --b. delete from action_param_sets and param_props
  --c. if 1:1 in 1, delete from maction_Defs and action_params and param_defs

  --I.
  if (x_maction_id <> -1) then
	l_def_type_flag := x_maction_def_flag;
  else
     SELECT db.maction_def_type_flag into l_def_type_flag
     FROM  ieu_uwq_maction_defs_b db,
          ieu_wp_act_param_sets_b sb
     WHERE db.maction_def_id = sb.wp_action_def_id
     AND   sb.action_param_set_id = x_param_set_id;
  end if;
  --1.
  if ( l_def_type_flag <> 'F' and l_def_type_flag <> 'N' and l_def_type_flag <> 'M') then

          SELECT count(unique(action_map_code))
          INTO l_num_map_entries
          FROM ieu_wp_action_maps
          WHERE action_map_type_code = 'NODE' AND action_param_set_id = x_param_set_id;

  elsif ( l_def_type_flag ='F') then

          SELECT count(unique(action_map_code))
          INTO l_num_map_entries
          FROM ieu_wp_action_maps
          WHERE action_map_type_code = 'NODE_DS' AND action_param_set_id = x_param_set_id;


  end if;

  --2.
  if (x_node_id <> 0) then
   if ( l_def_type_flag <> 'F') then

          DELETE FROM ieu_wp_action_maps
          WHERE action_param_set_id = x_param_set_id AND
                        action_map_type_code = 'NODE' AND
                        action_map_code IN
                          (SELECT enum_type_uuid FROM ieu_uwq_sel_enumerators
                           WHERE sel_enum_id = x_node_id);
          -- algupta modified on 8/31/04, if no action/information,
          -- delete related records in IEU_WP_NODE_SECTION_MAPS.
          if (l_def_type_flag = 'W' or l_def_type_flag = 'I') then
               if (l_def_type_flag = 'W') then
                    l_section_id := 10002;
               else
                    l_section_id := 10001;
               end if;

               l_count_map := 0;
               select count(distinct action_param_set_id) into l_count_map
               from ieu_wp_action_maps
               where action_map_type_code = 'NODE'
               AND action_map_code IN
                              (SELECT enum_type_uuid FROM ieu_uwq_sel_enumerators
                               WHERE sel_enum_id = x_node_id)
                               and action_param_set_id in
                                   (SELECT action_param_set_id
                                   FROM  ieu_wp_act_param_sets_b
                                   WHERE  wp_action_def_id in
                                      (select maction_def_id
                                      from ieu_uwq_maction_defs_b
                                      where maction_def_type_flag = l_def_type_flag
                                      ));
                if (l_count_map = 0) then
                     delete from  IEU_WP_NODE_SECTION_MAPS
                     where ENUM_TYPE_UUID IN
                            (SELECT enum_type_uuid FROM ieu_uwq_sel_enumerators
                             WHERE sel_enum_id = x_node_id)
                             and SECTION_ID = l_section_id;
                end if;
           end if;

   elsif ( l_def_type_flag ='F') then

                DELETE FROM ieu_wp_action_maps
                WHERE action_param_set_id = x_param_set_id AND
                        action_map_type_code = 'NODE_DS' AND
                        action_map_code IN
                                (SELECT ds.NODE_DS_ID FROM ieu_uwq_sel_enumerators e,  ieu_uwq_node_ds ds
                                WHERE e.sel_enum_id = x_node_id
                                and e.ENUM_TYPE_UUID = ds.ENUM_TYPE_UUID);

   end if;
  end if;
  --3.
  if (x_node_id = 0) then
   if (l_def_type_flag <> 'N' and l_def_type_flag <>'M') then
    --a.
    SELECT wp_action_def_id, COUNT(*)
    INTO l_maction_def_id, l_num_set_entries
    FROM ieu_wp_act_param_sets_b
    WHERE wp_action_def_id IN
           (SELECT wp_action_def_id FROM ieu_wp_act_param_sets_b
            WHERE action_param_set_id = x_param_set_id)
    GROUP BY wp_action_def_id;

    --b.
    DELETE FROM ieu_wp_param_props_tl
    WHERE param_property_id IN
            (SELECT param_property_id FROM ieu_wp_param_props_b
             WHERE
             action_param_set_id = x_param_set_id);

    DELETE FROM ieu_wp_param_props_b
    WHERE action_param_set_id = x_param_set_id;

    DELETE FROM ieu_wp_act_param_sets_tl
    WHERE action_param_set_id = x_param_set_id;

    DELETE FROM ieu_wp_act_param_sets_b
    WHERE action_param_set_id = x_param_set_id;

    --c.
    IF (l_num_set_entries = 1) THEN
      DELETE FROM ieu_wp_param_defs_tl
      WHERE param_id IN
             (SELECT param_id FROM ieu_wp_action_params
              WHERE wp_action_def_id = l_maction_def_id);

      DELETE FROM ieu_wp_param_defs_b
      WHERE param_id IN
             (SELECT param_id FROM ieu_wp_action_params
              WHERE wp_action_def_id = l_maction_def_id);

      DELETE FROM ieu_wp_action_params
      WHERE wp_action_def_id = l_maction_def_id;

      DELETE FROM ieu_uwq_maction_defs_tl
      WHERE maction_def_id = l_maction_def_id;

      DELETE FROM ieu_uwq_maction_defs_b
      WHERE maction_def_id = l_maction_def_id;
    END IF;
   else
      DELETE FROM ieu_uwq_maction_defs_tl
      WHERE maction_def_id = x_maction_id;

      DELETE FROM ieu_uwq_maction_defs_b
      WHERE maction_def_id = x_maction_id;

   end IF;
  END IF;

  COMMIT;

  if (l_def_type_flag <> 'F' and l_def_type_flag <> 'N' and l_def_type_flag <> 'M') then
    select count(m.WP_ACTION_MAP_ID) into l_count_map
    from IEU_WP_ACTION_MAPS m
    where m.ACTION_MAP_CODE = (select ENUM_TYPE_UUID from
            ieu_uwq_sel_enumerators where SEL_ENUM_ID = x_node_id)
    and m.ACTION_MAP_TYPE_CODE = 'NODE';

    if (l_count_map = 0) then

        update IEU_UWQ_SEL_ENUMERATORS set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        WORK_PANEL_REGISTERED_FLAG = null
        where SEL_ENUM_ID = x_node_id;


    end if;
  end if;
  COMMIT;
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
 END Delete_Action_From_Node;


END ieu_work_action_pvt;


/
