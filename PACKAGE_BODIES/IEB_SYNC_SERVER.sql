--------------------------------------------------------
--  DDL for Package Body IEB_SYNC_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEB_SYNC_SERVER" AS
/* $Header: IEBSVRB.pls 115.28 2004/02/10 19:35:48 gpagadal noship $ */

PROCEDURE GET_WB_SERVER_LIST (
   p_language IN varchar2,
   p_order_by IN varchar2,
   p_asc      IN varchar2,
   x_wb_servers_list  OUT NOCOPY SYSTEM.IEB_WB_SERVERS_DATA_NST,
   x_return_status  OUT NOCOPY VARCHAR2)
 AS

   v_cursorID INTEGER;
   v_selectStmt VARCHAR2(5000);
   v_dummy    INTEGER;

   v_serverId    NUMBER(15);
   v_serverName  VARCHAR2(80);
   v_fileName    VARCHAR2(256);
   v_logDbcFileName VARCHAR2(256);
   v_cciDbcFileName VARCHAR2(256);
   v_sunday       VARCHAR2(1);
   v_monday      VARCHAR2(1);
   v_tuesday      VARCHAR2(1);
   v_wednesday   VARCHAR2(1);
   v_thursday     VARCHAR2(1);
   v_friday       VARCHAR2(1);
   v_saturday     VARCHAR2(1);
   v_beginTime   NUMBER(4);
   v_endTime     NUMBER(4);
   v_cleanUp     VARCHAR2(1);
   v_cleanUpTime NUMBER(4);
   v_shutdown    VARCHAR2(1);
   v_shutdownTime NUMBER(4);
   v_cleanupSize  NUMBER(8);
   v_cacheSize    NUMBER(8);
   v_traceFileName VARCHAR2(256);
   v_serverType    VARCHAR2(20);
   v_desc          VARCHAR2(240);
   v_method        VARCHAR2(32);
   v_objName       VARCHAR2(32);
   v_dnsName       VARCHAR2(32);
   v_ipAddress     VARCHAR2(15);
   v_portNumber    NUMBER(15);
   v_param1        VARCHAR2(32);
   v_param2        VARCHAR2(32);
   v_param3        VARCHAR2(32);
   v_param4        VARCHAR2(32);
   v_checkNew      VARCHAR2(1);

 BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IEB_SYNC_SERVER.SYNC_SERVER(p_language, x_return_status);


   v_cursorID := DBMS_SQL.OPEN_CURSOR;

   v_selectStmt := 'select WBSVR_ID, WB_SERVER_NAME, LOG_FILE_NAME,
                    LOG_DBC_FILE_NAME, CCI_DBC_FILE_NAME, STAT_DUMP_SUNDAY_Y_N,
                    STAT_DUMP_MONDAY_Y_N, STAT_DUMP_TUESDAY_Y_N,
                    STAT_DUMP_WEDNESDAY_Y_N, DESCRIPTION
                    from IEB_WB_SERVERS
                    order by ' || p_order_by || ' ' || p_asc;

   DBMS_SQL.PARSE(v_cursorID, v_selectStmt, DBMS_SQL.V7);

   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 1, v_serverId);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 2, v_serverName, 80);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 3, v_fileName, 256);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 4, v_logDbcFileName, 256);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 5, v_cciDbcFileName, 256);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 6, v_sunday, 1);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 7, v_monday, 1);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 8, v_tuesday, 1);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 9, v_wednesday,1);
   DBMS_SQL.DEFINE_COLUMN(v_cursorID, 10, v_desc, 240);

   v_dummy := DBMS_SQL.EXECUTE(v_cursorID);

   x_wb_servers_list  := SYSTEM.IEB_WB_SERVERS_DATA_NST();
   loop
       if DBMS_SQL.FETCH_ROWS(v_cursorID) = 0 then
         exit;
       end if;

       DBMS_SQL.COLUMN_VALUE(v_cursorID, 1, v_serverId);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 2, v_serverName);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 3, v_fileName);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 4, v_logDbcFileName);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 5, v_cciDbcFileName);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 6, v_sunday);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 7, v_monday);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 8, v_tuesday);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 9, v_wednesday);
       DBMS_SQL.COLUMN_VALUE(v_cursorID, 10, v_desc);

       x_wb_servers_list.EXTEND;
       x_wb_servers_list(x_wb_servers_list.LAST) := SYSTEM.IEB_WB_SERVERS_DATA_OBJ(v_serverId,
                                                    v_serverName,
                                                    v_fileName, v_logDbcFileName,
                                                    v_cciDbcFileName, v_sunday,
                                                    v_monday, v_tuesday, v_wednesday, v_thursday,
                                                    v_friday, v_saturday,
                                                    v_beginTime,
                                                    v_endTime,
                                                    v_cleanUp, v_cleanUpTime,
                                                    v_shutdown, v_shutdownTime,
                                                    v_cleanupSize,
                                                    v_cacheSize,
                                                    v_traceFileName, v_serverType,
                                                    v_desc, v_method,
                                                    v_objName, v_dnsName,
                                                    v_ipAddress, v_portNumber,
                                                    v_param1, v_param2,
                                                    v_param3, v_param4,
                                                    v_checkNew);
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
 END GET_WB_SERVER_LIST;

