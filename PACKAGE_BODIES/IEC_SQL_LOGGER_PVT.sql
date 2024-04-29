--------------------------------------------------------
--  DDL for Package Body IEC_SQL_LOGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_SQL_LOGGER_PVT" AS
/* $Header: IECVLGRB.pls 115.12 2004/05/18 19:38:17 minwang ship $ */

-- Get the next record id
FUNCTION GET_NEXT_RECORD_ID
  RETURN NUMBER
  IS

BEGIN
   -- dbms_output.put_line('get_next_record_id: begin <'|| G_SEQ_NUM || '>' );

   if( G_SEQ_NUM IS NULL OR G_SEQ_NUM = G_FETCH_SEQ_NUM )
   then
      -- dbms_output.put_line('get_next_record_id: After fetch id is <'|| G_SEQ_NUM || '>' );
      select IEO_LNA_RECORDS_S1.nextval into G_SEQ_NUM from dual;
      G_FETCH_SEQ_NUM := G_SEQ_NUM + 2000;
   end if;

   G_SEQ_NUM := G_SEQ_NUM + 1;
   -- dbms_output.put_line('get_next_record_id: Returning ID <'|| G_SEQ_NUM || '>' );
   return G_SEQ_NUM;
END;


-- Get the source id
PROCEDURE GET_SOURCE_ID
  ( P_FACILITY_GUID       	IN     		VARCHAR2
  , P_APP_ID              	IN     		VARCHAR2
  , P_FACILITY_NAME_MSG_NAME	IN  		VARCHAR2
  , P_FACILITY_INSTANCE		IN     		VARCHAR2
  , P_FACILITY_INSTANCE_UID	IN  		VARCHAR2
  , P_IP_ADDRESS           	IN   		VARCHAR2
  , P_HOSTNAME             	IN     		VARCHAR2
  , P_OS_USER_NAME         	IN     		VARCHAR2
  , P_LOG_LEVEL            	IN     		NUMBER
  , X_SOURCE_ID            	IN OUT NOCOPY	NUMBER
  )
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  l_source_id IEO_LNA_SOURCES.SOURCE_ID%TYPE;
  l_log_level IEO_LNA_SOURCES.LOG_LEVEL%TYPE;

  l_last_updated_by NUMBER;
  l_created_by NUMBER;
  l_last_update_login NUMBER;

  l_date1 DATE;
  l_date2 DATE;

BEGIN
  l_source_id := -1;
  l_log_level := -1;

    -- dbms_output.put_line('get_source Id: begin' );
    -- Create a savepoint and then commit till this point.
    SAVEPOINT log_source;

    X_SOURCE_ID := 0;

    BEGIN
      l_last_updated_by := NVL(FND_GLOBAL.conc_login_id,-1);
      l_created_by := NVL(FND_GLOBAL.user_id,-1);
      l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

       -- Check if a record already exists for this source.

       Select SOURCE_ID, LOG_LEVEL into l_source_id, l_log_level
         from IEO_LNA_SOURCES
        where facility_guid = P_FACILITY_GUID
          and facility_name_msg_name = P_FACILITY_NAME_MSG_NAME
          and facility_instance = P_FACILITY_INSTANCE
          and facility_instance_uid = P_FACILITY_INSTANCE_UID
          and ip_address = P_IP_ADDRESS
          and hostname = P_HOSTNAME
          and os_user_name = P_OS_USER_NAME;

       -- Update the log_level if that is different.
       if ( l_log_level <> P_LOG_LEVEL )
       then

          -- Update the log_level for this source id;
          update ieo_lna_sources
             set log_level = P_LOG_LEVEL,
                 last_update_date = sysdate,
                 last_update_login = l_last_update_login
           where source_id = l_source_id;

          l_log_level := P_LOG_LEVEL;

       end if;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            -- dbms_output.put_line('get_source Id: No data found.' );
            l_date1 := sysdate;
            l_date2 := l_date1;

            insert into IEO_LNA_SOURCES (
                   SOURCE_ID,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   FACILITY_GUID,
                   FACILITY_NAME_MSG_NAME,
                   FACILITY_RESOURCE_GUID,
                   FACILITY_INSTANCE,
                   FACILITY_INSTANCE_UID,
                   IP_ADDRESS,
                   HOSTNAME,
                   OS_USER_NAME,
                   LOG_LEVEL
                   )
                   VALUES (
                   IEO_LNA_SOURCES_S1.NEXTVAL,
                   l_created_by,
                   l_date1,
                   l_last_updated_by,
                   l_date2,
                   l_last_update_login,
                   P_FACILITY_GUID,
                   P_FACILITY_NAME_MSG_NAME,
                   P_APP_ID,
                   P_FACILITY_INSTANCE,
                   P_FACILITY_INSTANCE_UID,
                   P_IP_ADDRESS,
                   P_HOSTNAME,
                   P_OS_USER_NAME,
                   P_LOG_LEVEL
                   )
            RETURNING SOURCE_ID into l_source_id;
            l_log_level := P_LOG_LEVEL;
    END;

    -- dbms_output.put_line('Returning source id <' || l_source_id || '> and log level <' || l_log_level || '>' );

    commit;
    X_SOURCE_ID := l_source_id;
    return;
