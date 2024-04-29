--------------------------------------------------------
--  DDL for Package Body IEU_DIAGNOSTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_DIAGNOSTICS_PVT" AS
/* $Header: IEUVDFB.pls 120.2 2007/12/04 06:41:12 majha ship $ */


-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_Diagnostics_PVT
-- Purpose
--    To provide easy to use apis for UQW Diagnostic Framework.
-- History
--    14-Mar-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

--===================================================================
-- NAME
--    Is_ResourceId_Exist
--
-- PURPOSE
--    Private api to determine if resource id exist for the user
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   14-Mar-2002     GPAGADAL   Created

--===================================================================

PROCEDURE Is_ResourceId_Exist (x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data  OUT NOCOPY VARCHAR2,
                                   p_user_name IN VARCHAR2
)
As

    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_language             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_resource_id   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
    l_sql   VARCHAR2(4000);



BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_msg_data := '';


    if (p_user_name is null) then
        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_USER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;

    else

        begin
            l_sql := ' select user_id  from fnd_user
                    where upper(user_name) like upper( :p_user_name)';

            EXECUTE IMMEDIATE l_sql
            into l_user_id
            USING p_user_name;
           -- DBMS_OUTPUT.PUT_LINE('sql : '||l_sql);
            --DBMS_OUTPUT.PUT_LINE('l_user_id : '||l_user_id);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.set_name('IEU', 'IEU_DIAG_USER_INVALID');
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

        end;

    end if;

    if NOT(l_user_id is null) then
        begin
        l_sql := 'select resource_id
                 from jtf_rs_resource_extns where user_id = :l_user_id';

        EXECUTE IMMEDIATE l_sql
         into l_resource_id
            USING l_user_id;

            ----DBMS_OUTPUT.PUT_LINE('sql : '||l_sql);
            --DBMS_OUTPUT.PUT_LINE('l_resource_id : '||l_resource_id);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            --DBMS_OUTPUT.PUT_LINE('resource id does not exists ');
            FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESOURCEID');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            --DBMS_OUTPUT.PUT_LINE('No data found for resource id : ');

       end;
    end if;

    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );*/


     x_msg_count := fnd_msg_pub.COUNT_MSG();

     FOR i in 1..x_msg_count LOOP
         l_msg_data := '';
         l_msg_count := 0;
         FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
         x_msg_data := x_msg_data || ',' || l_msg_data;
     END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --DBMS_OUTPUT.PUT_LINE('TError : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_ERROR;

        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    --DBMS_OUTPUT.PUT_LINE('TError : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

    WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('TError : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;



END Is_ResourceId_Exist;




--===================================================================
-- NAME
--    Check_User_Resp
--
-- PURPOSE
--    Private api to check the user id and responsibility
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   01-Apr-2002     GPAGADAL   Created

--===================================================================

PROCEDURE Check_User_Resp (x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           p_user_name IN VARCHAR2,
                           p_responsibility   IN VARCHAR2,
                           x_user_id OUT NOCOPY NUMBER,
                           x_resp_id OUT NOCOPY NUMBER,
                           x_appl_id OUT NOCOPY NUMBER
)
AS
    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_language             VARCHAR2(4);

    l_valid  boolean;
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_media_count INTEGER;

    l_sql   VARCHAR2(4000);


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_msg_data := '';


    if (p_user_name is null) then

        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_USER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;


    else
        begin
            l_sql := ' select user_id from fnd_user
                     where upper(user_name) like upper(:p_user_name)';
            EXECUTE IMMEDIATE l_sql
            INTO l_user_id
            USING in p_user_name;

            x_user_id := l_user_id;

            --DBMS_OUTPUT.PUT_LINE('l_user_id:='||l_user_id);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN



            FND_MESSAGE.set_name('IEU', 'IEU_DIAG_USER_INVALID');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;


        end;


    end if;

    if (p_responsibility is null) then

        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESP');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;

    else
        begin

	 l_sql := ' select responsibility_id, application_id from fnd_responsibility_tl where language = :l_language and responsibility_id = :p_responsibility';
           /* l_sql := ' select responsibility_id, application_id  //bug 6414726
                      from fnd_responsibility_tl where language = :l_language
                     and responsibility_name like :p_responsibility';  */

            EXECUTE IMMEDIATE l_sql
            INTO l_responsibility_id, l_application_id
            USING l_language, p_responsibility;

            x_resp_id := l_responsibility_id;
            x_appl_id := l_application_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            begin
      l_sql := ' select responsibility_id, application_id from fnd_responsibility where responsibility_id = :p_responsibility';
              /*  l_sql := ' select responsibility_id, application_id  //bug6414726
                          from fnd_responsibility where responsibility_key like :p_responsibility';  */
                EXECUTE IMMEDIATE l_sql
                INTO l_responsibility_id, l_application_id
                USING p_responsibility;

                x_resp_id := l_responsibility_id;
                x_appl_id := l_application_id;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN


                begin

                    -- l_responsibility_id := p_responsibility;

                    l_sql := ' select application_id
                             from fnd_responsibility where responsibility_id = :p_responsibility';

                    EXECUTE IMMEDIATE l_sql
                    INTO l_application_id
                    USING p_responsibility;

                    x_resp_id := p_responsibility;
                    x_appl_id := l_application_id;


                EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESP_USER');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    WHEN others then
                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_RESP_INVALID');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                end;

            end;
        end;

    end if;

    fnd_global.APPS_INITIALIZE(x_user_id, x_resp_id, x_appl_id, null);

    x_user_id := FND_GLOBAL.USER_ID;
    x_resp_id := FND_GLOBAL.RESP_ID;
    x_appl_id := FND_GLOBAL.RESP_APPL_ID;


    -- Standard call to get message count and if count is 1, get message info.
   /* FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );*/


      x_msg_count := fnd_msg_pub.COUNT_MSG();

      FOR i in 1..x_msg_count LOOP
          l_msg_data := '';
          l_msg_count := 0;
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
      END LOOP;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


--DBMS_OUTPUT.PUT_LINE('TError : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := fnd_msg_pub.COUNT_MSG();

          FOR i in 1..x_msg_count LOOP
              l_msg_data := '';
              l_msg_count := 0;
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;



    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


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
        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;



END Check_User_Resp;

--===================================================================
-- NAME
--    Check_Object_Resp
--
-- PURPOSE
--    Private api to check the user id and responsibility
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   20-Apr-2004     dolee   Created

--===================================================================

PROCEDURE Check_Object_Resp (x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           p_object_code IN VARCHAR2,
                           p_responsibility   IN VARCHAR2,
                           x_resp_id OUT NOCOPY NUMBER
)
AS
    l_object_code jtf_objects_vl.object_code%TYPE;


    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;
    x_appl_id number;
    x_user_id  number;
    l_language             VARCHAR2(4);
    l_count  number;
    l_valid  boolean;
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_media_count INTEGER;

    l_sql   VARCHAR2(4000);


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_msg_data := '';

    begin
            l_sql := ' select count(object_code) from jtf_objects_b
                     where upper(object_code) like upper(:p_object_code)';
            EXECUTE IMMEDIATE l_sql
            INTO l_count
            USING in p_object_code;

            IF l_count = 0 THEN
              FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_NO_OBJ_INVALID');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;

            END if;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_NO_OBJ_INVALID');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;


        end;



    if (p_responsibility is null) then

        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESP');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;

    else
	  if (p_responsibility = '-1') then
		x_resp_id := p_responsibility;
       else
        begin
            l_sql := ' select responsibility_id, application_id
                      from fnd_responsibility_tl where language = :l_language
                     and responsibility_name like :p_responsibility';

            EXECUTE IMMEDIATE l_sql
            INTO l_responsibility_id, l_application_id
            USING l_language, p_responsibility;

            x_resp_id := l_responsibility_id;
            x_appl_id := l_application_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            begin

                l_sql := ' select responsibility_id, application_id
                          from fnd_responsibility where responsibility_key like :p_responsibility';
                EXECUTE IMMEDIATE l_sql
                INTO l_responsibility_id, l_application_id
                USING p_responsibility;

                x_resp_id := l_responsibility_id;
                x_appl_id := l_application_id;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN
                begin

                    -- l_responsibility_id := p_responsibility;
                    l_sql := ' select application_id
                             from fnd_responsibility where responsibility_id = :p_responsibility';

                    EXECUTE IMMEDIATE l_sql
                    INTO l_application_id
                    USING p_responsibility;

                    x_resp_id := p_responsibility;


                EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESP_USER');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    WHEN others then
                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_RESP_INVALID');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                end;

            end;
        end;
     end if;
    end if;

    fnd_global.APPS_INITIALIZE(x_user_id, x_resp_id, x_appl_id, null);

    x_user_id := FND_GLOBAL.USER_ID;
    x_resp_id := FND_GLOBAL.RESP_ID;



    -- Standard call to get message count and if count is 1, get message info.
   /* FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );*/


      x_msg_count := fnd_msg_pub.COUNT_MSG();

      FOR i in 1..x_msg_count LOOP
          l_msg_data := '';
          l_msg_count := 0;
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
      END LOOP;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


--DBMS_OUTPUT.PUT_LINE('TError : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := fnd_msg_pub.COUNT_MSG();

          FOR i in 1..x_msg_count LOOP
              l_msg_data := '';
              l_msg_count := 0;
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;



    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


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
        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;



END Check_Object_Resp;


--===================================================================
-- NAME
--    Determine_Media_Enabled
--
-- PURPOSE
--    Private api to determine if any media queues are enabled.
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   14-Mar-2002     GPAGADAL   Created

--===================================================================



PROCEDURE Determine_Media_Enabled (x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data  OUT NOCOPY VARCHAR2,
                                   p_user_name IN VARCHAR2,
                                   p_responsibility   IN VARCHAR2,
                                   x_media_types OUT NOCOPY IEU_DIAG_STRING_NST
)
AS


    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_work_q_enable_profile_option IEU_UWQ_SEL_ENUMERATORS.WORK_Q_ENABLE_PROFILE_OPTION%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_language             VARCHAR2(4);

    l_media_type_id   IEU_UWQ_SEL_ENUMERATORS.MEDIA_TYPE_ID%TYPE;

    l_valid  boolean;
    l_media_type_name IEU_UWQ_MEDIA_TYPES_TL.MEDIA_TYPE_NAME%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_media_count INTEGER;

    v_count BINARY_INTEGER ;

    l_sql   VARCHAR2(4000);


    CURSOR c_types IS
    select media_type_id
    from ieu_uwq_sel_enumerators
    where ((not_valid_flag is null) or (not_valid_flag = 'N')) and
    work_q_register_type = 'M' order by media_type_id;

    i integer ;



BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_media_type_name := null;
    x_media_types := IEU_DIAG_STRING_NST();
    l_media_count := 0;
    x_msg_data := '';

    --dbms_output.put_line('calling check_user...');

    Check_User_Resp (x_return_status, x_msg_count,
    x_msg_data, p_user_name,
    p_responsibility, l_user_id,
    l_responsibility_id, l_application_id);


    if (x_return_status = 'S') then
        i:= 0;
        FOR c_rec IN c_types LOOP
            l_valid := TRUE;

            BEGIN
                 select work_q_enable_profile_option
                 into l_work_q_enable_profile_option
                 from   ieu_uwq_sel_enumerators
                 where  media_type_id = c_rec.media_type_id ;


            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                null;
            END;

            if (fnd_profile.value(l_work_q_enable_profile_option) = 'N')then
                l_valid := FALSE;
            end if;

            if (l_valid = true)then
                i := i+1;
                begin
                    x_media_types.EXTEND;

                    select media_type_name INTO x_media_types(i)
                    from ieu_uwq_media_types_tl
                    where media_type_id = c_rec.MEDIA_TYPE_ID
                    and language = l_language order by media_type_name;


                exception
                    when no_data_found then
                    i:= i-1;
                    x_media_types.trim(1);
                   --exit;
                end;
                ----DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);
            end if;
        END LOOP;

        --  user does not have any media queues enabled
        if x_media_types.COUNT = 0 then
            FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_MEDIAS_ENABLED');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
        end if;


        v_count := 1;
        loop
            if x_media_types.EXISTS(v_count) then
                --DBMS_OUTPUT.put_line('media names count: -->'|| v_count);
                begin
                    select count(s.SEL_ENUM_ID) into l_media_count
                    from
                        ieu_uwq_media_types_b b,
                        ieu_uwq_media_types_tl tl,
                        ieu_uwq_sel_enumerators s
                    where
                        b.media_type_id = tl.media_type_id and
                        tl.language = l_language and
                        s.media_type_id = b.media_type_id and
                        tl.media_type_name like x_media_types(v_count);

                    --DBMS_OUTPUT.put_line('mediatype name   '|| x_media_types(v_count));
                    --DBMS_OUTPUT.put_line('media count in enumerators: -->'|| l_media_count);

                    if (l_media_count = 1) then
                        null;
                    elsif (l_media_count = 0) then
                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_MEDIA');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    else
                        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_MORE_ENTRIES');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    end if;


                EXCEPTION
                    WHEN NO_DATA_FOUND then
                    null;
                end;
               --DBMS_OUTPUT.put_line('media_name(' || v_count || '): '|| x_media_types(v_count));
                v_count := v_count+1;
            else
                exit;
            end if;
        end loop;

    end if;


    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);

    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => x_msg_data --x_msg_data --l_msg_data
    );*/
  x_msg_data := '';

   x_msg_count := fnd_msg_pub.COUNT_MSG();

       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;

         x_msg_count := fnd_msg_pub.COUNT_MSG();

          FOR i in 1..x_msg_count LOOP
              l_msg_data := '';
              l_msg_count := 0;
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


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
         --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          x_msg_count := fnd_msg_pub.COUNT_MSG();

       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;



END Determine_Media_Enabled;


--===================================================================
-- NAME
--    Determine_Valid_Server
--
-- PURPOSE
--    Private api to determine if the user is in a valid server group and the user's
--    server group contains servers, which can handle congigured media types.
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   14-Mar-2002     GPAGADAL   Created

--===================================================================


PROCEDURE Determine_Valid_Server ( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                   x_server_group OUT NOCOPY VARCHAR2,
                                   x_medias OUT NOCOPY IEU_DIAG_STRING_NST
)
AS


    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_language             VARCHAR2(4);

    l_media_type_id   IEU_UWQ_SEL_ENUMERATORS.MEDIA_TYPE_ID%TYPE;

    l_valid  boolean;
    l_media_type_name IEU_UWQ_MEDIA_TYPES_TL.MEDIA_TYPE_NAME%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_server_group_id JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE;

    l_media_types  IEU_DIAG_STRING_NST;

    l_svr_group_name IEO_SVR_GROUPS.GROUP_NAME%TYPE;

    l_server_type_id IEU_UWQ_SVR_MPS_MMAPS.SVR_TYPE_ID%TYPE;
    j integer ;


    l_sql   VARCHAR2(4000);


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    j := 0;
    x_medias := IEU_DIAG_STRING_NST();

    ----DBMS_OUTPUT.put_line('calling check_user...');
    Check_User_Resp (x_return_status, x_msg_count,
                 x_msg_data, p_user_name,
                 p_responsibility, l_user_id,
                 l_responsibility_id, l_application_id);

    if x_return_status = 'S' then

        IEU_Diagnostics_PVT.Determine_Media_Enabled (x_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_user_name,
                                p_responsibility,
                                l_media_types);


        if x_return_status = 'S' then

            begin
            l_sql := 'select server_group_id from jtf_rs_resource_extns where user_id = :l_user_id';

            EXECUTE IMMEDIATE l_sql
            INTO l_server_group_id
            USING l_user_id;

            ----DBMS_OUTPUT.PUT_LINE('server group id :' || l_server_group_id);
            FOR i IN 1..l_media_types.COUNT
            LOOP

                --DBMS_OUTPUT.put_line('media names: -->'||i ||':' || l_media_types(i));
                    begin
                        select mmptab.SVR_TYPE_ID into l_server_type_id from
                            IEO_SVR_SERVERS svrtab,
                            IEU_UWQ_SVR_MPS_MMAPS mmptab,
                            IEU_UWQ_MEDIA_TYPES_B mttab,
                            IEU_UWQ_MEDIA_TYPES_TL mtltab
                        where  (mtltab.MEDIA_TYPE_NAME = l_media_types(i)) and
                            (mtltab.LANGUAGE = l_language) and
                            (mtltab.MEDIA_TYPE_ID = mttab.MEDIA_TYPE_ID) and
                            (mmptab.MEDIA_TYPE_ID = mttab.MEDIA_TYPE_ID) and
                            (svrtab.TYPE_ID = mmptab.SVR_TYPE_ID) and
                            (svrtab.MEMBER_SVR_GROUP_ID = l_server_group_id);




                    EXCEPTION
                        WHEN NO_DATA_FOUND then
                            FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_SVRS');
                            FND_MSG_PUB.Add;
                            j:=j+1;
                            x_medias.EXTEND;
                            x_medias(j) := l_media_types(i);
                            --DBMS_OUTPUT.put_line('failed medias '||x_medias(j)||':)');

                            x_return_status := FND_API.G_RET_STS_ERROR;
                           -- exit;

                    end;
              end LOOP;

            begin
                select GROUP_NAME into l_svr_group_name from IEO_SVR_GROUPS where SERVER_GROUP_ID = l_server_group_id;

                --DBMS_OUTPUT.put_line('server group name :--->'||l_svr_group_name||':)');
                x_server_group := l_svr_group_name;
                --DBMS_OUTPUT.put_line('server group name :--->'|| x_server_group||':)');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                null;
            end;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_SVR_GROUP');--Server group does not exist
                    FND_MSG_PUB.Add;
                    x_return_status := FND_API.G_RET_STS_ERROR;
            end;




        end if;
    end if;
    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);



    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );*/

    x_msg_data := '';

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

         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;



    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := '';

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

        x_msg_data := '';

          x_msg_count := fnd_msg_pub.COUNT_MSG();

              FOR i in 1..x_msg_count LOOP
                  l_msg_data := '';
                  l_msg_count := 0;
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
              END LOOP;




