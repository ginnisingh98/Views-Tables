--------------------------------------------------------
--  DDL for Package Body IEU_SH_CON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_SH_CON_PVT" AS
/* $Header: IEUVSHCB.pls 120.1 2005/10/28 14:36:43 parghosh noship $ */

PROCEDURE IEU_SH_END_IDLE_TRANS(ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, p_agent_name IN VARCHAR2, p_appl_name in VARCHAR2, p_timeout in NUMBER) IS

  l_media_active VARCHAR2(1);
  l_sh_active_flag VARCHAR2(1);
  l_update_time_format VARCHAR2(32);
  l_media_not_active VARCHAR2(1);
  l_end_state_code VARCHAR2(32);
  l_force_close_flag VARCHAR2(1);

  --Select all users who have more than one session open by UWQ

  cursor l_users(l_application_id in NUMBER)  is
       SELECT resource_id, count(resource_id) count, max(last_update_date) last_update
        FROM ieu_sh_sessions where active_flag = l_sh_active_flag
        and application_id = l_application_id
        GROUP BY resource_id HAVING count(resource_id) > 1;

       -- SELECT resource_id
        --FROM JTF_RS_RESOURCE_EXTNS j, FND_USER f
        --where j.user_id = f.user_id;

  --Select all the sessions corresponding to a particular resource_id
  --which are open by UWQ

  cursor l_ses_resource(l_resource_id in NUMBER, l_application_id in NUMBER) is
        SELECT session_id, last_update_date
        FROM ieu_sh_sessions
        WHERE resource_id = l_resource_id
        AND active_flag = l_sh_active_flag
        AND application_id = l_application_id;

  -- Select the session id if the sessions are open by UWQ

  cursor l_ses_cur(l_application_id in NUMBER) is
        SELECT session_id, resource_id
        FROM ieu_sh_sessions ses
        WHERE end_date_time is NULL
        AND   active_flag = l_sh_active_flag
        AND   application_id = l_application_id;

  -- Select all activity id for all open sessions

  cursor l_act_cur1(l_ses_id IN NUMBER) is
          SELECT activity_id, media_id, activity_type_code, session_id, BEGIN_DATE_TIME
          FROM ieu_sh_activities
  WHERE end_date_time is NULL
          AND   active_flag = l_sh_active_flag
          AND  session_id = l_ses_id;

  -- select the activity id for all activities opened by UWQ whose sessions have been closed,

  cursor l_act_cur2(l_application_id in NUMBER) is
          SELECT activity_id, session_id, media_id, BEGIN_DATE_TIME
          FROM ieu_sh_activities
  WHERE end_date_time is NULL
          AND   active_flag = l_sh_active_flag
          AND  session_id in (select session_id from ieu_sh_sessions
      where application_id = l_application_id
                              and   end_date_time is not null
                              and   active_flag is null)
                ;

  l_applCursor t_cursor;
  l_applId NUMBER;

  l_act_id NUMBER;
  l_end_date_time DATE;
  l_last_update_date DATE;
  l_last_update_time NUMBER;
  --l_count_ses NUMBER;
  --l_last_ses_update DATE;
  l_ses_timeout NUMBER;
  l_agent_resource_id NUMBER;

  l_count_lc_segs NUMBER;
  l_count_lc_segs_active NUMBER;
  l_cal_end_date_time DATE;
  --l_max_end_date_time DATE;
  --l_max_deliver_date_time DATE;
  --l_max_begin_date_time DATE;
  l_cycle_end_date_time DATE;

  l_total_act NUMBER;
  l_terminated_act NUMBER;

  l_act_resource_id NUMBER;
  l_act_end_date DATE;

  --l_cursor_index NUMBER := 2000;
  BEGIN

      l_media_active := 'Y';
      l_sh_active_flag := 'T';
      l_update_time_format := 'hh24';
      l_media_not_active := 'N';
      l_end_state_code := 'END';
      l_force_close_flag := 'Y';

      l_ses_timeout := p_timeout;
      l_total_act := 0;
      l_terminated_act := 0;


      /*
      IF (FND_PROFILE.VALUE('IEU_UWQ_SESSION_TIMEOUT') is null)
      THEN
        l_ses_timeout:=3;
      ELSE
        l_ses_timeout:=TO_NUMBER(FND_PROFILE.VALUE('IEU_UWQ_SESSION_TIMEOUT'))/60;

      END IF;
      */

      -- Main Cleanup Program
      IEU_SH_OPEN_CURSOR(l_applCursor, p_appl_name);

      loop
        FETCH l_applCursor INTO l_applId;
        EXIT WHEN l_applCursor%NOTFOUND;

      --INSERT into P_TEMP (cnt, msg) VALUES (l_cursor_index, l_applId);
      --l_cursor_index := l_cursor_index + 1;

        for ses_cur_rec in l_ses_cur(l_applId)
        loop

          select max(trunc(last_update_date)), max(to_number(to_char(last_update_date, l_update_time_format)))
          into   l_last_update_date, l_last_update_time
          from ieu_sh_activities act
          where act.session_id = ses_cur_rec.session_id;

          IF ( ( (trunc(sysdate) > l_last_update_date)
                 and
                 (trunc(sysdate) - l_last_update_date  > 0.00000)
                 and
                 (trunc(sysdate) - l_last_update_date < 1.00000)
                 and
                 ( (23 - l_last_update_time + to_number(to_char(sysdate, l_update_time_format)) >= l_ses_timeout      )
               )
               or
               (trunc(sysdate) - l_last_update_date > 1.00000)
               or
                ((trunc(sysdate) = l_last_update_date )
                  and
                 ((to_number(to_char(sysdate, l_update_time_format)) - l_ses_timeout) >= l_last_update_time )
                )
              )
          )
          THEN

             for act_cur_rec_1 in l_act_cur1(ses_cur_rec.session_id)
             loop

  --              dbms_output.put_line('Activity Id : '||act_cur_rec_1.activity_id||' Session Id : '||ses_cur_rec.session_id);

                select count(*), max(end_date_time)
                  into l_count_lc_segs, l_cal_end_date_time
                  FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE
                  media_id = act_cur_rec_1.media_id AND
                  resource_id = ses_cur_rec.resource_id AND
                  ACTIVE = l_media_not_active;

                select count(*)
                  into l_count_lc_segs_active
                  FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE
                  media_id = act_cur_rec_1.media_id AND
                  resource_id = ses_cur_rec.resource_id AND
                  ACTIVE = l_media_active;

                l_total_act := l_total_act + 1;

                IF (l_count_lc_segs > 0)
                THEN

                  update IEU_SH_ACTIVITIES set
                  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                  END_DATE_TIME = l_cal_end_date_time,
                  ACTIVE_FLAG = NULL,
                  STATE_CODE = l_end_state_code,
                  FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                  WHERE ACTIVITY_ID = act_cur_rec_1.activity_id;

                  l_terminated_act := l_terminated_act + 1;

                ELSE

                  IF (l_count_lc_segs_active > 0)

                  THEN
                  -- do nothing, skip the record
          exit;

	          -- for activities with no MEDIA ITEM IDs

                  ELSE

		    -- hack for media cycle issues

                    IF (act_cur_rec_1.activity_type_code = 'MEDIA_CYCLE')
                    THEN

		            BEGIN
                        select decode ( greatest (max(end_date_time), max(deliver_date_time), max(begin_date_time) ), null,
act_cur_rec_1.begin_date_time, greatest (max(end_date_time), max(deliver_date_time), max(begin_date_time) ) )
                        into l_cycle_end_date_time
		              from IEU_SH_ACTIVITIES where
		              parent_cycle_id = act_cur_rec_1.activity_id;
		            EXCEPTION
		              WHEN OTHERS THEN
			           NULL;
		            END;

                      IF (l_cycle_end_date_time is NULL)
                      THEN
                         l_cycle_end_date_time := act_cur_rec_1.BEGIN_DATE_TIME;
                      END IF;

		          ELSE

		            l_cycle_end_date_time := act_cur_rec_1.BEGIN_DATE_TIME;

		          END IF;

                    update IEU_SH_ACTIVITIES set
                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                    END_DATE_TIME = l_cycle_end_date_time,
                    ACTIVE_FLAG = NULL,
                    STATE_CODE = l_end_state_code,
                    FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                    WHERE ACTIVITY_ID = act_cur_rec_1.activity_id;

                    l_terminated_act := l_terminated_act + 1;


                  END IF;
                END IF;

              end loop;

              IF (l_terminated_act = l_total_act)
              THEN

                BEGIN
                 select max(end_date_time)
                 into   l_end_date_time
                 from   ieu_sh_activities
                 where  session_id = ses_cur_rec.session_id;
                EXCEPTION
                 WHEN OTHERS THEN
                  NULL;
                END;

                if (l_end_date_time is null) then
                 select begin_date_time
                 into   l_end_date_time
                 from   ieu_sh_sessions
                 where  session_id = ses_cur_rec.session_id;
                end if;

  --            dbms_output.put_line(' end_date_time : '||l_end_date_time);

                update IEU_SH_SESSIONS set
                  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                  END_DATE_TIME = l_end_date_time,
                  ACTIVE_FLAG = NULL,
                  FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                WHERE SESSION_ID = ses_cur_rec.session_id;

              END IF;

            ELSIF ( (l_last_update_date is null) and (l_last_update_time is null) )
            THEN

  --             dbms_output.put_line('Session id for sessions with no activities: '||ses_cur_rec.session_id);

               select trunc(last_update_date), to_number(to_char(last_update_date, l_update_time_format))
               into   l_last_update_date, l_last_update_time
               from   ieu_sh_sessions ses
               where  ses.session_id = ses_cur_rec.session_id;

          IF ( ( (trunc(sysdate) > l_last_update_date)
                 and
                 (trunc(sysdate) - l_last_update_date  > 0.00000)
                 and
                 (trunc(sysdate) - l_last_update_date < 1.00000)
                    and
                 ( (23 - l_last_update_time + to_number(to_char(sysdate, l_update_time_format))
  >= l_ses_timeout      )
                 )
                  or
                  ( trunc(sysdate) - l_last_update_date > 1.00000 )
                  or
                    ((trunc(sysdate) = l_last_update_date )
                    and
                    ((to_number(to_char(sysdate, l_update_time_format)) - l_ses_timeout) >= l_last_update_time )
                   )
                 )
               )
               THEN

                  update IEU_SH_SESSIONS set
                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                    END_DATE_TIME = BEGIN_DATE_TIME,
                    ACTIVE_FLAG = NULL,
                    FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                  WHERE SESSION_ID = ses_cur_rec.session_id;

               END IF;

            END IF;

        end loop;

      end loop;

      close l_applCursor;

      -- Moved the cleanup of activities with no active sessions to the end

    -- Kill all sesssions and activities pertaining to a particular user_name
    -- if it is supplied as a parameter

   IF (p_agent_name  is not null)
   THEN

      DECLARE

        l_upper_agent VARCHAR2(100);

      BEGIN
        l_upper_agent := upper(p_agent_name);


        select resource_id into l_agent_resource_id
        FROM JTF_RS_RESOURCE_EXTNS
        where user_name=l_upper_agent;


      EXCEPTION

        when NO_DATA_FOUND THEN
          NULL;

      END;


      IF (l_agent_resource_id is not NULL)
      THEN

        IEU_SH_OPEN_CURSOR(l_applCursor, p_appl_name);
        loop
          FETCH l_applCursor INTO l_applId;
          EXIT WHEN l_applCursor%NOTFOUND;

          for cur_ses in l_ses_resource(l_agent_resource_id, l_applId)
            loop

          /*
            update IEU_SH_SESSIONS set
                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                    END_DATE_TIME = BEGIN_DATE_TIME,
                    ACTIVE_FLAG = NULL,
                    FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                  WHERE SESSION_ID = cur_ses.session_id;
          */



            for cur_act in l_act_cur1(cur_ses.session_id)
            loop

              l_count_lc_segs := 0;

              -- Should delete this block in future, use l_agent_resource_id straight way
              select RESOURCE_ID into
              l_act_resource_id from
              IEU_SH_SESSIONS where
              SESSION_ID = cur_act.session_id;

              select count(*), max(end_date_time)
                  into l_count_lc_segs, l_cal_end_date_time
                  FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE
                  media_id = cur_act.media_id AND
                  resource_id = l_act_resource_id AND
                  ACTIVE = l_media_not_active;

              IF (l_count_lc_segs > 0 )
              THEN
                l_act_end_date := l_cal_end_date_time;
              ELSE
                l_act_end_date := cur_act.BEGIN_DATE_TIME;
              END IF;

              update IEU_SH_ACTIVITIES set
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                END_DATE_TIME =  l_act_end_date,
                ACTIVE_FLAG = NULL,
                STATE_CODE = l_end_state_code,
                FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                WHERE ACTIVITY_ID = cur_act.activity_id;

            end loop;

            BEGIN
             select max(end_date_time)
             into   l_end_date_time
             from   ieu_sh_activities
             where  session_id = cur_ses.session_id;
            EXCEPTION
             WHEN OTHERS THEN
              NULL;
            END;

            if (l_end_date_time is null) then
             select begin_date_time
             into   l_end_date_time
             from   ieu_sh_sessions
             where  session_id = cur_ses.session_id;
            end if;

