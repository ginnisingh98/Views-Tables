--------------------------------------------------------
--  DDL for Package APP_EXCEPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."APP_EXCEPTIONS" AUTHID CURRENT_USER as
/* $Header: AFEXCP1S.pls 115.0 99/07/16 23:16:49 porting ship $ */

--
-- Package
--   app_exceptions
-- Purpose
--   APP user-defined exceptions
-- History
--   04/22/97	Murali     	Created
--

  --
  -- Exceptions
  --
  application_exception exception;
  record_lock_exception exception;

  --
  -- Pragmas
  --
  pragma exception_init(application_exception, -20001);
  pragma exception_init(record_lock_exception,  -0054);

  --
  -- Exception Codes
  --

end app_exceptions;

 

/