END Determine_Valid_Server;


--===================================================================
-- NAME
--    Get_Valid_Nodes
--
-- PURPOSE
--    Private api to get the list of all valid nodes
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   01-Apr-2002     GPAGADAL   Created

--===================================================================
PROCEDURE Get_Valid_Nodes (x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data  OUT NOCOPY VARCHAR2,
                            p_user_name IN VARCHAR2,
                            p_responsibility   IN VARCHAR2,
                            x_valid_nodes OUT NOCOPY IEU_DIAG_VNODE_NST)
AS

    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_language             VARCHAR2(4);

    l_valid_nodes IEU_DIAG_VNODE_NST;

    l_sql   VARCHAR2(4000);




    CURSOR c_enum IS
    SELECT
      distinct l.meaning node_name,
      e.SEL_ENUM_ID enum_id
    FROM
      IEU_UWQ_SEL_ENUMERATORS e,
      fnd_lookup_values l
    WHERE EXISTS (select 'x' from FND_PROFILE_OPTIONS b
                  where upper(b.PROFILE_OPTION_NAME) = upper(e.work_q_enable_profile_option))
      AND ((e.NOT_VALID_FLAG is NULL) OR (e.NOT_VALID_FLAG = 'N')) AND
      (nvl(fnd_profile.value(e.work_q_enable_profile_option),'Y') = 'Y')
      AND l.language = l_language
      AND l.lookup_code = e.work_q_label_lu_code
      AND l.lookup_type = e.work_q_label_lu_type order by l.meaning;

       i integer ;

BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_valid_nodes := IEU_DIAG_VNODE_NST();
    i :=  0;
    Check_User_Resp (x_return_status, x_msg_count, x_msg_data,
                    p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);

    if (x_return_status = 'S') then
        FOR cur_rec IN c_enum
        LOOP
            --dbms_output.put_line('in the loop of enum');
            i := i+1;
            x_valid_nodes.EXTEND(1);

           -- dbms_output.put_line('extended');

            x_valid_nodes(x_valid_nodes.last) := IEU_DIAG_VNODE_OBJ(cur_rec.enum_id, cur_rec.node_name);

           -- dbms_output.put_line('id-->'||i||'....)-'||cur_rec.enum_id);
            --dbms_output.put_line('name-->'||cur_rec.node_name);

        end LOOP;
    end if;

    --dbms_output.PUT_LINE('initialized');
    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);


    -- Standard call to get message count and if count is 1, get message info.
   /* FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );*/

    x_msg_data := '';

      x_msg_count := fnd_msg_pub.COUNT_MSG();

          FOR i in 1..x_msg_count LOOP
              l_msg_data := '';
              l_msg_count := 0;
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;




EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := '';

         x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;

       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

END Get_Valid_Nodes;

--===================================================================
-- NAME
--    Check_Profile_Options
--
-- PURPOSE
--    Private api to check profile options
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   04-Apr-2002     GPAGADAL   Created
--===================================================================
PROCEDURE Check_Profile_Options( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_invalid_profile_options OUT NOCOPY IEU_DIAG_VNODE_NST
)
AS

    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_language             VARCHAR2(4);

    l_valid_nodes IEU_DIAG_VNODE_NST;

    l_profle_name IEU_UWQ_SEL_ENUMERATORS.WORK_Q_ENABLE_PROFILE_OPTION%TYPE;

    v_count BINARY_INTEGER ;

    --x_valid_nodes IEU_DIAG_VNODE_NST;

    i integer ;

    l_sql   VARCHAR2(4000);



BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    --x_valid_nodes := IEU_DIAG_VNODE_NST();
    x_invalid_profile_options := IEU_DIAG_VNODE_NST();
    l_profle_name := null;
    i := 0;

    ----dbms_output.put_line('check user resp...');
    Check_User_Resp(x_return_status, x_msg_count, x_msg_data,
                    p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);

    if (x_return_status = 'S') then
        --dbms_output.put_line('check user resp...success');

        Get_Valid_Nodes ( x_return_status,
                                    x_msg_count,
                                    x_msg_data,
                                    p_user_name,
                                    p_responsibility,
                                    l_valid_nodes);
       v_count := 1;
        loop
            if l_valid_nodes.EXISTS(v_count) then
                --dbms_output.put_line('count: -->'|| v_count);
                --dbms_output.put_line('id-->'||l_valid_nodes(v_count).enum_id);
                BEGIN
                    select a.WORK_Q_ENABLE_PROFILE_OPTION into l_profle_name
                    from ieu_uwq_sel_enumerators a,
                     ieu_uwq_sel_enumerators b
                    where
                    a.sel_enum_id = b.sel_enum_id and
                    a.sel_enum_id = l_valid_nodes(v_count).enum_id and
                    (upper(a.WORK_Q_ENABLE_PROFILE_OPTION) <> b.WORK_Q_ENABLE_PROFILE_OPTION
                    or (a.WORK_Q_ENABLE_PROFILE_OPTION) not like ('IEU_QEN_%'));



                    if not(l_profle_name is null) then
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        i:= i+1;
                        x_invalid_profile_options.EXTEND(1);
                        --dbms_output.put_line('invalid profile extended');
                        x_invalid_profile_options(x_invalid_profile_options.LAST) :=
                                IEU_DIAG_VNODE_OBJ(l_valid_nodes(v_count).enum_id, l_profle_name);
                        --dbms_output.put_line('invalid profile added');


                    else
                        null;
                    end if;

                    v_count := v_count+1;

                EXCEPTION

                    WHEN NO_DATA_FOUND then
                        v_count := v_count+1;
                END;
            else
                exit;
            end if;
        end loop;

    end if;

    if (x_invalid_profile_options.COUNT > 0) then
        FND_MESSAGE.set_name('IEU', 'IEU_DIAG_PROFILE_INVALID');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;

    end if;


    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);


    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

    /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;*/
 x_msg_data := '';

   x_msg_count := fnd_msg_pub.COUNT_MSG();

       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := '';

          x_msg_count := fnd_msg_pub.COUNT_MSG();

              FOR i in 1..x_msg_count LOOP
                  l_msg_data := '';
                  l_msg_count := 0;
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
              END LOOP;

        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;

       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


END Check_Profile_Options;

--===================================================================
-- NAME
--    Check_Node_Enumeration
--
-- PURPOSE
--    Private api for node enumeration
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   28-Mar-2002     GPAGADAL   Created
--   9-Jan-2003     GPAGADAL   Updated--Display status/time taken to enumerate
--   each node
--   30-Apr-2003 GPAGADAl updated- display total time.


--===================================================================
 PROCEDURE Check_Node_Enumeration ( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_dupli_proc OUT  NOCOPY IEU_DIAG_ENUM_NST,
                                    x_invalid_pkg OUT NOCOPY IEU_DIAG_ENUM_NST,
                                    x_invalid_proc OUT NOCOPY IEU_DIAG_ENUM_ERR_NST,
                                    x_enum_time  OUT NOCOPY IEU_DIAG_ENUM_TIME_NST,
                                    x_user_ver_time OUT NOCOPY NUMBER,
                                    x_etime_grand_total OUT NOCOPY NUMBER

)
AS

    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_language             VARCHAR2(4);

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_resource_id   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

    l_wb_style     VARCHAR2(2);

    l_media_eligible VARCHAR2(5) ;

    l_source_lang varchar2(4);

    l_savepoint_valid NUMBER(1);

    l_media_count  PLS_INTEGER;

    l_node_label   VARCHAR2(80);

    l_count NUMBER(10) ;

    l_temp_eproc IEU_UWQ_SEL_ENUMERATORS.ENUM_PROC%TYPE;

    l_temp_pkg_name IEU_UWQ_SEL_ENUMERATORS.ENUM_PROC%TYPE;

    l_media_type_name   IEU_UWQ_MEDIA_TYPES_TL.MEDIA_TYPE_NAME%TYPE;

    l_temp_count NUMBER(10) ;

    i integer ;

    j integer ;



    l_svr_group_name IEO_SVR_GROUPS.GROUP_NAME%TYPE;

    l_medias IEU_DIAG_STRING_NST;

    l_temp_msg_data VARCHAR2(5000);

    l_temp_msg_count NUMBER(2);

    l_temp_return_status VARCHAR2(1);

    v_count BINARY_INTEGER ;
    temp_not_eligible_flag boolean;


    l_node_id number(10);
    l_node_pid number(10);
    l_node_weight ieu_uwq_sel_rt_nodes.node_weight%type;
    l_vnode_label varchar2(512);

    t1           NUMBER;  -- start time
    t2           NUMBER;  -- end time
    l_time_spent NUMBER;  -- time elapsed
    enum_status VARCHAR2(1); -- Succeeded or Failed

    l_total_time NUMBER; -- total time
    l_user_ver_time NUMBER; -- time taken to verify user name and responsibility

    temp1           NUMBER;  -- start time
    temp2           NUMBER;  -- end time

    l_sql   VARCHAR2(4000);


    cursor c_eproc is
    SELECT
    e.sel_enum_id,
    e.enum_proc,
    e.work_q_register_type,
    e.media_type_id,
    e.application_id,
    e.work_q_label_lu_type,
    e.work_q_label_lu_code
    FROM
    IEU_UWQ_SEL_ENUMERATORS e
    WHERE EXISTS (select 'x' from FND_PROFILE_OPTIONS b
    where upper(b.PROFILE_OPTION_NAME) = upper(e.work_q_enable_profile_option))
    AND ((e.NOT_VALID_FLAG is NULL) OR (e.NOT_VALID_FLAG = 'N')) AND
    (nvl(fnd_profile.value(e.work_q_enable_profile_option),'Y') = 'Y')
    AND (e.work_q_register_type <> 'W' or e.work_q_register_type is null)
    order by e.sel_enum_id;


    cursor c_dproc (enum_id NUMBER, app_id NUMBER, l_type VARCHAR2, l_code VARCHAR2)is
    select distinct v.meaning, s.sel_enum_id, s.enum_proc, tl.application_name
    from ieu_uwq_sel_enumerators s,
         fnd_application_tl tl,
         fnd_lookup_values v
    where s.sel_enum_id = enum_id
    and tl.application_id = app_id
    and v.lookup_type = l_type
    and v.lookup_code = l_code
    and tl.language = l_language
    and v.language = l_language;


BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    l_source_lang :=FND_GLOBAL.BASE_LANGUAGE;
    x_dupli_proc := IEU_DIAG_ENUM_NST();
    x_invalid_pkg := IEU_DIAG_ENUM_NST();
    x_invalid_proc := IEU_DIAG_ENUM_ERR_NST();
    x_enum_time := IEU_DIAG_ENUM_TIME_NST();
    x_user_ver_time := 0;
    x_etime_grand_total := 0;
    x_msg_count := 0;
    x_msg_data := '';

    l_medias := IEU_DIAG_STRING_NST();
    l_total_time := 0;

    t1 := DBMS_UTILITY.GET_TIME;

    Check_User_Resp(x_return_status, x_msg_count, x_msg_data,
                    p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);

    t2 := DBMS_UTILITY.GET_TIME;

    x_user_ver_time := (t2 -t1)*10;
    --DBMS_OUTPUT.put_line('verified userid and resp values, time taken - '|| x_user_ver_time);


    if (x_return_status = 'S') then
       /* Determine_Valid_Server ( l_temp_return_status, l_temp_msg_count,
                                 l_temp_msg_data, p_user_name,
                                 p_responsibility, l_svr_group_name,
                                 l_medias);*/

        l_sql := 'select resource_id from jtf_rs_resource_extns where user_id = :l_user_id';

        EXECUTE IMMEDIATE l_sql
        INTO l_resource_id
        USING l_user_id;


        UPDATE IEU_UWQ_SEL_RT_NODES
        SET not_valid = 'Y'
        WHERE resource_id = l_resource_id;

        UPDATE IEU_UWQ_RTNODE_BIND_VALS
        SET not_valid_flag = 'Y'
        WHERE resource_id = l_resource_id;


        l_wb_style := ieu_pvt.determine_wb_style( l_resource_id );


        FOR c_rec in c_eproc LOOP

            BEGIN

                t1 := DBMS_UTILITY.GET_TIME;

                --get the details of a node
                /*  SELECT lu.MEANING into l_vnode_label
                from IEU_UWQ_SEL_ENUMERATORS u,  FND_LOOKUP_VALUES lu
                where
                u.WORK_Q_LABEL_LU_TYPE = lu.LOOKUP_TYPE
                and u.WORK_Q_LABEL_LU_CODE = lu.LOOKUP_CODE
                and u.SEL_ENUM_ID =c_rec.SEL_ENUM_ID;*/


                select distinct v.meaning into l_vnode_label
                from ieu_uwq_sel_enumerators s,
                    fnd_application_tl tl,
                    fnd_lookup_values v
                where s.sel_enum_id = c_rec.SEL_ENUM_ID
                    and tl.application_id = s.APPLICATION_ID
                    and v.lookup_type = s.WORK_Q_LABEL_LU_TYPE
                    and v.lookup_code = s.WORK_Q_LABEL_LU_CODE
                    and tl.language = v.language
                    and v.language= l_language;




                --starting time
                enum_status := 'S';


                t1 := DBMS_UTILITY.GET_TIME;
                 --DBMS_OUTPUT.put_line('after select enum id==='||c_rec.SEL_ENUM_ID);
                  --DBMS_OUTPUT.put_line('start time== '||t1);



                -- first check whether the enum_proc is unique or not.
                /*if(temp_not_eligible_flag = false) then
                null;
                end if;*/

                begin

                    select count(sel_enum_id) into l_count from ieu_uwq_sel_enumerators
                    where enum_proc = c_rec.enum_proc;


                     --DBMS_OUTPUT.put_line('count of duplicate enum_proc-->'||l_count);

                    if not(l_count is null) and (l_count > 1) then
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        --dbms_output.put_line('there are duplicate records with the same enum_proc');

                        FOR c_temp in c_dproc(c_rec.sel_enum_id, c_rec.application_id, c_rec.work_q_label_lu_type, c_rec.work_q_label_lu_code) LOOP
                            --dbms_output.put_line('in the for loop of duplicate row cursor');
                            i := i+1;
                            x_dupli_proc.EXTEND();
                            --dbms_output.put_line('extended');
                            x_dupli_proc(x_dupli_proc.LAST) := IEU_DIAG_ENUM_OBJ(c_temp.application_name,
                                                            c_temp.meaning, c_temp.enum_proc);
                            --dbms_output.put_line('added');
                        END LOOP;

                    end if;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;


                end;
            -- next check the procedure

                begin

                    l_temp_eproc := c_rec.enum_proc;

                    if not(l_temp_eproc is null) then

                        l_temp_pkg_name := substr(l_temp_eproc,1,  ( instr(l_temp_eproc,'.',1,1)-1));
                        begin

                           select count(*) into l_temp_count from all_objects where owner = 'APPS' and object_type in('PACKAGE', 'PACKAGE BODY') and status='VALID'and object_name = l_temp_pkg_name;



                            if not(l_temp_count is null) and (l_temp_count <= 0) then
                                x_return_status := FND_API.G_RET_STS_ERROR;

                                FOR c_temp2 in c_dproc(c_rec.sel_enum_id, c_rec.application_id, c_rec.work_q_label_lu_type, c_rec.work_q_label_lu_code)
                                LOOP
                                    --dbms_output.put_line('in the for loop');
                                    j := j+1;
                                    x_invalid_pkg.EXTEND();
                                    --dbms_output.put_line('extended');
                                    enum_status := 'F';
                                    x_invalid_pkg(x_invalid_pkg.LAST) := IEU_DIAG_ENUM_OBJ(c_temp2.application_name,
                                                            c_temp2.meaning, c_temp2.enum_proc);
                                    --dbms_output.put_line('added');
                                END LOOP;

                            end if;

                        EXCEPTION

                            WHEN NO_DATA_FOUND THEN
                                null;


                        end;


                    end if;
                end;

                l_media_eligible := null;


                if ( ( (l_wb_style = 'F') or  (l_wb_style = 'SF') )
                  and (c_rec.work_q_register_type = 'M') )  -- Full/Simple Forced Blending
                then

                IEU_DEFAULT_MEDIA_ENUMS_PVT.create_blended_node( l_resource_id, l_language, l_source_lang );

                else

                if ( ( (l_wb_style = 'O') or (l_wb_style = 'SO') )
                and (c_rec.work_q_register_type = 'M') )   -- Full/Simple Optional Blending
                then

                 IEU_DEFAULT_MEDIA_ENUMS_PVT.create_blended_node( l_resource_id, l_language, l_source_lang );

                end if;

          -- Here we are excluding Inbound and Acquired email as these will not have servers now.
            IF ( not( (c_rec.media_type_id = 10001) or (c_rec.media_type_id = 10008) ))
            THEN

                IF ((c_rec.work_q_register_type = 'M') and (c_rec.media_type_id is not NULL))
                THEN

                    IF (IEU_PVT.IS_MEDIA_TYPE_ELIGIBLE
                         (l_resource_id ,c_rec.media_type_id) = FALSE)
                    THEN
                      l_media_eligible := 'FALSE';
                    ELSE
                      l_media_eligible := 'TRUE';
                    END IF;

                END IF;
            END IF;

            --dbms_output.put_line('l_media_eligible : '||l_media_eligible||' enum proc : '||c_rec.enum_proc);
            IF ( (l_media_eligible is null) or (l_media_eligible = 'TRUE') )
            THEN

            BEGIN

                EXECUTE IMMEDIATE
                    'begin ' || c_rec.ENUM_PROC ||
                    '( ' ||
                       'p_resource_id => :1, ' ||
                       'p_language => :2, ' ||
                       'p_source_lang => :3, ' ||
                       'p_sel_enum_id => :4 ' ||
                    '); end;'
                 USING
                   IN l_resource_id,
                   IN l_language,
                   IN l_source_lang,
                   IN c_rec.SEL_ENUM_ID;

                 --dbms_output.put_line('l_media_eligible : '||l_media_eligible||' enum proc : '||c_rec.enum_proc);

                SAVEPOINT last_enum_success;

               -- if we got here, the savepoint has been executed
               l_savepoint_valid := 1;

               EXCEPTION
                WHEN others then
                 x_return_status := FND_API.G_RET_STS_ERROR;

                 --dbms_output.put_line('sqlerr : ' ||sqlerrm || ' end err msg');
                  FOR c_temp3 in c_dproc(c_rec.sel_enum_id, c_rec.application_id, c_rec.work_q_label_lu_type, c_rec.work_q_label_lu_code)
                     LOOP
                     --dbms_output.put_line('in the for loop');
                     enum_status := 'F';

                         x_invalid_proc.EXTEND();
                         --dbms_output.put_line('extended');
                         x_invalid_proc(x_invalid_proc.LAST) := IEU_DIAG_ENUM_ERR_OBJ(c_temp3.application_name,
                                                             c_temp3.meaning, c_temp3.enum_proc, SQLERRM);
                     --dbms_output.put_line('added in the x_invalid_proc');
                     END LOOP;


            END;


           END IF;

          end if;

         EXCEPTION
          WHEN OTHERS THEN
            -- Adding this condition will prevent an error if the exception
            -- was caused by the first record

            if (l_savepoint_valid = 1) then
              ROLLBACK TO last_enum_success;
            end if;
        END;

            --end time

            t2 := DBMS_UTILITY.GET_TIME;
            l_time_spent := (t2 - t1)*10;

            --DBMS_OUTPUT.put_line('node - '||l_time_spent);

            x_enum_time.EXTEND();

            /*(
            vnode_label VARCHAR2(512),
            status VARCHAR2(512),
            time_taken NUMBER(22)

            */
            x_enum_time(x_enum_time.LAST) := IEU_DIAG_ENUM_TIME_OBJ(l_vnode_label,
                                           enum_status, l_time_spent);

            l_total_time := l_total_time + l_time_spent;
            --DBMS_OUTPUT.PUT_LINE('Enumeration grand total time - ' || l_total_time);

      END LOOP;

        --
        temp1 := DBMS_UTILITY.GET_TIME;

        begin
          select
            rownum
          into
            l_media_count
          from
            IEU_UWQ_SEL_RT_NODES
          where
            (resource_id = l_resource_id) and
            (not_valid = 'N') and
            (media_type_id IS NOT NULL) and
            (rownum = 1);
        exception
          when others then
            l_media_count := 0;
        end;


        if (l_media_count >= 1)
        then

          Select
            meaning
          into
            l_node_label
          from
            fnd_lookup_values_vl
          where
            (lookup_type         = 'IEU_NODE_LABELS') and
            (view_application_id = 696) and
            (lookup_code         = 'IEU_MEDIA_LBL');

          IEU_UWQ_SEL_RT_NODES_PKG.LOAD_ROW (
            X_RESOURCE_ID          => l_resource_id,
            X_SEL_ENUM_ID          => 0,
            X_NODE_ID              => IEU_CONSTS_PUB.G_SNID_MEDIA,
            X_NODE_TYPE            => 0,
            X_NODE_PID             => 0,
            X_NODE_WEIGHT          => nvl(IEU_UWQ_UTIL_PUB.to_number_noerr(fnd_profile.value('IEU_QOR_MEDIA')) , IEU_CONSTS_PUB.G_SNID_MEDIA),
            X_NODE_DEPTH           => 1,
            X_SEL_ENUM_PID         => 0,
            X_MEDIA_TYPE_ID        => NULL,
            X_COUNT                => 0,
            X_DATA_SOURCE          => 'IEU_UWQ_MEDIA_DS',
            X_VIEW_NAME            => 'IEU_UWQ_MEDIA_V',
            X_WHERE_CLAUSE         => '',
            X_HIDE_IF_EMPTY        => NULL,
            X_NOT_VALID            => 'N',
            X_NODE_LABEL           => l_node_label,
            X_REFRESH_VIEW_NAME    => 'IEU_UWQ_MEDIA_V',
            X_RES_CAT_ENUM_FLAG    => NULL,
            X_REFRESH_VIEW_SUM_COL => 'QUEUE_COUNT'
           );

        end if;


    COMMIT;


    end if;

    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);


    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

   /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;*/
-- x_msg_data := '';

   x_msg_count := fnd_msg_pub.COUNT_MSG();

       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

temp2 := DBMS_UTILITY.GET_TIME;

x_etime_grand_total := l_total_time ;

--DBMS_OUTPUT.put_line('final total time ='|| x_etime_grand_total);



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
     --  x_msg_data := '';

                x_msg_count := fnd_msg_pub.COUNT_MSG();

                    FOR i in 1..x_msg_count LOOP
                        l_msg_data := '';
                        l_msg_count := 0;
                        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                        x_msg_data := x_msg_data || ',' || l_msg_data;
                    END LOOP;


       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        -- dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- x_msg_data := '';

         x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;


       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
           --  dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       --  x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/



END Check_Node_Enumeration;



--===================================================================
-- NAME
--    Get_Valid_RT_Nodes
--
-- PURPOSE
--    Private api to get the list of all valid rt nodes
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   01-Apr-2002     GPAGADAL   Created

--===================================================================
PROCEDURE Get_Valid_RT_Nodes( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_valid_nodes OUT NOCOPY IEU_DIAG_NODE_NST
)
AS
    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_language             VARCHAR2(4);

    l_valid_nodes IEU_DIAG_NODE_NST;

    l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

    CURSOR c_node IS
    SELECT
     node_id, node_label, node_pid, node_weight
    FROM ieu_uwq_sel_rt_nodes
    WHERE
     (resource_id = l_resource_id) and
          ((not_valid is null) or (not_valid <> 'Y'))order by node_pid, node_weight;


    i integer ;
    l_sql   VARCHAR2(4000);



BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_valid_nodes := IEU_DIAG_NODE_NST();

    Check_User_Resp (x_return_status, x_msg_count, x_msg_data,
                    p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);
    if (x_return_status = 'S') then
        BEGIN
            l_sql := ' select resource_id
                       from jtf_rs_resource_extns
                       where user_id = :l_user_id';

            EXECUTE IMMEDIATE l_sql
            INTO l_resource_id
            USING l_user_id;

            --dbms_output.put_line('resource_id--> '||l_resource_id);
            FOR cur_rec IN c_node
            LOOP
                --dbms_output.put_line('in the loop of enum');
                i := i+1;
                x_valid_nodes.EXTEND(1);

                --dbms_output.put_line('extended');

                x_valid_nodes(x_valid_nodes.last) := IEU_DIAG_NODE_OBJ(cur_rec.node_id, cur_rec.node_label,
                                                                   cur_rec.node_pid, cur_rec.node_weight);

                --dbms_output.put_line('node_id--> '||i||'-->'||cur_rec.node_id);
                --dbms_output.put_line('node_name-->'||cur_rec.node_label);
                --dbms_output.put_line('node_pid-->'||cur_rec.node_pid);
                --dbms_output.put_line('node_weight-->'||cur_rec.node_weight);
            end LOOP;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            --dbms_output.PUT_LINE('resource id does not exists ');
                   FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESOURCEID');-- Resource ID does not exist
                   FND_MSG_PUB.Add;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   --dbms_output.PUT_LINE('No data found for resource id : ');
        END;

    end if;

    --dbms_output.PUT_LINE('initialized');
    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);


    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

    /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;*/
     x_msg_data := '';

       x_msg_count := fnd_msg_pub.COUNT_MSG();

           FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
           END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := '';

          x_msg_count := fnd_msg_pub.COUNT_MSG();

              FOR i in 1..x_msg_count LOOP
                  l_msg_data := '';
                  l_msg_count := 0;
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
              END LOOP;


       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := '';

          x_msg_count := fnd_msg_pub.COUNT_MSG();

              FOR i in 1..x_msg_count LOOP
                  l_msg_data := '';
                  l_msg_count := 0;
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
              END LOOP;

        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

END Get_Valid_RT_Nodes;


--===================================================================
-- NAME
--    Check_Refresh_Node_Counts
--
-- PURPOSE
--    Private api used to refresh nodes table
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   18-Apr-2002     GPAGADAL   Created
--   8-Jan-2003     GPAGADAL   updated-- display status/time taken to
--   refresh node
--   1-May-2003 GPAGADAL updated -- display total time
--===================================================================

