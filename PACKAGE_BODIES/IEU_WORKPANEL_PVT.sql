--------------------------------------------------------
--  DDL for Package Body IEU_WORKPANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORKPANEL_PVT" AS
/* $Header: IEUVWPB.pls 120.2 2007/12/17 11:40:55 svidiyal ship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_WorkPanel_PVT
-- Purpose
--    To provide easy to use apis for UQW Work Panel
-- History
--    08-May-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ==================================================================


--===================================================================
-- NAME
--   Validate_Action
--
-- PURPOSE
--    Private api to Validate fields.
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to validate action
--
--
-- HISTORY
--   08-May-2002     GPAGADAL   Created

--===================================================================

PROCEDURE Validate_Action (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                        is_create IN VARCHAR2,
                        p_maction_def_type_flag IN VARCHAR2,
                        p_param_set_id IN NUMBER) AS

    l_language             VARCHAR2(4);

    l_act_usr_lbl_count  NUMBER(10);

    l_act_def_key_count NUMBER(10);

    l_temp_act_label   IEU_UWQ_MACTION_DEFS_TL.ACTION_USER_LABEL%type;

    l_temp_pkg_name   IEU_UWQ_MACTION_DEFS_B.ACTION_PROC%TYPE;


    l_temp_aproc   IEU_UWQ_MACTION_DEFS_B.ACTION_PROC%TYPE;

    l_temp_count NUMBER(10);
    l_msg_count            NUMBER(10);
    l_msg_data             VARCHAR2(2000);

    l_set_id_count NUMBER(10);

    temp_act_user_label IEU_UWQ_MACTION_DEFS_TL.action_user_label%type;

    temp_act_key IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_KEY%type;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_act_usr_lbl_count := 0;
    l_act_def_key_count := 0;



    temp_act_user_label := LTRIM(RTRIM(rec_obj.action_user_label));

   -- select count(b.maction_def_id) into l_act_usr_lbl_count
   -- from IEU_UWQ_MACTION_DEFS_B b, IEU_UWQ_MACTION_DEFS_TL tl
   -- where b.maction_def_id = tl.maction_def_id
   -- and tl.language = l_language
   -- and lower(tl.action_user_label) = lower(temp_act_user_label)
   -- and b.maction_def_type_flag = p_maction_def_type_flag;


   if (p_maction_def_type_flag <> 'F' and p_maction_def_type_flag <> 'N' and p_maction_def_type_flag <> 'M' ) then

    select count(b.maction_def_id) into l_act_usr_lbl_count
    from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
    ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl
    where e. sel_enum_id =  rec_obj.enum_id
    -- and e.application_id = m.application_id
    and e.enum_type_uuid = m.action_map_code
    and b.maction_def_id = tl.maction_def_id
    and tl.language = l_language
    and s.wp_action_def_id = b.maction_def_id
    and s.action_param_set_id = m.action_param_set_id
    and m.action_map_type_code = 'NODE'
    and b.maction_def_type_flag = p_maction_def_type_flag
    and s.action_param_set_id = stl.action_param_set_id
    and stl.language = l_language
    and m.responsibility_id = -1
    and lower(tl.action_user_label) = lower(temp_act_user_label);


    --select count(sb.action_param_set_id) into l_set_id_count
    --from IEU_WP_ACT_PARAM_SETS_B sb, IEU_WP_ACT_PARAM_SETS_TL stl
    --where sb.action_param_set_id = stl.action_param_set_id
    --and stl.language = l_language
    --and lower(stl.action_param_set_label) = lower(temp_act_user_label);



    select count(b.maction_def_id) into l_set_id_count
    from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
    ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl
    where e. sel_enum_id =  rec_obj.enum_id
    --and e.application_id = m.application_id
    and e.enum_type_uuid = m.action_map_code
    and b.maction_def_id = tl.maction_def_id
    and tl.language = l_language
    and s.wp_action_def_id = b.maction_def_id
    and s.action_param_set_id = m.action_param_set_id
    and m.action_map_type_code = 'NODE'
    and b.maction_def_type_flag = p_maction_def_type_flag
    and s.action_param_set_id = stl.action_param_set_id
    and stl.language = l_language
    and m.responsibility_id = -1
    and lower(stl.action_param_set_label) =  lower(temp_act_user_label);


 elsif (p_maction_def_type_flag = 'F') then

         select count(b.maction_def_id) into l_act_usr_lbl_count
     from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
     ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,
     ieu_wp_act_param_sets_tl stl,  ieu_uwq_node_ds ds
     where e. sel_enum_id =  rec_obj.enum_id
     --and e.application_id = m.application_id
     and e.enum_type_uuid = ds.ENUM_TYPE_UUID
     and b.maction_def_id = tl.maction_def_id
     and tl.language = l_language
     and s.wp_action_def_id = b.maction_def_id
     and s.action_param_set_id = m.action_param_set_id
     and m.action_map_type_code = 'NODE_DS'
     and b.maction_def_type_flag = 'F'
     and s.action_param_set_id = stl.action_param_set_id
     and stl.language = l_language
     and m.responsibility_id = -1
     and lower(tl.action_user_label) = lower(temp_act_user_label)
         and  to_char(ds.NODE_DS_ID) = m.ACTION_MAP_CODE;



        select count(b.maction_def_id) into l_set_id_count
        from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
        ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,
        ieu_wp_act_param_sets_tl stl,  ieu_uwq_node_ds ds
        where e. sel_enum_id =  rec_obj.enum_id
        --and e.application_id = m.application_id
        and e.enum_type_uuid = ds.ENUM_TYPE_UUID
        and b.maction_def_id = tl.maction_def_id
        and tl.language = l_language
        and s.wp_action_def_id = b.maction_def_id
        and s.action_param_set_id = m.action_param_set_id
        and m.action_map_type_code = 'NODE_DS'
        and b.maction_def_type_flag = 'F'
        and s.action_param_set_id = stl.action_param_set_id
        and stl.language = l_language
        and m.responsibility_id = -1
        and lower(stl.action_param_set_label) =  lower(temp_act_user_label)
        and  to_char(ds.NODE_DS_ID) = m.ACTION_MAP_CODE;



 end if;

    if (is_create = 'N' and p_maction_def_type_flag <> 'M' and p_maction_def_type_flag <> 'N') then
        select action_param_set_label into l_temp_act_label
        from ieu_wp_act_param_sets_tl stl, ieu_wp_act_param_sets_b s
        where s.action_param_set_id = stl.action_param_set_id
        and s.wp_action_def_id = rec_obj.maction_def_id
        and stl.language = l_language
        and stl.action_param_set_id = p_param_set_id;

        if (l_temp_act_label <> rec_obj.action_user_label) then
            if (l_set_id_count <> 0) then
                FND_MESSAGE.set_name('IEU', 'IEU_PROV_WP_LABLE_UNIQUE');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            end if;
        end if;
   else
        if (l_act_usr_lbl_count <> 0 or l_set_id_count <> 0) then
            FND_MESSAGE.set_name('IEU', 'IEU_PROV_WP_LABLE_UNIQUE');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
  end if;


  -- this check for media and non-media actions is always done
  if (p_maction_def_type_flag = 'M' or p_maction_def_type_flag = 'N') then
    -- count how many maction_defs of the same type have the same name, besides the current one
    select count(mb.maction_def_id) into l_set_id_count
    from ieu_uwq_maction_defs_tl mtl,
         ieu_uwq_maction_defs_b mb
    where mb.maction_def_id = mtl.maction_def_id and
          mb.maction_def_id <> nvl(rec_obj.maction_def_id, -1) and       -- ignore current action's record
          nvl(mb.maction_def_type_flag, 'M') = p_maction_def_type_flag and
          mtl.action_user_label = rec_obj.action_user_label and  --
          mtl.language = l_language;

    if (l_set_id_count >= 1) then
      FND_MESSAGE.set_name('IEU', 'IEU_PROV_WP_LABLE_UNIQUE');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    end if;
  end if;

    temp_act_key := LTRIM(RTRIM(rec_obj.maction_def_key));

    if (is_create = 'Y')  then

        select count(*) into l_act_def_key_count from IEU_UWQ_MACTION_DEFS_B
        where lower(MACTION_DEF_KEY) = lower(temp_act_key)
        and maction_def_type_flag = p_maction_def_type_flag;


        if (l_act_def_key_count <> 0) then
            FND_MESSAGE.set_name('IEU', 'IEU_PROV_WP_NAME_UNIQUE');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

    end if;

     --  commented for seed115
     --    l_temp_aproc := rec_obj.action_proc;
     --   l_temp_pkg_name := substr(l_temp_aproc,1, (instr(l_temp_aproc,'.',1,1)-1));


     --  select count(*) into l_temp_count
     --   from all_objects
     --   where owner = 'APPS' and object_type in('PACKAGE', 'IEU_PROV_PKG_INVALID')
     --  and status ='VALID' and object_name = l_temp_pkg_name;



     --   if (l_temp_count <= 0) then
     --       FND_MESSAGE.set_name('IEU', 'IEU_PROV_PKG_INVALID');
     --       FND_MSG_PUB.Add;
     --       x_return_status := FND_API.G_RET_STS_ERROR;
     --   end if;



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
    -- DBMS_OUTPUT.PUT_LINE(' Error : '||sqlerrm);

            FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --     DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
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
            --DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);


            x_msg_count := fnd_msg_pub.COUNT_MSG();

            FOR i in 1..x_msg_count LOOP
             l_msg_data := '';
             l_msg_count := 0;
             FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
             x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;
        --     DBMS_OUTPUT.PUT_LINE('x_return_status : '||x_return_status);


END Validate_Action;

--===================================================================
-- NAME
--   Validate_Action_Label
--
-- PURPOSE
--    Private api to Validate label fields.
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to validate action
--
--
-- HISTORY
--   08-May-2002     GPAGADAL   Created

--===================================================================


PROCEDURE Validate_Action_Label( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT NOCOPY VARCHAR2,
                        p_label IN VARCHAR2,
                        p_maction_def_type_flag IN VARCHAR2,
                        p_enum_id IN NUMBER)
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


   -- select count(sb.action_param_set_id) into l_set_id_count
   -- from IEU_WP_ACT_PARAM_SETS_B sb, IEU_WP_ACT_PARAM_SETS_TL stl
   -- where sb.action_param_set_id = stl.action_param_set_id
   -- and stl.language = l_language
   --and lower(stl.action_param_set_label) = lower(temp_act_user_label);



if(p_maction_def_type_flag <> 'F') then

    select count(b.maction_def_id) into l_act_usr_lbl_count
    from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
    ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl
    where e. sel_enum_id =  p_enum_id
    -- and e.application_id = m.application_id
    and e.enum_type_uuid = m.action_map_code
    and b.maction_def_id = tl.maction_def_id
    and tl.language = l_language
    and s.wp_action_def_id = b.maction_def_id
    and s.action_param_set_id = m.action_param_set_id
    and m.action_map_type_code = 'NODE'
    and b.maction_def_type_flag = p_maction_def_type_flag
    and s.action_param_set_id = stl.action_param_set_id
    and stl.language = l_language
    and m.responsibility_id = -1
    and lower(tl.action_user_label) = lower(temp_act_user_label);

    --DBMS_OUTPUT.PUT_LINE(' maction  lable count : '||l_act_usr_lbl_count);

    select count(b.maction_def_id) into l_set_id_count
    from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
    ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl
    where e. sel_enum_id = p_enum_id
    --and e.application_id = m.application_id
    and e.enum_type_uuid = m.action_map_code
    and b.maction_def_id = tl.maction_def_id
    and tl.language = l_language
    and s.wp_action_def_id = b.maction_def_id
    and s.action_param_set_id = m.action_param_set_id
    and m.action_map_type_code = 'NODE'
    and b.maction_def_type_flag = p_maction_def_type_flag
    and s.action_param_set_id = stl.action_param_set_id
    and stl.language = l_language
    and m.responsibility_id = -1
    and lower(stl.action_param_set_label) =  lower(temp_act_user_label);

 elsif (p_maction_def_type_flag = 'F') then

         select count(b.maction_def_id) into l_act_usr_lbl_count
     from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
     ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl,
     IEU_UWQ_NODE_DS ds
     where e. sel_enum_id =  p_enum_id
     --and e.application_id = m.application_id
     and e.enum_type_uuid = ds.ENUM_TYPE_UUID
     and b.maction_def_id = tl.maction_def_id
     and tl.language = l_language
     and s.wp_action_def_id = b.maction_def_id
     and s.action_param_set_id = m.action_param_set_id
     and m.action_map_type_code = 'NODE_DS'
     and b.maction_def_type_flag = 'F'
     and s.action_param_set_id = stl.action_param_set_id
     and stl.language = l_language
     and m.responsibility_id = -1
        and m.action_map_code = to_char(ds.NODE_DS_ID)
    and lower(tl.action_user_label) = lower(temp_act_user_label);




     select count(b.maction_def_id) into l_set_id_count
            from ieu_uwq_maction_defs_b b, ieu_uwq_maction_defs_tl tl, ieu_wp_action_maps m,
            ieu_wp_act_param_sets_b s, ieu_uwq_sel_enumerators e,  ieu_wp_act_param_sets_tl stl, IEU_UWQ_NODE_DS ds
            where e. sel_enum_id = p_enum_id
            --and e.application_id = m.application_id
            and e.enum_type_uuid = ds.ENUM_TYPE_UUID
            and b.maction_def_id = tl.maction_def_id
            and tl.language = l_language
            and s.wp_action_def_id = b.maction_def_id
            and s.action_param_set_id = m.action_param_set_id
            and m.action_map_type_code = 'NODE_DS'
            and b.maction_def_type_flag = 'F'
            and s.action_param_set_id = stl.action_param_set_id
            and stl.language = l_language
            and m.responsibility_id = -1
                and m.action_map_code = to_char(ds.NODE_DS_ID)
    and lower(stl.action_param_set_label) =  lower(temp_act_user_label);


 end if;

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
    -- DBMS_OUTPUT.PUT_LINE(' Error : '||sqlerrm);

           FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
           END LOOP;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --           DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);


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
           --      DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);


             x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;
    -- DBMS_OUTPUT.PUT_LINE('x_return_status : '||x_return_status);

END Validate_Action_Label;

--===================================================================
-- NAME
--   Create_MAction
--   PURPOSE
--    Private api to create an action
--
-- NOTES
--    1. UWQ Work Panel Admin will use this
--    procedure to create a work panel action
--
--
-- HISTORY
--   08-May-2002     GPAGADAL   Created
--===================================================================

PROCEDURE Create_MAction (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2)
                             AS

        l_language             VARCHAR2(4);

        l_source_lang          VARCHAR2(4);

        l_return_status             VARCHAR2(4);

        l_msg_count            NUMBER(2);

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


    IEU_WorkPanel_PVT.Create_MAction2 (x_return_status,
                             x_msg_count,
                             x_msg_data,
                             rec_obj,
                             p_maction_def_type_flag,
                             null);


   COMMIT;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_MAction;

--===================================================================
-- NAME
--   Create_MAction2
--   PURPOSE
--    Private api to create an action
--
-- NOTES
--    1. UWQ Work Panel Admin will use this
--    procedure to create a work panel action
--
--
-- HISTORY
--   14-NOV-2002     GPAGADAL   Created
--===================================================================



PROCEDURE Create_MAction2 (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY  VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2,
                             p_datasource IN VARCHAR2)
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

--dbms_output.put_line('out out from validate_action :' || l_return_status);

    if (l_return_status = 'S') then
    --dbms_output.put_line('out out from validate_action is S');
        select IEU_UWQ_MACTION_DEFS_B_S1.NEXTVAL into l_maction_def_id from sys.dual;

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

    --DBMS_OUTPUT.PUT_LINE('inserted in maction defs b: ');

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

        --DBMS_OUTPUT.PUT_LINE('inserted in maction defs tl ');

        select IEU_WP_ACT_PARAM_SETS_B_S1.NEXTVAL into l_action_param_set_id from sys.dual;

        --DBMS_OUTPUT.PUT_LINE('got next val '|| l_action_param_set_id);


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
        --DBMS_OUTPUT.PUT_LINE('inserted in param sets b: ');

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

        -- DBMS_OUTPUT.PUT_LINE('inserted in param sets tl: ');


        select enum_type_uuid into l_enum_uuid
        from ieu_uwq_sel_enumerators
        where sel_enum_id = rec_obj.enum_id;

         if (p_maction_def_type_flag <> 'F') then

                         select max(m.action_map_sequence) into l_temp_map_sequence
                         from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db,
                                  ieu_wp_act_param_sets_b sb
                         --where m.application_id  = rec_obj.application_id
                         where m.action_map_type_code = 'NODE'
                         and m.action_map_code = l_enum_uuid
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

        --DBMS_OUTPUT.PUT_LINE('calling  IEU_wp_action_maps_OBJ');
/*
TYPE IEU_WP_ACTION_MAPS_OBJ AS OBJECT
(
  wp_action_map_id NUMBER,
  ACTION_PARAM_SET_ID NUMBER,
  APPLICATION_ID NUMBER,
  RESPONSIBILITY_ID NUMBER,
  ACTION_MAP_TYPE_CODE VARCHAR2(50),
  ACTION_MAP_CODE VARCHAR2(50),
  ACTION_MAP_SEQUENCE NUMBER,
  PANEL_SEC_CAT_CODE VARCHAR2(32),
  NOT_VALID_FLAG VARCHAR2(5),
  DEV_DATA_FLAG VARCHAR2(1)
)

*/

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
                l_enum_uuid := p_datasource;
        end if;