--            dbms_output.put_line(' end_date_time : '||l_end_date_time);

            update IEU_SH_SESSIONS set
              OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
              END_DATE_TIME = l_end_date_time,
              ACTIVE_FLAG = NULL,
              FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
            WHERE SESSION_ID = cur_ses.session_id;

          end loop;

        end loop;

        close l_applCursor;

      END IF;

    END IF;

    -- Delete duplicate sessions corresponding to a resource_id
    IEU_SH_OPEN_CURSOR(l_applCursor, p_appl_name);

    loop
      FETCH l_applCursor INTO l_applId;
      EXIT WHEN l_applCursor%NOTFOUND;

      --INSERT into P_TEMP (cnt, msg) VALUES (l_cursor_index, l_applId);
      --l_cursor_index := l_cursor_index + 1;

      for cur_user in l_users(l_applId)
      loop

        for cur_ses in l_ses_resource(cur_user.resource_id, l_applId)
          loop
            IF (cur_ses.last_update_date < cur_user.last_update)
            THEN

              -- New introduction 09/03/03 not updating session table with last_update_time anymore
              /*
              update IEU_SH_SESSIONS set
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                END_DATE_TIME = cur_user.last_update,
                ACTIVE_FLAG = NULL,
                FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
              WHERE SESSION_ID = cur_ses.session_id;
              */


              -- New introduction 09/03/03 updating activity set as well

              for cur_act in l_act_cur1(cur_ses.session_id)
              loop

                l_count_lc_segs := 0;

                -- Should delete this block in future, use cur_user.resource_id straight way
                select RESOURCE_ID into
                l_act_resource_id from
                IEU_SH_SESSIONS where
                SESSION_ID = cur_act.session_id;

                select count(*), max(end_date_time)
                    into l_count_lc_segs, l_cal_end_date_time
                    FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE
                    media_id = cur_act.media_id AND
                    resource_id = l_act_resource_id AND
                    ACTIVE = l_media_not_active;

                IF (l_count_lc_segs > 0 )
                THEN
                  l_act_end_date := l_cal_end_date_time;
                ELSE
                  l_act_end_date := cur_act.BEGIN_DATE_TIME;
                END IF;

                update IEU_SH_ACTIVITIES set
                  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                  END_DATE_TIME =  l_act_end_date,
                  ACTIVE_FLAG = NULL,
                  STATE_CODE = l_end_state_code,
                  FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
                  WHERE ACTIVITY_ID = cur_act.activity_id;

              end loop;

              BEGIN
               select max(end_date_time)
               into   l_end_date_time
               from   ieu_sh_activities
               where  session_id = cur_ses.session_id;
              EXCEPTION
               WHEN OTHERS THEN
                NULL;
              END;

              if (l_end_date_time is null) then
               select begin_date_time
               into   l_end_date_time
               from   ieu_sh_sessions
               where  session_id = cur_ses.session_id;
              end if;

  --            dbms_output.put_line(' end_date_time : '||l_end_date_time);

              update IEU_SH_SESSIONS set
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                END_DATE_TIME = l_end_date_time,
                ACTIVE_FLAG = NULL,
                FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
              WHERE SESSION_ID = cur_ses.session_id;

            END IF;
          end loop;

        end loop;

      end loop;

      close l_applCursor;

      -- Gracefully end all activities with no open sessions
      IEU_SH_OPEN_CURSOR(l_applCursor, p_appl_name);

      loop
        FETCH l_applCursor INTO l_applId;
        EXIT WHEN l_applCursor%NOTFOUND;

        for act_cur_rec_2 in l_act_cur2(l_applId)
        loop