PROCEDURE Check_Refresh_Node_Counts (  x_return_status  OUT NOCOPY VARCHAR2,
                                        x_msg_count OUT NOCOPY NUMBER,
                                        x_msg_data  OUT NOCOPY VARCHAR2,
                                        p_user_name IN VARCHAR2,
                                        p_responsibility   IN VARCHAR2,
                                        x_invalid_pkg OUT NOCOPY IEU_DIAG_REFRESH_NST,
                                        x_invalid_rproc OUT NOCOPY IEU_DIAG_REFRESH_ERR_NST,
                                        x_refresh_time  OUT NOCOPY IEU_DIAG_REFRENUM_TIME_NST,
                                        x_user_ver_time OUT NOCOPY NUMBER,
                                        x_etime_total OUT NOCOPY NUMBER,
                                        x_rtime_total OUT NOCOPY NUMBER
)
AS

    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_language             VARCHAR2(4);

    l_valid_nodes IEU_DIAG_NODE_NST;

    l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

    l_temp_rproc IEU_UWQ_SEL_ENUMERATORS.REFRESH_PROC%TYPE;

    l_temp_pkg_name IEU_UWQ_SEL_ENUMERATORS.REFRESH_PROC%TYPE;

    l_temp_count NUMBER(10) ;

    i integer ;

    j integer ;

    l_invalid_rproc IEU_DIAG_REFRESH_ERR_NST;

    l_return_status VARCHAR2(1) ;


    l_count         NUMBER;
    l_where_clause  VARCHAR2(30000);
    l_refresh_view_name varchar2(200);
    l_refresh_view_sum_col varchar2(200);
    l_sel_rt_node_id number;
    l_node_id number(10);
    l_node_pid number(10);
    l_sel_enum_id number(15);
    l_res_cat_enum_flag varchar2(1);
    l_view_name varchar2(512);
    l_node_label varchar2(512);
    l_node_weight ieu_uwq_sel_rt_nodes.node_weight%type;

    l_temp_view_name varchar2(512);
    l_temp_view_count number(2);

    l_appli_name varchar2(240) ;

    t1           NUMBER;  -- start time
    t2           NUMBER;  -- end time
    l_time_spent NUMBER;  -- time elapsed
    refresh_status VARCHAR2(1); -- Succeeded or Failed


    l_rtotal_time NUMBER; -- refresh total time
    l_etotal_time NUMBER; -- enum total time
    l_user_ver_time NUMBER; -- time taken to verify user name and responsibility

    l_sql   VARCHAR2(4000);



    CURSOR c_nodes IS
    SELECT
        rt_nodes.sel_rt_node_id,
        rt_nodes.node_id,
        rt_nodes.node_pid,
        rt_nodes.view_name,
        rt_nodes.where_clause,
        rt_nodes.media_type_id,
        rt_nodes.sel_enum_id,
        rt_nodes.refresh_view_name,
        rt_nodes.refresh_view_sum_col,
        rt_nodes.res_cat_enum_flag,
        rt_nodes.node_label,
        rt_nodes.node_weight
    FROM

        ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
        (rt_nodes.resource_id = l_resource_id) AND
        (rt_nodes.node_id <> 0) AND
        (rt_nodes.node_id <> IEU_CONSTS_PUB.G_SNID_MEDIA) and
        (rt_nodes.not_valid = 'N')
        order by rt_nodes.node_pid, rt_nodes.node_weight;

    CURSOR c_media_nodes IS
    SELECT
        rt_nodes.sel_rt_node_id,
        rt_nodes.node_id,
        rt_nodes.node_pid,
        rt_nodes.where_clause,
        rt_nodes.sel_enum_id,
        rt_nodes.refresh_view_name,
        rt_nodes.refresh_view_sum_col,
        rt_nodes.res_cat_enum_flag,
        rt_nodes.view_name,
        rt_nodes.node_label,
        rt_nodes.node_weight
    FROM
        ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
        (rt_nodes.resource_id = l_resource_id) AND
        (rt_nodes.node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) and
        (rt_nodes.not_valid = 'N')
        order by rt_nodes.node_pid, rt_nodes.node_weight;

    cursor c_rproc is
    SELECT
        e.sel_enum_id,
        e.refresh_proc,
        e.work_q_register_type,
        e.media_type_id,
        e.application_id,
        e.work_q_label_lu_type,
        e.work_q_label_lu_code
    FROM
        IEU_UWQ_SEL_ENUMERATORS e
    WHERE EXISTS (select 'x' from FND_PROFILE_OPTIONS b
        where upper(b.PROFILE_OPTION_NAME) = upper(e.work_q_enable_profile_option))
        AND ((e.NOT_VALID_FLAG is NULL) OR (e.NOT_VALID_FLAG = 'N')) AND
        (nvl(fnd_profile.value(e.work_q_enable_profile_option),'Y') = 'Y')
        order by e.sel_enum_id;


    cursor c_dproc (enum_id NUMBER, app_id NUMBER, l_type VARCHAR2, l_code VARCHAR2)is
    select distinct v.meaning, s.sel_enum_id, s.refresh_proc, tl.application_name
    from ieu_uwq_sel_enumerators s,
         fnd_application_tl tl,
         fnd_lookup_values v
    where s.sel_enum_id = enum_id
        and tl.application_id = app_id
        and v.lookup_type = l_type
        and v.lookup_code = l_code
        and tl.language = l_language
        and v.language = l_language;

    cursor c_temp (enum_id NUMBER)is
    select tl.application_name
    from ieu_uwq_sel_enumerators s,
         fnd_application_tl tl
    where s.sel_enum_id = enum_id
        and tl.application_id = s.application_id
        and tl.language = l_language;



    l_dupli_proc IEU_DIAG_ENUM_NST;
    l_invalid_pkg  IEU_DIAG_ENUM_NST;
    l_invalid_proc IEU_DIAG_ENUM_ERR_NST;
    l_enum_time  IEU_DIAG_ENUM_TIME_NST;

BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_invalid_pkg := IEU_DIAG_REFRESH_NST();
    x_invalid_rproc := IEU_DIAG_REFRESH_ERR_NST();
    l_invalid_rproc := IEU_DIAG_REFRESH_ERR_NST();
    x_refresh_time := IEU_DIAG_REFRENUM_TIME_NST();

    l_dupli_proc := IEU_DIAG_ENUM_NST();
    l_invalid_pkg := IEU_DIAG_ENUM_NST();
    l_invalid_proc := IEU_DIAG_ENUM_ERR_NST();
    l_enum_time := IEU_DIAG_ENUM_TIME_NST();
    l_user_ver_time := 0;
    l_etotal_time := 0;
    l_rtotal_time := 0;
    x_msg_count := 0;
    x_msg_data := '';


    --Check_User_Resp(x_return_status, x_msg_count, x_msg_data,
           --         p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);

Check_Node_Enumeration ( x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_user_name,
                         p_responsibility,
                         l_dupli_proc,
                         l_invalid_pkg ,
                         l_invalid_proc ,
                         l_enum_time  ,
                         l_user_ver_time ,
                         l_etotal_time

);

           x_user_ver_time := l_user_ver_time;
           x_etime_total := l_etotal_time;

    if (x_return_status = 'S') then
     --   DBMS_OUTPUT.put_line('Check_Node_Enumeration...success');

-- get the user id , responsibility id and application id

            l_sql := ' select user_id from fnd_user
                     where upper(user_name) like upper(:p_user_name)';
            EXECUTE IMMEDIATE l_sql
            INTO l_user_id
            USING in p_user_name;
