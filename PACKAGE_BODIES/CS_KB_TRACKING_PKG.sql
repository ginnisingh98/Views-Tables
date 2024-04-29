--------------------------------------------------------
--  DDL for Package Body CS_KB_TRACKING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_TRACKING_PKG" AS
/* $Header: cskbtkb.pls 115.2 2003/11/18 01:04:38 allau noship $ */

PROCEDURE PURGE_TRACKING_HISTORY (ERRBUF  OUT NOCOPY VARCHAR2,
                                  RETCODE OUT NOCOPY VARCHAR2) IS



cursor get_session_attr_count is
select count(*)
from cs_kb_session_attrs b
where b.session_id in (
    select  a.session_id
    from cs_kb_sessions a
    where a.source_object_code like 'KMT%'
    and (a.source_object_id not in
         (select session_id from icx_sessions
          where nvl(disabled_flag,'N') = 'N')));

cursor get_session_count is
select count(*)
from cs_kb_sessions a
  where a.source_object_code like 'KMT%'
  and (a.source_object_id not in
         (select session_id from icx_sessions
          where nvl(disabled_flag,'N') = 'N'));


l_session_attr_count number;
l_session_count number;

BEGIN

--ERRBUF = err messages
--RETCODE = 0=success, 1=warning, 2=error

--  FND_FILE.PUT_LINE(FND_FILE.LOG,
--    'Starting Concurrent Program to purge tracking history at: '|| to_char(sysdate,'DD-MON-YY HH24:MI:SS'));

  -- "Tracking history of invalid ICX session will be deleted."
  FND_FILE.PUT_LINE(FND_FILE.LOG,
    fnd_message.get_string('CS', 'CS_KB_DEL_TRACKING_DATA'));

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

  -- LOGIC START

  open get_session_attr_count;
  fetch get_session_attr_count into l_session_attr_count;
  close get_session_attr_count;

  open get_session_count;
  fetch get_session_count into l_session_count;
  close get_session_count;

  -- "Number of session attributes to be deleted:"
  FND_FILE.PUT_LINE(FND_FILE.LOG,
    fnd_message.get_string('CS', 'CS_KB_NUM_SES_ATTR_DEL') || l_session_attr_count);

  -- "Number of sessions to be deleted:"
  FND_FILE.PUT_LINE(FND_FILE.LOG,
    fnd_message.get_string('CS', 'CS_KB_NUM_SES_DEL') || l_session_count);

--  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Purging data...');

  delete  cs_kb_session_attrs b
  where b.session_id in (
    select  a.session_id
    from cs_kb_sessions a
    where a.source_object_code like 'KMT%'
    and (a.source_object_id not in
         (select session_id from icx_sessions
          where nvl(disabled_flag,'N') = 'N')));

  delete cs_kb_sessions a
  where a.source_object_code like 'KMT%'
  and (a.source_object_id not in
         (select session_id from icx_sessions
          where nvl(disabled_flag,'N') = 'N'));

  open get_session_attr_count;
  fetch get_session_attr_count into l_session_attr_count;
  close get_session_attr_count;

  open get_session_count;
  fetch get_session_count into l_session_count;
  close get_session_count;

  -- "Number of session attributes to be deleted:"
  FND_FILE.PUT_LINE(FND_FILE.LOG,
    fnd_message.get_string('CS', 'CS_KB_NUM_SES_ATTR_DEL') || l_session_attr_count);

  -- "Number of sessions to be deleted:"
  FND_FILE.PUT_LINE(FND_FILE.LOG,
    fnd_message.get_string('CS', 'CS_KB_NUM_SES_DEL') || l_session_count);

  -- LOGIC END


--  FND_FILE.PUT_LINE(FND_FILE.LOG,
--    'Finished Concurrent Program to purge tracking history at: '|| to_char(sysdate,'DD-MON-YY HH24:MI:SS'));

  COMMIT;

  ERRBUF := 'Success';
  RETCODE := 0;

EXCEPTION

  WHEN OTHERS THEN
    RETCODE := 2;

    -- "Execution failed due to unexpected error."
    ERRBUF := fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);

END PURGE_TRACKING_HISTORY;

END CS_KB_TRACKING_PKG;

/
