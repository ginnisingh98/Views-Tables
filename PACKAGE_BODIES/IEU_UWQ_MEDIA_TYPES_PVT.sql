--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MEDIA_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MEDIA_TYPES_PVT" AS
-- $Header: IEUMEDB.pls 120.1 2005/06/28 08:20:01 appldev ship $


-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_UWQ_MEDIA_TYPES_PVT
-- Purpose
--    To provide easy to use apis for UQW Admin.
-- History
--    11-Feb-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================




--===================================================================
-- NAME
--    GET_MEDIA_TYPE_LIST
--
-- PURPOSE
--    Private api to get all media types.
--
-- NOTES
--    1. UWQ Admin will use this procedure to get all media types
--
--
-- HISTORY
--   11-Feb-2002     GPAGADAL   Created

--===================================================================

PROCEDURE GET_MEDIA_TYPE_LIST (
   p_language IN VARCHAR2,
   p_order_by IN VARCHAR2,
   p_asc      IN VARCHAR2,
   x_media_type_list  OUT NOCOPY SYSTEM.IEU_MEDIA_TYPE_NST,
   x_return_status  OUT NOCOPY VARCHAR2)
AS
    v_cursorID   INTEGER;

    v_selectStmt VARCHAR2(32767);

    v_dummy      INTEGER;


    v_media_type_id              IEU_UWQ_MEDIA_TYPES_B.MEDIA_TYPE_ID%type;

    v_tel_reqd_flag              IEU_UWQ_MEDIA_TYPES_B.TEL_REQD_FLAG%type;

    v_media_type_name            IEU_UWQ_MEDIA_TYPES_TL.MEDIA_TYPE_NAME%type;

    v_media_type_description     IEU_UWQ_MEDIA_TYPES_TL.MEDIA_TYPE_DESCRIPTION%type;

    v_cli_plugin_id              IEU_UWQ_CLI_MED_PLUGINS.CLI_PLUGIN_ID%type;

    v_cli_plugin_class           IEU_UWQ_CLI_MED_PLUGINS.CLI_PLUGIN_CLASS%type;

    v_svr_type_id                IEU_UWQ_SVR_MPS_MMAPS.SVR_TYPE_ID%type;

    v_svr_mps_plugin_id          IEU_UWQ_SVR_MPS_PLUGINS.SVR_MPS_PLUGIN_ID%type;

    v_svr_plugin_class           IEU_UWQ_SVR_MPS_PLUGINS.SVR_PLUGIN_CLASS%type;

    v_media_type_uuid            IEU_UWQ_MEDIA_TYPES_B.MEDIA_TYPE_UUID%type;

    v_svr_login_rule_id          IEU_UWQ_MEDIA_TYPES_B.SVR_LOGIN_RULE_ID%type;

    v_application_id             IEU_UWQ_MEDIA_TYPES_B.APPLICATION_ID%type;

    v_application_name           FND_APPLICATION_TL.APPLICATION_NAME%type;

    v_is_server_side                    VARCHAR2(2);

    v_classfn_query_proc                 IEU_UWQ_MEDIA_TYPES_B.CLASSIFICATION_QUERY_PROC%type;


BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    v_cursorID := DBMS_SQL.OPEN_CURSOR;


    v_is_server_side := 'N';

    v_selectStmt :=  ' select b.MEDIA_TYPE_ID, b.TEL_REQD_FLAG, tl.MEDIA_TYPE_NAME, tl.MEDIA_TYPE_DESCRIPTION, cl.CLI_PLUGIN_ID,' ||
                    ' cl.CLI_PLUGIN_CLASS, svm.SVR_TYPE_ID, svp.SVR_MPS_PLUGIN_ID, svp.SVR_PLUGIN_CLASS, b.MEDIA_TYPE_UUID, ' ||
                    ' b.SVR_LOGIN_RULE_ID, b.APPLICATION_ID,b.CLASSIFICATION_QUERY_PROC from  IEU_UWQ_MEDIA_TYPES_B b, IEU_UWQ_MEDIA_TYPES_TL tl, IEU_UWQ_CLI_MED_PLUGINS cl, ' ||
                    '   IEU_UWQ_SVR_MPS_MMAPS svm, IEU_UWQ_SVR_MPS_PLUGINS svp ' ||
                    ' where b.MEDIA_TYPE_ID = tl.MEDIA_TYPE_ID and b.MEDIA_TYPE_ID = cl.MEDIA_TYPE_ID ' ||
                    '   and tl.LANGUAGE = '||''''||p_language||''''||' and b.MEDIA_TYPE_ID = svm.MEDIA_TYPE_ID ' ||
                    '   and svm.SVR_TYPE_ID = svp.SVR_TYPE_ID order by ' || p_order_by || ' ' || p_asc;

    DBMS_SQL.PARSE(v_cursorID, v_selectStmt, DBMS_SQL.V7);

    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 1, v_media_type_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 2, v_tel_reqd_flag, 1);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 3, v_media_type_name, 1996);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 4, v_media_type_description,1996);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 5, v_cli_plugin_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 6, v_cli_plugin_class, 1996);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 7, v_svr_type_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 8, v_svr_mps_plugin_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 9, v_svr_plugin_class, 1996);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 10, v_media_type_uuid, 38);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 11, v_svr_login_rule_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 12, v_application_id);

    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 13, v_is_server_side, 1);
    DBMS_SQL.DEFINE_COLUMN(v_cursorID, 14, v_classfn_query_proc, 60);


    v_dummy := DBMS_SQL.EXECUTE(v_cursorID);

    x_media_type_list  := SYSTEM.IEU_MEDIA_TYPE_NST();
    loop
        if DBMS_SQL.FETCH_ROWS(v_cursorID) = 0 then
         exit;
        end if;

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 1, v_media_type_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 2, v_tel_reqd_flag);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 3, v_media_type_name);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 4, v_media_type_description);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 5, v_cli_plugin_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 6, v_cli_plugin_class);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 7, v_svr_type_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 8, v_svr_mps_plugin_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 9, v_svr_plugin_class);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 10, v_media_type_uuid);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 11, v_svr_login_rule_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 12, v_application_id);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 13, v_is_server_side);

        DBMS_SQL.COLUMN_VALUE(v_cursorID, 14, v_classfn_query_proc);



        x_media_type_list.EXTEND;
        x_media_type_list(x_media_type_list.LAST) := SYSTEM.IEU_MEDIA_TYPE_OBJ(v_media_type_id,
                                                                   v_tel_reqd_flag ,
                                                                   v_media_type_name ,
                                                                   v_media_type_description,
                                                                   v_cli_plugin_id ,
                                                                   v_cli_plugin_class ,
                                                                   v_svr_type_id ,
                                                                   v_svr_mps_plugin_id ,
                                                                   v_svr_plugin_class,
                                                                   v_media_type_uuid,
                                                                   v_svr_login_rule_id,
                                                                   v_application_id,
                                                                   v_application_name,
                                                                   v_is_server_side,
                                                                   v_classfn_query_proc
                                                                );
    end loop;

    DBMS_SQL.CLOSE_CURSOR(v_cursorID);

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            DBMS_SQL.CLOSE_CURSOR(v_cursorID);
            x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN

            DBMS_SQL.CLOSE_CURSOR(v_cursorID);
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN

            DBMS_SQL.CLOSE_CURSOR(v_cursorID);
            x_return_status := fnd_api.g_ret_sts_unexp_error;

END GET_MEDIA_TYPE_LIST;

--===================================================================
-- NAME
--   VALIDATE
--
-- PURPOSE
--    Private api to Validate fields.
--
-- NOTES
--    1. UWQ Admin will use this procedure to validate fields
--
--
-- HISTORY
--   11-Feb-2002     GPAGADAL   Created

--===================================================================

PROCEDURE VALIDATE (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ,
                        is_create IN boolean

   ) AS


    media_name_count       NUMBER(5);
    media_uuid_count       NUMBER(5);
    application_name_count NUMBER(5);
    l_language             VARCHAR2(4);

    l_msg_count            NUMBER(2);
    l_msg_data             VARCHAR2(2000);
    temp_media_name        VARCHAR2(1996);
    temp_char              VARCHAR2(1);
    temp_uuid              VARCHAR2(38);
    temp_cli_class         VARCHAR2(1996);
    temp_svr_class         VARCHAR2(1996);

    valid_name             boolean;

    valid_uuid             boolean;

    valid_cli_class        boolean;

    valid_svr_class        boolean;

    class_name_count       NUMBER(5);

    cli_class_name_count       NUMBER(5);

    l_temp_classproc   IEU_UWQ_MEDIA_TYPES_B.CLASSIFICATION_QUERY_PROC%type;
    l_temp_pkg_name   IEU_UWQ_MEDIA_TYPES_B.CLASSIFICATION_QUERY_PROC%type;

    l_temp_class_count NUMBER(5);




BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;

    l_language := FND_GLOBAL.CURRENT_LANGUAGE;

    valid_name := true;
    valid_uuid := true;
    valid_cli_class := true;
    valid_svr_class := true;


    if is_create then

        if rec_obj.media_type_name IS NULL then

            FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_NAME_NULL');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        else
            temp_media_name := LTRIM(RTRIM(rec_obj.media_type_name));

            FOR i in 1..LENGTH(temp_media_name) LOOP

                temp_char := substr(temp_media_name, i, 1);
                if ((temp_char >= '0' and temp_char <= '9') or (temp_char >= 'a' and temp_char <= 'z') or
                      (temp_char >= 'A' and temp_char <= 'Z') or (temp_char = '-') or (temp_char = '_') or
                       (temp_char = '.') or (temp_char = ' ')) then

                    x_return_status := fnd_api.g_ret_sts_success;

               else
                    valid_name := false;
                    exit;
                end if;
            END LOOP;

            if NOT(valid_name) then
                FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_NAME_ILLEGAL');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            else

                select count(*) into media_name_count from IEU_UWQ_MEDIA_TYPES_TL where lower(MEDIA_TYPE_NAME) like lower(temp_media_name);
                if media_name_count <> 0 then
                    FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_NAME_EXISTS');
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
            end if;


        end if;

        if rec_obj.media_type_uuid IS NULL then
            FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_UUID_NULL');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        else

          temp_uuid := LTRIM(RTRIM(rec_obj.media_type_uuid));

            FOR i in 1..LENGTH(temp_uuid) LOOP

                temp_char := substr(temp_uuid, i, 1);
                if ((temp_char >= '0' and temp_char <= '9') or (temp_char >= 'a' and temp_char <= 'z') or
                      (temp_char >= 'A' and temp_char <= 'Z') or (temp_char = '-') or (temp_char = '_') or
                       (temp_char = '.')) then

                    --x_return_status := fnd_api.g_ret_sts_success;
                    null;

               else
                    valid_uuid := false;
                    exit;
                end if;
            END LOOP;
            if NOT(valid_uuid) then
                FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_UUID_ILLEGAL');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            else

                select count(*) into media_uuid_count from IEU_UWQ_MEDIA_TYPES_B where lower(MEDIA_TYPE_UUID) like lower(temp_uuid);

                if media_uuid_count <> 0 then
                    FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_UUID_EXISTS');
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
            end if;
        end if;


    end if;


    if rec_obj.application_name IS NULL then
        FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_APPNAME_NULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    else
        select count(*) into application_name_count from FND_APPLICATION_TL T, FND_APPLICATION B
        where B.APPLICATION_ID = T.APPLICATION_ID and T.LANGUAGE = l_language and lower(T.APPLICATION_NAME) like lower(rec_obj.application_name);

        if application_name_count = 0 then
            FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_APPNAME_INVALID');
            FND_MSG_PUB.Add;
            raise FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
    end if;


    if NOT(rec_obj.cli_plugin_class IS NULL) then

            temp_cli_class := LTRIM(RTRIM(rec_obj.cli_plugin_class));

            FOR i in 1..LENGTH(temp_cli_class) LOOP

                temp_char := substr(temp_cli_class, i, 1);
                if ((temp_char >= '0' and temp_char <= '9') or (temp_char >= 'a' and temp_char <= 'z') or
                      (temp_char >= 'A' and temp_char <= 'Z') or (temp_char = '-') or (temp_char = '_') or
                       (temp_char = '.')) then

                    -- x_return_status := fnd_api.g_ret_sts_success;
                    null;

               else
                    valid_cli_class := false;
                    exit;
                end if;
            END LOOP;

            if NOT(valid_cli_class) then
                FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_CLI_ILLEGAL');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            end if;

                        if (rec_obj.cli_plugin_id IS NULL) then
                                        select count(*) into cli_class_name_count from IEU_UWQ_CLI_MED_PLUGINS
                                        where lower(CLI_PLUGIN_CLASS) like lower(temp_cli_class);



                                        if cli_class_name_count <> 0 then


                                                        FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_CLI_NAME');
                                                        FND_MSG_PUB.Add;
                                                        x_return_status := FND_API.G_RET_STS_ERROR;

                                        end if;
                        end if;

    end if;




     if NOT(rec_obj.svr_plugin_class IS NULL) then

                temp_svr_class := LTRIM(RTRIM(rec_obj.svr_plugin_class));

                FOR i in 1..LENGTH(temp_svr_class) LOOP

                    temp_char := substr(temp_svr_class, i, 1);
                    if ((temp_char >= '0' and temp_char <= '9') or (temp_char >= 'a' and temp_char <= 'z') or
                          (temp_char >= 'A' and temp_char <= 'Z') or (temp_char = '-') or (temp_char = '_') or
                           (temp_char = '.')) then

                        --x_return_status := fnd_api.g_ret_sts_success;
                        null;

                    else
                        valid_svr_class := false;
                        exit;
                    end if;
                END LOOP;

                if NOT(valid_svr_class) then
                    FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_SVR_ILLEGAL');
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                end if;

                                if (rec_obj.svr_mps_plugin_id IS NULL) then

                                        if rec_obj.is_server_side = 'Y' then

                                                select count(*) into class_name_count from IEU_UWQ_SVR_MPS_PLUGINS
                                                where lower(SVR_PLUGIN_CLASS) like lower(temp_svr_class);



                                                if class_name_count <> 0 then
                                                                FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_SVR_NAME');
                                                                FND_MSG_PUB.Add;
                                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                end if;
                                        else
                                                select count(*) into class_name_count from IEU_CLI_PROV_PLUGINS
                                                where lower(PLUGIN_CLASS_NAME) like lower(temp_svr_class);



                                                if class_name_count <> 0 then
                                                                FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDIA_SVR_NAME');
                                                                FND_MSG_PUB.Add;
                                                                x_return_status := FND_API.G_RET_STS_ERROR;
                                                end if;

                                        end if;
                                end if;

    end if;