if (p_maction_def_type_flag <> 'F') then

        act_map_obj := SYSTEM.IEU_wp_action_maps_OBJ(null, l_action_param_set_id,
                                              rec_obj.application_id, null, l_action_map_type_code,
                                              l_enum_uuid, l_map_sequence, l_panel_sec_cat_code, null, 'Y');

        IEU_WP_ACTION_PVT.CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj);


 end if;



        act_map_obj1 := SYSTEM.IEU_wp_action_maps_OBJ(null, l_action_param_set_id,
                                              rec_obj.application_id, -1, l_action_map_type_code,
                                              l_enum_uuid, l_map_sequence, l_panel_sec_cat_code, null, 'Y');

        IEU_WP_ACTION_PVT.CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj1);


        --DBMS_OUTPUT.PUT_LINE('inserted in maction maps: ');

        if (p_maction_def_type_flag <> 'F') then


                        update IEU_UWQ_SEL_ENUMERATORS set
                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                        WORK_PANEL_REGISTERED_FLAG = 'Y'
                        where SEL_ENUM_ID = rec_obj.enum_id;


                        if (p_maction_def_type_flag <> 'G') then

                                select count(*) into l_count
                                from IEU_WP_NODE_SECTION_MAPS
                                where ENUM_TYPE_UUID = l_enum_uuid
                                and APPLICATION_ID = rec_obj.application_id
                                AND SECTION_ID = l_section_id;

                                if (l_count > 0) then

                                        update IEU_WP_NODE_SECTION_MAPS set
                                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                                        LAST_UPDATE_DATE = SYSDATE,
                                        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                                        RESPONSIBILITY_ID = null,
                                        SECTION_MAP_SEQUENCE = l_section_map_sequence
                                        where ENUM_TYPE_UUID = l_enum_uuid
                                        and APPLICATION_ID = rec_obj.application_id
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
                                        APPLICATION_ID,
                                        RESPONSIBILITY_ID,
                                        ENUM_TYPE_UUID,
                                        SECTION_ID,
                                        SECTION_MAP_SEQUENCE
                                        ) values
                                        (l_wp_node_section_map_id,
                                        0,
                                        FND_GLOBAL.USER_ID,
                                        SYSDATE,
                                        FND_GLOBAL.USER_ID,
                                        SYSDATE,
                                        FND_GLOBAL.LOGIN_ID,
                                        rec_obj.application_id,
                                        null,
                                        l_enum_uuid,
                                        l_section_id,
                                        l_section_map_sequence);

                                end if;
                   end if;
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
    --    DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
     --   DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
     --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);

            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END Create_MAction2;

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
PROCEDURE Update_MAction (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_param_set_id IN NUMBER,
                             p_maction_def_type_flag IN VARCHAR2) AS


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_action_param_set_id  IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type;

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';

   IEU_WorkPanel_PVT.Validate_Action ( l_return_status,
                     l_msg_count,
                     l_msg_data,
                     rec_obj, 'N', p_maction_def_type_flag, p_param_set_id);


    if (l_return_status = 'S') then
	  if (p_maction_def_type_flag = 'N' or p_maction_def_type_flag = 'M') then
        update IEU_UWQ_MACTION_DEFS_B set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        ACTION_PROC = LTRIM(RTRIM(rec_obj.action_proc)),
        MULTI_SELECT_FLAG  = rec_obj.multi_select_flag
        where MACTION_DEF_ID = p_param_set_id
        and nvl(MACTION_DEF_TYPE_FLAG,'M') = p_maction_def_type_flag;

        update IEU_UWQ_MACTION_DEFS_tl set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
	   action_description =  LTRIM(RTRIM(rec_obj.action_description)),
	   action_user_label =  LTRIM(RTRIM(rec_obj.action_user_label))
        where MACTION_DEF_ID = p_param_set_id
        and l_language IN (language, source_lang);


	  else
        update IEU_UWQ_MACTION_DEFS_B set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        ACTION_PROC = LTRIM(RTRIM(rec_obj.action_proc)),
        MULTI_SELECT_FLAG  = rec_obj.multi_select_flag
        where MACTION_DEF_ID = rec_obj.maction_def_id
        and MACTION_DEF_TYPE_FLAG = p_maction_def_type_flag;


        update  IEU_WP_ACT_PARAM_SETS_TL set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        ACTION_PARAM_SET_LABEL = LTRIM(RTRIM(rec_obj.action_user_label)),
        ACTION_PARAM_SET_DESC  = LTRIM(RTRIM(rec_obj.action_description))
        where ACTION_PARAM_SET_ID = p_param_set_id
        and l_language IN (language, source_lang);
	   end if;

    else
        x_return_status := l_return_status;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
    end if;

