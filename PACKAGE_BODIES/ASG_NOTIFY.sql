--------------------------------------------------------
--  DDL for Package Body ASG_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_NOTIFY" as
/* $Header: asgnotb.pls 115.8 2001/06/04 15:14:29 pkm ship      $*/
-- Description
-- ASG_Notify.
-- This package is a debuging / logging package that allows a developer to
-- Error, logging, and information messages real time.
--
-- In order to see the logged information real time, the developer must run
-- oracle.apps.asg.util.SqlLogger.  SqlLogger is a standalone java application
-- that retirves the output from ASG_Notify.
--
-- HISTORY
--   02-feb-99  D Cassinera           Created.

m_ses_info varchar2 (200);

/*==========================================================================
	  Read_Pipe
	  Reads a message from the pipe
===========================================================================*/
Function  Read_PIPE  RETURN varchar2
IS
V_STATUS INTEGER;
ret      integer;
text     varchar2(32000);
begin
	ret := 0; /* assume ok */
	V_STATUS := DBMS_PIPE.RECEIVE_MESSAGE ('MIDDLE_TIER_MTS_CONTROL');
	if (V_STATUS = 0 ) then
		DBMS_PIPE.UNPACK_MESSAGE (text);
	else
		ret := v_status;
	end if;
	return text;
exception
	when others then
		/* This package is a debuging package therefore it should not raise any execptions */
		return null;
end Read_PIPE;
/*==========================================================================
	  send_mesg
	  Sends a message to another session
===========================================================================*/
FUNCTION  SEND_MSG(text in varchar2, location varchar2) return number
IS
begin
	Send_Message (text , location );
	return 0;
end SEND_MSG;

/*==========================================================================
	  send message
	  Sends a message to another session
===========================================================================*/
Procedure Send_Message(text IN varchar2, location varchar2) is
V_STATUS INTEGER;
v_user varchar2(20);
--v_ses_info varchar2 (200);

begin
--	SELECT ' '||MACHINE|| ' ' ||PROGRAM||' ' INTO V_SES_INFO FROM V$SESSION WHERE AUDSID = USERENV('SESSIONID') and rownum = 1;
--	SELECT MACHINE|| ' ' INTO V_SES_INFO FROM V$SESSION WHERE AUDSID = USERENV('SESSIONID') and rownum = 1;
	DBMS_PIPE.PACK_MESSAGE (to_char (sysdate,'MMDD HH24:MI.SS')||' '||user||' '||m_SES_INFO||' '||location||' ' || text);
	V_STATUS:=DBMS_PIPE.send_message ('MIDDLE_TIER_MTS_CONTROL',1);
exception
	when others then
		/* This package is a debuging package therefore it should not raise any execptions */
		null;
end Send_Message;

/*==========================================================================
	  Stop
	  Sends a disconnect signal to the client if any.
===========================================================================*/
Procedure STOP is
V_STATUS INTEGER;
v_user varchar2(20);
v_ses_info varchar2 (80);

begin
--	SELECT MACHINE|| ' ' ||PROGRAM||' ' INTO V_SES_INFO FROM V$SESSION WHERE AUDSID = USERENV('SESSIONID') and rownum = 1;
	DBMS_PIPE.PACK_MESSAGE ('STOP '||to_char (sysdate,'MMDD HH24:MI.SS')||' '||user||' '||m_SES_INFO);
	V_STATUS:=DBMS_PIPE.send_message ('MIDDLE_TIER_MTS_CONTROL',1);
exception
	when others then
		/* This package is a debuging package therefore it should not raise any execptions */
		null;
end STOP;

begin
SELECT ' '||MACHINE|| ' ' ||PROGRAM||' ' INTO m_SES_INFO FROM V$SESSION WHERE AUDSID = USERENV('SESSIONID') and rownum = 1;

END ASG_NOTIFY;

/