PROCEDURE SYNC_SERVER (
  p_language IN varchar2,
  x_return_status   OUT NOCOPY VARCHAR2 )
IS
  cursor c1 is
     select *
     from IEO_SVR_SERVERS
     where type_id = 10020
     and not exists (select 'x' from IEB_WB_SERVERS SRV, IEB_WB_SVC_CATS SVC
                     where SRV.WB_SERVER_NAME = SERVER_NAME AND
                     SVC.WBSVR_WBSVR_ID = SRV.WBSVR_ID );
  l_wbsvr_id  number(15,0);
  l_ieo_svr_id  number(15,0);

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

    -- there are 2 parts to syncing the schema - one is to delete data for
    -- servers that no longer exist in ieo schema, and the other is to
    -- create data for new servers created in ieo schema

   -- this takes care of deleting data from ieb schema
   DELETE FROM ieb_wb_servers WHERE wb_server_name NOT IN
   (SELECT server_name FROM ieo_svr_servers WHERE type_id = 10020);

   if (sql%notfound) then
    null; -- not finding any such iebs is good
   else
    -- delete the service categories of the deleted servers
    DELETE FROM ieb_wb_svc_cats WHERE wbsvr_wbsvr_id NOT IN
    (SELECT wbsvr_id FROM ieb_wb_servers);

    IF (sql%notfound) then
     null; -- not finding any data is not too good because there should be
           -- default service categories here; but no problem, may be the
           -- data is messed up
    else
      -- delete any service category rules for the deleted service categories
      DELETE FROM ieb_wb_svc_cat_rules WHERE wbsc_wbsc_id NOT IN
      (SELECT wbsc_id FROM ieb_wb_svc_cats);

      IF (sql%notfound) then
        null; -- is ok if no data found here
      END if;

    END if;

    commit;  -- got to save the changes

   END if;

   -- this takes care of creating data for new servers.
   for c1_rec in c1 loop

      l_wbsvr_id := NULL;
      l_ieo_svr_id := NULL;
      begin
      select wbsvr_id, ieo_server_id into l_wbsvr_id, l_ieo_svr_id
        from IEB_WB_SERVERS
        where WB_server_name = c1_rec.server_name;
      exception
        when others then
          l_wbsvr_id := NULL;
          l_ieo_svr_id := NULL;
      end;

      if ( l_wbsvr_id IS NULL ) then
      select IEB_WB_SERVER_S1.NEXTVAL into l_wbsvr_id from sys.dual;
      insert into IEB_WB_SERVERS
            (wbsvr_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login,
             wb_server_name,
             log_file_name,
             log_dbc_file_name,
             cci_dbc_file_name,
             stat_dump_sunday_y_n,
             stat_dump_monday_y_n,
             stat_dump_tuesday_y_n,
             stat_dump_wednesday_y_n,
             stat_dump_thursday_y_n,
             stat_dump_friday_y_n,
             stat_dump_saturday_y_n,
             stat_dump_beg_time_hhmm,
             stat_dump_end_time_hhmm,
             daily_cleanup_y_n,
             cleanup_time_hhmm,
             auto_shut_down_y_n,
             auto_shut_down_time_hhmm,
             virtual_q_cleanup_size,
             work_queue_cache_size,
             trace_file_name,
             wb_server_type,
             description,
             communication_method,
             com_object_name,
             com_dns_name,
             com_ip_address,
             com_port_number,
             com_param1,
             com_param2,
             com_param3,
             com_param4,
             object_version_number,
             security_group_id,
             check_new_sc_entry,
             ieo_server_id)
      VALUES (l_wbsvr_id,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.LOGIN_ID,
             c1_rec.server_name,
             NULL, NULL, NULL,
             'N','N','N','N','N','N','N',
             NULL, NULL,
             'N',
             NULL,
             'N',
             NULL,
             0,
             0,
             NULL,
             'N',
             c1_rec.description,
             'RMI',
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
             0,
             0,
             NULL,
             c1_rec.server_id);
      else if ( l_ieo_svr_id IS NULL ) then
             Update IEB_WB_SERVERS
             Set IEO_SERVER_ID = c1_rec.server_id
             Where WB_server_name = c1_rec.server_name;
            end if;
      end if;

      IEB_SYNC_SERVER.INSERT_SVC_CAT_ENTRIES(p_language, l_wbsvr_id, x_return_status);

      exit when c1%notfound;
  commit;
  end loop;

  update ieb_wb_servers a
  set a.IEO_SERVER_ID = (select b.server_id from ieo_svr_servers b where a.WB_SERVER_NAME = b.SERVER_NAME);
  if (sql%notfound) then
     null;
  end if;
  commit;

  IEB_SYNC_SERVER.SYNC_CAT_ENTRIES(p_language, x_return_status);

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END SYNC_SERVER;

