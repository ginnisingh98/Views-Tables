--------------------------------------------------------
--  DDL for Package Body FND_AUDIT_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AUDIT_SEQ_PKG" as
/* $Header: AFATUTLB.pls 120.1 2005/07/02 03:57:28 appldev ship $ */

--
-- Global variables
--   FND_AUDIT_GLOBAL number;  (current sequence number)
--   FND_AUDIT_COMMIT number;  (current commit number)
--

--
-- Function NXT - returns next sequence number for a new audit row.
--
     Function NXT
       return Number is
     Begin
       FND_AUDIT_GLOBAL:= FND_AUDIT_GLOBAL+1;
       return FND_AUDIT_GLOBAL;
     End;

--
-- Function CMT - returns the current commit number; i.e. the number of
-- commits done in the current session.
-- a lock is requested and if a commit occurs, the lock is released and
-- the commit number (FND_AUDIT_COMMIT) is incremented.
--
     Function CMT
       return Number is
       LOCKNUM number;
     Begin
       LOCKNUM := dbms_lock.request(2000000001, dbms_lock.nl_mode,0,TRUE);
       if (LOCKNUM = 0) then
         FND_AUDIT_COMMIT := FND_AUDIT_COMMIT+1;
       end if;
       return FND_AUDIT_COMMIT;
     End;

--
-- Function USER_NAME
-- returns the current Applications user name if an applications context
-- exists and the current database account otherwise.
--
     Function USER_NAME
       return varchar2 is
       NUSER varchar2(100);
     Begin
       NUSER := FND_GLOBAL.USER_NAME;
       if (NUSER is NULL) then
         select USER into NUSER from dual;
       end if;
       return NUSER;
     End;
   End FND_AUDIT_SEQ_PKG;

/
