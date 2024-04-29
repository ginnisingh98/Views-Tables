--------------------------------------------------------
--  DDL for Package Body IEU_SEED_DATA_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_SEED_DATA_LOADER_PKG" AS
/* $Header: IEUCMSDLDB.pls 120.0 2005/07/27 13:56:59 appldev noship $ */

PROCEDURE Load_IEU_UWQ_SVR_MPS_MMAPS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SVR_MPS_MMAP_ID IN VARCHAR2,
  P_MEDIA_TYPE_ID IN VARCHAR2,
  P_SVR_TYPE_ID IN VARCHAR2,
  P_MEDIA_TYPE_MAP IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is

user_id number := 0;

begin
  if (P_UPLOAD_MODE = 'NLS') then
    null;
  else
    begin
      --if (P_OWNER = 'SEED') then
      --  user_id := 1;
      --end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

      update IEU_UWQ_SVR_MPS_MMAPS b
        set b.LAST_UPDATED_BY = user_id,
        b.LAST_UPDATE_DATE = SYSDATE,
        b.LAST_UPDATE_LOGIN = 0,
        b.MEDIA_TYPE_ID = P_MEDIA_TYPE_ID,
        b.SVR_TYPE_ID = P_SVR_TYPE_ID,
        b.MEDIA_TYPE_MAP = P_MEDIA_TYPE_MAP
        where b.SVR_MPS_MMAP_ID = P_SVR_MPS_MMAP_ID;
      if sql%notfound then
        raise NO_DATA_FOUND;
      end if;

    exception
      when NO_DATA_FOUND then
        insert into IEU_UWQ_SVR_MPS_MMAPS (
          SVR_MPS_MMAP_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          MEDIA_TYPE_ID,
          SVR_TYPE_ID,
          MEDIA_TYPE_MAP )
          values( to_number(P_SVR_MPS_MMAP_ID),
          user_id,
          SYSDATE,
          user_id,
          SYSDATE,
          0,
          to_number(P_MEDIA_TYPE_ID),
          to_number(P_SVR_TYPE_ID),
          P_MEDIA_TYPE_MAP);
    end;

  end if;

end Load_IEU_UWQ_SVR_MPS_MMAPS;

PROCEDURE Load_IEU_UWQ_CLI_MED_PLUGINS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_CLI_PLUGIN_ID IN VARCHAR2,
  P_MEDIA_TYPE_ID IN VARCHAR2,
  P_CLI_PLUGIN_CLASS IN  VARCHAR2,
  P_APPLICATION_ID IN  NUMBER,
  P_OWNER IN VARCHAR2
)is
user_id                 number := 0;
begin
  if (P_UPLOAD_MODE = 'NLS') then
    null;
  else
    begin
      --if (P_OWNER = 'SEED') then
      --  user_id := 1;
      --end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

      update IEU_UWQ_CLI_MED_PLUGINS b
        set b.LAST_UPDATED_BY = user_id,
        b.LAST_UPDATE_DATE = SYSDATE,
        b.LAST_UPDATE_LOGIN = 0,
        b.MEDIA_TYPE_ID = P_MEDIA_TYPE_ID,
        b.CLI_PLUGIN_CLASS = P_CLI_PLUGIN_CLASS,
        b.APPLICATION_ID = P_APPLICATION_ID
        where b.CLI_PLUGIN_ID = P_CLI_PLUGIN_ID;

      if sql%notfound then
        raise NO_DATA_FOUND;
      end if;

      exception
        when NO_DATA_FOUND then
        insert into IEU_UWQ_CLI_MED_PLUGINS (
        CLI_PLUGIN_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        MEDIA_TYPE_ID,
        CLI_PLUGIN_CLASS,
        APPLICATION_ID )
        values( to_number(P_CLI_PLUGIN_ID),
        user_id,
        SYSDATE,
        user_id,
        SYSDATE,
        0,
        to_number(P_MEDIA_TYPE_ID),
        P_CLI_PLUGIN_CLASS,
        P_APPLICATION_ID );
    end;
  end if;
end Load_IEU_UWQ_CLI_MED_PLUGINS;

PROCEDURE Load_IEU_UWQ_SVR_MPS_PLUGINS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SVR_MPS_PLUGIN_ID IN VARCHAR2,
  P_SVR_TYPE_ID IN VARCHAR2,
  P_SVR_PLUGIN_CLASS IN VARCHAR2,
  P_APPLICATION_ID IN NUMBER,
  P_OWNER IN VARCHAR2
)is
user_id                 number := 0;
begin
  if (P_UPLOAD_MODE = 'NLS') then
    null;
  else
    begin
      --if (P_OWNER = 'SEED') then
      --  user_id := 1;
      --end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

      update IEU_UWQ_SVR_MPS_PLUGINS b
        set b.LAST_UPDATED_BY = user_id,
        b.LAST_UPDATE_DATE = SYSDATE,
        b.LAST_UPDATE_LOGIN = 0,
        b.SVR_TYPE_ID = P_SVR_TYPE_ID,
        b.SVR_PLUGIN_CLASS = P_SVR_PLUGIN_CLASS,
        b.APPLICATION_ID = P_APPLICATION_ID
        where b.SVR_MPS_PLUGIN_ID = P_SVR_MPS_PLUGIN_ID;
        if sql%notfound then
          raise NO_DATA_FOUND;
        end if;

    exception
      when NO_DATA_FOUND then
        insert into IEU_UWQ_SVR_MPS_PLUGINS (
          SVR_MPS_PLUGIN_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          SVR_TYPE_ID,
          SVR_PLUGIN_CLASS,
          APPLICATION_ID )
          values( to_number(P_SVR_MPS_PLUGIN_ID),
          user_id,
          SYSDATE,
          user_id,
          SYSDATE,
          0,
          to_number(P_SVR_TYPE_ID),
          P_SVR_PLUGIN_CLASS,
          P_APPLICATION_ID );

    end;
  end if;