l_sql := ' select responsibility_id, application_id from fnd_responsibility_tl where language = :l_language and responsibility_id = :p_responsibility';
          /*  l_sql := ' select responsibility_id, application_id  //bug6414726
                      from fnd_responsibility_tl where language = :l_language
                     and responsibility_name like :p_responsibility'; */

            EXECUTE IMMEDIATE l_sql
            INTO l_responsibility_id, l_application_id
            USING l_language, p_responsibility;




        l_sql := 'select resource_id
                  from jtf_rs_resource_extns
                  where user_id = :l_user_id';

            --DBMS_OUTPUT.put_line('query---'||l_sql);
        EXECUTE IMMEDIATE l_sql
        INTO l_resource_id
        USING l_user_id;

        --DBMS_OUTPUT.put_line('resource_id--> '||l_resource_id);

        FOR c_rec in c_rproc LOOP

            begin

                l_temp_rproc := c_rec.refresh_proc;

                if not(l_temp_rproc is null) then

                    l_temp_pkg_name := substr(l_temp_rproc,1,  ( instr(l_temp_rproc,'.',1,1)-1));
                    begin

                         select count(*) into l_temp_count
                         from all_objects
                         where owner = 'APPS' and object_type in('PACKAGE', 'PACKAGE BODY')
                         and status='VALID'and object_name = l_temp_pkg_name;


                        if not(l_temp_count is null) and (l_temp_count <= 0) then

                            FOR c_temp2 in c_dproc(c_rec.sel_enum_id, c_rec.application_id, c_rec.work_q_label_lu_type, c_rec.work_q_label_lu_code)
                            LOOP
                                --dbms_output.put_line('in the for loop');
                                j := j+1;
                                x_invalid_pkg.EXTEND();
                                refresh_status := 'F';
                                ----DBMS_OUTPUT.put_line('invalid pkg extended');
                                x_invalid_pkg(x_invalid_pkg.LAST) := IEU_DIAG_REFRESH_OBJ(c_temp2.application_name,
                                                                c_temp2.meaning, c_temp2.refresh_proc, 'PACKAGE');
                                --DBMS_OUTPUT.put_line('invalid pkg added');
                            END LOOP;

                        end if;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            null;
                    end;
                end if;
            end;
        END LOOP;

        if (x_invalid_pkg IS NOT NULL and x_invalid_pkg.count > 0 ) then
            x_return_status := FND_API.G_RET_STS_ERROR;
            refresh_status := 'F';--Failed
        end if;



        begin
            FOR node in c_nodes
            LOOP

                refresh_status := 'S';--Succeeded
                t1 := DBMS_UTILITY.GET_TIME;
                --DBMS_OUTPUT.put_line('start time== '||t1);

                begin
                    null;
                    select count(object_name) into l_temp_view_count from all_objects
                    where object_name = node.view_name and object_type = 'VIEW'
                        and status = 'VALID' and owner = 'APPS';

                    select tl.application_name into l_appli_name
                    from ieu_uwq_sel_enumerators s,
                        fnd_application_tl tl
                    where s.sel_enum_id = node.sel_enum_id
                        and tl.application_id = s.application_id
                        and tl.language = l_language;


                    if (l_temp_view_count <> 1) then
                        x_return_status := FND_API.G_RET_STS_ERROR;

                        i:= i+1;
                        x_invalid_pkg.EXTEND();
                        --DBMS_OUTPUT.put_line('invalid pkg  extended for view');
                        refresh_status := 'F';--Failed

                        x_invalid_pkg(x_invalid_pkg.LAST) := IEU_DIAG_REFRESH_OBJ(l_appli_name, node.node_label, node.view_name,'VIEW');
                        --DBMS_OUTPUT.put_line('invalid pkg added');


                    end if;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
                end;


                l_count := 0;



                Refresh_Node(node.node_id, node.node_pid, node.sel_enum_id, node.where_clause,
                node.res_cat_enum_flag, node.refresh_view_name, node.refresh_view_sum_col,
                node.sel_rt_node_id, l_count, l_resource_id, node.view_name, node.node_label, l_invalid_rproc);

                t2 := DBMS_UTILITY.GET_TIME;
                --DBMS_OUTPUT.put_line('end time=== '||t2);
                l_time_spent := (t2 - t1)*10;
                --DBMS_OUTPUT.put_line('Difference***-- '||l_time_spent);
                l_rtotal_time := l_rtotal_time + l_time_spent;
                --DBMS_OUTPUT.put_line('total***-- '||l_rtotal_time);

                IF l_invalid_rproc.count > 0 THEN
                    refresh_status := 'F';--Failed
                    --DBMS_OUTPUT.put_line('failed');
                END IF;
                --DBMS_OUTPUT.put_line('put refresh time in nst');

                x_refresh_time.EXTEND();

                /*(vnode_id NUMBER(22),
                vnode_label VARCHAR2(512),
                vnode_pid NUMBER(22),
                vnode_weight NUMBER(22),
                status VARCHAR2(512),
                time_taken NUMBER(22)

                */
                x_refresh_time(x_refresh_time.LAST) := IEU_DIAG_REFRENUM_TIME_OBJ(node.node_id, node.node_label,
                                          node.node_pid, node.node_weight, refresh_status, l_time_spent);


                /*  insert into g_temp (G) values (l_time_spent);
                commit;*/

                IF l_invalid_rproc.count > 0 THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FOR i IN l_invalid_rproc.first..l_invalid_rproc.last LOOP
                        IF l_invalid_rproc.exists(i) THEN
                            x_invalid_rproc.EXTEND();
                            x_invalid_rproc(x_invalid_rproc.last) := l_invalid_rproc(i);

                        END IF;
                    END LOOP;
                END IF;

                /* if (x_invalid_rproc IS NOT NULL) then
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    loop

                        if x_invalid_rproc.EXISTS(i) then
                            --dbms_output.put_line('count: -->'|| i);

                            --dbms_output.put_line('application name id (' || i|| '): '||x_invalid_rproc(i).app_name);
                            --dbms_output.put_line('node name (' || i|| '): '|| x_invalid_rproc(i).vnode_label);
                            --dbms_output.put_line('obj name (' || i || '): '|| x_invalid_rproc(i).obj_name);
                            i := i+1;
                        else
                            exit;
                        end if;


                    end loop;

                end if;*/

            END LOOP;
        end;

        begin
            open c_media_nodes;

            fetch c_media_nodes
            into l_sel_rt_node_id,l_node_id, l_node_pid, l_where_clause, l_sel_enum_id,
            l_refresh_view_name,l_refresh_view_sum_col, l_res_cat_enum_flag, l_view_name, l_node_label, l_node_weight;

            t1 := DBMS_UTILITY.GET_TIME;
            --DBMS_OUTPUT.put_line('start time== '||t1);

            if c_media_nodes%NOTFOUND then
                null;
            else
                begin

                    select count(object_name) into l_temp_view_count from all_objects
                    where object_name = l_view_name and object_type = 'VIEW'
                    and status = 'VALID' and owner = 'APPS';

                    select tl.application_name into l_appli_name
                    from ieu_uwq_sel_enumerators s,
                        fnd_application_tl tl
                    where s.sel_enum_id = l_sel_enum_id
                        and tl.application_id = s.application_id
                        and tl.language = l_language;

                    if (l_temp_view_count <> 1) then
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        i:= i+1;
                        x_invalid_pkg.EXTEND();
                        --DBMS_OUTPUT.put_line('invalid pkg  extended');
                        refresh_status := 'F';--Failed

                        x_invalid_pkg(x_invalid_pkg.LAST) := IEU_DIAG_REFRESH_OBJ(l_appli_name, l_node_label, l_view_name,'VIEW');
                        --DBMS_OUTPUT.put_line('invalid pkg added for view');

                    end if;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    null;
                end;

                l_count := 0;
                refresh_status := 'S';--Succeeded


                Refresh_Node(l_node_id, l_node_pid, l_sel_enum_id, l_where_clause,
                l_res_cat_enum_flag, l_refresh_view_name, l_refresh_view_sum_col,
                l_sel_rt_node_id, l_count, l_resource_id,l_view_name, l_node_label, l_invalid_rproc);

                t2 := DBMS_UTILITY.GET_TIME;
                --DBMS_OUTPUT.put_line('end time=== '||t2);
                l_time_spent := (t2 - t1)*10;
                --DBMS_OUTPUT.put_line('Difference***-- '||l_time_spent);
                l_rtotal_time := l_rtotal_time + l_time_spent;
                --DBMS_OUTPUT.put_line('total***-- '||l_rtotal_time);

                IF l_invalid_rproc.count > 0 THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;--
                    refresh_status := 'F';--Failed
                    --DBMS_OUTPUT.put_line('failed');
                END IF;
                   --DBMS_OUTPUT.put_line('put refresh time in nst');

                x_refresh_time.EXTEND();

                /*(vnode_id NUMBER(22),
                vnode_label VARCHAR2(512),
                vnode_pid NUMBER(22),
                vnode_weight NUMBER(22),
                status VARCHAR2(512),
                time_taken NUMBER(22)

                */
                x_refresh_time(x_refresh_time.LAST) := IEU_DIAG_REFRENUM_TIME_OBJ(l_node_id, l_node_label,
                                          l_node_pid, l_node_weight, refresh_status, l_time_spent);

                /* insert into g_temp (G) values (l_time_spent);
                commit;*/

                IF l_invalid_rproc.count > 0 THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;--
                    FOR i IN l_invalid_rproc.first..l_invalid_rproc.last LOOP
                        IF l_invalid_rproc.exists(i) THEN
                            x_invalid_rproc.EXTEND();
                            refresh_status := 'F';--Failed
                            x_invalid_rproc(x_invalid_rproc.last) := l_invalid_rproc(i);
                            --dbms_output.put_line('application name '|| l_invalid_rproc(i).app_name);null; -- type of data not known
                        END IF;
                    END LOOP;
                END IF;


                /*  --x_invalid_rproc.EXTEND();
                x_invalid_rproc := l_invalid_rproc;
                --x_return_status := l_return_status;*/
                if (x_invalid_rproc IS NOT NULL and x_invalid_rproc.count > 0) then
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    refresh_status := 'F';--Failed
                end if;

            end if;
        END;
   else
  --  DBMS_OUTPUT.put_line('Check_Node_Enumeration...failed');
    FND_MESSAGE.set_name('IEU', 'IEU_DIAG_ENUM_FAIL_FIXIT');
    FND_MSG_PUB.Add;

   end if;

    commit;

    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);
    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

    /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;*/
   -- x_msg_data := '';

    x_msg_count := fnd_msg_pub.COUNT_MSG();

    FOR i in 1..x_msg_count LOOP
        l_msg_data := '';
        l_msg_count := 0;
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;

x_rtime_total := l_rtotal_time;
--DBMS_OUTPUT.put_line('refresh time'||x_rtime_total);
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);
        x_return_status := FND_API.G_RET_STS_ERROR;
      --  x_msg_data := '';
        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


        /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- x_msg_data := '';

        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
        --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     --   x_msg_data := '';

        x_msg_count := fnd_msg_pub.COUNT_MSG();

        FOR i in 1..x_msg_count LOOP
            l_msg_data := '';
            l_msg_count := 0;
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

END Check_Refresh_Node_Counts;

--===================================================================
-- NAME
--    Refresh_Node
--
-- PURPOSE
--    Private api to refresh nodes
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--  19-Apr-2002     GPAGADAL   Created

--===================================================================

PROCEDURE Refresh_Node(
       p_node_id in number,
       p_node_pid in number,
       p_sel_enum_id in number,
       p_where_clause in varchar2,
       p_res_cat_enum_flag in varchar2,
       p_refresh_view_name in varchar2,
       p_refresh_view_sum_col in varchar2,
       p_sel_rt_node_id in number,
       p_count in number,
       p_resource_id in number,
       p_view_name in varchar2,
       p_node_label in varchar2,
       x_invalid_rproc OUT NOCOPY IEU_DIAG_REFRESH_ERR_NST
)
AS

    l_count         NUMBER;
    l_refresh_proc  VARCHAR2(100);
    l_where_clause  VARCHAR2(30000);
    l_res_cat_where_clause     VARCHAR2(30000);
    l_sql_stmt VARCHAR2(30000);
    l_cursor_name INTEGER;
    l_rows_processed INTEGER;
    l_rtnode_bind_var_flag   Varchar2(50) ;
    l_enum_bind_var_flag     Varchar2(50) ;
    l_resource_id_flag       Varchar2(10) ;
    l_node_count  number;
    l_param_pk_value varchar2(500);
    l_media_sql_stmt varchar2(10000);


    l_language             VARCHAR2(4);
        l_appli_name varchar2(240) ;
    --valid_rproc boolean;

    i integer ;
    l_sql   VARCHAR2(4000);



    CURSOR c_bindVal IS
    SELECT
      rt_nodes_bind_val.SEL_RT_NODE_ID,
      rt_nodes_bind_val.node_id,
      rt_nodes_bind_val.BIND_VAR_NAME,
      rt_nodes_bind_val.bind_var_value
    FROM

      ieu_uwq_rtnode_bind_vals rt_nodes_bind_val
    WHERE
      (rt_nodes_bind_val.resource_id = p_resource_id) AND
      (rt_nodes_bind_val.node_id <> 0) AND
      (rt_nodes_bind_val.not_valid_flag = 'N');