-- check the classification_query api

--commented for seed database
/*      if NOT(rec_obj.classfn_query_proc IS NULL) then

                l_temp_classproc := rec_obj.classfn_query_proc;

                l_temp_pkg_name := substr(l_temp_classproc,1,  ( instr(l_temp_classproc,'.',1,1)-1));
                        begin
                           select count(*) into l_temp_class_count from all_objects where owner = 'APPS' and object_type in('PACKAGE', 'PACKAGE BODY') and status='VALID'and object_name = l_temp_pkg_name;

                                if not(l_temp_class_count is null) and (l_temp_class_count <= 0) then
                                        FND_MESSAGE.set_name('IEU', 'IEU_PROV_MEDCLASSFN_INVALID');
                                        FND_MSG_PUB.Add;
                                        x_return_status := FND_API.G_RET_STS_ERROR;

                                end if;

                        EXCEPTION

                                WHEN NO_DATA_FOUND THEN
                                        null;


                        end;


         end if;*/


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => x_msg_data
    );

    FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;



    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN


            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
                p_count        => x_msg_count,
                p_data         => x_msg_data
            );


            FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
                FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
            (
             p_count        => x_msg_count,
             p_data         => x_msg_data
            );

            FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;

        WHEN OTHERS THEN


            --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get (
                p_count        => x_msg_count,
                p_data         => x_msg_data
            );

            FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
            END LOOP;


END VALIDATE;

--===================================================================
-- NAME
--   CREATE_MEDIA_TYPE
--
-- PURPOSE
--    Private api to create media type
--
-- NOTES
--    1. UWQ Admin will use this procedure to create media type
--
--
-- HISTORY
--   11-Feb-2002     GPAGADAL   Created
--   18-Sep-2002         GPAGADAL   Updated--added client side media provider

--===================================================================


PROCEDURE CREATE_MEDIA_TYPE (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ
) AS

    l_media_type_id     NUMBER(15);
    l_language          VARCHAR2(4);
    l_cli_plugin_id     NUMBER(15);
    l_svr_mps_mmap_id   NUMBER(15);
    l_svr_mps_plugin_id NUMBER(15);

    temp_svr_type_id    NUMBER(15);
    temp_cli_plugin_id  NUMBER(15);
    l_plugin_id        NUMBER(15);
    l_plugin_med_map_id NUMBER(15);

BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IEU_UWQ_MEDIA_TYPES_PVT.VALIDATE ( x_return_status,
                     x_msg_count,
                     x_msg_data,
                     rec_obj, true);
    if x_return_status = 'S' then

        select IEU_UWQ_MEDIA_TYPES_B_S2.NEXTVAL into l_media_type_id from sys.dual;

        l_language := FND_GLOBAL.CURRENT_LANGUAGE;

        insert INTO IEU_UWQ_MEDIA_TYPES_B
        (MEDIA_TYPE_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SECURITY_GROUP_ID,
        OBJECT_VERSION_NUMBER,
        SIMPLE_BLENDING_ORDER,
        MEDIA_TYPE_UUID,
        TEL_REQD_FLAG,
        APPLICATION_ID,
        SVR_LOGIN_RULE_ID,
        CLASSIFICATION_QUERY_PROC,
        SH_CATEGORY_TYPE ,
        IMAGE_FILE_NAME,
        BLENDED_FLAG,
        BLENDED_DIR
        )
        values (
        l_media_type_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        null,
        1,
        null,
        LTRIM(RTRIM(rec_obj.media_type_uuid)),
        rec_obj.tel_reqd_flag,
        rec_obj.application_id,
        rec_obj.svr_login_rule_id,
        rec_obj.classfn_query_proc,
        null,
        null,
        null,
        null
        );

        insert into IEU_UWQ_MEDIA_TYPES_TL
        ( MEDIA_TYPE_ID,
        LANGUAGE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        MEDIA_TYPE_NAME,
        SOURCE_LANG,
        MEDIA_TYPE_DESCRIPTION,
        SECURITY_GROUP_ID,
        OBJECT_VERSION_NUMBER
        )
        values ( l_media_type_id,
        l_language,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        LTRIM(RTRIM(rec_obj.media_type_name)),
        l_language,
        rec_obj.media_type_description,
        null,
        1
        );

        if NOT (rec_obj.cli_plugin_class IS NULL) then


            select IEU_UWQ_CLI_MED_PLUGINS_S2.NEXTVAL into l_cli_plugin_id from sys.dual;

            insert into IEU_UWQ_CLI_MED_PLUGINS
            (  CLI_PLUGIN_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            MEDIA_TYPE_ID,
            CLI_PLUGIN_CLASS,
            SECURITY_GROUP_ID ,
            OBJECT_VERSION_NUMBER,
            APPLICATION_ID
            )
            values  ( l_cli_plugin_id,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
            l_media_type_id,
            LTRIM(RTRIM(rec_obj.cli_plugin_class)),
            null,
            1,
            rec_obj.application_id
            );

        end if;