end Load_IEU_UWQ_SVR_MPS_PLUGINS;

PROCEDURE Load_IEU_UWQ_SEL_ENUMERATORS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SEL_ENUM_ID IN VARCHAR2,
  P_ENUM_PROC IN VARCHAR2,
  P_REFRESH_PROC IN VARCHAR2,
  P_ENUM_TYPE_UUID IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
user_id number := 0;
begin
  if (P_UPLOAD_MODE = 'NLS') then
    null;
  else
    begin
      --if (P_OWNER = 'SEED') then
      --  user_id := 1;
      -- end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

       update IEU_UWQ_SEL_ENUMERATORS b
         set b.LAST_UPDATED_BY = user_id,
         b.LAST_UPDATE_DATE = SYSDATE,
         b.LAST_UPDATE_LOGIN = 0,
         b.ENUM_PROC = P_ENUM_PROC,
         b.REFRESH_PROC = P_REFRESH_PROC,
         b.ENUM_TYPE_UUID = P_ENUM_TYPE_UUID
         where b.SEL_ENUM_ID = P_SEL_ENUM_ID;

       if sql%notfound then
         raise NO_DATA_FOUND;
       end if;

     exception
       when NO_DATA_FOUND then
       insert into IEU_UWQ_SEL_ENUMERATORS (
         SEL_ENUM_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ENUM_PROC,
         REFRESH_PROC,
         ENUM_TYPE_UUID )
         values( to_number(P_SEL_ENUM_ID),
         user_id,
         SYSDATE,
         user_id,
         SYSDATE,
         0,
         P_ENUM_PROC,
         P_REFRESH_PROC,
         P_ENUM_TYPE_UUID);
     end;
   end if;

end Load_IEU_UWQ_SEL_ENUMERATORS;

--ieuenum.lct