BEGIN

    l_rtnode_bind_var_flag :='T';
    l_enum_bind_var_flag    := '';
    l_resource_id_flag       := '';

            l_language := FND_GLOBAL.CURRENT_LANGUAGE;
            x_invalid_rproc := IEU_DIAG_REFRESH_ERR_NST();
           -- valid_rproc := true;
            --x_return_status := null;
      if ( (p_node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) or
           (p_node_id = IEU_CONSTS_PUB.G_SNID_BLENDED) )
      then
        begin
          select
            where_clause
          into
            l_res_cat_where_clause
          from
            ieu_uwq_res_cats_b
          where
            res_cat_id = 10001;

        exception
          when no_data_found then
            null;
        end;
      else
        l_res_cat_where_clause := ieu_pub.get_enum_res_cat(p_sel_enum_id);
      end if;

      if (p_where_clause is NULL)
      then
        l_where_clause := l_res_cat_where_clause;
        l_rtnode_bind_var_flag := 'F';
      else

        if (p_res_cat_enum_flag = 'Y') OR (p_res_cat_enum_flag is NULL)
        then
          if  (l_res_cat_where_clause) is not null
          then
            l_where_clause :=
              l_res_cat_where_clause || ' and ' || p_where_clause;
            --l_rtnode_bind_var_flag := 'F';
            l_rtnode_bind_var_flag := 'T';
          end if;
        else
          l_where_clause := p_where_clause;
          l_rtnode_bind_var_flag := 'T';
        end if;
      end if;



      if (l_res_cat_where_clause is not null)
     then
       select
        decode(
          (instr(l_res_cat_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
       into
        l_enum_bind_var_flag
       from
        dual;
      else
      l_enum_bind_var_flag := 'F';
      end if;


      BEGIN


        -- Use sel_enum_id to find which proc to call
        BEGIN
          select
            refresh_proc
          into
            l_refresh_proc
          from
            ieu_uwq_sel_enumerators
          where
            sel_enum_id = p_sel_enum_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;

        END;

        --
        -- If Refresh Proc is present then get the count from refresh proc
        -- otherwise, get count from the refresh view, or default query.
        --
        IF (l_refresh_proc IS not NULL)
        THEN

          BEGIN
            -- If any refresh proc produces an error

            select tl.application_name into l_appli_name
            from ieu_uwq_sel_enumerators s,
                 fnd_application_tl tl
            where s.sel_enum_id = p_sel_enum_id
            and tl.application_id = s.application_id
            and tl.language = l_language;

            --dbms_output.put_line('call refresh procedure');
            execute immediate
              'begin '|| l_refresh_proc || '(' || ':P_RESOURCE_ID' ||
              ', '|| ':p_node_id ' || ',:l_count);end;'
            using
              in p_resource_id, in p_node_id, out l_count;
          EXCEPTION

            when no_data_found then
            null;
            when others then
             --valid_rproc := false;

            --x_return_status := FND_API.G_RET_STS_ERROR;
            --dbms_output.put_line('exception raised while calling refresh');
            x_invalid_rproc.EXTEND();
            --dbms_output.put_line('invalid rproc  extended');

            x_invalid_rproc(x_invalid_rproc.LAST) := IEU_DIAG_REFRESH_ERR_OBJ(l_appli_name,
            p_node_label, l_refresh_proc, 'PROCEDURE', SQLERRM);
            --dbms_output.put_line('invalid rproc  added');


          END;

        ELSE

          --

          -- if we have a refresh view then get the count from the refresh
          -- view else from the base view .
          --
          IF (p_refresh_view_name IS NOT NULL)
          THEN

            --
            -- If there is a SUM column specified for the node, then use that
            -- to perform a sum on the specified column in refresh view.
            --
            IF (p_REFRESH_VIEW_SUM_COL IS NOT NULL)
            THEN
              --
              -- special processing for SUM count logic (i.e., Media nodes)
              --
              l_sql_stmt :=
                'Select sum(' || p_REFRESH_VIEW_SUM_COL || ') from ' ||
                p_REFRESH_view_name || ' where ' || l_where_clause ||
                ' and ieu_param_pk_value is not null';

              /* this following codes added because in passive mode there is no classification but 'ANY'
                 so, the above select would not work for 'ANY' */

               if p_node_pid = 4000 then
                  l_media_sql_stmt :=
                      'begin select count(*) into :l_node_count from '||
                       p_refresh_view_name||' where resource_id =  '||p_resource_id||'; end;';

                  EXECUTE IMMEDIATE l_media_sql_stmt
                  USING out l_node_count;

                  if l_node_count = 1 then
                    l_media_sql_stmt :=
                      'begin select ieu_param_pk_value into :l_param_pk_value from '||
                       p_refresh_view_name||' where resource_id =  '||p_resource_id||'; end;';

                     EXECUTE IMMEDIATE l_media_sql_stmt
                     USING out l_param_pk_value;

                     if l_param_pk_value is null then
                        l_sql_stmt :=
                              'Select sum(' || p_REFRESH_VIEW_SUM_COL || ') from ' ||
                               p_REFRESH_view_name || ' where ' || l_where_clause;
                     end if;
                  end if;

               end if;

            ELSE

              l_sql_stmt :=
                'select count(resource_id) from ' || p_refresh_view_name ||
                ' where ' || l_where_clause;


            END IF;

          ELSE

            --
            -- we'll have to collect the count
            --
            l_sql_stmt :=
              'select count(resource_id) from ' || p_view_name ||
              ' where ' || l_where_clause;

          END IF;



          --
          -- Execute the sql_stmt to get the count
          --

          BEGIN
            l_cursor_name := dbms_sql.open_cursor;
            DBMS_SQL.PARSE(l_cursor_name,l_sql_stmt , dbms_sql.native);

             If (l_rtnode_bind_var_flag = 'T')
             then

               -- Check if resource_id is present.
             if (l_where_clause is not null)
             then
                 select
                    decode((instr(l_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
                 into
                    l_resource_id_flag
                 from
                    dual;
               else
              l_resource_id_flag := 'F';
               end if;

               if (l_resource_id_flag = 'T')
               then
                 DBMS_SQL.BIND_VARIABLE (
                   l_cursor_name,
                   ':resource_id',
                   p_resource_id );
               end if;


               for b in c_bindVal
               loop

                 if ( (b.sel_rt_node_id = p_sel_rt_node_id) and
                      (b.node_id   = p_node_id) )
                 then
                   -- Ignore bind Var :resource_id here.
                   If (b.bind_var_name <> ':resource_id')
                   then

                       DBMS_SQL.BIND_VARIABLE (
                         l_cursor_name,
                         b.bind_var_name,
                         b.bind_var_value );
                   end if;
                end if;

               end loop;


             else

               if (l_enum_bind_var_flag = 'T')
               then
                 DBMS_SQL.BIND_VARIABLE (
                   l_cursor_name,
                   ':resource_id',
                   p_resource_id );
               end if;

            end if;

            --DBMS_SQL.BIND_VARIABLE(l_cursor_name, ':resource_id', 3807);
            DBMS_SQL.DEFINE_COLUMN(l_cursor_name, 1, l_count);
            l_rows_processed := dbms_sql.execute(l_cursor_name);

            IF (DBMS_SQL.FETCH_ROWS(l_cursor_name) > 0)
            THEN
              -- get column values of the row
              DBMS_SQL.COLUMN_VALUE(l_cursor_name, 1, l_count);
            END IF;

            DBMS_SQL.close_cursor(l_cursor_name);

          EXCEPTION

            WHEN OTHERS THEN
              DBMS_SQL.CLOSE_CURSOR(l_cursor_name);

          END;

        END IF;

      exception
        WHEN OTHERS THEN
          l_count := 0;
          --dbms_output.put_line(SQLCODE);
          --dbms_output.put_line(SQLERRM);


      end;

      IF (l_count IS NULL)
      THEN
        l_count := 0;
      END IF;

      --
      -- now update the count for the row
      --
      UPDATE
        IEU_UWQ_SEL_RT_NODES nodes
      SET

        nodes.count = l_count
      WHERE
        (nodes.sel_rt_node_id = p_sel_rt_node_id) AND
        (nodes.resource_id = p_resource_id);

  -- if NOT(valid_rproc)then
  -- x_return_status := FND_API.G_RET_STS_ERROR;
  -- end if;

--dbms_output.put_line('return status in refresh_node' || x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- nothing we can really do if this fails...
        NULL;
        --DBMS_OUTPUT.put_line('exception : '||substr(sqlerrm, 1, 50));

END Refresh_Node;


--===================================================================
-- NAME
--    Check_View
--
-- PURPOSE
--    Private api to check each view of the node
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   17-Apr-2002     GPAGADAL   Created

--===================================================================


 PROCEDURE Check_View ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY  NUMBER,
                        x_msg_data  OUT NOCOPY VARCHAR2,
                        p_user_name IN VARCHAR2,
                        p_responsibility   IN VARCHAR2,
                        x_invalid_views OUT NOCOPY IEU_DIAG_STRING_NST)
AS
    l_user_name FND_USER.USER_NAME%TYPE;

    l_user_id FND_USER.USER_ID%TYPE;

    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

    l_responsibility_name FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE;

    l_responsibility_key  FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;

    l_application_id FND_RESPONSIBILITY.APPLICATION_ID%TYPE;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);

    l_language             VARCHAR2(4);

    l_valid_nodes IEU_DIAG_NODE_NST;

    l_resource_id JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;

    l_count NUMBER(3) ;

    l_sql   VARCHAR2(4000);



    CURSOR c_node IS
    SELECT
     node_id, view_name
    FROM ieu_uwq_sel_rt_nodes
    WHERE
     (resource_id = l_resource_id) and
          ((not_valid is null) or (not_valid <> 'Y'))order by node_pid, node_weight;


    i integer ;

    l_temp_view VARCHAR2(512) ;

BEGIN
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_invalid_views := IEU_DIAG_STRING_NST();

    Check_User_Resp (x_return_status, x_msg_count, x_msg_data,
                    p_user_name, p_responsibility, l_user_id, l_responsibility_id, l_application_id);

    if (x_return_status = 'S') then
        BEGIN
            l_sql := ' select resource_id  from jtf_rs_resource_extns where user_id = :l_user_id';

            EXECUTE IMMEDIATE l_sql
            INTO l_resource_id
            USING l_user_id;

            --dbms_output.put_line('resource_id--> '||l_resource_id);




            FOR cur_rec IN c_node
            LOOP
                --dbms_output.put_line('in the loop of enum');
                begin

                    select count(object_name) into l_count from all_objects
                    where object_name = cur_rec.view_name and object_type = 'VIEW'
                    and status = 'VALID' and owner = 'APPS';

                    if l_count <> 1 then

                        x_return_status := FND_API.G_RET_STS_ERROR;
                        i := i+1;
                        x_invalid_views.EXTEND;
                        x_invalid_views(i) := cur_rec.view_name;
                    end if;


                exception
                    when no_data_found then
                        null;
                end;


            end LOOP;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                --dbms_output.PUT_LINE('resource id does not exists ');
                FND_MESSAGE.set_name('IEU', 'IEU_DIAG_NO_RESOURCEID');-- Resource ID does not exist
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                --dbms_output.PUT_LINE('No data found for resource id : ');
        END;

    end if;

    fnd_global.APPS_INITIALIZE(l_user_id, l_responsibility_id, l_application_id, null);
    -- Standard call to get message count and if count is 1, get message info.
    /*FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

   /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;*/

     x_msg_data := '';

       x_msg_count := fnd_msg_pub.COUNT_MSG();

           FOR i in 1..x_msg_count LOOP
               l_msg_data := '';
               l_msg_count := 0;
               FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
               x_msg_data := x_msg_data || ',' || l_msg_data;
           END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count        => x_msg_count,
            p_data         => l_msg_data
        );


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := '';

          x_msg_count := fnd_msg_pub.COUNT_MSG();

              FOR i in 1..x_msg_count LOOP
                  l_msg_data := '';
                  l_msg_count := 0;
                  FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                  x_msg_data := x_msg_data || ',' || l_msg_data;
              END LOOP;


        /*FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/

    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := '';

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


       /* FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;*/


END Check_View;

PROCEDURE CHECK_OBJECT_FUNCTION(x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_object_code  IN VARCHAR2,
                               p_task_source IN VARCHAR2,
                               x_problem_tasks IN OUT NOCOPY IEU_DIAG_STRING_NST,
                               x_log IN OUT NOCOPY IEU_DIAG_STRING_NST
                               )AS
    v_create_string2   VARCHAR2(4000);
    v_cursor               NUMBER;
    v_numrows              NUMBER;
    v_cursor2               NUMBER;
    v_numrows2              NUMBER;
    v_numrows1             NUMBER;
    l_source_object_type_code varchar2(60);
    l_object_function      varchar2(60);
    l_object_code          varchar2(30);
    l_name                 varchar2(30);
    l_index integer ;
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    TYPE c_cursor IS REF CURSOR;
    c_view_name c_cursor;
    sql_stmt             varchar2(2000);
    sql_stmt1             varchar2(2000);

    l_sql   VARCHAR2(4000);
    l_count NUMBER;
    l_application_name VARCHAR2(2000);

begin
x_return_status := fnd_api.g_ret_sts_success;
-- 1. get object_function from jtf_objects_vl and call FND_FUNCTION.TEST
-- 2. if FND_FUNCTION.TEST run successfully, show successful message with function name, application name
-- 3. if FND_FUNCITON.TEST run failed,
-- 3.1 if object_code is 'TASK', test 'Launch TASK Manager',
--     i.e. get object_function from jtf_objects_vl
--     show log message IEU_UWQ_DEFTASKMAN_LAUNCH
-- 3.1.1 successfully, show success message
-- 3.1.2 failed, show error message IEU_UWQ_FUNCTION_NOT_ALLOWED
-- 3.2 not 'TASK' object_code, show error message IEU_UWQ_ALL_NO_SOURCE_DOC
      v_cursor := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.parse(v_cursor,
                     'SELECT unique object_function,  name , APPLICATION_NAME
                         FROM jtf_objects_vl
                          WHERE lower(object_code) = lower(:action_code)',
             DBMS_SQL.V7);

      DBMS_SQL.BIND_VARIABLE(v_cursor, 'action_code', p_object_code);
      DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, l_object_function,60);
       DBMS_SQL.DEFINE_COLUMN(v_cursor, 2, l_name,30);
        DBMS_SQL.DEFINE_COLUMN(v_cursor, 3, l_application_name,30);

      v_numrows := DBMS_SQL.EXECUTE(v_cursor);
      --v_numrows := DBMS_SQL.FETCH_ROWS(v_cursor);

      LOOP
        if DBMS_SQL.FETCH_ROWS(v_cursor) = 0 then
          --DBMS_OUTPUT.Put_Line('end of rows');
          exit;
        end if;

        DBMS_SQL.COLUMN_VALUE(v_cursor, 1, l_object_function);
        DBMS_SQL.COLUMN_VALUE(v_cursor, 2, l_name);
        DBMS_SQL.COLUMN_VALUE(v_cursor, 3, l_application_name);

        IF (l_object_function IS null) THEN
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_NULL_OBJ_F');
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_NULL_OBJ_FUNC');
                  FND_MSG_PUB.Add;
                  x_return_status := FND_API.G_RET_STS_ERROR;


        ELSe
         -- call FND_FUNCTION.TEST  with this l_object_function
         IF (FND_FUNCTION.TEST(l_object_function)) then
           -- show success message
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_OBJ_SU');
                  FND_MESSAGE.SET_TOKEN ('APPLICATION_NAME', l_application_name);
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
         else
           -- failed.
           IF (p_task_source = 'Y' or p_task_source = 'y') THEN
                EXECUTE immediate  ' select  object_function '||
                                   ' from jtf_objects_vl '||
                                   ' where lower(OBJECT_CODE) = lower(:1) '
                INTO l_object_function
                USING  'TASK';
                 IF (FND_FUNCTION.TEST(l_object_function)) then
                 -- show success message
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_OBJ_SU');
                  FND_MESSAGE.SET_TOKEN ('APPLICATION_NAME', l_application_name);
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
                 ELSE
                  -- show failed message, IEU_UWQ_FUNCTION_NOT_ALLOWED
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_L_F');
                  FND_MESSAGE.SET_TOKEN ('APPLICATION_NAME', l_application_name);
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_OBJ_FUN_Y_FAIL');
                  FND_MSG_PUB.Add;
                  x_return_status := FND_API.G_RET_STS_ERROR;

                 END if; -- test for launch Task Manager
           ELSE -- not a TASK object code
             -- show error message, IEU_UWQ_ALL_NO_SOURCE_DOC
             FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_OBJ_FUN_N_FAIL');
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;

           END if; -- object_code = 'TASK'
         END IF; -- if FND_FUNCTION.TEST
       END if; -- if object function is null
      end LOOP; -- select object function from view
      DBMS_SQL.CLOSE_CURSOR(v_cursor);

      --DBMS_OUTPUT.Put_Line('v_numrows is '|| v_numrows);
      --DBMS_OUTPUT.Put_Line('l_action_code is '|| l_action_code);

    FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

    FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        -- DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count        => x_msg_count,
            p_data         => l_msg_data
        );


        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
         p_count        => x_msg_count,
         p_data         => l_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


      WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
            -- DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
            p_count        => x_msg_count,
            p_data         => l_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

end CHECK_OBJECT_FUNCTION;

--===================================================================
-- NAME
--    CHECK_TASKS_LAUNCHING
--
-- PURPOSE
--    Private api
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   17-Apr-2002     GPAGADAL   Created
--   14-Apr-2004     dolee modified for workitem launch
--===================================================================
PROCEDURE CHECK_TASK_LAUNCHING(x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_object_code  IN VARCHAR2,
                               p_responsibility   IN VARCHAR2,
                               p_task_source IN VARCHAR2,
                               x_problem_tasks OUT NOCOPY IEU_DIAG_STRING_NST,
                               x_log OUT NOCOPY IEU_DIAG_STRING_NST
                              )
                              AS

    l_user_name            FND_USER.USER_NAME%TYPE;
    l_responsibility_id FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;
    l_application_id       FND_RESPONSIBILITY.APPLICATION_ID%TYPE;
    l_user_id              FND_USER.USER_ID%TYPE;
    l_language             VARCHAR2(4);
    l_action_code          VARCHAR2(60);
    l_view_name            VARCHAR2(512);
    v_cursor               NUMBER;
    v_cursor1               NUMBER;
    v_create_string        varchar2(1000);
    v_numrows              NUMBER;
    v_cursor2               NUMBER;
    v_cursor3              NUMBER;
    v_create_string2        varchar2(1000);
    v_numrows2              NUMBER;
    v_numrows1             NUMBER;
    l_count                NUMBER;
    l_resource_id          JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
    l_string1              varchar2(60);
    l_string2              varchar2(60) ;
    l_string3              varchar2(60) ;
    l_source_object_type_code varchar2(60);
    l_object_function      varchar2(60);
    l_object_code          varchar2(30);
    l_name                 varchar2(30);
    l_index integer ;
    l_decrease number;
    l_decrease1 number;

    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    v_create_string1        varchar2(1000);
    v_create_string3        varchar2(1000);
    v_create_string4        varchar2(1000);
    v_create_string5        varchar2(1000);
    TYPE c_cursor IS REF CURSOR;
    c_view_name c_cursor;
    sql_stmt             varchar2(2000);
    sql_stmt1             varchar2(2000);

    l_sql   VARCHAR2(4000);

    x_dupli_proc  IEU_DIAG_ENUM_NST;
    x_invalid_pkg  IEU_DIAG_ENUM_NST;
    x_invalid_proc IEU_DIAG_ENUM_ERR_NST;
    x_enum_time IEU_DIAG_ENUM_TIME_NST;
    x_user_ver_time NUMBER;
    l_application_name VARCHAR2(2000);
    x_etime_grand_total NUMBER;

BEGIN

    l_string1 := 'RS_INDIVIDUAL';
    l_string2 := 'RS_EMPLOYEE';
    l_string3 := 'RS_GROUP';
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;
    x_problem_tasks := IEU_DIAG_STRING_NST();
    x_log := IEU_DIAG_STRING_NST();

 Check_Object_Resp(x_return_status, x_msg_count, x_msg_data,
				 p_object_code, p_responsibility,  l_responsibility_id);

  if (x_return_status = 'S') then -- object code and  resp are valid
  -- check if the given inputs is
  -- registered in ieu_uwq_nonmedia_action
    v_cursor3 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.parse(v_cursor3,
                   'SELECT count(action_object_code)
                    FROM ieu_uwq_nonmedia_actions
                    WHERE lower(action_object_code) = lower(:action_code)
                    AND lower(source_for_task_flag) = lower(:flag)
                    AND nvl(responsibility_id, -1)   IN (-1, :resp) ',
              DBMS_SQL.V7);

    DBMS_SQL.BIND_VARIABLE(v_cursor3, 'action_code', p_object_code);
    DBMS_SQL.BIND_VARIABLE(v_cursor3, 'flag', p_task_source);
    DBMS_SQL.BIND_VARIABLE(v_cursor3, 'resp', l_responsibility_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursor3, 1, l_count);
    v_numrows := DBMS_SQL.EXECUTE_AND_FETCH(v_cursor3);
    DBMS_SQL.COLUMN_VALUE(v_cursor3, 1, l_count);
    DBMS_SQL.CLOSE_CURSOR(v_cursor3);
    -- DBMS_OUTPUT.Put_Line('count(action_object_code) in ieu_uwq_nonmedia_actions is ' || l_count);
      EXECUTE immediate  ' select  NAME , application_name'||
                         ' from jtf_objects_vl '||
                         ' where lower(OBJECT_CODE) = lower(:1)  '
      INTO l_name,l_application_name
      USING  p_object_code;
    if ( l_count = 0 ) then
      -- no data registered in ieu_uwq_nonmedia_actions
      -- a.1. get object_function from base view and call FND_FUNCTION.TEST
      -- a.2. if FND_FUNCTION.TEST run successfully, show successful message with function name, application name
      -- a.3. if FND_FUNCITON.TEST run failed,
      -- a.3.1 if object_code is 'TASK', test 'Launch TASK Manager',
      --     i.e. get object_function from jtf_objects_vl
      --     show log message IEU_UWQ_DEFTASKMAN_LAUNCH
      -- a.3.1.1 successfully, show success message
      -- a.3.1.2 failed, show error message IEU_UWQ_FUNCTION_NOT_ALLOWED
      -- a.3.2 not 'TASK' object_code, show error message IEU_UWQ_ALL_NO_SOURCE_DOC

      -- log object_code name in base view is not registered in ieu_UWQ_NONMEDIA_ACTIONS

      FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_OBJ_FA');
      x_log.extend;
      x_log(x_log.last) := FND_MESSAGE.GET();
      CHECK_OBJECT_FUNCTION(x_return_status ,
                     x_msg_count,
                     x_msg_data  ,
                     p_object_code,
                     p_task_source,
                     x_problem_tasks ,
                     x_log );
    ELSE -- ieu_action_object_code is registered in ieu_uwq_nonmedia_actions
      -- b.1. get the non_media function defined in ieu_uwq_maction_defs_b
      -- b.2. show success message with the non_media_function and application name
        EXECUTE immediate  ' select  action_proc'||
                         ' from ieu_uwq_maction_defs_b a, ieu_uwq_nonmedia_actions b'||
                         ' where a.maction_def_id = b.maction_def_id ' ||
                         ' and lower(action_object_code) = lower(:1) ' ||
                         ' and  nvl(responsibility_id, -1) in (-1, :2) ' ||
                         ' and lower(source_for_task_flag) = lower(:3) '
      INTO l_object_function
      USING   p_object_code, l_responsibility_id, p_task_source;
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_OBJ_SUC');
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
                  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_LOG_OBJ_SUCCESS');
			   FND_MESSAGE.set_token('FUNCTION', l_object_function);
			   FND_MESSAGE.set_token('APPLICATION_NAME', l_application_name);
                  x_log.extend;
                  x_log(x_log.last) := FND_MESSAGE.GET();
    end if ; -- ieu_action_object_code is not registered in ieu_uwq_nonmedia_actions

end if;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => l_msg_data
    );

    FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
        FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
        x_msg_data := x_msg_data || ',' || l_msg_data;
    END LOOP;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        -- DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count        => x_msg_count,
            p_data         => l_msg_data
        );


        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
         p_count        => x_msg_count,
         p_data         => l_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;


      WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
            -- DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
            p_count        => x_msg_count,
            p_data         => l_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
              FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
              x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

end CHECK_TASK_LAUNCHING;


END IEU_Diagnostics_PVT;

/