COMMIT;

END Update_MAction;


--===================================================================
-- NAME
--   Delete_MAction
--
-- PURPOSE
--    Private api to delete work panel action
--
-- NOTES
--    1. UWQ  Work Panel Admin will use this procedure to delete an action
--
--
-- HISTORY
--   08-May-2002     GPAGADAL   Created


--===================================================================


PROCEDURE Delete_MAction (
    x_action_def_id IN NUMBER
    ) is

    l_language             VARCHAR2(4);

    l_action_param_set_id  IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type;



BEGIN
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;


    select ACTION_PARAM_SET_ID into l_action_param_set_id
    from IEU_WP_ACT_PARAM_SETS_B
    where WP_ACTION_DEF_ID = x_action_def_id;



    delete from IEU_UWQ_MACTION_DEFS_B
    where  MACTION_DEF_ID =  x_action_def_id;

    if (sql%notfound) then
        null;
    end if;

    delete from IEU_UWQ_MACTION_DEFS_TL
    where  MACTION_DEF_ID =  x_action_def_id and language= l_language;

    if (sql%notfound) then
        null;
    end if;


    delete from IEU_WP_ACT_PARAM_SETS_B
    where WP_ACTION_DEF_ID = x_action_def_id;

    if (sql%notfound) then
        null;
    end if;


    delete from IEU_WP_ACT_PARAM_SETS_TL
    where ACTION_PARAM_SET_ID = l_action_param_set_id and language= l_language;

    if (sql%notfound) then
        null;
    end if;