PROCEDURE Load_IEU_UWQ_SEL_ENUMERATORS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SEL_ENUM_ID IN VARCHAR2,
  P_APPLICATION_SHORT_NAME IN VARCHAR2,
  P_ENUM_TYPE_UUID IN VARCHAR2,
  P_OWNER IN VARCHAR2,
  P_ENUM_PROC IN VARCHAR2,
  P_REFRESH_PROC IN VARCHAR2,
  P_WORK_Q_LABEL_LU_TYPE IN VARCHAR2,
  P_WORK_Q_LABEL_LU_CODE IN VARCHAR2,
  P_WORK_Q_ENABLE_PROFILE_OPTION IN VARCHAR2,
  P_WORK_Q_ORDER_PROFILE_OPTION IN VARCHAR2,
  P_WORK_Q_ORDER_SYSTEM_DEFAULT IN VARCHAR2,
  P_WORK_Q_VIEW_FOR_PRIMARY_NODE IN VARCHAR2,
  P_WORK_Q_VIEW_EXTRA_WHERE IN VARCHAR2,
  P_MEDIA_TYPE_ID IN VARCHAR2,
  P_DEFAULT_RES_CAT_ID IN VARCHAR2,
  P_RES_CAT_PROFILE_OPT IN VARCHAR2,
  P_NOT_FOR_MYWORK_FLAG IN VARCHAR2,
  P_NOT_VALID_FLAG IN VARCHAR2,
  P_ACTION_PROC IN VARCHAR2,
  P_ACTION_PROC_TYPE_CODE IN VARCHAR2,
  P_ACTION_OBJECT_CODE IN VARCHAR2,
  P_WORK_Q_REGISTER_TYPE IN VARCHAR2,
  P_WORK_PANEL_REGISTERED_FLAG IN VARCHAR2
)is
l_user_id      number := 0;
l_app_id       number;
l_cur_app_id   number;
begin
  if (P_UPLOAD_MODE = 'NLS') then
    return;
  end if;

  select
    application_id
  into
    l_app_id
  from
    fnd_application
  where
    application_short_name = P_APPLICATION_SHORT_NAME;

  --if (P_OWNER = 'SEED') then
  --  l_user_id := 1;
  --end if;

  l_user_id := fnd_load_util.owner_id(P_OWNER);

  begin

  -- if we're uploading IEU data, then we don't want to over-write
  -- new provider data if if already exists... only if it's still
  -- owned by IEU.

  if (l_app_id = 696) then
    l_cur_app_id := 0;
    select
      application_id
    into
      l_cur_app_id
    from
      IEU_UWQ_SEL_ENUMERATORS e
    where
      e.SEL_ENUM_ID = P_SEL_ENUM_ID;

    if (sql%notfound) then
      raise NO_DATA_FOUND;
    end if;

    if ((l_cur_app_id = 696) or (l_cur_app_id = -1)) then

      update IEU_UWQ_SEL_ENUMERATORS e
      set
             e.LAST_UPDATED_BY               = l_user_id,
             e.LAST_UPDATE_DATE              = SYSDATE,
             e.LAST_UPDATE_LOGIN             = 0,
             e.enum_proc                     = P_ENUM_PROC,
             e.enum_type_uuid                = P_ENUM_TYPE_UUID,
             e.refresh_proc                  = P_REFRESH_PROC,
             e.application_id                = l_app_id,
             e.work_q_label_lu_type          = P_WORK_Q_LABEL_LU_TYPE,
             e.work_q_label_lu_code          = P_WORK_Q_LABEL_LU_CODE,
             e.work_q_enable_profile_option  = P_WORK_Q_ENABLE_PROFILE_OPTION,
             e.work_q_view_for_primary_node  = P_WORK_Q_VIEW_FOR_PRIMARY_NODE,
             e.work_q_view_extra_where       = P_WORK_Q_VIEW_EXTRA_WHERE,
             e.work_q_order_profile_option   = P_WORK_Q_ORDER_PROFILE_OPTION,
             e.work_q_order_system_default   = P_WORK_Q_ORDER_SYSTEM_DEFAULT,
             e.media_type_id                 = P_MEDIA_TYPE_ID,
             e.default_res_cat_id            = P_DEFAULT_RES_CAT_ID,
             e.res_cat_profile_opt           = P_RES_CAT_PROFILE_OPT,
             e.not_for_mywork_flag           = P_NOT_FOR_MYWORK_FLAG,
             e.not_valid_flag                = P_NOT_VALID_FLAG,
             e.action_proc                   = P_ACTION_PROC,
             e.action_proc_type_code         = P_ACTION_PROC_TYPE_CODE,
             e.action_object_code            = P_ACTION_OBJECT_CODE,
             e.work_q_register_type          = P_WORK_Q_REGISTER_TYPE,
             e.work_panel_registered_flag    = P_WORK_PANEL_REGISTERED_FLAG
      where
             e.SEL_ENUM_ID = P_SEL_ENUM_ID;

    end if;
  else

    update IEU_UWQ_SEL_ENUMERATORS e
    set
           e.LAST_UPDATED_BY               = l_user_id,
           e.LAST_UPDATE_DATE              = SYSDATE,
           e.LAST_UPDATE_LOGIN             = 0,
           e.enum_proc                     = P_ENUM_PROC,
           e.enum_type_uuid                = P_ENUM_TYPE_UUID,
           e.refresh_proc                  = P_REFRESH_PROC,
           e.application_id                = l_app_id,
           e.work_q_label_lu_type          = P_WORK_Q_LABEL_LU_TYPE,
           e.work_q_label_lu_code          = P_WORK_Q_LABEL_LU_CODE,
           e.work_q_enable_profile_option  = P_WORK_Q_ENABLE_PROFILE_OPTION,
           e.work_q_view_for_primary_node  = P_WORK_Q_VIEW_FOR_PRIMARY_NODE,
           e.work_q_view_extra_where       = P_WORK_Q_VIEW_EXTRA_WHERE,
           e.work_q_order_profile_option   = P_WORK_Q_ORDER_PROFILE_OPTION,
           e.work_q_order_system_default   = P_WORK_Q_ORDER_SYSTEM_DEFAULT,
           e.media_type_id                 = P_MEDIA_TYPE_ID,
           e.default_res_cat_id            = P_DEFAULT_RES_CAT_ID,
           e.res_cat_profile_opt           = P_RES_CAT_PROFILE_OPT,
           e.not_for_mywork_flag           = P_NOT_FOR_MYWORK_FLAG,
           e.not_valid_flag                = P_NOT_VALID_FLAG,
           e.action_proc                   = P_ACTION_PROC,
           e.action_proc_type_code         = P_ACTION_PROC_TYPE_CODE,
           e.action_object_code            = P_ACTION_OBJECT_CODE,
           e.work_q_register_type          = P_WORK_Q_REGISTER_TYPE,
           e.work_panel_registered_flag    = P_WORK_PANEL_REGISTERED_FLAG
    where
           e.SEL_ENUM_ID = P_SEL_ENUM_ID;

    if (sql%notfound) then
      raise NO_DATA_FOUND;
    end if;

  end if;

  exception
    when NO_DATA_FOUND then

    insert into IEU_UWQ_SEL_ENUMERATORS (
           SEL_ENUM_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ENUM_TYPE_UUID,
           ENUM_PROC,
           REFRESH_PROC,
           OBJECT_VERSION_NUMBER,
           APPLICATION_ID,
           WORK_Q_LABEL_LU_TYPE,
           WORK_Q_LABEL_LU_CODE,
           WORK_Q_ENABLE_PROFILE_OPTION,
           WORK_Q_ORDER_PROFILE_OPTION,
           WORK_Q_ORDER_SYSTEM_DEFAULT,
           WORK_Q_VIEW_FOR_PRIMARY_NODE,
           WORK_Q_VIEW_EXTRA_WHERE,
           MEDIA_TYPE_ID,
           DEFAULT_RES_CAT_ID,
           RES_CAT_PROFILE_OPT,
           NOT_FOR_MYWORK_FLAG,
           NOT_VALID_FLAG,
           ACTION_PROC,
           ACTION_PROC_TYPE_CODE,
           ACTION_OBJECT_CODE,
           WORK_Q_REGISTER_TYPE,
           WORK_PANEL_REGISTERED_FLAG
          )
         values (
           to_number(P_SEL_ENUM_ID),
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           0,
           P_ENUM_TYPE_UUID,
           P_ENUM_PROC,
           P_REFRESH_PROC,
           0,
           l_app_id,
           P_WORK_Q_LABEL_LU_TYPE,
           P_WORK_Q_LABEL_LU_CODE,
           P_WORK_Q_ENABLE_PROFILE_OPTION,
           P_WORK_Q_ORDER_PROFILE_OPTION,
           to_number(P_WORK_Q_ORDER_SYSTEM_DEFAULT),
           P_WORK_Q_VIEW_FOR_PRIMARY_NODE,
           P_WORK_Q_VIEW_EXTRA_WHERE,
           to_number(P_MEDIA_TYPE_ID),
           to_number(P_DEFAULT_RES_CAT_ID),
           P_RES_CAT_PROFILE_OPT,
           P_NOT_FOR_MYWORK_FLAG,
           P_NOT_VALID_FLAG,
           P_ACTION_PROC,
           P_ACTION_PROC_TYPE_CODE,
           P_ACTION_OBJECT_CODE,
           P_WORK_Q_REGISTER_TYPE,
           P_WORK_PANEL_REGISTERED_FLAG );
  end;