-- if server side media provider
                if rec_obj.is_server_side = 'Y' then

                        if  rec_obj.svr_mps_plugin_id IS NULL then

                                select IEU_UWQ_SVR_MPS_MMAPS_S2.NEXTVAL into l_svr_mps_mmap_id from sys.dual;

                                select IEU_UWQ_SVR_MPS_PLUGINS_S2.NEXTVAL into l_svr_mps_plugin_id from sys.dual;
                                insert into IEU_UWQ_SVR_MPS_MMAPS
                                (  SVR_MPS_MMAP_ID,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                MEDIA_TYPE_ID,
                                SVR_TYPE_ID,
                                MEDIA_TYPE_MAP,
                                SECURITY_GROUP_ID,
                                OBJECT_VERSION_NUMBER
                                )
                                values ( l_svr_mps_mmap_id,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.LOGIN_ID,
                                l_media_type_id,
                                rec_obj.svr_type_id,
                                null,
                                null,
                                1
                                );

                                insert into IEU_UWQ_SVR_MPS_PLUGINS
                                (  SVR_MPS_PLUGIN_ID,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                SVR_TYPE_ID,
                                SVR_PLUGIN_CLASS,
                                SECURITY_GROUP_ID,
                                OBJECT_VERSION_NUMBER,
                                APPLICATION_ID
                                )
                                values ( l_svr_mps_plugin_id,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.LOGIN_ID,
                                rec_obj.svr_type_id,
                                LTRIM(RTRIM(rec_obj.svr_plugin_class)),
                                null,
                                1,
                                rec_obj.application_id
                                );

                        else


                                select svr_type_id into temp_svr_type_id from ieu_uwq_svr_mps_plugins  where  svr_mps_plugin_id = rec_obj.svr_mps_plugin_id;


                                select IEU_UWQ_SVR_MPS_MMAPS_S2.NEXTVAL into l_svr_mps_mmap_id from sys.dual;

                                insert into IEU_UWQ_SVR_MPS_MMAPS
                                (  SVR_MPS_MMAP_ID,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                MEDIA_TYPE_ID,
                                SVR_TYPE_ID,
                                MEDIA_TYPE_MAP,
                                SECURITY_GROUP_ID,
                                OBJECT_VERSION_NUMBER
                                )
                                values ( l_svr_mps_mmap_id,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.LOGIN_ID,
                                l_media_type_id,
                                temp_svr_type_id,
                                null,
                                null,
                                1
                                );

                        end if;
                else
                --client side media provider
                        select IEU_CLI_PROV_PLUGINS_S1.NEXTVAL into l_plugin_id from sys.dual;

                        insert into IEU_CLI_PROV_PLUGINS
                        (PLUGIN_ID,
                         PLUGIN_CLASS_NAME,
                         IS_ACTIVE_FLAG,
                         APPLICATION_ID,
                         OBJECT_VERSION_NUMBER,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN
                         )
                         values (l_plugin_id,
                         LTRIM(RTRIM(rec_obj.svr_plugin_class)),
                         'Y',
                         rec_obj.application_id,
                         1,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.LOGIN_ID
                         );

                         select IEU_CLI_PROV_PLUGIN_MED_MAP_S1.NEXTVAL into l_plugin_med_map_id from sys.dual;
                         insert into IEU_CLI_PROV_PLUGIN_MED_MAPS
                         (PLUGIN_MED_MAP_ID,
                          PLUGIN_ID,
                          MEDIA_TYPE_ID,
                          CONDITIONAL_FUNC,
                          OBJECT_VERSION_NUMBER,
                          CREATED_BY,
                          CREATION_DATE,
                          LAST_UPDATE_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_LOGIN
                          )
                          values (l_plugin_med_map_id,
                          l_plugin_id,
                          l_media_type_id,
                          null,
                          1,
                          FND_GLOBAL.USER_ID,
                          SYSDATE,
                          SYSDATE,
                          FND_GLOBAL.USER_ID,
                          FND_GLOBAL.LOGIN_ID
                          );

                end if;
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