COMMIT;
END Delete_MAction;

--===================================================================
-- NAME
--   Delete_Action_From_Node
--
-- PURPOSE
--    Private api to delete work panel action
--
-- NOTES
--    1. UWQ  Work Panel Admin will use this procedure to delete an action
--       from a work panel node.
--
--
-- HISTORY
--   12-June-2002     Msista   Created


--===================================================================


PROCEDURE Delete_Action_From_Node (
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY VARCHAR2,
  x_param_set_id IN NUMBER,
  x_node_id IN NUMBER
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
    SELECT db.maction_def_type_flag
    into l_def_type_flag
    FROM  ieu_uwq_maction_defs_b db,
          ieu_wp_act_param_sets_b sb
    WHERE db.maction_def_id = sb.wp_action_def_id
    AND   sb.action_param_set_id = x_param_set_id;

  --1.
  if ( l_def_type_flag <> 'F') then

          SELECT count(unique(action_map_code))
          INTO l_num_map_entries
          FROM ieu_wp_action_maps
          WHERE action_map_type_code = 'NODE' AND
                        action_param_set_id = x_param_set_id;

  elsif ( l_def_type_flag ='F') then

          SELECT count(unique(action_map_code))
          INTO l_num_map_entries
          FROM ieu_wp_action_maps
          WHERE action_map_type_code = 'NODE_DS' AND
                        action_param_set_id = x_param_set_id;


  end if;

  --2.
   if ( l_def_type_flag <> 'F') then
          DELETE FROM ieu_wp_action_maps
          WHERE action_param_set_id = x_param_set_id AND
                        action_map_type_code = 'NODE' AND
                        action_map_code IN
                          (SELECT enum_type_uuid FROM ieu_uwq_sel_enumerators
                           WHERE sel_enum_id = x_node_id);

        -- dolee modified on 8/27/04, if no action/information,
        -- delete related records in IEU_WP_NODE_SECTION_MAPS
	   if (l_def_type_flag = 'W' or l_def_type_flag = 'I') then
	          if (l_def_type_flag = 'W') then
	               l_section_id := 10002;
	          else l_section_id := 10001;
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
	                                 )
	                           );
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
                                (SELECT to_char(ds.NODE_DS_ID) FROM ieu_uwq_sel_enumerators e,  ieu_uwq_node_ds ds
                                WHERE e.sel_enum_id = x_node_id
                                and e.ENUM_TYPE_UUID = ds.ENUM_TYPE_UUID);

  end if;






  --3.
  IF (l_num_map_entries = 1 and l_def_type_flag ='F') THEN

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
  END IF;

  COMMIT;

  if (l_def_type_flag <> 'F') then
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


--===================================================================
-- NAME
--   Validate_Parameter
--   PURPOSE
--    Private api to validate parameter
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to validate
--       a work panel action parameter name and label
--
--
-- HISTORY
--   20-June-2002     GPAGADAL   Created
--===================================================================



PROCEDURE Validate_Parameter( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data  OUT NOCOPY VARCHAR2,
                            rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ,
                            is_create IN VARCHAR2) AS



    l_language             VARCHAR2(4);

    l_param_usr_lbl_count  NUMBER(10);

    l_param_name_count NUMBER(10);

    l_temp_param_label   ieu_wp_param_defs_TL.PARAM_USER_LABEL%type;
    l_temp_param_name   ieu_wp_param_defs_b.PARAM_NAME%type;


    l_temp_count NUMBER(10);
    l_msg_count            NUMBER(10);
    l_msg_data             VARCHAR2(2000);


    temp_param_user_label ieu_wp_param_defs_TL.PARAM_USER_LABEL%type;

    temp_param_name ieu_wp_param_defs_b.PARAM_NAME%type;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_param_usr_lbl_count := 0;
    l_param_name_count := 0;


    temp_param_user_label := LTRIM(RTRIM(rec_obj.param_user_label));
    temp_param_name := LTRIM(RTRIM(rec_obj.param_name));


    select count(*) into l_param_name_count
    from ieu_wp_action_params p,
    ieu_wp_param_defs_b b
    where p.PARAM_ID = b.PARAM_ID
    and p.WP_ACTION_DEF_ID = rec_obj.wp_action_def_id
    and lower(b.PARAM_NAME) = lower(temp_param_name);


    select count(*) into l_param_usr_lbl_count
    from ieu_wp_action_params p,
    ieu_wp_param_defs_b b,
    ieu_wp_param_defs_tl tl
    where p.PARAM_ID = b.PARAM_ID
    and p.WP_ACTION_DEF_ID = rec_obj.wp_action_def_id
    and b.PARAM_ID = tl.PARAM_ID
    and tl.LANGUAGE = l_language
    and lower(tl.PARAM_USER_LABEL) = lower(temp_param_user_label);

    if (is_create = 'Y') then

        if (l_param_name_count <> 0) then
            FND_MESSAGE.set_name('IEU', 'Parameter name must be unique');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if (l_param_usr_lbl_count <> 0) then
            FND_MESSAGE.set_name('IEU', 'Parameter label must be unique');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

    end if;


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
    -- DBMS_OUTPUT.PUT_LINE(' Error : '||sqlerrm);

            FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --     DBMS_OUTPUT.PUT_LINE('unexpected Error : '||sqlerrm);
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
         --   DBMS_OUTPUT.PUT_LINE('other Error : '||sqlerrm);


            x_msg_count := fnd_msg_pub.COUNT_MSG();

            FOR i in 1..x_msg_count LOOP
             l_msg_data := '';
             l_msg_count := 0;
             FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
             x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;
        --     DBMS_OUTPUT.PUT_LINE('x_return_status : '||x_return_status);