end Load_IEU_UWQ_SEL_ENUMERATORS;



PROCEDURE Load_IEU_UWQ_NODE_DS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SEL_ENUM_ID IN VARCHAR2,
  P_APPLICATION_SHORT_NAME IN VARCHAR2,
  P_ENUM_TYPE_UUID IN VARCHAR2,
  P_NODE_DS_ID IN VARCHAR2,
  P_DATASOURCE_NAME IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
l_user_id      number := 0;
begin

  if (P_UPLOAD_MODE = 'NLS') then
    return;
  end if;

  begin

    --if (:OWNER = 'SEED') then
    --  l_user_id := 1;
    --end if;

    l_user_id := fnd_load_util.owner_id(P_OWNER);

    update IEU_UWQ_NODE_DS m
    set
    m.LAST_UPDATED_BY               = l_user_id,
    m.LAST_UPDATE_DATE              = SYSDATE,
    m.LAST_UPDATE_LOGIN             = 0,
    m.DATASOURCE_NAME               = P_DATASOURCE_NAME
    where
    (m.enum_type_uuid = P_ENUM_TYPE_UUID) and
    (m.node_ds_id = P_NODE_DS_ID);

    if (sql%notfound) then
      raise NO_DATA_FOUND;
    end if;

  exception
    when NO_DATA_FOUND then

    insert into IEU_UWQ_NODE_DS (
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      ENUM_TYPE_UUID,
      NODE_DS_ID,
	DATASOURCE_NAME
      )
      values (
      0,
      l_user_id,
      SYSDATE,
      l_user_id,
      SYSDATE,
      0,
      P_ENUM_TYPE_UUID,
      to_number(P_NODE_DS_ID),
	P_DATASOURCE_NAME
      );
  end;
end Load_IEU_UWQ_NODE_DS;

PROCEDURE Load_IEU_UWQ_RES_CAT_ENM_MAPS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SEL_ENUM_ID IN VARCHAR2,
  P_APPLICATION_SHORT_NAME IN VARCHAR2,
  P_ENUM_TYPE_UUID IN VARCHAR2,
  P_OWNER IN VARCHAR2,
  P_RES_CAT_ID IN VARCHAR2
)is
l_user_id      number := 0;
begin

  if (P_UPLOAD_MODE = 'NLS') then
    return;
  end if;

  --if (:OWNER = 'SEED') then
  --  l_user_id := 1;
  --end if;

  l_user_id := fnd_load_util.owner_id(P_OWNER);

  begin
    update IEU_UWQ_RES_CAT_ENM_MAPS m
    set
    m.LAST_UPDATED_BY               = l_user_id,
    m.LAST_UPDATE_DATE              = SYSDATE,
    m.LAST_UPDATE_LOGIN             = 0
    where
    (m.enum_type_uuid = P_ENUM_TYPE_UUID) and
    (m.res_cat_id = P_RES_CAT_ID);

    if (sql%notfound) then
      raise NO_DATA_FOUND;
    end if;

   exception
     when NO_DATA_FOUND then

       insert into IEU_UWQ_RES_CAT_ENM_MAPS (
         OBJECT_VERSION_NUMBER,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         ENUM_TYPE_UUID,
         RES_CAT_ID
         )
         values (
         0,
         l_user_id,
         SYSDATE,
         l_user_id,
         SYSDATE,
         0,
         P_ENUM_TYPE_UUID,
         to_number(P_RES_CAT_ID)
       );
   end;

