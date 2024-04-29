--------------------------------------------------------
--  DDL for Package FND_PERFMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PERFMON" AUTHID CURRENT_USER as
/* $Header: AFPMMONS.pls 115.5 2003/08/22 19:25:09 fskinner ship $ */


--
-- SET_WAIT_SAMPLE_EXPIRATION
-- Set the number of days that wait_samples will be stored in the db.
-- Then delete expired samples.
--
procedure SET_WAIT_SAMPLE_EXPIRATION(new_expire float);

--
-- GET_WAIT_SAMPLE_EXPIRATION
-- Return the current expiration limit (ie: the number of days that
-- wait_samples will be stored in the db).
--
function GET_WAIT_SAMPLE_EXPIRATION return float;


--
-- TAKE_WAIT_SAMPLE
-- Sample v$session_wait to capture:
-- encoded event, background or foreground, batch or real-time, snapdate,
-- and group similar events so it records a count for the group.
--
procedure TAKE_WAIT_SAMPLE;





--
-- SET_SQL_SAMPLE_EXPIRATION
-- Set the number of days that sql_samples will be stored in the db.
-- Then delete expired samples.
--
procedure SET_SQL_SAMPLE_EXPIRATION(new_expire float);


--
-- GET_SQL_SAMPLE_EXPIRATION
-- Return the current expiration limit (ie: the number of days that
-- sql_samples will be stored in the db).
--
function GET_SQL_SAMPLE_EXPIRATION return float;


--
-- TAKE_SQL_SAMPLE
-- Sample v$session to capture
-- the sql currently being executed by every session.
--
procedure TAKE_SQL_SAMPLE;



end FND_PERFMON;

 

/