END Validate_Parameter;




--===================================================================
-- NAME
--   Create_Param_Defs
--   PURPOSE
--    Private api to create parameter
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to create
--       a work panel action parameter
--
--
-- HISTORY
--   10-May-2002     GPAGADAL   Created
--===================================================================



PROCEDURE Create_Param_Defs (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ,
                             p_param_id OUT NOCOPY NUMBER) AS

    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);

    l_return_status             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;

    l_action_param_map_id          IEU_WP_ACTION_PARAMS.ACTION_PARAM_MAP_ID%TYPE;

    l_action_param_set_id     IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%TYPE;


BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';



    IEU_WorkPanel_PVT.Validate_Parameter ( l_return_status,
                     l_msg_count,
                     l_msg_data,
                     rec_obj, 'Y');

    if (l_return_status = 'S') then
        select IEU_WP_PARAM_DEFS_B_S1.NEXTVAL into l_param_id from sys.dual;


        insert INTO IEU_WP_PARAM_DEFS_B
        (PARAM_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PARAM_NAME,
         DATA_TYPE,
         OBJECT_VERSION_NUMBER,
         APPLICATION_ID
         ) values
         (l_param_id,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         LTRIM(RTRIM(rec_obj.param_name)),
         rec_obj.data_type,
         0,
         rec_obj.application_id
         );

        --dbms_outPUT.PUT_LINE('inserted into param defs b ');
        -- APPLICATION_ID
        --rec_obj.application_id

        insert INTO IEU_WP_PARAM_DEFS_TL
        (PARAM_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        PARAM_USER_LABEL,
        PARAM_DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG,
        OBJECT_VERSION_NUMBER
        ) VALUES (
        l_param_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        LTRIM(RTRIM(rec_obj.param_user_label)),
        LTRIM(RTRIM(rec_obj.param_description)),
        l_language,
        l_source_lang,
        0
        );

        --DBMS_OUTPUT.PUT_LINE('inserted into param defs tl ');

        select IEU_WP_ACTION_PARAMS_S1.NEXTVAL into l_action_param_map_id from sys.dual;

        insert INTO IEU_WP_ACTION_PARAMS
        (PARAM_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        WP_ACTION_DEF_ID,
        ACTION_PARAM_MAP_ID,
        NOT_VALID_FLAG,
        OBJECT_VERSION_NUMBER
        ) VALUES (
        l_param_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        rec_obj.wp_action_def_id,
        l_action_param_map_id,
        null,
        0
        );

        --dbms_outPUT.PUT_LINE('inserted into params ');
        p_param_id := l_param_id;

 else
 x_return_status := l_return_status;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;
 end if;


COMMIT;

 EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;


        WHEN fnd_api.g_exc_unexpected_error THEN
            --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            --dbms_outPUT.PUT_LINE('Error : '||sqlerrm);
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


END Create_Param_Defs;


--===================================================================
-- NAME
--   Update_Param_Defs
--   PURPOSE
--    Private api to update parameter details
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to update
--        work panel action parameter details
--
--
-- HISTORY
--   10-May-2002     GPAGADAL   Created
--===================================================================


PROCEDURE Update_Param_Defs (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ
                             ) AS


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;

    l_action_param_map_id          IEU_WP_ACTION_PARAMS.ACTION_PARAM_MAP_ID%TYPE;

    l_action_param_set_id     IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%TYPE;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';




    update IEU_WP_PARAM_DEFS_B set
     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
     LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
     DATA_TYPE = rec_obj.data_type
    where PARAM_ID = rec_obj.param_id;


    if (SQL%NOTFOUND) then
        null;
    end if;


    update IEU_WP_PARAM_DEFS_TL set
     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
     LAST_UPDATE_DATE = SYSDATE,
     LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
     PARAM_USER_LABEL = LTRIM(RTRIM(rec_obj.param_user_label)),
     PARAM_DESCRIPTION = LTRIM(RTRIM(rec_obj.param_description))
    where PARAM_ID = rec_obj.param_id
    and l_language IN (language, source_lang);

    if (SQL%NOTFOUND) then
        null;
    end if;


    COMMIT;
    x_return_status := fnd_api.g_ret_sts_success;



END Update_Param_Defs;



--===================================================================
-- NAME
--   Create_Param_Props
--   PURPOSE
--    Private api to create parameter properties
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to create
--        work panel action parameter properties
--
--
-- HISTORY
--   10-May-2002     GPAGADAL   Created
--===================================================================


PROCEDURE Create_Param_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY  NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER)AS


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;

    l_return_status             VARCHAR2(4);


BEGIN



    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


    if ( p_property_id <> -1) then

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
         OBJECT_VERSION_NUMBER
         ) VALUES (
         l_param_property_id,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         p_action_param_set_id,
         p_param_id,
         p_property_id,
         p_property_value,
         'F',
         0
         );
         --dbms_outPUT.PUT_LINE('inserted into param props b ');

         select VALUE_TRANSLATABLE_FLAG into l_trans_flag
         from ieu_wp_properties_b
         where property_id = p_property_id;

         if (l_trans_flag = 'Y') then

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
              p_property_value,
              l_language,
              l_source_lang,
              0
             );

             --dbms_outPUT.PUT_LINE('inserted into param props tl ');
         end if;

      end if;

 COMMIT;



     EXCEPTION
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

END Create_Param_Props;


--===================================================================
-- NAME
--   Update_Param_Props
--   PURPOSE
--    Private api to update parameter properties
--
-- NOTES
--    1. UWQ Work Panel Admin will use this procedure to update
--        work panel action parameter properties
--
--
-- HISTORY
--   10-May-2002     GPAGADAL   Created
--===================================================================


