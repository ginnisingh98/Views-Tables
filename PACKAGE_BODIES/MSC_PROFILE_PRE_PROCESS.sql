--------------------------------------------------------
--  DDL for Package Body MSC_PROFILE_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PROFILE_PRE_PROCESS" AS -- body
/* $Header: MSCPFPPB.pls 115.0 2004/07/30 08:58:23 rawasthi noship $ */

 v_pref_set varchar2(50);
 v_usr_name varchar2(15);
 v_current_user NUMBER := -1;
 v_sql_stmt   varchar2(100);

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


PROCEDURE setprofile(ERRBUF      OUT NOCOPY VARCHAR2,
                     RETCODE     OUT NOCOPY NUMBER,
                     p_preference_set_name IN VARCHAR2,
		     p_upload_profile IN NUMBER) IS

 CURSOR c1 is
  select profile_option_name,profile_option_value,level_type,level_name,application_name from msc_profiles where    preference_set_name=p_preference_set_name;

    usr_flag_enabled varchar2(5);
    appl_flag_enabled varchar2(5);
    resp_flag_enabled varchar2(5);
    usr_id NUMBER;
    appl_id NUMBER;
    resp_id NUMBER;
    ret_value BOOLEAN;
    x_prof_err EXCEPTION;
    l_prof_name msc_profiles.profile_option_name%TYPE;
    l_level_type msc_profiles.level_type%TYPE;
    l_level_name msc_profiles.level_name%TYPE;


BEGIN


FOR cur_rec in c1 LOOP

  l_level_type := cur_rec.level_type;
  l_level_name := cur_rec.level_name;
  l_prof_name := cur_rec.profile_option_name;


 IF cur_rec.level_type='USER' THEN

  v_sql_stmt := 1;

  SELECT user_id into usr_id from fnd_user where user_name=cur_rec.level_name;

       ret_value := FND_PROFILE.SAVE(cur_rec.profile_option_name,cur_rec.profile_option_value,'USER',usr_id);
          IF ret_value = FALSE THEN
             RAISE x_prof_err;
          END IF;


 ELSIF cur_rec.level_type='RESP' THEN

  v_sql_stmt := 2;


  SELECT application_id into appl_id from fnd_application where application_short_name=cur_rec.application_name;

 v_sql_stmt := 3;

  SELECT responsibility_id into resp_id from fnd_responsibility_vl where responsibility_name=cur_rec.level_name and    application_id=appl_id;


       ret_value := FND_PROFILE.SAVE(cur_rec.profile_option_name,cur_rec.profile_option_value,'RESP',resp_id,appl_id);
          IF ret_value = FALSE THEN
             RAISE x_prof_err;
          END IF;

 ELSIF cur_rec.level_type='APPL' THEN

  v_sql_stmt := 4;

  select application_id into appl_id from fnd_application where application_short_name=cur_rec.level_name;

        ret_value := FND_PROFILE.SAVE(cur_rec.profile_option_name,cur_rec.profile_option_value,'APPL',appl_id);
          IF ret_value = FALSE THEN
             RAISE x_prof_err;
          END IF;

 ELSE
 --Check if the user has selected the upload site level values to YES.
 IF p_upload_profile=SYS_YES THEN
   ret_value := FND_PROFILE.SAVE(cur_rec.profile_option_name,cur_rec.profile_option_value,'SITE');
      IF ret_value = FALSE THEN
         RAISE x_prof_err;
      END IF;
  END IF;

 END IF;
 END LOOP;
 COMMIT;

 EXCEPTION

   WHEN NO_DATA_FOUND THEN
   ROLLBACK;
   ERRBUF  := SQLERRM;
   RETCODE := G_ERROR;
   LOG_MESSAGE('The level value ' || l_level_name || ' has errors at ' || l_level_type || ' level');
  LOG_MESSAGE('The error occured while processing the profile ' || l_prof_name);
   LOG_MESSAGE('The error occured at stmt => ' || v_sql_stmt);
   LOG_MESSAGE(SQLERRM);

   WHEN OTHERS THEN
   ROLLBACK;
   ERRBUF  := SQLERRM;
   RETCODE := G_ERROR;
   LOG_MESSAGE('The profile option ' ||l_prof_name || ' has errors');
   LOG_MESSAGE(SQLERRM);

 END setprofile;


  PROCEDURE MSC_PROF_PRE_PROCESS (ERRBUF          OUT NOCOPY VARCHAR2,
                                  RETCODE         OUT NOCOPY NUMBER,
                                  p_preference_set_name   IN VARCHAR2,
				   p_upload_profile IN NUMBER)
   IS

 CURSOR c2 IS
 SELECT
  preference_set_name,
  level_type,
  level_name,
  profile_option_name,
  profile_option_value,
  application_name,
  process_flag
