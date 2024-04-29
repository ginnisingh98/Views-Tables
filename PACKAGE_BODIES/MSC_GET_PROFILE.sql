--------------------------------------------------------
--  DDL for Package Body MSC_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_GET_PROFILE" AS -- body
/* $Header: MSCPROFB.pls 115.0 2004/05/21 13:13:47 rawasthi noship $ */

 PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

  PROCEDURE GET_SPECIFIC_LEVEL_PROFILES(
                           name_z in varchar2,
                           level_id_z in number,
                           level_value_z in number,
                           level_value_application_z in number,
                           val_z out NOCOPY varchar2,
                           cached_z out NOCOPY boolean) is
      pid number;
      aid number;
      tableIndex binary_integer;
      contextLevelValue number;

      --
      -- this cursor fetches profile information that will
      -- allow subsequent fetches to be more efficient
      --
      cursor profile_info is
        select profile_option_id,
               application_id
        from   fnd_profile_options
        where  profile_option_name = upper(name_z)
        and    start_date_active  <= sysdate
        and    nvl(end_date_active, sysdate) >= sysdate;

      --
      -- this cursor fetches profile option values for site, application,
      -- and user levels (10001/10002/10004)
      --
      cursor value_uas(pid number, aid number, lid number, lval number) is
        select profile_option_value
        from   fnd_profile_option_values
        where  profile_option_id = pid
        and    application_id    = aid
        and    level_id          = lid
        and    level_value       = lval;

      --
      -- this cursor fetches profile option values at the responsibility
      -- level (10003)
      --
      cursor value_resp(pid number, aid number, lval number, laid number) is
        select profile_option_value
        from   fnd_profile_option_values
        where  profile_option_id = pid
        and    application_id = aid
        and    level_id = 10003
        and    level_value = lval
        and    level_value_application_id = laid;

    begin

      val_z := NULL;
      cached_z := FALSE;

    -- get profile info from database --
      open profile_info;
        fetch profile_info into pid, aid;
        if (profile_info%NOTFOUND) then
          val_z := -27323;
          cached_z := FALSE;
          return;
        end if;
      close profile_info;

      -- get profile value from database --
      if (level_id_z = 10001 or level_id_z = 10002 or level_id_z = 10004 or
          level_id_z = 10005 or level_id_z = 10006)  then
        for c1 in value_uas(pid,aid,level_id_z,level_value_z) loop
          val_z := c1.profile_option_value;
          cached_z := FALSE;
          return;
        end loop;
      else
        for c1 in value_resp(pid,aid,level_value_z,level_value_application_z) loop
          val_z := c1.profile_option_value;
          cached_z := FALSE;
          return;
        end loop;
      end if;

      val_z := NULL;
      cached_z := FALSE;

  END GET_SPECIFIC_LEVEL_PROFILES;


    -- This procedure is to create the flat file for profile option values

  PROCEDURE utl_debug(p_pref varchar2, p_level varchar2, p_level_val varchar2, p_prof_name varchar2, p_prof_val varchar2, p_appl varchar2 default null, log_file_handle   UTL_FILE.FILE_TYPE)  IS


   BEGIN

    utl_file.put(log_file_handle,p_pref);
    utl_file.put(log_file_handle,'~');
    utl_file.put(log_file_handle,p_level);
    utl_file.put(log_file_handle,'~');
    utl_file.put(log_file_handle,p_level_val);
    utl_file.put(log_file_handle,'~');
    utl_file.put(log_file_handle,p_prof_name);
    utl_file.put(log_file_handle,'~');
    utl_file.put(log_file_handle,p_prof_val);
    utl_file.put(log_file_handle,'~');
    utl_file.put(log_file_handle,p_appl);
    utl_file.put(log_file_handle,'~');
    utl_file.new_line(log_file_handle,1);

  exception
   when no_data_found then
        utl_file.put_line(log_file_handle,'No locks');

   when utl_file.invalid_path then
     log_message('INvalid path');

   when utl_file.invalid_filehandle then
     log_message('INvalid filehandle');

   when others then
     log_message('EXCEPTION : '||sqlerrm);

 END;


  PROCEDURE  GETPROF  (      ERRBUF                OUT NOCOPY VARCHAR2,
                             RETCODE               OUT NOCOPY NUMBER,
                             preference_set_name   IN  VARCHAR2,
                             usr_name              IN varchar2 default NULL,
                             application_name      IN varchar2 default NULL,
                             resp_name             IN varchar2 default NULL,
                             schema_name           IN varchar2,
                             p_file_name           IN varchar2)
  IS

 CURSOR get_profile_name(prod varchar2) is
    select PROFILE_OPTION_NAME FROM FND_PROFILE_OPTIONS_VL
    WHERE START_DATE_ACTIVE <= SYSDATE and NVL(END_DATE_ACTIVE,SYSDATE) >= SYSDATE
    AND (SITE_ENABLED_FLAG = 'Y' or USER_ENABLED_FLAG = 'Y')
    AND UPPER(USER_PROFILE_OPTION_NAME) LIKE prod||'%';

 CURSOR get_dir is
       select nvl(substr(value,1,instr(value,',')-1),value) from v$parameter where name = 'utl_file_dir';

   var1 varchar2(240);
   var2 BOOLEAN;
   var4 BOOLEAN :=TRUE;
   prod_name varchar2(3);
   l_start_index number := 1;
   l_end_index  number := 1;
   l_next_start_index number;
   usr_id number;
   appl_id number;
   resp_id number;
   mydir  varchar2(200) ;
   log_file_handle     UTL_FILE.FILE_TYPE;
   lv_file_name        VARCHAR2(1000):= '';