PROCEDURE Update_Param_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER)AS

    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;


    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';



    if (p_property_id = 10003 or p_property_id =10010 or p_property_id = 10021
        or p_property_id =10011 or p_property_id = 10022) then


       EXECUTE immediate
       ' update IEU_WP_PARAM_PROPS_B set  '||
       '    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,  '||
       '   LAST_UPDATE_DATE = SYSDATE, '||
       '    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID, '||
       '    PROPERTY_VALUE = :1, '||
       '    PROPERTY_ID = :2 '||
       '    where PARAM_ID=  :3 '||
       '    and ACTION_PARAM_SET_ID = :4 ' ||
       '    and PROPERTY_ID in ( 10010, 10021, 10011, 10022, 10003)'
       USING p_property_value, p_property_id,p_param_id,p_action_param_set_id;
         if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then

            select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;


            EXECUTE immediate
            ' INSERT INTO IEU_WP_PARAM_PROPS_B '||
            ' (PARAM_PROPERTY_ID, '||
            ' CREATED_BY, '||
            ' CREATION_DATE,'||
            ' LAST_UPDATED_BY, '||
            ' LAST_UPDATE_DATE, '||
            ' LAST_UPDATE_LOGIN, '||
            ' ACTION_PARAM_SET_ID, '||
            ' PARAM_ID, '||
            ' PROPERTY_ID, '||
            ' PROPERTY_VALUE, '||
            ' VALUE_OVERRIDE_FLAG, '||
            ' OBJECT_VERSION_NUMBER '||
            ' ) VALUES ( ' ||
            ' :1, '||
            ' :2, '||
            ' :3, '||
            ' :4, '||
            ' :5, '||
            ' :6, '||
            ' :7, '||
            ' :8, '||
            ' :9, '||
            ' :10, '||
            ' :11, '||
            ' :12 '||
            ' ) '
            USING l_param_property_id,FND_GLOBAL.USER_ID,SYSDATE, FND_GLOBAL.USER_ID,
            SYSDATE,FND_GLOBAL.LOGIN_ID, p_action_param_set_id,p_param_id,p_property_id,
            p_property_value, 'F', '0';

        end if;




    else



            EXECUTE immediate
            ' update IEU_WP_PARAM_PROPS_B set '||
            '    LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
            '    LAST_UPDATE_DATE = SYSDATE, '||
            '    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID, '||
            '    PROPERTY_VALUE = :1 '||
            ' where PARAM_ID=  :2 '||
            '    and ACTION_PARAM_SET_ID = :3 '||
            '    and PROPERTY_ID = :4 '
            USING p_property_value,p_param_id, p_action_param_set_id, p_property_id ;

                if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then

                 select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
                     EXECUTE immediate
                     ' INSERT INTO IEU_WP_PARAM_PROPS_B'||
                     ' (PARAM_PROPERTY_ID, '||
                     '  CREATED_BY, '||
                     '  CREATION_DATE, '||
                     '  LAST_UPDATED_BY, '||
                     '  LAST_UPDATE_DATE, '||
                     '  LAST_UPDATE_LOGIN, '||
                     '  ACTION_PARAM_SET_ID, '||
                     ' PARAM_ID, '||
                     ' PROPERTY_ID, '||
                     ' PROPERTY_VALUE, '||
                     ' VALUE_OVERRIDE_FLAG, '||
                     ' OBJECT_VERSION_NUMBER '||
                     ' ) VALUES ( '||
                     ' :1, '||
                     ' :2, '||
                     ' :3, '||
                     ' :4, '||
                     ' :5, '||
                     ' :6, '||
                     ' :7, '||
                     ' :8, '||
                     ' :9, '||
                     ' :10, '||
                     ' :11, '||
                     ' :12) '
                     USING l_param_property_id,FND_GLOBAL.USER_ID,SYSDATE,
                      FND_GLOBAL.USER_ID, SYSDATE,FND_GLOBAL.LOGIN_ID,
                      p_action_param_set_id, p_param_id, p_property_id,
                       p_property_value, 'F','0' ;
                       EXECUTE immediate
                       ' select VALUE_TRANSLATABLE_FLAG '||
                       ' from ieu_wp_properties_b '||
                       ' where property_id = :1 '
                        into l_trans_flag  USING p_property_id;

                       if (l_trans_flag = 'Y') then

                           EXECUTE immediate
                           ' insert INTO IEU_WP_PARAM_PROPS_TL '||
                           ' (PARAM_PROPERTY_ID, '||
                           ' CREATED_BY, '||
                           ' CREATION_DATE, '||
                           '  LAST_UPDATED_BY, '||
                           ' LAST_UPDATE_DATE, '||
                           ' LAST_UPDATE_LOGIN, '||
                           ' PROPERTY_VALUE, '||
                           ' LANGUAGE, '||
                           ' SOURCE_LANG, '||
                           ' OBJECT_VERSION_NUMBER '||
                           ' ) VALUES ( '||
                           ' :1, '||
                           ' :2, '||
                           ' :3,'||
                           ' :4, '||
                           ' :5, '||
                           ' :6, '||
                           ' :7, '||
                           ' :8, '||
                           ' :9, '||
                           ' :10 '||
                           ') '
                           USING l_param_property_id, FND_GLOBAL.USER_ID, SYSDATE,
                           FND_GLOBAL.USER_ID, SYSDATE,FND_GLOBAL.LOGIN_ID,
                            p_property_value, l_language, l_source_lang , '0' ;

                        end if;


                end if;



                begin

                    execute immediate
                    ' select PARAM_PROPERTY_ID '||
                    ' from IEU_WP_PARAM_PROPS_B '||
                    ' where PARAM_ID = :1 '||
                    ' and ACTION_PARAM_SET_ID = :2 ' ||
                    ' and PROPERTY_ID = :3 '
                    into l_param_property_id USING p_param_id,p_action_param_set_id, p_property_id  ;


                    EXECUTE immediate
                    ' update IEU_WP_PARAM_PROPS_TL set '||
                    '    LAST_UPDATED_BY = FND_GLOBAL.USER_ID, '||
                    '    LAST_UPDATE_DATE = SYSDATE, '||
                    '    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID, '||
                    '    PROPERTY_VALUE = :1 ' ||
                    ' where PARAM_PROPERTY_ID = :2 '
                    USING p_property_value, l_param_property_id;

                        if (sql%notfound) then
                            null;
                        end if;


                       EXCEPTION

                            WHEN NO_DATA_FOUND THEN
                                null;
                 end;



    end if;

    x_return_status := fnd_api.g_ret_sts_success;

    COMMIT;


END Update_Param_Props;


PROCEDURE Update_Column_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER)AS

    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;


    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
    if (p_property_id = 10003 or p_property_id = 10022) then
--if (p_property_id = 10003 or p_property_id = 10022 or p_property_id = 10011) then
/*********************************************************************************/
       update IEU_WP_PARAM_PROPS_B set
       LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
       PROPERTY_VALUE = p_property_value,
       PROPERTY_ID = p_property_id
       where PARAM_ID=  p_param_id
       and ACTION_PARAM_SET_ID = p_action_param_set_id
/*******************ADD FOR FORWARD PORT BUG5585922 BY MAJHA**********************/
       and PROPERTY_ID in (10022, 10003);
      --and PROPERTY_ID in (10022, 10003, 10011);
/*********************************************************************************/
       if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then

            select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;


            INSERT INTO IEU_WP_PARAM_PROPS_B
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
            OBJECT_VERSION_NUMBER
            ) VALUES (
            l_param_property_id,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
            p_action_param_set_id,
            p_param_id,
            p_property_id,
            p_property_value,
            'F',
            0
            );

        end if;




    else



            update IEU_WP_PARAM_PROPS_B set
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                PROPERTY_VALUE = p_property_value
            where PARAM_ID=  p_param_id
                and ACTION_PARAM_SET_ID = p_action_param_set_id
                and PROPERTY_ID = p_property_id;

                if (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) then

                 select IEU_WP_PARAM_PROPS_B_S1.NEXTVAL into  l_param_property_id from sys.dual;
                      INSERT INTO IEU_WP_PARAM_PROPS_B
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
                      OBJECT_VERSION_NUMBER
                      ) VALUES (
                      l_param_property_id,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.LOGIN_ID,
                      p_action_param_set_id,
                      p_param_id,
                      p_property_id,
                      p_property_value,
                      'F',
                      0
                      );


                       select VALUE_TRANSLATABLE_FLAG into l_trans_flag
                       from ieu_wp_properties_b
                       where property_id = p_property_id;

                       if (l_trans_flag = 'Y') then

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
                            p_property_value,
                            l_language,
                            l_source_lang,
                            0
                           );

                        end if;


                end if;



                begin

                    select PARAM_PROPERTY_ID into l_param_property_id
                    from IEU_WP_PARAM_PROPS_B
                    where PARAM_ID = p_param_id
                    and ACTION_PARAM_SET_ID = p_action_param_set_id
                    and PROPERTY_ID = p_property_id;


                    update IEU_WP_PARAM_PROPS_TL set
                        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                        PROPERTY_VALUE = p_property_value
                    where PARAM_PROPERTY_ID = l_param_property_id;

                        if (sql%notfound) then
                            null;
                        end if;


                       EXCEPTION

                            WHEN NO_DATA_FOUND THEN
                                null;
                 end;



    end if;

    x_return_status := fnd_api.g_ret_sts_success;

    COMMIT;