EXCEPTION
      WHEN OTHERS THEN
           rollback TO log_source;
           commit;
           RAISE;

END GET_SOURCE_ID;

-- This uses the format 'yyyy-MM-DD HH:MI:SS'
-- Log a message
PROCEDURE LOG
  ( P_SOURCE_ID            IN     		NUMBER
  , P_LOG_LEVEL            IN     		NUMBER
  , P_TIMESTAMP            IN     		VARCHAR2
  , P_TIMESTAMP_MILLI      IN     		NUMBER
  , P_ACTION_ID            IN     		NUMBER
  , P_SEVERITY_ID          IN     		NUMBER
  , P_TITLE_MSG_NAME       IN     		VARCHAR2
  , P_TITLE_MSG_APP_NAME   IN     		VARCHAR2
  , P_MESSAGE              IN     		VARCHAR2
  , X_RECORD_ID            IN OUT NOCOPY	NUMBER
  )
  IS

BEGIN

  LOG( P_SOURCE_ID, P_LOG_LEVEL, TO_DATE(P_TIMESTAMP, 'YYYY-MM-DD HH24:MI:SS'), P_TIMESTAMP_MILLI, P_ACTION_ID, P_SEVERITY_ID, P_TITLE_MSG_NAME, P_TITLE_MSG_APP_NAME, P_MESSAGE, X_RECORD_ID );

END;

PROCEDURE LOG
  ( P_SOURCE_ID            IN                   NUMBER
  , P_LOG_LEVEL            IN                   NUMBER
  , P_TIMESTAMP            IN                   DATE
  , P_TIMESTAMP_MILLI      IN                   NUMBER
  , P_ACTION_ID            IN                   NUMBER
  , P_SEVERITY_ID          IN                   NUMBER
  , P_TITLE_MSG_NAME       IN                   VARCHAR2
  , P_TITLE_MSG_APP_NAME   IN                   VARCHAR2
  , P_MESSAGE              IN                   VARCHAR2
  , X_RECORD_ID            IN OUT NOCOPY        NUMBER
  )
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log NUMBER(1);
  l_record_id  IEO_LNA_RECORDS.RECORD_ID%TYPE;
  l_date1 DATE;
  l_date2 DATE;

  l_last_updated_by NUMBER;
  l_created_by NUMBER;
  l_last_update_login NUMBER;

BEGIN
  l_log := -1;
  l_record_id := -1;

    X_RECORD_ID := -1;

    -- dbms_output.put_line('log: begin' );

    select 1 into l_log
         from ieo_lna_sources
        where log_level >= P_LOG_LEVEL
          and source_id = P_SOURCE_ID;

    BEGIN
       -- Create a savepoint and then commit till this point.
       SAVEPOINT log_record;

       -- Log only if log_level is <= the specified level.
       if( l_log = 1 )
       then

          l_date1 := sysdate;
          l_date2 := l_date1;

          l_last_updated_by := NVL(FND_GLOBAL.conc_login_id,-1);
          l_created_by := NVL(FND_GLOBAL.user_id,-1);
          l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

          insert into ieo_lna_records ( record_id,
					created_by,
          				creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
          				source_id,
					timestamp,
					timestamp_milli,
					action_id,
					severity_id,
          				title_msg_name,
					title_resource_guid,
					xml_data  )
				values ( get_next_record_id,
					l_created_by,
					l_date1,
				  	l_last_updated_by,
					l_date2,
					l_last_update_login,
					P_SOURCE_ID,
           				P_TIMESTAMP,
					P_TIMESTAMP_MILLI,
					P_ACTION_ID,
					P_SEVERITY_ID,
					P_TITLE_MSG_NAME,
           				P_TITLE_MSG_APP_NAME,
					P_MESSAGE )
				RETURNING RECORD_ID into l_record_id;
	end if;

    EXCEPTION
       WHEN OTHERS THEN
           rollback to log_record;
           commit;
           RAISE;
    END;

    -- dbms_output.put_line('Send back <' || l_record_id || '>' );

    commit;
    X_RECORD_ID := l_record_id;
    return;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
           return;