END CREATE_MEDIA_TYPE;


--===================================================================
-- NAME
--   UPDATE_MEDIA_TYPE
--
-- PURPOSE
--    Private api to update media type
--
-- NOTES
--    1. UWQ Admin will use this procedure to update media type
--
--
-- HISTORY
--   11-Feb-2002     GPAGADAL   Created
--   25-Feb-2002     GPAGADAL   Updated
--   18-Sep-2002         GPAGADAL   Updated

--===================================================================



PROCEDURE UPDATE_MEDIA_TYPE (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ
) AS

    l_cli_plugin_id       NUMBER(15);
    l_svr_mps_mmap_id     NUMBER(15);
    l_svr_mps_plugin_id   NUMBER(15);
    l_language            VARCHAR2(4);

    temp_map_id           NUMBER(15);
    temp_cli_plugin_id    NUMBER(15);
    temp_svr_type_id      NUMBER(15);

        l_plugin_id           NUMBER(15);
        l_plugin_med_map_id   NUMBER(15);
        temp_plugin_id            NUMBER(15);



BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;



    IEU_UWQ_MEDIA_TYPES_PVT.VALIDATE ( x_return_status,
             x_msg_count,
             x_msg_data,
             rec_obj, false);

    if x_return_status = 'S' then


        update IEU_UWQ_MEDIA_TYPES_B  set
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID,
        TEL_REQD_FLAG = rec_obj.tel_reqd_flag,
        APPLICATION_ID = rec_obj.application_id,
        SVR_LOGIN_RULE_ID = rec_obj.svr_login_rule_id,
        CLASSIFICATION_QUERY_PROC = rec_obj.classfn_query_proc
        where MEDIA_TYPE_ID = rec_obj.media_type_id;


        update IEU_UWQ_MEDIA_TYPES_TL set
        LANGUAGE = l_language,
        LAST_UPDATED_BY =FND_GLOBAL.USER_ID ,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        MEDIA_TYPE_NAME  = rec_obj.media_type_name,
        SOURCE_LANG = l_language,
        MEDIA_TYPE_DESCRIPTION = rec_obj.media_type_description
        where MEDIA_TYPE_ID = rec_obj.media_type_id
        and l_language IN (language, source_lang);


        if NOT (rec_obj.cli_plugin_class IS NULL) then

            begin
                select cli_plugin_id into temp_cli_plugin_id from IEU_UWQ_CLI_MED_PLUGINS where media_type_id = rec_obj.media_type_id;

                update IEU_UWQ_CLI_MED_PLUGINS  set
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN  =FND_GLOBAL.LOGIN_ID,
                CLI_PLUGIN_CLASS = rec_obj.cli_plugin_class,
                MEDIA_TYPE_ID =  rec_obj.media_type_id,
                APPLICATION_ID = rec_obj.application_id
                where CLI_PLUGIN_ID = temp_cli_plugin_id;


            EXCEPTION

            WHEN NO_DATA_FOUND THEN

                select IEU_UWQ_CLI_MED_PLUGINS_S2.NEXTVAL into l_cli_plugin_id from sys.dual;
                insert into IEU_UWQ_CLI_MED_PLUGINS
                 (  CLI_PLUGIN_ID,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    MEDIA_TYPE_ID,
                    CLI_PLUGIN_CLASS,
                    SECURITY_GROUP_ID,
                    OBJECT_VERSION_NUMBER,
                    APPLICATION_ID
                 )
                 values  ( l_cli_plugin_id,
                           FND_GLOBAL.USER_ID,
                           SYSDATE,
                           FND_GLOBAL.USER_ID,
                           SYSDATE,
                           FND_GLOBAL.LOGIN_ID,
                           rec_obj.media_type_id,
                           rec_obj.cli_plugin_class,
                           null,
                           1,
                           rec_obj.application_id
                 );

            end;

        else

            begin


                select cli_plugin_id into temp_cli_plugin_id from IEU_UWQ_CLI_MED_PLUGINS where media_type_id = rec_obj.media_type_id;

                delete from IEU_UWQ_CLI_MED_PLUGINS where cli_plugin_id = temp_cli_plugin_id;

                if (sql%notfound) then
                    RAISE no_data_found;

                end if;

                EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                        null;

            end;

        end if;

        --server side media provider

                if rec_obj.is_server_side = 'Y' then

                        if  rec_obj.svr_mps_plugin_id IS NULL AND NOT (rec_obj.svr_type_id IS NULL) then

                           -- select IEU_UWQ_SVR_MPS_MMAPS_S2.NEXTVAL into l_svr_mps_mmap_id from sys.dual;

                                select IEU_UWQ_SVR_MPS_PLUGINS_S2.NEXTVAL into l_svr_mps_plugin_id from sys.dual;



                                update  IEU_UWQ_SVR_MPS_MMAPS set
                                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                                LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                                SVR_TYPE_ID = rec_obj.svr_type_id
                                where MEDIA_TYPE_ID = rec_obj.media_type_id;


                                insert into IEU_UWQ_SVR_MPS_PLUGINS
                                (  SVR_MPS_PLUGIN_ID,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                SVR_TYPE_ID,
                                SVR_PLUGIN_CLASS,
                                SECURITY_GROUP_ID,
                                OBJECT_VERSION_NUMBER,
                                APPLICATION_ID
                                )
                                values ( l_svr_mps_plugin_id,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.LOGIN_ID,
                                rec_obj.svr_type_id,
                                rec_obj.svr_plugin_class,
                                null,
                                1,
                                rec_obj.application_id
                                );

                        elsif NOT (rec_obj.svr_mps_plugin_id IS NULL) AND rec_obj.svr_type_id IS NULL then


                         begin
                                select svr_type_id into temp_svr_type_id from ieu_uwq_svr_mps_plugins  where  svr_mps_plugin_id = rec_obj.svr_mps_plugin_id;


                                update  IEU_UWQ_SVR_MPS_MMAPS set
                                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                                LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
                                SVR_TYPE_ID = temp_svr_type_id
                                where MEDIA_TYPE_ID = rec_obj.media_type_id;

                          EXCEPTION

                                WHEN NO_DATA_FOUND THEN
                                RAISE no_data_found;

                         end;

                                if (SQL%NOTFOUND) then

                                        select IEU_UWQ_SVR_MPS_MMAPS_S2.NEXTVAL into l_svr_mps_mmap_id from sys.dual;
                                        insert into IEU_UWQ_SVR_MPS_MMAPS
                                        (  SVR_MPS_MMAP_ID,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN,
                                        MEDIA_TYPE_ID,
                                        SVR_TYPE_ID,
                                        MEDIA_TYPE_MAP,
                                        SECURITY_GROUP_ID,
                                        OBJECT_VERSION_NUMBER
                                        )
                                        values ( l_svr_mps_mmap_id,
                                        FND_GLOBAL.USER_ID,
                                        SYSDATE,
                                        FND_GLOBAL.USER_ID,
                                        SYSDATE,
                                        FND_GLOBAL.LOGIN_ID,
                                        rec_obj.media_type_id,
                                        temp_svr_type_id,
                                        null,
                                        null,
                                        1
                                        );

                                end if;

                        end if;

                        --delete an entry in client side media provider
                        begin

                                delete from IEU_CLI_PROV_PLUGIN_MED_MAPS where media_type_id = rec_obj.media_type_id;

                                if (sql%notfound) then
                                        RAISE no_data_found;

                                end if;

                                EXCEPTION

                                        WHEN NO_DATA_FOUND THEN
                                                null;

            end;

                else
                -- client side media provider
                begin
                        --select PLUGIN_ID into temp_plugin_id from IEU_CLI_PROV_PLUGIN_MED_MAPS where
                        --      MEDIA_TYPE_ID = rec_obj.media_type_id;
                        if NOT(rec_obj.svr_mps_plugin_id IS NULL) then



                                update IEU_CLI_PROV_PLUGIN_MED_MAPS set
                                PLUGIN_ID = rec_obj.svr_mps_plugin_id,
                                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                                LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
                                where MEDIA_TYPE_ID = rec_obj.media_type_id;

                                if (sql%notfound) then

                                         select IEU_CLI_PROV_PLUGIN_MED_MAP_S1.NEXTVAL into l_plugin_med_map_id from sys.dual;

                                         insert into IEU_CLI_PROV_PLUGIN_MED_MAPS
                                         (PLUGIN_MED_MAP_ID,
                                          PLUGIN_ID,
                                          MEDIA_TYPE_ID,
                                          CONDITIONAL_FUNC,
                                          OBJECT_VERSION_NUMBER ,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN
                                          )
                                          values (l_plugin_med_map_id,
                                          rec_obj.svr_mps_plugin_id,
                                          rec_obj.media_type_id,
                                          null,
                                          null,
                                          FND_GLOBAL.USER_ID,
                                          SYSDATE,
                                          SYSDATE,
                                          FND_GLOBAL.USER_ID,
                                          FND_GLOBAL.LOGIN_ID
                                          );
                                end if;


                        else

                                select IEU_CLI_PROV_PLUGINS_S1.NEXTVAL into l_plugin_id from sys.dual;

                                insert into IEU_CLI_PROV_PLUGINS
                                (PLUGIN_ID,
                                 PLUGIN_CLASS_NAME,
                                 IS_ACTIVE_FLAG,
                                 APPLICATION_ID,
                                 OBJECT_VERSION_NUMBER ,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN
                                 )
                                 values (l_plugin_id,
                                 LTRIM(RTRIM(rec_obj.svr_plugin_class)),
                                 'Y',
                                 rec_obj.application_id,
                                 1,
                                 FND_GLOBAL.USER_ID,
                                 SYSDATE,
                                 FND_GLOBAL.USER_ID,
                                 SYSDATE,
                                 FND_GLOBAL.LOGIN_ID
                                 );

                                 select IEU_CLI_PROV_PLUGIN_MED_MAP_S1.NEXTVAL into l_plugin_med_map_id from sys.dual;

                                 insert into IEU_CLI_PROV_PLUGIN_MED_MAPS
                                 (PLUGIN_MED_MAP_ID,
                                  PLUGIN_ID,
                                  MEDIA_TYPE_ID,
                                  CONDITIONAL_FUNC,
                                  OBJECT_VERSION_NUMBER ,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN
                                  )
                                  values (l_plugin_med_map_id,
                                  l_plugin_id,
                                  rec_obj.media_type_id,
                                  null,
                                  1,
                                  FND_GLOBAL.USER_ID,
                                  SYSDATE,
                                  SYSDATE,
                                  FND_GLOBAL.USER_ID,
                                  FND_GLOBAL.LOGIN_ID
                                  );
                        end if;



                        EXCEPTION

                        WHEN NO_DATA_FOUND THEN
                        null;


                end;

                -- delete server side media provider
                begin
                        delete from IEU_UWQ_SVR_MPS_MMAPS where  MEDIA_TYPE_ID = rec_obj.media_type_id;

                        if (sql%notfound) then
                                RAISE no_data_found;

                        end if;

                        EXCEPTION

                                WHEN NO_DATA_FOUND THEN
                                        null;

        end;


                end if;


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