FROM  MSC_ST_PROFILES
WHERE preference_set_name = p_preference_set_name
  AND process_flag=1;


 BEGIN

  v_sql_stmt := 5;

  UPDATE MSC_ST_PROFILES msp1
        SET PROCESS_FLAG = 3
        WHERE EXISTS (select 1 from msc_st_profiles msp2
                      where msp2.preference_set_name=msp1.preference_set_name
                      and   nvl(msp2.level_name,'-27323')=nvl(msp1.level_name,'-27323')
                      and   nvl(msp2.level_type,'-27323')=nvl(msp1.level_type,'-27323')
                      and   msp2.profile_option_name = msp1.profile_option_name
                      and   nvl(msp2.application_name,'-27323') = nvl(msp1.application_name,'-27323')
                      and   msp2.rowid <> msp1.rowid
                      and   msp2.process_flag=1
                      )
         AND PROCESS_FLAG = 1
         AND PREFERENCE_SET_NAME = p_preference_set_name;


  v_sql_stmt := 6;

  DELETE FROM MSC_PROFILES
    WHERE PREFERENCE_SET_NAME = p_preference_set_name ;

  FOR c_rec in c2 LOOP


 /* UPDATE MSC_PROFILES SET
           PROFILE_OPTION_VALUE = c_rec.PROFILE_OPTION_VALUE
         WHERE PREFERENCE_SET_NAME = c_rec.PREFERENCE_SET_NAME
                AND nvl(level_name,'-27323') = nvl(c_rec.level_name,'-27323')
                AND nvl(level_type,'-27323') = nvl(c_rec.level_type,'-27323')
                AND PROFILE_OPTION_NAME = c_rec.PROFILE_OPTION_NAME
                AND nvl(APPLICATION_NAME,'-27323') = nvl(c_rec.APPLICATION_NAME,'-27323')
                AND c_rec.PROCESS_FLAG=1;

 IF SQL%NOTFOUND THEN */
  IF c_rec.process_flag=1 THEN

 insert into msc_profiles
 (
  PREFERENCE_SET_NAME,
  LEVEL_TYPE,
  LEVEL_NAME,
  PROFILE_OPTION_NAME,
  PROFILE_OPTION_VALUE,
  APPLICATION_NAME,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_LOGIN
  )
 values
 (
  c_rec.PREFERENCE_SET_NAME,
  c_rec.LEVEL_TYPE,
  c_rec.LEVEL_NAME,
  c_rec.PROFILE_OPTION_NAME,
  c_rec.PROFILE_OPTION_VALUE,
  c_rec.APPLICATION_NAME,
  SYSDATE,
  v_current_user,
  SYSDATE,
  v_current_user,
  v_current_user
  );

 END IF;

 UPDATE msc_st_profiles set process_flag = 5
    WHERE PREFERENCE_SET_NAME =  c_rec.PREFERENCE_SET_NAME
      AND nvl(LEVEL_NAME,'-27223') = nvl(c_rec.LEVEL_NAME,'-27223')
      AND nvl(level_type,'-27323') = nvl(c_rec.level_type,'-27323')
      AND PROFILE_OPTION_NAME = c_rec.PROFILE_OPTION_NAME
      AND nvl(APPLICATION_NAME,'-27323') = nvl(c_rec.APPLICATION_NAME,'-27323')
      AND nvl(PROFILE_OPTION_VALUE,'-27223') = nvl(c_rec.PROFILE_OPTION_VALUE,'-27223')
      AND process_flag = 1;


 END LOOP;

 v_sql_stmt := 7;

  DELETE from msc_st_profiles where process_flag=5;

  setprofile(ERRBUF => ERRBUF,
             RETCODE => RETCODE,
             p_preference_set_name => p_preference_set_name,
	     p_upload_profile => p_upload_profile);

  EXCEPTION

   WHEN NO_DATA_FOUND THEN
   ROLLBACK;
   ERRBUF  := SQLERRM;
   RETCODE := G_ERROR;
   LOG_MESSAGE('The error occured at stmt ' || v_sql_stmt);
   LOG_MESSAGE(SQLERRM);

   WHEN OTHERS THEN
   ROLLBACK;
   ERRBUF  := SQLERRM;
   RETCODE := G_ERROR;
   LOG_MESSAGE('The error occured at stmt ' || v_sql_stmt);
   LOG_MESSAGE(SQLERRM);

  END MSC_PROF_PRE_PROCESS;

END MSC_PROFILE_PRE_PROCESS;

/
