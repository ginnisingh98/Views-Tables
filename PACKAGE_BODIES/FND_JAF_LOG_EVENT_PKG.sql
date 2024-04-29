--------------------------------------------------------
--  DDL for Package Body FND_JAF_LOG_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_JAF_LOG_EVENT_PKG" AS
  /* $Header: FNDLJAFB.pls 120.0.12010000.11 2013/05/03 21:29:03 dbowles noship $ */

FUNCTION getCurrentTimeInMillis
  RETURN NUMBER
IS
  l_timestamp_diff INTERVAL DAY (9) TO SECOND (6);
  l_day_value             NUMBER;
  l_hour_value            NUMBER;
  l_minute_value          NUMBER;
  l_second_value          NUMBER;
  l_timestamp_diff_number NUMBER;
  l_err_code              NUMBER(38);
  l_err_mesg              VARCHAR2(250);
BEGIN

  l_timestamp_diff        := SYSTIMESTAMP - TO_TIMESTAMP('1970-01-01 00:00:00.000000', 'YYYY-MM-DD HH24:MI:SS.FF');
  l_day_value             := extract(DAY FROM l_timestamp_diff);
  l_hour_value            := extract(hour FROM l_timestamp_diff);
  l_minute_value          := extract(minute FROM l_timestamp_diff);
  l_second_value          := extract(second FROM l_timestamp_diff);
  l_timestamp_diff_number := ROUND((l_day_value * 86400 + l_hour_value * 3600 + l_minute_value * 60 + l_second_value) * 1000);
  RETURN l_timestamp_diff_number;
EXCEPTION
WHEN OTHERS THEN
  l_err_code := SQLCODE;
  l_err_mesg := SQLERRM;
  fnd_message.SET_NAME('FND', 'Error in FND_JAF_LOG_EVENT_PKG');
  fnd_message.set_token( 'MESSAGE', 'EXCEPTION in Function FND_JAF_LOG_EVENT_PKG.getCurrentTimeInMillis: SQLCODE=' || l_err_code || ' , SQLERRM=' || l_err_mesg ) ;
  if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_ERROR, 'fnd.plsql.FND_JAF_LOG_EVENT_PKG.getCurrentTimeInMillis', true);
  end if;
END getCurrentTimeInMillis;


PROCEDURE updateEventTimeStamp(
        p_request_id IN varchar2,
        p_event_name IN varchar2,
        p_event_type IN varchar2
        ) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_err_code NUMBER(38);
    l_err_mesg VARCHAR2(250);
    BEGIN
        UPDATE FND_JAF_EVENT_LOG SET start_timestamp = SYSTIMESTAMP
            WHERE request_id = p_request_id AND event_name = p_event_name AND event_type = p_event_type;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
        l_err_code := SQLCODE;
        l_err_mesg := SQLERRM;
        ROLLBACK;
        fnd_message.SET_NAME('FND', 'Error in FND_JAF_LOG_EVENT_PKG');
        fnd_message.set_token( 'MESSAGE', 'EXCEPTION in Procedure FND_JAF_LOG_EVENT_PKG.logEventToDB: SQLCODE=' || l_err_code || ' , SQLERRM=' || l_err_mesg
                    || ' (p_request_id=' || p_request_id || ', p_event_name=' || p_event_name || ', p_event_type=' || p_event_type || ')') ;
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.message(FND_LOG.LEVEL_ERROR, 'fnd.plsql.FND_JAF_LOG_EVENT_PKG.logEventToDB', true);
        end if;

END updateEventTimeStamp;

PROCEDURE logEventToDB(
    p_request_id               IN VARCHAR2,
    p_event_name               IN VARCHAR2,
    p_event_type               IN VARCHAR2,
    p_prev_event_payload       IN VARCHAR2,
    p_grand_prev_event_payload IN VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR fnd_jaf_event_log_cur
  IS
    SELECT *
    FROM FND_JAF_EVENT_LOG
    WHERE start_timestamp =
      (SELECT NVL(MAX(start_timestamp), SYSTIMESTAMP)
      FROM FND_JAF_EVENT_LOG
      WHERE request_id = p_request_id
      AND event_name   = p_event_name
      AND event_type   = 'SEND'
      ) FOR UPDATE;
  l_timestamp_value TIMESTAMP;
  fnd_jaf_event_log_rec FND_JAF_EVENT_LOG%ROWTYPE;
  l_err_code NUMBER(38);
  l_err_mesg VARCHAR2(250);

BEGIN
  OPEN fnd_jaf_event_log_cur;
  FETCH fnd_jaf_event_log_cur INTO fnd_jaf_event_log_rec;
  l_timestamp_value := SYSTIMESTAMP;

  IF fnd_jaf_event_log_cur%NOTFOUND THEN
    -- insert event log. event_type should be 'SEND' here, and timestampValue should be the start timestamp of the event
    INSERT
    INTO FND_JAF_EVENT_LOG
      (
        request_id,
        event_name,
        event_type,
        start_timestamp,
        prev_event_name,
        grand_prev_event_name
      )
      VALUES
      (
        p_request_id,
        p_event_name,
        p_event_type,
        l_timestamp_value,
        p_prev_event_payload,
        p_grand_prev_event_payload
      );
    COMMIT;
  ELSE
    -- update event log. event_type should be 'RECEIVE' here, and timestampValue should be the end timestamp of the event
    UPDATE FND_JAF_EVENT_LOG
    SET end_timestamp = l_timestamp_value,
      event_type      = p_event_type
    WHERE CURRENT OF fnd_jaf_event_log_cur;
    COMMIT;
  END IF;
  CLOSE fnd_jaf_event_log_cur;
EXCEPTION
WHEN OTHERS THEN
  l_err_code := SQLCODE;
  l_err_mesg := SQLERRM;
  ROLLBACK;
  fnd_message.SET_NAME('FND', 'Error in FND_JAF_LOG_EVENT_PKG');
  fnd_message.set_token( 'MESSAGE', 'EXCEPTION in Procedure FND_JAF_LOG_EVENT_PKG.logEventToDB: SQLCODE=' || l_err_code || ' , SQLERRM=' || l_err_mesg
                        || ' (p_request_id=' || p_request_id || ', p_event_name=' || p_event_name || ', p_event_type=' || p_event_type || ')') ;
  if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_ERROR, 'fnd.plsql.FND_JAF_LOG_EVENT_PKG.logEventToDB', true);
  end if;
END logEventToDB;

END FND_JAF_LOG_EVENT_PKG;

/