END Update_Column_Props;





--===================================================================
-- NAME
--   Delete_Parameter
--
-- PURPOSE
--    Private api to delete work panel action parameter
--
-- NOTES
--    1. UWQ  Work Panel Admin will use this procedure to delete an action parameter
--
--
-- HISTORY
--   08-May-2002     GPAGADAL   Created


--===================================================================
PROCEDURE Delete_Parameter (x_param_id IN NUMBER, x_param_set_id IN NUMBER) AS

    l_language             VARCHAR2(4);

    l_param_property_id    IEU_WP_PARAM_PROPS_TL.PARAM_PROPERTY_ID%type;
BEGIN
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;



    EXECUTE immediate
    ' delete from ieu_wp_action_params where param_id = :1 '
    USING x_param_id;

    if (sql%notfound) then
        null;
    end if;


    EXECUTE immediate
    ' delete from IEU_WP_PARAM_DEFS_TL where PARAM_ID = :1 '
    USING x_param_id;

    if (sql%notfound) then
        null;
    end if;



    EXECUTE immediate
    ' delete from IEU_WP_PARAM_DEFS_B where PARAM_ID = :1 '
    USING x_param_id;

    if (sql%notfound) then
        null;
    end if;



    EXECUTE immediate
    ' delete from IEU_WP_PARAM_PROPS_B ' ||
    ' where PARAM_ID = :1 '||
    ' and ACTION_PARAM_SET_ID = :2 '
    USING x_param_id, x_param_set_id;

    if (sql%notfound) then
        null;
    end if;

    begin

       EXECUTE immediate
       ' select PARAM_PROPERTY_ID '||
       ' from IEU_WP_PARAM_PROPS_B '||
       ' where PARAM_ID = :1 ' ||
       ' and ACTION_PARAM_SET_ID= :2 '
       INTO l_param_property_id USING x_param_id, x_param_set_id;

        delete from IEU_WP_PARAM_PROPS_TL
        where  PARAM_PROPERTY_ID = l_param_property_id;

        if (sql%notfound) then
            null;
        end if;


    EXCEPTION

            WHEN NO_DATA_FOUND THEN
                null;
    end;



    --delete param props if param has been deleted by some actions
    delete from ieu_wp_param_props_b where param_property_id in
    (select param_property_id
    from ieu_wp_param_props_b
    where param_id not in (select param_id from ieu_wp_param_defs_b));

    if (sql%notfound) then
        null;
    end if;

    delete from ieu_wp_param_props_tl where param_property_id in
    (select param_property_id
    from ieu_wp_param_props_b
    where param_id not in (select param_id from ieu_wp_param_defs_b));

    if (sql%notfound) then
        null;
    end if;

COMMIT;



END Delete_Parameter;


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--          Create_From_Action
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

PROCEDURE Create_From_Action(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT NOCOPY VARCHAR2,
                                -- r_wp_action_key IN VARCHAR2,
                                -- r_language  IN VARCHAR2,
                                -- r_label  IN VARCHAR2,
                                -- r_desc   IN VARCHAR2,
                                rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                                  p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                                   p_maction_def_type_flag IN VARCHAR2)
 AS

    l_wp_maction_def_id     NUMBER(15);
    l_param_set_id          NUMBER(15);

    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_return_status             VARCHAR2(4);


    l_enum_uuid IEU_UWQ_SEL_ENUMERATORS.ENUM_TYPE_UUID%type;



    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


IEU_WorkPanel_PVT.Validate_Action_Label(l_return_status,
                        l_msg_count,
                        l_msg_data,
                        rec_obj.action_user_label,
                        p_maction_def_type_flag,
                        rec_obj.enum_id);

 if (l_return_status = 'S') then

    IEU_WP_ACTION_PVT.CreateFromAction2(x_return_status, x_msg_count, x_msg_data,
                                       rec_obj.maction_def_key, l_language,
                                       rec_obj.action_user_label, rec_obj.action_description,
                                       p_param_set_id,rec_obj.enum_id, 'Y');
 else
 x_return_status := l_return_status;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;
 end if; -- end (l_return_status = 'S')

commit;
end Create_From_Action;


PROCEDURE Create_From_Filter(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data  OUT NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                                  p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                                   p_maction_def_type_flag IN VARCHAR2)
 AS

    l_wp_maction_def_id     NUMBER(15);
    l_param_set_id          NUMBER(15);

    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_return_status             VARCHAR2(4);


    l_enum_uuid IEU_UWQ_SEL_ENUMERATORS.ENUM_TYPE_UUID%type;



    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


IEU_WorkPanel_PVT.Validate_Action_Label(l_return_status,
                        l_msg_count,
                        l_msg_data,
                        rec_obj.action_user_label,
                        p_maction_def_type_flag,
                        rec_obj.enum_id);

 if (l_return_status = 'S') then

 /*
  x_return_status  OUT VARCHAR2,
                             x_msg_count OUT  NUMBER,
                             x_msg_data  OUT  VARCHAR2,
                             r_wp_action_key IN VARCHAR2,
                             r_language  IN VARCHAR2,
                             r_label  IN VARCHAR2,
                             r_desc   IN VARCHAR2,
                             r_param_set_id IN NUMBER,
                             r_enumId IN VARCHAR2,
                            r_dev_data_flag IN VARCHAR2)

 */

    IEU_WP_ACTION_PVT.CreateFromQFilter(x_return_status, x_msg_count, x_msg_data,
                                       rec_obj.maction_def_key, l_language,
                                       rec_obj.action_user_label, rec_obj.action_description,
                                       p_param_set_id,rec_obj.enum_id, 'Y');
 else
 x_return_status := l_return_status;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;
 end if; -- end (l_return_status = 'S')

commit;
end Create_From_Filter;