end Load_IEU_UWQ_RES_CAT_ENM_MAPS;

-- ieuctlpg.lct

PROCEDURE Load_IEU_CLI_PROV_PLUGINS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_PLUGIN_ID IN NUMBER,
  P_PLUGIN_CLASS_NAME IN VARCHAR2,
  P_IS_ACTIVE_FLAG IN VARCHAR2,
  P_APPLICATION_ID IN NUMBER,
  P_OWNER IN VARCHAR2
)is
user_id NUMBER := 0;
begin

  IF (P_UPLOAD_MODE = 'NLS') THEN
    NULL;
  ELSE
    BEGIN
      --IF (P_OWNER = 'SEED') then
        --user_id := 1;
      --END IF;

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE IEU_CLI_PROV_PLUGINS cliprov
      SET
      cliprov.LAST_UPDATED_BY      = user_id,
      cliprov.LAST_UPDATE_DATE     = SYSDATE,
      cliprov.LAST_UPDATE_LOGIN    = 0,
      cliprov.PLUGIN_CLASS_NAME    = P_PLUGIN_CLASS_NAME,
      cliprov.IS_ACTIVE_FLAG       = P_IS_ACTIVE_FLAG,
      cliprov.APPLICATION_ID       = P_APPLICATION_ID
      WHERE cliprov.PLUGIN_ID = P_PLUGIN_ID;

      IF sql%notfound then
        raise NO_DATA_FOUND;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

      INSERT INTO IEU_CLI_PROV_PLUGINS (
    		PLUGIN_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
   		PLUGIN_CLASS_NAME,
                IS_ACTIVE_FLAG,
                APPLICATION_ID
              )
              VALUES (
                to_number(P_PLUGIN_ID),
                user_id,
                SYSDATE,
                user_id,
                SYSDATE,
                0,
   		P_PLUGIN_CLASS_NAME,
   		P_IS_ACTIVE_FLAG,
                to_number(P_APPLICATION_ID)
              );
    END;
  END IF;

end Load_IEU_CLI_PROV_PLUGINS;

PROCEDURE Load_IEU_CLI_PROV_MED_MAPS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_PLUGIN_MED_MAP_ID IN NUMBER,
  P_PLUGIN_ID IN NUMBER,
  P_MEDIA_TYPE_ID IN NUMBER,
  P_CONDITIONAL_FUNC IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
user_id                 NUMBER := 0;
begin

  IF (P_UPLOAD_MODE = 'NLS') THEN
    NULL;
  ELSE
    BEGIN
      --IF (P_OWNER = 'SEED') then
      --  user_id := 1;
      -- END IF;

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE IEU_CLI_PROV_PLUGIN_MED_MAPS clipmmap
      SET
        clipmmap.LAST_UPDATED_BY      = user_id,
        clipmmap.LAST_UPDATE_DATE     = SYSDATE,
        clipmmap.LAST_UPDATE_LOGIN    = 0,
        clipmmap.PLUGIN_ID            = P_PLUGIN_ID,
        clipmmap.MEDIA_TYPE_ID        = P_MEDIA_TYPE_ID,
        clipmmap.CONDITIONAL_FUNC     = P_CONDITIONAL_FUNC
        WHERE clipmmap.PLUGIN_MED_MAP_ID = P_PLUGIN_MED_MAP_ID;

      IF sql%notfound then
        raise NO_DATA_FOUND;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

      INSERT INTO IEU_CLI_PROV_PLUGIN_MED_MAPS (
                PLUGIN_MED_MAP_ID,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
   	        PLUGIN_ID,
                MEDIA_TYPE_ID,
                CONDITIONAL_FUNC )
              VALUES (
                to_number(P_PLUGIN_MED_MAP_ID),
                user_id,
                SYSDATE,
                user_id,
                SYSDATE,
                0,
   		to_number(P_PLUGIN_ID),
                to_number(P_MEDIA_TYPE_ID),
                P_CONDITIONAL_FUNC
             );
    END;
  END IF;
end Load_IEU_CLI_PROV_MED_MAPS;

--ieuwpsec.lct