END LOG;

-- =======================================================================
-- Provided for a single "log"
-- =======================================================================
PROCEDURE LOG_DESCRIPTION
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER
  , P_DESC_MSG_NAME        IN     VARCHAR2
  , P_DESC_MSG_APP_NAME    IN     VARCHAR2
  )
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log NUMBER(1);
  l_date1 DATE;
  l_date2 DATE;

  l_last_updated_by NUMBER;
  l_created_by NUMBER;
  l_last_update_login NUMBER;

BEGIN
  l_log := -1;

    -- dbms_output.put_line('log_description: begin' );
    if( P_RECORD_ID < 0 )
    then
      return;
    end if;

    select 1 into l_log
      from ieo_lna_records
     where record_id = P_RECORD_ID;

    -- Create a savepoint and then commit till this point.
    SAVEPOINT log_description;

    BEGIN
          -- Log only if log_level is <= the specified level.
          if( l_log = 1 )
          then
              l_date1 := sysdate;
              l_date2 := l_date1;

              l_last_updated_by := NVL(FND_GLOBAL.conc_login_id,-1);
              l_created_by := NVL(FND_GLOBAL.user_id,-1);
              l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

               -- dbms_output.put_line('log_description: Adding the description' );
               insert into ieo_lna_descriptions ( record_id,
						desc_pos,
						created_by,
						creation_date,
						last_updated_by,
						last_update_date,
						last_update_login,
                  				desc_msg_name,
						desc_resource_guid )
					values ( P_record_id,
						P_desc_pos,
						l_created_by,
                   				l_date1,
						l_last_updated_by,
						l_date2,
						l_last_update_login,
						P_desc_msg_name,
						P_desc_msg_app_name );
	end if;
    EXCEPTION
        WHEN OTHERS THEN
           rollback to log_description;
           commit;
           RAISE;
    END;
    commit;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
          return;

END LOG_DESCRIPTION;

-- =======================================================================
-- Provided for "logs" with multiple "descriptions"
-- =======================================================================
PROCEDURE LOG_DESCRIPTION
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_MSG_NAME        IN     VARCHAR2_TABLE
  , P_DESC_MSG_APP_NAME    IN     VARCHAR2_TABLE
  )
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_log NUMBER(1);

BEGIN
  l_log := -1;

    -- dbms_output.put_line('log_description || : begin count is <' || P_DESC_MSG_NAME.count || '>');

    if( P_RECORD_ID <= 0 )
    then
      return;
    end if;
    select 1 into l_log
      from ieo_lna_records
     where record_id = P_RECORD_ID;

    -- Create a savepoint and then commit till this point.
    SAVEPOINT log_description_II;

    BEGIN
       -- Log only if log_level is <= the specified level.
       if( l_log = 1 )
       then
          -- dbms_output.put_line('log_description || : Adding the log' );
          for L in 1 .. P_DESC_MSG_NAME.count
          loop
              if ( P_DESC_MSG_NAME(L) IS NULL )
              then
                  if( P_DESC_MSG_NAME(L+1) IS NULL )
                  then
                    exit;
                  end if;
              else
                  -- dbms_output.put_line('log_description ||: id <' || P_RECORD_ID || '> pos <' || L || '> desc <' || P_DESC_MSG_NAME(L) || '>' );

                  log_description( P_RECORD_ID,
                               L,
                               P_DESC_MSG_NAME(L),
                               P_DESC_MSG_APP_NAME(L) );
              end if;

          end loop;
       end if;

    EXCEPTION
      WHEN OTHERS THEN
           rollback to log_description_II;
           commit;
           RAISE;
    END;

    commit;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
          return;