BEGIN

 log_message('USER NAME=> '||usr_name);
 log_message('APPLICATION NAME=> '||application_name);
 log_message('RESPONSIBILITY NAME=> '||resp_name);

   open get_dir;
    fetch get_dir into mydir;
   close get_dir;

    IF instr(p_file_name, '.', -1) = 0 then
        lv_file_name := p_file_name ||'.dat';
    ELSE
        lv_file_name := p_file_name ;
    END IF;

  IF usr_name is NOT NULL THEN
   select user_id into usr_id from fnd_user where user_name=usr_name;
  END IF;

  IF application_name is NOT NULL THEN
   select application_id into appl_id from fnd_application where application_short_name=application_name;
  END IF;

  IF resp_name is NOT NULL THEN
   select responsibility_id into resp_id from fnd_responsibility_vl where responsibility_name=resp_name and   application_id=appl_id;
  END IF;

  log_file_handle := utl_file.fopen(mydir, lv_file_name, 'w');


 WHILE (var4) LOOP

   l_next_start_index := instr(schema_name,',',l_end_index);
   IF l_next_start_index = 0 THEN
      prod_name := substr(schema_name,l_start_index);
       FOR cur1 in get_profile_name(prod_name) LOOP
         IF usr_name is NOT NULL THEN
           GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10004,usr_id,0,var1,var2);
           utl_debug(preference_set_name,'USER',usr_name,cur1.profile_option_name,var1,NULL,log_file_handle);
         END IF;
         IF resp_name is NOT NULL THEN
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10003,resp_id,appl_id,var1,var2);
          utl_debug(preference_set_name,'RESP',resp_name,cur1.profile_option_name,var1,application_name,log_file_handle);
         END IF;
         IF application_name is NOT NULL THEN
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10002,appl_id,0,var1,var2);
           utl_debug(preference_set_name,'APPL',application_name,cur1.profile_option_name,var1,NULL,log_file_handle);

         END IF;
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10001,0,0,var1,var2);
          utl_debug(preference_set_name,'SITE','SITE',cur1.profile_option_name,var1,NULL,log_file_handle);
       end LOOP;
     var4 := FALSE;

   ELSE

     prod_name := substr(schema_name,l_start_index,l_next_start_index-l_start_index);
       FOR cur1 in get_profile_name(prod_name) LOOP
         IF usr_name is NOT NULL THEN
           GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10004,usr_id,0,var1,var2);
           utl_debug(preference_set_name,'USER',usr_name,cur1.profile_option_name,var1,NULL,log_file_handle);
         END IF;
         IF resp_name is NOT NULL THEN
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10003,resp_id,appl_id,var1,var2);
          utl_debug(preference_set_name,'RESP',resp_name,cur1.profile_option_name,var1,application_name,log_file_handle);
         END IF;
         IF application_name is NOT NULL THEN
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10002,appl_id,0,var1,var2);
           utl_debug(preference_set_name,'APPL',application_name,cur1.profile_option_name,var1,NULL,log_file_handle);
         END IF;
          GET_SPECIFIC_LEVEL_PROFILES(cur1.PROFILE_OPTION_NAME,10001,0,0,var1,var2);
          utl_debug(preference_set_name,'SITE','SITE',cur1.profile_option_name,var1,NULL,log_file_handle);

       end LOOP;
     l_start_index := l_next_start_index+1;
     l_end_index := l_start_index;
   END IF;

 END LOOP;

 utl_file.fclose(log_file_handle);

 EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
   ERRBUF  := SQLERRM;
   RETCODE := G_ERROR;
   log_message(SQLERRM);
      RAISE;

END GETPROF;
END MSC_GET_PROFILE;

/