--        dbms_output.put_line('Activity Id for activities with no sessions : '|| act_cur_rec_2.activity_id);
          l_count_lc_segs := 0;

          select RESOURCE_ID into
          l_act_resource_id from
          IEU_SH_SESSIONS where
          SESSION_ID = act_cur_rec_2.session_id;

          select count(*), max(end_date_time)
              into l_count_lc_segs, l_cal_end_date_time
              FROM JTF_IH_MEDIA_ITEM_LC_SEGS WHERE
              media_id = act_cur_rec_2.media_id AND
              resource_id = l_act_resource_id AND
              ACTIVE = l_media_not_active;

          IF (l_count_lc_segs > 0 )
          THEN
            l_act_end_date := l_cal_end_date_time;
          ELSE
            l_act_end_date := act_cur_rec_2.BEGIN_DATE_TIME;
          END IF;

          update IEU_SH_ACTIVITIES set
            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
            END_DATE_TIME =  l_act_end_date,
            ACTIVE_FLAG = NULL,
            STATE_CODE = l_end_state_code,
            FORCE_CLOSED_BY_UWQ_FLAG = l_force_close_flag
          WHERE ACTIVITY_ID = act_cur_rec_2.activity_id;

        end loop;

      end loop;

      close l_applCursor;

  EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;

  END IEU_SH_END_IDLE_TRANS;

  PROCEDURE IEU_SH_OPEN_CURSOR(l_applCursor IN OUT NOCOPY t_cursor, p_appl_name IN NUMBER) IS
  l_app_names VARCHAR2(32);
  l_app_uwq VARCHAR2(32);
  l_app_emc VARCHAR2(32);
  BEGIN

    l_app_names := 'IEU_SH_APPL_NAMES';
    l_app_uwq := 'IEU_SH_APPL_UWQ';
    l_app_emc := 'IEU_SH_APPL_EMC';

    IF (p_appl_name = '1')
      THEN
        OPEN l_applCursor FOR
          SELECT to_number(attribute2) APPL_ID
          FROM FND_LOOKUP_VALUES
          WHERE LOOKUP_TYPE = l_app_names and
          LOOKUP_CODE = l_app_uwq;
      ELSIF (p_appl_name = '2')
      THEN
        OPEN l_applCursor FOR
          SELECT to_number(attribute2) APPL_ID
          FROM FND_LOOKUP_VALUES
          WHERE LOOKUP_TYPE = l_app_names and
          LOOKUP_CODE = l_app_emc;
      ELSIF (p_appl_name = '3')
      THEN
        OPEN l_applCursor FOR
          SELECT to_number(attribute2) APPL_ID
          FROM FND_LOOKUP_VALUES
          WHERE LOOKUP_TYPE = l_app_names;
      ELSE
        RAISE_APPLICATION_ERROR (-20000,
          'Input must be "1" or "2" or "3"');
      END IF;
    END IEU_SH_OPEN_CURSOR;

END IEU_SH_CON_PVT;


/
