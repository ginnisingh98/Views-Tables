--------------------------------------------------------
--  DDL for Package FND_AUDIT_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AUDIT_SEQ_PKG" AUTHID CURRENT_USER As
/* $Header: AFATUTLS.pls 120.1 2005/07/02 03:57:32 appldev ship $ */

--
-- Global variables
--   FND_AUDIT_GLOBAL number;  (current sequence number)
     FND_AUDIT_GLOBAL number := 0;

--   FND_AUDIT_COMMIT number;  (current commit number)
     FND_AUDIT_COMMIT number := 0;

--
-- PUBLIC FUNCTIONS
--

--
-- Function NXT
--
-- Purpose
--   Returns next sequence number for a new audit row.
--
-- Arguments
--   NONE
--
     Function NXT
       return NUMBER;

--
-- Function CMT
--
-- Purpose
--   Returns the current commit number; i.e. the number of
--   commits done in the current session.
--   a lock is requested and if a commit occurs, the lock is released and
--   the commit number (FND_AUDIT_COMMIT) is incremented.
--
-- Arguments
--   NONE
--
     Function CMT
       return NUMBER;

--
-- Function USER_NAME
--
-- Purpose
--   Returns the current Applications user name if an applications context
--   exists and the current database account otherwise.
--
-- Arguments
--   NONE
--
     Function USER_NAME
       return VARCHAR2;
   End FND_AUDIT_SEQ_PKG;

 

/