PROCEDURE Map_Action(    x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2,
                         p_enum_id IN NUMBER,
                         p_application IN NUMBER,
                         p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                         p_maction_def_type_flag IN VARCHAR2
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
    --l_panel_sec_cat_code   IEU_WP_ACTION_MAPS.PANEL_SEC_CAT_CODE%type;
    l_action_map_type_code  IEU_WP_ACTION_MAPS.ACTION_MAP_TYPE_CODE%type;
    l_count NUMBER(2);
    l_wp_node_section_map_id IEU_WP_NODE_SECTION_MAPS.WP_NODE_SECTION_MAP_ID%type;



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

    select max(m.action_map_sequence) into l_temp_map_sequence
    from ieu_wp_action_maps m, ieu_uwq_maction_defs_b db,
        ieu_wp_act_param_sets_b sb
    --where m.application_id = p_application
    where m.action_map_type_code = 'NODE'
    and m.action_map_code = l_enum_uuid
    -- and m.application_id = db.application_id
    and db.maction_def_type_flag = p_maction_def_type_flag
    and db.maction_def_id = sb.wp_action_def_id
    and sb.action_param_set_id = m.action_param_set_id
    and m.responsibility_id = -1;
   -- and m.action_param_set_id = p_param_set_id;



   if (l_temp_map_sequence IS NULL) then
        l_map_sequence := 1;
   else
        l_map_sequence := l_temp_map_sequence +1;
   end if;
/*
    if (p_maction_def_type_flag ='W') then
        l_panel_sec_cat_code := null;
    elsif (p_maction_def_type_flag ='I') then
        l_panel_sec_cat_code := 'NOTES';
    elsif (p_maction_def_type_flag ='G') then
        l_panel_sec_cat_code := null;
    end if;
*/
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
             -- l_enum_uuid := p_datasource;
        end if;


    act_map_obj := SYSTEM.IEU_wp_action_maps_OBJ(null, p_param_set_id,
                                      p_application, null, 'NODE',
                                      l_enum_uuid, l_map_sequence, l_panel_sec_cat_code,
                                      'N', 'Y');

    IEU_WP_ACTION_PVT.CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj);


    act_map_obj1 := SYSTEM.IEU_wp_action_maps_OBJ(null, p_param_set_id,
                                          p_application, -1, 'NODE',
                                          l_enum_uuid, l_map_sequence, l_panel_sec_cat_code,
                                          'N', 'Y');

    IEU_WP_ACTION_PVT.CREATE_action_map(x_return_status,x_msg_count, x_msg_data, act_map_obj1);

    /* dolee add on 8/26/04 mapped action should set registered flag to 'y' */
     if (p_maction_def_type_flag <> 'F') then

        update IEU_UWQ_SEL_ENUMERATORS set
	   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	   LAST_UPDATE_DATE = SYSDATE,
	   LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
	   WORK_PANEL_REGISTERED_FLAG = 'Y'
	   where SEL_ENUM_ID = p_enum_id;


        if (p_maction_def_type_flag <> 'G') then
         select count(*) into l_count
         from IEU_WP_NODE_SECTION_MAPS
         where ENUM_TYPE_UUID = l_enum_uuid
         and APPLICATION_ID = p_application
         AND SECTION_ID = l_section_id;

        if (l_count > 0) then
         update IEU_WP_NODE_SECTION_MAPS set
         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
         LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
         RESPONSIBILITY_ID = null,
         SECTION_MAP_SEQUENCE = l_section_map_sequence
         where ENUM_TYPE_UUID = l_enum_uuid
         and APPLICATION_ID = p_application
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
			  APPLICATION_ID,
			  RESPONSIBILITY_ID,
			  ENUM_TYPE_UUID,
			  SECTION_ID,
			  SECTION_MAP_SEQUENCE
			 ) values
			 (l_wp_node_section_map_id,
			  0,
			  FND_GLOBAL.USER_ID,
			  SYSDATE,
			  FND_GLOBAL.USER_ID,
			  SYSDATE,
			  FND_GLOBAL.LOGIN_ID,
			  p_application,
			  null,
			  l_enum_uuid,
			  l_section_id,
			  l_section_map_sequence);

         end if;
       end if;
     end if;

    x_return_status := fnd_api.g_ret_sts_success;
   COMMIT;


     EXCEPTION
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


END   Map_Action;

PROCEDURE Update_Data_Type ( x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_wp_action_def_id IN NUMBER,
                             p_param_id IN NUMBER)
AS


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;


    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;

    cursor c_cur is
    select distinct ppb.action_param_set_id, ap.param_id
    from
        ieu_wp_action_params ap,
        ieu_wp_param_props_b ppb
    where
        ap.wp_action_def_id=p_wp_action_def_id
        and ap.param_id = ppb.param_id
        and ap.param_id=p_param_id;

BEGIN


    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';



    delete  from ieu_wp_param_props_b
    where  action_param_set_id in ( select distinct ppb.ACTION_PARAM_SET_ID
                                    from
                                        ieu_wp_action_params ap,
                                        ieu_wp_param_props_b ppb
                                    where
                                        ap.WP_ACTION_DEF_ID=p_wp_action_def_id
                                        and ap.PARAM_ID = ppb.PARAM_ID)
    and param_id =p_param_id
    and property_id in (10002, 10013, 10014, 10015, 10016, 10017, 10018, 10019, 10020, 10010, 10003, 10021, 10011,10022);

    if (sql%notfound) then
        null;
    end if;

  x_return_status := fnd_api.g_ret_sts_success;
  COMMIT;
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;


END Update_Data_Type;

PROCEDURE Update_Multi_Select_Flag ( x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_wp_action_def_id IN NUMBER)
as


    l_language             VARCHAR2(4);

    l_source_lang          VARCHAR2(4);


    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_param_id     IEU_WP_PARAM_DEFS_B.PARAM_ID%TYPE;


    l_param_property_id    IEU_WP_PARAM_PROPS_B.PARAM_PROPERTY_ID%TYPE;

    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;


BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_msg_data := '';


    delete  from  ieu_wp_param_props_b
    where property_id in(10010, 10003, 10021, 10011)
    and action_param_set_id in (select distinct ppb.ACTION_PARAM_SET_ID
                                    from
                                        ieu_wp_action_params ap,
                                        ieu_wp_param_props_b ppb
                                    where
                                        ap.WP_ACTION_DEF_ID= p_wp_action_def_id
                                        and ap.PARAM_ID = ppb.PARAM_ID);

    if (sql%notfound) then
        null;
    end if;

    x_return_status := fnd_api.g_ret_sts_success;
    COMMIT;
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;



END Update_Multi_Select_Flag;



PROCEDURE Param_ReOrdering(x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT  NOCOPY NUMBER,
                           x_msg_data  OUT  NOCOPY VARCHAR2,
                           p_wp_action_def_id IN NUMBER,
                           p_action_param_set_id IN NUMBER)
As
    cursor c_cur is
    select ppb.PARAM_PROPERTY_ID, pdb.PARAM_ID, ppb.PROPERTY_VALUE
    from ieu_wp_action_params p,
    ieu_wp_param_defs_b pdb,
    ieu_wp_param_props_b ppb
    where p.WP_ACTION_DEF_ID = p_wp_action_def_id
    and p.PARAM_ID = pdb.PARAM_ID
    and pdb.PARAM_ID = ppb.PARAM_ID
    and ppb.ACTION_PARAM_SET_ID = p_action_param_set_id
    and ppb.PROPERTY_ID = 10000
    order by to_number(ppb.PROPERTY_VALUE);

    l_count  NUMBER:=1;



BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;

    x_msg_data := '';
    for c_rec in c_cur LOOP
        if l_count <> c_rec.PROPERTY_VALUE then

            update ieu_wp_param_props_b
            set property_value = l_count
            where param_id = c_rec.param_id
            and  param_property_id = c_rec.param_property_id
            and  property_value = c_rec.property_value
            and property_id = 10000
            and action_param_set_id = p_action_param_set_id;

        end if;
        l_count :=l_count+1;
    end loop;
    commit;

END Param_ReOrdering;





END IEU_WorkPanel_PVT;

/