END UPDATE_MEDIA_TYPE;


--===================================================================
-- NAME
--   DELETE_MEDIA_TYPE
--
-- PURPOSE
--    Private api to delete media type
--
-- NOTES
--    1. UWQ Admin will use this procedure to delete media type
--
--
-- HISTORY
--   11-Feb-2002     GPAGADAL   Created
--   26-Feb-2002     GPAGADAL   Updated

--===================================================================


PROCEDURE DELETE_MEDIA_TYPE (
    x_media_type_id IN NUMBER
    ) is

    media_count    NUMBER(15);
    temp_svr_type_id    NUMBER(15);

    BEGIN
    delete from IEU_UWQ_MEDIA_TYPES_TL
    where MEDIA_TYPE_ID = x_media_type_id;


    if (sql%notfound) then
        null;
    end if;

    delete from IEU_UWQ_MEDIA_TYPES_B
    where MEDIA_TYPE_ID = x_media_type_id;

    if (sql%notfound) then
          null;
    end if;

    delete from IEU_UWQ_CLI_MED_PLUGINS
    where MEDIA_TYPE_ID = x_media_type_id;

    if (sql%notfound) then
       null;
    end if;


    begin

        select svr_type_id into temp_svr_type_id from IEU_UWQ_SVR_MPS_MMAPS where MEDIA_TYPE_ID = x_media_type_id;


        select count(MEDIA_TYPE_ID) into media_count from IEU_UWQ_SVR_MPS_MMAPS where svr_type_id = temp_svr_type_id;

        delete from IEU_UWQ_SVR_MPS_MMAPS
        where MEDIA_TYPE_ID = x_media_type_id;


        if (sql%notfound) then
            null;
        end if;



        if media_count = 1 then

             delete from IEU_UWQ_SVR_MPS_PLUGINS
            where svr_type_id = temp_svr_type_id;

            if (sql%notfound) then
                null;
            end if;

        end if;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            null;

    end;




 COMMIT;
 END DELETE_MEDIA_TYPE;



END IEU_UWQ_MEDIA_TYPES_PVT;


/
