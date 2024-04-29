--------------------------------------------------------
--  DDL for Package FND_GSM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_GSM_UTIL" AUTHID CURRENT_USER as
/* $Header: AFCPGUTS.pls 120.2 2005/08/19 17:38:53 vvengala ship $ */


--
-- procedure
--   Append_ctx_fragment
--
-- Purpose
--   Used to upload a context file into a clob for parsing.
--   A temporary clob is created on the first call.  This clob
--   will be freed when the upload_context_file procedure is called.
--
-- In Arguments:
--   buffer - Context file, or fragment of a context file.
--
-- Out Arguments:
--   retcode - 0 on success, >0 on error.
--   message - Error message, up to 2000 bytes.
--
procedure append_ctx_fragment(buffer  in  varchar2,
                              retcode out nocopy number,
                              message out nocopy varchar2);


--
-- Procedure
--   upload_context_file
--
-- Purpose
--   Parse the context file stored in the temporary clob and create
--   the appropriate service instance definitions for GSM.  The clob is
--   created by the append_ctx_fragment
--
-- In Arguments:
--   filepath - Full path to the context file.  Used for bookkeeping.
--   context_type - 'APPS' Application middle tier,
--                  'DATABASE' Database context
--   file_type  - 'CONTEXT' - Instantiated Context file
--                'TEMPLATE' - Template file for Context file.
--
-- Out Arguments:
--   retcode - 0 on success, >0 on error.
--   message - Error message, up to 2000 bytes.
--
procedure upload_context_file(filepath in varchar2,
                              retcode out nocopy number,
                              message out nocopy varchar2,
			      context_type in varchar2 default 'APPS',
                              file_type in varchar2 default 'CONTEXT');

--
-- Function
--   version_check
--
-- Purpose
--   This function compares two different versions of a file it will return a positive number
--   if version1 is higher than version2, '0' if both the versions are same,negative number
--   if version1 is lesser than version1
--
-- In Arguments:
--   version1 - version1 of the file.
--   version2 - version2 of the file
--
function version_check(version1 varchar,version2 varchar) return number;

end fnd_gsm_util;

 

/
