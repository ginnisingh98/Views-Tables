--------------------------------------------------------
--  DDL for Package Body EDW_SOURCE_OPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SOURCE_OPTION" AS
/* $Header: EDWSRCFB.pls 115.8 2003/11/18 07:11:53 smulye noship $  */
   FUNCTION get_source_option (
      p_object_name                 VARCHAR2,
      p_object_id                   NUMBER,
      p_option_code                 VARCHAR2,
      p_option_value   OUT NOCOPY   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_object_id       NUMBER (9);
      l_instance_code   VARCHAR2 (30);
      l_dblink          all_db_links.db_link%TYPE;
      l_dblink2         all_db_links.db_link%TYPE;
      l_stmt            VARCHAR2 (5000);
      l_owner           all_users.username%TYPE;
      check_tspace_exist varchar(1);
      check_ts_mode varchar(1);
      physical_tspace_name varchar2(100);

      TYPE curtyp IS REF CURSOR;

      cv                curtyp;
   BEGIN
      p_option_value := NULL;

      IF (p_option_code = 'DEBUG_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_DEBUG');
      ELSIF (p_option_code = 'TRACE_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_TRACE');
      ELSIF (p_option_code = 'PARALLELISM_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_PARALLEL_SRC');
      ELSIF (p_option_code = 'COMMITSIZE_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_PUSH_SIZE');
      ELSIF (p_option_code = 'OPTABLESPACE_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_COL_OP_TABLE_SPACE');
      ELSIF (p_option_code = 'ROLLBACK_SR')
      THEN
         p_option_value := fnd_profile.VALUE ('EDW_ROLLBACK_SRC');
      END IF;

      IF (p_option_code = 'OPTABLESPACE_SR' AND p_option_value IS NULL)
      THEN
         l_owner := edw_source_option.get_db_user ('BIS');

	 AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	  If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			p_option_value :=  physical_tspace_name;
		end if;
       	  end if;

           if p_option_value is null then
		   SELECT default_tablespace
		   INTO p_option_value
		   FROM dba_users
         	  WHERE username = l_owner;
           end if;

      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_status_message := SQLERRM;
         p_option_value := NULL;
         edw_log.put_line ('Error in get_source_option ' || SQLERRM);
         RETURN FALSE;
   END get_source_option;

   FUNCTION get_db_user (p_product VARCHAR2)
      RETURN VARCHAR2
   IS
      l_dummy1   VARCHAR2 (2000);
      l_dummy2   VARCHAR2 (2000);
      l_schema   VARCHAR2 (400);
   BEGIN
      IF fnd_installation.get_app_info (p_product,
                                        l_dummy1,
                                        l_dummy2,
                                        l_schema
                                       ) = FALSE
      THEN
         edw_log.put_line ('FND_INSTALLATION.GET_APP_INFO returned with error'
                          );
         RETURN NULL;
      END IF;

      RETURN l_schema;
   EXCEPTION
      WHEN OTHERS
      THEN
         edw_log.put_line ('Error in get_db_user ' || SQLERRM);
         RETURN NULL;
   END;
END;


/
