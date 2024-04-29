--------------------------------------------------------
--  DDL for Package Body QA_DBLINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_DBLINK_PKG" AS
/* $Header: qadblinkb.pls 120.5.12010000.1 2008/07/25 09:19:16 appldev ship $ */

    err_logon_denied             CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_LOGON_DENIED');
    err_invalid_host             CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_INVALID_HOST');
    err_dblink_exists            CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_DBLINK_EXISTS');
    err_fetching_link            CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_FETCHING_LINK');
    err_dblink_creation          CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_DBLINK_CREATION');
    err_view_creation            CONSTANT VARCHAR2(100) := fnd_message.get_string('QA','QA_ERR_VIEW_CREATION');
    successful_completion        CONSTANT VARCHAR2(100) := 'SUCCESS';
    p_quote                      CONSTANT VARCHAR2(4)  := '''';

    --
    -- Apps schema info
    --
    g_dummy           BOOLEAN;
    g_fnd             CONSTANT VARCHAR2(3) := 'FND';
    g_status          VARCHAR2(1);
    g_industry        VARCHAR2(10);
    g_schema          VARCHAR2(30);

    PROCEDURE drop_dblink(
        p_dblink_name VARCHAR2) IS
    --
    -- Local procedure to drop the database link
    --
    BEGIN
        EXECUTE IMMEDIATE 'drop database link ' || p_dblink_name;
    END drop_dblink;

    FUNCTION create_view(
        p_dblink_name VARCHAR2)
        RETURN VARCHAR2 IS
    --
    -- Local function to regenerate the view qa_device_data_values_v on edg_event_vw@dblink
    --
       l_stmt  VARCHAR2(1000);
    BEGIN
        l_stmt := 'create or replace view qa_device_data_values_v ' ||
                  'as select event_time, event_data, event_tag_id device_source, ' ||
                  'device_name, 192 quality_code from edg_event_vw@';
        l_stmt := l_stmt || p_dblink_name;
        --EXECUTE IMMEDIATE  l_stmt || p_dblink_name;
        ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, l_stmt,
                'qa_device_data_values_v');

        RETURN successful_completion;
    EXCEPTION
       WHEN OTHERS THEN
            l_stmt := 'create or replace view qa_device_data_values_v as ' ||
                              'select systimestamp event_time, ' ||
                              'null event_data, ' ||
                              'null device_source, ' ||
                              'null device_name from dual';
            --EXECUTE IMMEDIATE l_stmt;
            ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, l_stmt,
                'qa_device_data_values_v');


            RETURN err_view_creation || substr(sqlerrm, 1, 100);
    END create_view;

    FUNCTION create_dblink(
        p_dblink_name VARCHAR2,
        p_user_name VARCHAR2,
        p_pwd VARCHAR2,
        p_connect_str VARCHAR2)
        RETURN VARCHAR2 IS
    --
    -- Main location function to create dblink.
    -- If the dblink already exists, then
    -- an error needs to be raised .
    -- If the db link is created
    -- Return 0 if successful, a negative error code if not.
    -- Because this is a DDL, by definition a commit is
    -- performed inherently.
    --
        l_chk           NUMBER := 0;
        return_status   VARCHAR2(200);

        INVALID_HOST EXCEPTION;
        PRAGMA EXCEPTION_INIT(INVALID_HOST, -12154);

    BEGIN

        EXECUTE IMMEDIATE 'create database link ' || p_dblink_name ||
                          ' connect to ' || p_user_name  ||
                          ' identified by ' || p_pwd ||
                          ' using ' || p_quote || p_connect_str || p_quote;
        BEGIN
            EXECUTE IMMEDIATE 'select 1 from edg_event_vw@' || p_dblink_name || ' where rownum = 1' INTO l_chk;

            return_status := create_view(p_dblink_name);

            IF return_status <> successful_completion THEN
                drop_dblink(p_dblink_name);
                RETURN return_status;
            END IF;
        EXCEPTION
            WHEN LOGIN_DENIED THEN
                drop_dblink(p_dblink_name);
                RETURN err_logon_denied;
            WHEN INVALID_HOST THEN
                drop_dblink(p_dblink_name);
                RETURN err_invalid_host;
            WHEN NO_DATA_FOUND THEN
	        null;
            WHEN OTHERS THEN
                drop_dblink(p_dblink_name);
                RETURN err_fetching_link || substr(sqlerrm, 1, 100);
        END;
        RETURN successful_completion;
    EXCEPTION
       WHEN OTHERS THEN
            RETURN err_dblink_creation || substr(sqlerrm, 1, 100);
    END create_dblink;

    --
    -- Local procedure to regenerate the view qa_device_data_values_v on qa_device_data_values table
    --
    PROCEDURE create_opc_view  IS

       l_stmt  VARCHAR2(1000);
    BEGIN
        l_stmt := 'CREATE OR REPLACE VIEW qa_device_data_values_v AS ' ||
                   ' SELECT TO_TIMESTAMP_TZ(event_time) event_time, ' ||
                   ' event_data, ' ||
                   ' device_source, ' ||
                   ' device_name, ' ||
                   ' quality_code ' ||
                   'FROM qa_device_data_values';
        --EXECUTE IMMEDIATE  l_stmt;
        ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, l_stmt,
                'qa_device_data_values_v');
    EXCEPTION
       WHEN OTHERS THEN
            l_stmt := 'create or replace view qa_device_data_values_v as ' ||
                              'select systimestamp event_time, ' ||
                              'null event_data, ' ||
                              'null device_source, ' ||
                              'null device_name from dual';
            --EXECUTE IMMEDIATE l_stmt;
            ad_ddl.do_ddl(g_schema, 'QA', ad_ddl.create_view, l_stmt,
                'qa_device_data_values_v');

    END create_opc_view;

    PROCEDURE wrapper(
        errbuf    OUT NOCOPY VARCHAR2,
        retcode   OUT NOCOPY NUMBER,
        argument1            VARCHAR2,
        dummy                NUMBER,
        argument2            VARCHAR2,
        argument3            VARCHAR2,
        argument4            VARCHAR2,
        argument5            VARCHAR2) IS

    --
    -- Wrapper procedure to create or drop the index.
    -- This procedure is the entry point for this package
    -- through the concurrent program 'Manage Collection
    -- element indexes'. This wrapper procedure is attached
    -- to the QADBLINK executable.
    -- argument1 -> Server Type : Server Type for Device Integration. 1 - Sensor Edge Server, 2- OPC Server (Third Party)
    -- dummy     -> Dummy Parameter : To handle Enabling/Disabling of SDR specific fields based on Server Type.
    -- argument2 -> SDR DB Link Name : 'Create a dblink using this name. If already existant then raise an error'.
    -- argument3 -> User Name for connecting to SDR database.
    -- argument4 -> Password for connecting to SDR database for the user name specified in argument2.
    -- argument5 -> Connection Descriptor (The entire TNS Entry of the SDR Database instance).
    --

    l_return                    VARCHAR2(2000);
    l_db_link_name              VARCHAR2(128);
    l_err_mes_license		VARCHAR2(2000);
    BEGIN

       fnd_file.put_line(fnd_file.log, 'qa_dblink_pkg: entered the wrapper');

       -- APPS schema params.
       g_dummy := fnd_installation.get_app_info(g_fnd, g_status,
           g_industry, g_schema);

       IF FND_PROFILE.VALUE('WIP_MES_OPS_FLAG') <> 1 THEN
          l_err_mes_license := fnd_message.get_string('WIP','WIP_WS_NO_LICENSE');
          fnd_file.put_line(fnd_file.log, 'ERROR: ' || substr(l_err_mes_license, 1, 200));
          errbuf := 'ERROR: ' || substr(l_err_mes_license, 1, 200);
          retcode := 2;
       ELSIF trim(argument1) = '1' THEN
       	  fnd_file.put_line(fnd_file.log, 'Create the DB Link');
          l_db_link_name := UPPER(trim(argument2));


          l_return := create_dblink(p_dblink_name            => l_db_link_name,
                                    p_user_name              => trim(argument3),
                                    p_pwd                    => trim(argument4),
                                    p_connect_str            => trim(argument5));

          IF (l_return = successful_completion) THEN
             fnd_file.put_line(fnd_file.log, 'DB Link successfully created');
             errbuf := '';
             retcode := 0;
          ELSE
             fnd_file.put_line(fnd_file.log, 'DB Link creation failed : ' || substr(l_return, 1, 200));
             errbuf := substr(l_return, 1, 200);
             retcode := 2;
          END IF;
       ELSE
       	-- If third party OPC server is selected, revert the view to its original state.
       	create_opc_view;
       END IF;
       fnd_file.put_line(fnd_file.log, 'qa_dblink_pkg: exiting the wrapper');

    END wrapper;

END qa_dblink_pkg;

/