PROCEDURE Load_IEU_WP_SECTIONS_B (
  P_UPLOAD_MODE IN VARCHAR2,
  P_SECTION_ID IN VARCHAR2,
  P_SECTION_CODE IN VARCHAR2,
  P_SECTION_LABEL IN VARCHAR2,
  P_SECTION_DESCRIPTION IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
user_id   number := 0;
begin

  --if (p_owner = 'SEED') then
  --  user_id := 1;
  --end if;

  user_id := fnd_load_util.owner_id(P_OWNER);

  if (p_upload_mode = 'NLS') then
    update IEU_WP_SECTIONS_TL
      set source_lang = userenv('LANG'),
      object_version_number = object_version_number + 1,
      section_label = p_section_label,
      section_description = p_section_description,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = 0
      where (section_id = to_number(p_section_id))
      and (userenv('LANG') IN (LANGUAGE, SOURCE_LANG));

   else

     begin

       update IEU_WP_SECTIONS_B
       set object_version_number = object_version_number + 1,
       last_updated_by       = user_id,
       last_update_date      = sysdate,
       last_update_login     = 0,
       section_code          = p_section_code
       where section_id = to_number(p_section_id);

       if (sql%notfound) then
         raise no_data_found;
       end if;

       update IEU_WP_SECTIONS_TL
         set object_version_number = object_version_number + 1,
         last_updated_by       = user_id,
         last_update_date      = sysdate,
         last_update_login     = 0,
         section_label         = p_section_label,
         section_description   = p_section_description,
         source_lang           = userenv('LANG')
         where section_id = to_number(p_section_id)
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

       if (sql%notfound) then
         raise no_data_found;
       end if;

     exception when no_data_found then

       insert into ieu_wp_sections_b
         (section_id,
         object_version_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         section_code)
         values ( to_number(p_section_id),
         1,
         user_id,
         sysdate,
         user_id,
         sysdate,
         0,
         p_section_code);

       insert into ieu_wp_sections_tl
         (section_id,
         object_version_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         section_label,
         section_description,
         language,
         source_lang)
         select to_number(p_section_id),
         1,
         user_id,
         sysdate,
         user_id,
         sysdate,
         0,
         p_section_label,
         p_section_description,
         l.language_code,
         userenv('LANG')
         from fnd_languages l
         where l.installed_flag in ('I', 'B')
         and not exists
         (select null from ieu_wp_sections_tl t
         where t.section_id = to_number(p_section_id)
         and t.language = l.language_code);
     end;
   end if;

end Load_IEU_WP_SECTIONS_B;

--ieumact.lct

PROCEDURE Load_WORK_PANEL_ACTION_PARAMS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_MACTION_DEF_ID IN VARCHAR2,
  P_ACTION_PARAM_MAP_ID IN NUMBER,
  P_ACTION_PARAM_ID IN NUMBER,
  P_NOT_VALID_FLAG IN VARCHAR2,
  P_LAST_UPDATE_DATE IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
user_id                 number := FND_GLOBAL.USER_ID;
created_id              number := FND_GLOBAL.USER_ID;
begin

  if (p_upload_mode = 'NLS') then
    null;
  else
    begin

      --if (P_OWNER = 'ORACLE' or P_OWNER = 'SEED') then
      --  user_id := 1;
	--  created_id := -1;
      --end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

      update ieu_wp_action_params
                 set LAST_UPDATED_BY      = user_id,
                 LAST_UPDATE_DATE     = decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
                 LAST_UPDATE_LOGIN    = 0,
                 WP_ACTION_DEF_ID = P_MACTION_DEF_ID,
                 PARAM_ID = P_ACTION_PARAM_ID,
                 NOT_VALID_FLAG = P_NOT_VALID_FLAG,
                 OBJECT_VERSION_NUMBER = nvl(object_version_number,0) +1
                 where action_param_map_id   = P_ACTION_PARAM_MAP_ID;

      if sql%notfound then
        raise NO_DATA_FOUND;
      end if;

    exception

      when NO_DATA_FOUND then

      insert into ieu_wp_action_params
                           ( action_param_map_id ,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
                             PARAM_ID,
                             WP_ACTION_DEF_ID,
                             NOT_VALID_FLAG,
                             OBJECT_VERSION_NUMBER)
                      values( P_ACTION_PARAM_MAP_ID,
                              --created_id,
                              user_id,
                              SYSDATE,
                              user_id,
                              decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
                              FND_GLOBAL.LOGIN_ID,
                              P_ACTION_PARAM_ID,
                              P_MACTION_DEF_ID,
                              P_NOT_VALID_FLAG,
                              1);
    end;
  end if;
end Load_WORK_PANEL_ACTION_PARAMS;

PROCEDURE Load_NON_MEDIA_ACTIONS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_NONMEDIA_ACTION_ID IN NUMBER,
  P_ACTION_OBJECT_CODE IN VARCHAR2,
  P_MEDIA_MACTION_DEF_ID IN VARCHAR2,
  P_APPLICATION_ID IN NUMBER,
  P_SOURCE_FOR_TASK_FLAG IN varchar2,
  P_RESPONSIBILITY_ID IN NUMBER,
  P_LAST_UPDATE_DATE IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
user_id number := FND_GLOBAL.USER_ID;
created_id number := FND_GLOBAL.USER_ID;
begin

if (p_upload_mode = 'NLS') then
  null;
else
  begin
    --if (P_OWNER = 'ORACLE' or P_OWNER = 'SEED') then
    --  user_id := 1;
    --  created_id := -1;
    --end if;

    user_id := fnd_load_util.owner_id(P_OWNER);

    update IEU_UWQ_NONMEDIA_ACTIONS
      set LAST_UPDATED_BY      = user_id,
      LAST_UPDATE_DATE     = decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
      LAST_UPDATE_LOGIN    = 0,
      ACTION_OBJECT_CODE   = P_ACTION_OBJECT_CODE,
      MACTION_DEF_ID       = P_MEDIA_MACTION_DEF_ID,
      APPLICATION_ID       = P_APPLICATION_ID,
      SOURCE_FOR_TASK_FLAG = P_SOURCE_FOR_TASK_FLAG,
      RESPONSIBILITY_ID    = P_RESPONSIBILITY_ID,
      OBJECT_VERSION_NUMBER = nvl(object_version_number,0) +1
      where nonmedia_action_id = P_NONMEDIA_ACTION_ID;

    if sql%notfound then
      raise NO_DATA_FOUND;
    end if;

  exception
    when NO_DATA_FOUND then

    insert into IEU_UWQ_NONMEDIA_ACTIONS (
        NONMEDIA_ACTION_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        ACTION_OBJECT_CODE,
        MACTION_DEF_ID,
        APPLICATION_ID,
        SOURCE_FOR_TASK_FLAG,
        RESPONSIBILITY_ID,
        OBJECT_VERSION_NUMBER)
        values( P_NONMEDIA_ACTION_ID,
        --created_id,
        user_id,
        SYSDATE,
        user_id,
        decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
        FND_GLOBAL.LOGIN_ID,
        P_ACTION_OBJECT_CODE,
        P_MEDIA_MACTION_DEF_ID,
        P_APPLICATION_ID,
        P_SOURCE_FOR_TASK_FLAG,
        P_RESPONSIBILITY_ID,
        1);
  end;
end if;
end Load_NON_MEDIA_ACTIONS;

PROCEDURE Load_WP_ACTION_MAPS (
  P_UPLOAD_MODE IN VARCHAR2,
  P_ACTION_PARAM_SET_ID IN NUMBER,
  P_WP_ACTION_MAP_ID IN NUMBER,
  P_RESPONSIBILITY_ID IN NUMBER,
  P_ACTION_MAP_TYPE_CODE IN VARCHAR2,
  P_ACTION_MAP_CODE IN VARCHAR2,
  P_ACTION_MAP_SEQUENCE IN NUMBER,
  P_PANEL_SEC_CAT_CODE IN VARCHAR2,
  P_APPLICATION_ID IN NUMBER,
  P_NOT_VALID_FLAG IN VARCHAR2,
  P_DEV_DATA_FLAG IN VARCHAR2,
  P_LAST_UPDATE_DATE IN VARCHAR2,
  P_OWNER IN VARCHAR2
)is
x_return_status   VARCHAR2(2000);
x_msg_count        NUMBER:=0;
x_msg_data    VARCHAR2(2000);
user_id                 number := FND_GLOBAL.USER_ID;
created_id                 number := FND_GLOBAL.USER_ID;
l_temp_map_sequence ieu_wp_action_maps.action_map_sequence%type;
l_section_id  ieu_wp_sections_b.section_id%type;
l_wp_node_section_map_id ieu_wp_node_section_maps.wp_node_section_map_id%type;
l_sequence         number:=0;
l_def_flag    ieu_uwq_maction_defs_b.maction_def_type_flag%type;
l_last_updated_by ieu_wp_action_maps.last_updated_by%type;
begin
  --call UpdateParamProps to make sure all actions have all properties which they should have
  IEU_WP_ACTION_PVT.UpdateParamProps(x_return_status ,x_msg_count  ,x_msg_data, P_APPLICATION_ID );

  if (p_upload_mode = 'NLS') then
    null;
  else
    begin
      --if (P_OWNER = 'ORACLE' or P_OWNER = 'SEED') then
      --  user_id := 1;
	--  created_id := -1;
      --end if;

      user_id := fnd_load_util.owner_id(P_OWNER);

      select last_updated_by into l_last_updated_by
	from ieu_wp_action_maps
	where wp_action_map_id   = P_WP_ACTION_MAP_ID;

      -- dolee added on 2-03-03
	-- a. when upload seed data, don't change customerized sequence number
	-- b. if there are new seed data, give max+1 sequence number.

	--a.
      if (l_last_updated_by = user_id) then
		 update ieu_wp_action_maps
	 	  set
		  LAST_UPDATED_BY      = user_id,
		  LAST_UPDATE_DATE     = decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
		  LAST_UPDATE_LOGIN    = 0,
		  APPLICATION_ID       = P_APPLICATION_ID,
		  OBJECT_VERSION_NUMBER = nvl(object_version_number,0) +1,
		  action_param_set_id = P_ACTION_PARAM_SET_ID,
		  RESPONSIBILITY_ID = P_RESPONSIBILITY_ID,
		  action_map_type_code = P_ACTION_MAP_TYPE_CODE,
		  action_map_code = P_ACTION_MAP_CODE,
		  action_map_sequence = P_ACTION_MAP_SEQUENCE,
		  PANEL_SEC_CAT_CODE = P_PANEL_SEC_CAT_CODE,
		  NOT_VALID_FLAG = P_NOT_VALID_FLAG,
		  DEV_DATA_FLAG = P_DEV_DATA_FLAG
		 where wp_action_map_id   = P_WP_ACTION_MAP_ID;
      else
		 update ieu_wp_action_maps
		  set
		  LAST_UPDATED_BY      = user_id,
		  LAST_UPDATE_DATE     = decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
		  LAST_UPDATE_LOGIN    = 0,
		  APPLICATION_ID       = P_APPLICATION_ID,
		  OBJECT_VERSION_NUMBER = nvl(object_version_number,0) +1,
		  action_param_set_id = P_ACTION_PARAM_SET_ID,
		  RESPONSIBILITY_ID = P_RESPONSIBILITY_ID,
		  action_map_type_code = P_ACTION_MAP_TYPE_CODE,
		  action_map_code = P_ACTION_MAP_CODE,
		  --action_map_sequence = P_ACTION_MAP_SEQUENCE,
		  PANEL_SEC_CAT_CODE = P_PANEL_SEC_CAT_CODE,
	        --NOT_VALID_FLAG = P_NOT_VALID_FLAG,
		  DEV_DATA_FLAG = P_DEV_DATA_FLAG
		 where wp_action_map_id   = P_WP_ACTION_MAP_ID;
      end if;

      if sql%notfound then
        raise NO_DATA_FOUND;
      end if;

    exception
        when NO_DATA_FOUND then
        begin

        -- b.
        select max(action_map_sequence) into l_temp_map_sequence
          from ieu_wp_action_maps
          where application_id = P_APPLICATION_ID
          and action_map_type_code = P_ACTION_MAP_TYPE_CODE
          and action_map_code = P_ACTION_MAP_CODE;

        if l_temp_map_sequence is null then
          l_temp_map_sequence :=1;
        else
          l_temp_map_sequence := l_temp_map_sequence + 1;
        end if;

        insert into ieu_wp_action_maps
              ( wp_action_map_id ,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                action_param_set_id,
                RESPONSIBILITY_ID,
                APPLICATION_ID,
                action_map_type_code,
                action_map_code,
                action_map_sequence,
                PANEL_SEC_CAT_CODE,
                NOT_VALID_FLAG,
                DEV_DATA_FLAG,
                OBJECT_VERSION_NUMBER)
              values
              ( P_WP_ACTION_MAP_ID,
                --created_id,
                user_id,
                SYSDATE,
                user_id,
                decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
                FND_GLOBAL.LOGIN_ID,
                P_ACTION_PARAM_SET_ID,
                P_RESPONSIBILITY_ID,
                P_APPLICATION_ID,
                P_ACTION_MAP_TYPE_CODE,
                P_ACTION_MAP_CODE,
                l_temp_map_sequence,
                P_PANEL_SEC_CAT_CODE,
                P_NOT_VALID_FLAG,
                P_DEV_DATA_FLAG,
                1
              );
        end ;
        --for outer exception

        select MACTION_DEF_TYPE_FLAG into l_def_flag
        from ieu_uwq_maction_defs_b
        where
          maction_def_id in
            (select wp_action_def_id
             from ieu_wp_act_param_sets_b
             where action_param_set_id = P_ACTION_PARAM_SET_ID);

        if l_def_flag = 'W' then
          l_section_id := 10002;
          l_sequence := 2;
        elsif l_def_flag = 'I' then
          l_section_id := 10001;
          l_sequence :=1;
        end if;

        if l_section_id is not null then
         begin
           update ieu_wp_node_section_maps
           set LAST_UPDATED_BY      = user_id,
           LAST_UPDATE_DATE     = decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
           LAST_UPDATE_LOGIN    = 0,
           OBJECT_VERSION_NUMBER = nvl(object_version_number,0) +1
           where
                enum_type_uuid = P_ACTION_MAP_CODE
            and section_id = l_section_id;


         if sql%notfound then
           raise NO_DATA_FOUND;
         end if;

        exception
         when NO_DATA_FOUND then

         select IEU_WP_NODE_SECTION_MAPS_S1.NEXTVAL into  l_wp_node_section_map_id from sys.dual;
         insert into ieu_wp_node_section_maps
		      ( wp_node_section_map_id ,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			APPLICATION_ID,
			enum_type_uuid,
			section_id,
			section_map_sequence,
			OBJECT_VERSION_NUMBER)
		      values
		      ( l_wp_node_section_map_id,
			--created_id,
                  user_id,
			sysdate,
			user_id,
			decode(P_LAST_UPDATE_DATE, null,SYSDATE,to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD')),
			FND_GLOBAL.LOGIN_ID,
			P_APPLICATION_ID,
			P_ACTION_MAP_CODE,
			l_section_id,
			l_sequence,
			1);
        end;
      end  if;
    end;
  end  if;
end Load_WP_ACTION_MAPS;


END IEU_SEED_DATA_LOADER_PKG;

/
