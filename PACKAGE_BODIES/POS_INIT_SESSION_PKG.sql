--------------------------------------------------------
--  DDL for Package Body POS_INIT_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_INIT_SESSION_PKG" AS
/* $Header: POSINSEB.pls 115.0 2001/10/29 17:18:54 pkm ship   $*/


PROCEDURE InitSession(p_resp_id VARCHAR2) IS

BEGIN
     -- we need to manually set the responsibility id
     -- that is passed in from the function.
     UPDATE ICX_SESSIONS
        SET responsibility_id = to_number(p_resp_id),
            RESPONSIBILITY_APPLICATION_ID = 178
      WHERE session_id = icx_sec.getID(icx_sec.PV_SESSION_ID);
     COMMIT;

     IF NOT icx_sec.validatesession THEN
       RETURN;
     END IF;

     UPDATE ICX_SESSIONS
        SET ORG_ID = fnd_profile.value('ORG_ID')
      WHERE session_id = icx_sec.getID(icx_sec.PV_SESSION_ID);
     COMMIT;

END InitSession;


END POS_INIT_SESSION_PKG;

/
