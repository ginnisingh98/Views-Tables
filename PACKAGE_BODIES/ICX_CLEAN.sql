--------------------------------------------------------
--  DDL for Package Body ICX_CLEAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CLEAN" as
/* $Header: ICXADCLB.pls 120.0 2005/10/07 11:47:16 gjimenez noship $ */

procedure tempTables is

begin

/* Delete rows older than 4 hours */

	delete	icx_text
	where   to_number(to_char(TIMESTAMP,'SSSSS'))
                < to_number(to_char(SYSDATE,'SSSSS')) - (4 * 60 * 60);
	commit;

/* Delete rows older than 12 hours */

        delete  icx_session_attributes
        where   session_id in
                (select session_id
                 from   icx_sessions
                 where  to_number(to_char(CREATION_DATE,'SSSSS'))
                 < to_number(to_char(SYSDATE,'SSSSS')) - (12 * 60 * 60));
        commit;

	delete	icx_sessions
	where	to_number(to_char(CREATION_DATE,'SSSSS'))
		< to_number(to_char(SYSDATE,'SSSSS')) - (12 * 60 * 60);
	commit;

        delete  icx_session_attributes
        where   session_id not in
                (select session_id
                 from   icx_sessions);
        commit;

/* Delete rows older than 12 hours */

        delete  icx_transactions
        where   to_number(to_char(CREATION_DATE,'SSSSS'))
                < to_number(to_char(SYSDATE,'SSSSS')) - (12 * 60 * 60);

/* Delete rows older than 30 days */

        delete  icx_failures
        where   to_number(to_char(CREATION_DATE,'J'))
                < to_number(to_char(SYSDATE,'J')) - 30;
        commit;

/* Delete rows older than 4 hours */

        delete  icx_context_results_temp
        where   to_number(to_char(DATESTAMP,'SSSSS'))
                < to_number(to_char(SYSDATE,'SSSSS')) - (1 * 60 * 60);
        commit;

/* Delete rows older than 12 hours.  FND_SESSION_VALUES table should be
   purged when ICX_SESSIONS table is purged. */

        delete  fnd_session_values
        where   to_number(to_char(TIMESTAMP,'SSSSS'))
                < to_number(to_char(SYSDATE,'SSSSS')) - (12 * 60 * 60);
        commit;

/* Uncomment this when DATESTAMP is added to cs_incidents_ctx_results
        delete  cs_incidents_ctx_results
        where   to_number(to_char(DATESTAMP,'SSSSS'))
                < to_number(to_char(SYSDATE,'SSSSS')) - (1 * 60 * 60);
        commit;
*/

end;

end icx_clean;

/