PROCEDURE INSERT_SVC_CAT_ENTRIES (
 p_language IN varchar2,
 p_wbsvr_id IN number,
 x_return_status OUT NOCOPY varchar2 )
IS
    cursor c1 is
         select a.direction, b.created_by, b.creation_date, b.last_updated_by,
                b.last_update_date, b.last_update_login,
                tl.service_category_name, b.media_type_id,
                b.active_y_n, b.media_type, tl.description,
                b.depth, b.svcpln_svcpln_id, b.object_version_number,
                b.security_group_id
           from ieb_service_plans a, ieb_svc_cat_temps_tl tl,
                ieb_svc_cat_temps_b b
          where b.wbsc_id = tl.wbsc_id
            and svcpln_svcpln_id = svcpln_id
            and language = p_language
            order by depth, direction;
    l_wbsc_id   number(15,0);
    l_parent_id number(15,0);
    l_parent_id_ib number(15,0);
    l_parent_id_ob number(15,0);
    begin
       x_return_status := fnd_api.g_ret_sts_success;

       for c1_rec in c1 loop
            select IEB_SVC_CATS_S1.NEXTVAL into l_wbsc_id from sys.dual;
            if c1_rec.depth = 0 then
               l_parent_id := NULL;
               l_parent_id_ib := l_wbsc_id;
               l_parent_id_ob := l_wbsc_id;
            end if;

            if c1_rec.depth = 1 and c1_rec.direction = 'INBOUND' then
               l_parent_id    := l_parent_id_ib;
               l_parent_id_ib := l_wbsc_id;
            elsif c1_rec.depth = 1 and c1_rec.direction = 'OUTBOUND' then
               l_parent_id    := l_parent_id_ob;
               l_parent_id_ob := l_wbsc_id;
            end if;

            if c1_rec.depth = 2 and c1_rec.direction = 'INBOUND' then
               l_parent_id := l_parent_id_ib;
            elsif c1_rec.depth = 2 and c1_rec.direction = 'OUTBOUND' then
               l_parent_id := l_parent_id_ob;
            end if;

            insert into IEB_WB_SVC_CATS
                  (wbsc_id,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   service_category_name,
                   campaign_server_name,
                   campaign_name,
                   active_y_n,
                   media_type,
                   description,
                   priority,
                   depth,
                   wbsvr_wbsvr_id,
                   parent_id,
                   svcpln_svcpln_id,
                   media_type_id,
                   default_flag,
                   object_version_number,
                   security_group_id)
            values (l_wbsc_id,
                   FND_GLOBAL.USER_ID,
                   sysdate,
                   FND_GLOBAL.USER_ID,
                   sysdate,
                   FND_GLOBAL.LOGIN_ID,
                   c1_rec.service_category_name,
                   NULL, NULL,
                   c1_rec.active_y_n,
                   c1_rec.media_type,
                   c1_rec.description,
                   0,
                   c1_rec.depth,
                   p_wbsvr_id,
                   l_parent_id,
                   c1_rec.svcpln_svcpln_id,
                   c1_rec.media_type_id,
                   'Y',
                   0,
                   0);

            exit when c1%notfound;
        end loop;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END INSERT_SVC_CAT_ENTRIES;



PROCEDURE SYNC_CAT_ENTRIES (
    p_language IN varchar2,
    x_return_status   OUT NOCOPY VARCHAR2 )
IS
    l_default_count  number(5);
    l_count  number(5);

    cursor c1 is
    select * from ieb_wb_servers WHERE wb_server_name  IN
    (SELECT server_name FROM ieo_svr_servers WHERE type_id = 10020);


    cursor c2 is
         select a.direction, b.created_by, b.creation_date, b.last_updated_by,
                b.last_update_date, b.last_update_login,
                tl.service_category_name, b.media_type_id,
                b.active_y_n, b.media_type, tl.description,
                b.depth, b.svcpln_svcpln_id, b.object_version_number,
                b.security_group_id
           from ieb_service_plans a, ieb_svc_cat_temps_tl tl,
                ieb_svc_cat_temps_b b
          where b.wbsc_id = tl.wbsc_id
            and svcpln_svcpln_id = svcpln_id
            and language = 'US'
            order by depth, direction;

    l_wbsc_id   number(15,0);
    l_parent_id number(15,0);
    l_root_id_ib number(15,0);
    l_root_id_ob number(15,0);
    l_root_id number(15,0);

    l_depth   number(15,0);




BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    l_default_count := 0;
    l_count := 0;



    for c1_rec in c1 loop

        for c1_rec2 in c2 loop


            begin

                select WBSC_ID, depth into l_wbsc_id ,l_depth from ieb_wb_svc_cats
                where service_category_name = c1_rec2.service_category_name
                and wbsvr_wbsvr_id =c1_rec.wbsvr_id;




                if (l_depth = 0) then
                  l_parent_id := NULL;
                  l_root_id_ib := l_wbsc_id;
                  l_root_id_ob := l_wbsc_id;

                end if;

                if (l_depth = 1) then
                  if (c1_rec2.direction = 'INBOUND')then
                    l_parent_id := l_root_id_ib;
                    l_root_id_ib := l_wbsc_id;
                  elsif (c1_rec2.direction = 'OUTBOUND') then
                    l_parent_id := l_root_id_ob;
                    l_root_id_ob := l_wbsc_id;
                  end if;
                end if;

                if (l_depth = 2) then
                  if (c1_rec2.direction = 'INBOUND') then
                    l_parent_id := l_root_id_ib;
                   -- l_root_id_ib := l_wbsc_id;
                  elsif (c1_rec2.direction = 'OUTBOUND') then
                    l_parent_id  := l_root_id_ob;
                   -- l_root_id_ob := l_wbsc_id;
                  end if;
                end if;

            EXCEPTION
                when NO_DATA_FOUND then
                null;

            end;



                update IEB_WB_SVC_CATS set
                media_type_id = c1_rec2.media_type_id,
                default_flag = 'Y'
                where
                wbsvr_wbsvr_id =c1_rec.wbsvr_id
                and service_category_name = c1_rec2.service_category_name
                and media_type = c1_rec2.media_type;

                -- commit;

                if (sql%notfound) then

                    select IEB_SVC_CATS_S1.NEXTVAL into l_wbsc_id from sys.dual;
                    if c1_rec2.depth = 0 then
                        l_parent_id := NULL;
                        l_root_id_ib := l_wbsc_id;
                        l_root_id_ob := l_wbsc_id;

                    end if;
                    if c1_rec2.depth = 1 then
                        if (c1_rec2.direction = 'INBOUND') then
                            l_parent_id := l_root_id_ib;
                            l_root_id_ib := l_wbsc_id;

                        elsif (c1_rec2.direction = 'OUTBOUND') then
                            l_parent_id := l_root_id_ob;
                            l_root_id_ob := l_wbsc_id;
                        end if;

                    end if ;
                    if c1_rec2.depth = 2 then
                        if (c1_rec2.direction = 'INBOUND') then
                            l_parent_id := l_root_id_ib;
                           -- l_root_id_ib := l_wbsc_id;
                        elsif (c1_rec2.direction = 'OUTBOUND') then
                            l_parent_id := l_root_id_ob;
                          --  l_root_id_ob := l_wbsc_id;
                        end if;

                    end if;

                    insert into IEB_WB_SVC_CATS
                      (wbsc_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       service_category_name,
                       campaign_server_name,
                       campaign_name,
                       active_y_n,
                       media_type,
                       description,
                       priority,
                       depth,
                       wbsvr_wbsvr_id,
                       parent_id,
                       svcpln_svcpln_id,
                       media_type_id,
                       default_flag,
                       object_version_number,
                       security_group_id)
                    values (l_wbsc_id,
                       FND_GLOBAL.USER_ID,
                       sysdate,
                       FND_GLOBAL.USER_ID,
                       sysdate,
                       FND_GLOBAL.LOGIN_ID,
                       c1_rec2.service_category_name,
                       NULL, NULL,
                       c1_rec2.active_y_n,
                       c1_rec2.media_type,
                       c1_rec2.description,
                       0,
                       c1_rec2.depth,
                       c1_rec.wbsvr_id,
                       l_parent_id,
                       c1_rec2.svcpln_svcpln_id,
                       c1_rec2.media_type_id,
                       'Y',
                       0,
                       0);


                  --  commit;


                end if;

        exit when c2%notfound;
        --commit;
        end loop;


    exit when c1%notfound;
    commit;
    end loop;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);

   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
    --DBMS_OUTPUT.PUT_LINE('Error : '||sqlerrm);



END SYNC_CAT_ENTRIES;

END IEB_SYNC_SERVER;

/