END LOG_DESCRIPTION;


-- =======================================================================
-- Provided for a description with a single param
-- =======================================================================
PROCEDURE DESCRIPTION_PARAMS
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER
  , P_PARAM_POS            IN     NUMBER
  , P_PARAM_MSG_NAME       IN     VARCHAR2
  , P_PARAM_MSG_APP_NAME   IN     VARCHAR2
  , P_VALUE                IN     VARCHAR2
  , P_VALUE_TYPE           IN     NUMBER
  )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log NUMBER(1);
  l_date1 DATE;
  l_date2 DATE;

  l_last_updated_by NUMBER;
  l_created_by NUMBER;
  l_last_update_login NUMBER;

BEGIN
  l_log := -1;

    -- dbms_output.put_line('description_params: begin' );
    if( P_RECORD_ID <= 0 )
    then
      return;
    end if;

    select 1 into l_log
      from ieo_lna_records
     where record_id = P_RECORD_ID;

    -- Create a savepoint and then commit till this point.
    SAVEPOINT desc_params;

    BEGIN
       -- Log only if log_level is <= the specified level.
       if( l_log = 1 )
       then
          l_date1 := sysdate;
          l_date2 := l_date1;

          l_last_updated_by := NVL(FND_GLOBAL.conc_login_id,-1);
          l_created_by := NVL(FND_GLOBAL.user_id,-1);
          l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

          insert into ieo_lna_parameters ( record_id,
					desc_pos,
					param_pos,
					created_by,
           				creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
           				pname_msg_name,
					pname_resource_guid,
					value_type,
					value )
				values ( P_record_id,
					P_desc_pos,
					p_param_pos,
           				l_created_by,
					l_date1,
					l_last_updated_by,
           				l_date2,
					l_last_update_login,
					P_param_msg_name,
					P_param_msg_app_name,
					P_value_type,
					P_value );
	end if;
    EXCEPTION
      WHEN OTHERS THEN
           rollback to desc_params;
           commit;
           RAISE;
    END;

    commit;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
          return;

END DESCRIPTION_PARAMS;


-- =======================================================================
-- Provided for "descriptions" with multiple "params"
-- =======================================================================
PROCEDURE DESCRIPTION_PARAMS
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER_TABLE
  , P_PARAM_MSG_NAME       IN     VARCHAR2_TABLE
  , P_PARAM_MSG_APP_NAME   IN     VARCHAR2_TABLE
  , P_PARAM_VALUE          IN     VARCHAR2_TABLE
  , P_PARAM_VALUE_TYPE     IN     NUMBER_TABLE
  )
  IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_log NUMBER(1);

BEGIN
  l_log := -1;

    -- dbms_output.put_line('description_params II: begin' );
    if( P_RECORD_ID < 0 )
    then
      return;
    end if;

    select 1 into l_log
      from ieo_lna_records
     where record_id = P_RECORD_ID;

    -- Create a savepoint and then commit till this point.
    SAVEPOINT desc_params_II;

    BEGIN
       -- Log only if log_level is <= the specified level.
       if( l_log = 1 )
       then
          -- dbms_output.put_line('description_params ||: Adding params' );
          for L in 1 .. P_DESC_POS.count
          loop
              if ( P_DESC_POS(L) IS NULL )
              then
                  if( P_DESC_POS(L+1) IS NULL )
                  then
                    exit;
                  end if;
              else
                  -- dbms_output.put_line('description_params || ||: id <' || P_RECORD_ID || '> pos <' || L || '> value <' || P_PARAM_VALUE(L) || '>' );
                  description_params( P_RECORD_ID,
                               P_DESC_POS(L),
                               L,
                               P_PARAM_MSG_NAME(L),
                               P_PARAM_MSG_APP_NAME(L),
                               P_PARAM_VALUE(L),
                               P_PARAM_VALUE_TYPE(L) );
              end if;

          end loop;
       end if;

    EXCEPTION
      WHEN OTHERS THEN
           rollback to desc_params_II;
           commit;
           RAISE;
    END;

    commit;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
          return;

END DESCRIPTION_PARAMS;

END IEC_SQL_LOGGER_PVT;

/
