--------------------------------------------------------
--  DDL for Package FND_CONC_MAINTAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_MAINTAIN" AUTHID CURRENT_USER as
/* $Header: AFCPMNTS.pls 120.1.12010000.4 2015/01/26 16:31:40 ckclark ship $ */


/* APPS_INITIALIZE_FOR_MGR-
**   Initialize the application context (userid, respid, etc) if it hasn't
**   already been set.  This will point to a special user APPSMGR which
**   is used for running requests to maintain the data.
**   This should be called before submitting requests in places like loaders
**   where there is no user signed in.
**   If another user has already signed in, this will not switch users.
**   returns TRUE on success, FALSE on failure.
*/
PROCEDURE apps_initialize_for_mgr;



/*
** GET_PENDING_REQUEST_ID-
** Returns zero if the request ID isn't pending right away.
*/
FUNCTION get_pending_request_id
  (p_application_short_name  IN VARCHAR2,
   p_concurrent_program_name IN VARCHAR2)
RETURN number;





-- Constants to indicate logfile, output file or both
LOG       constant number := 1;
OUT       constant number := 2;
BOTH      constant number := 3;


-- Array type for use with the procedures below
TYPE request_list IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;


-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of a single request's logfile, output file or both.
--   Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   reqid     - Concurrent request id
--   directory - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which     in  number,
                             reqid     in  number,
                             directory in  varchar2,
                             updated   out nocopy number);



-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for a list of requests.
--   Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   requests  - List of request ids
--   directory - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which     in  number,
                             requests  in  request_list,
                             directory in  varchar2,
                             updated   out nocopy number);

-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for requests within a
--   date range (inclusive). Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   min_compldate  - Minimum completion date of requests
--   max_compldate  - Maximum completion date of requests
--   directory - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which         in  number,
                             min_compldate in  date,
                             max_compldate in  date,
                             directory     in  varchar2,
                             updated       out nocopy number);


-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for requests within a
--   range (inclusive) of request_id's. Updates the directory only, does not change
--   the file names.  Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which      - LOG, OUT or BOTH
--   min_reqid  - Minimum request_id for set of requests
--   max_reqid  - Maximum request_id for set of requests
--   directory  - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which     in  number,
                             min_reqid in  number,
                             max_reqid in  number,
                             directory in  varchar2,
                             updated   out nocopy number);

-- Procedure
--   SET_REQUEST_FILES
--
-- Purpose
--   Changes the location of a single request's logfile, output file or both.
--   Sets the filename to the passed-in value, which should be a complete path
--   and filename.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   reqid     - Concurrent request id
--   logfile   - New logfile name, can be null
--   outfile   - New outfile name, can be null
--
procedure set_request_files(reqid   in number,
                            logfile in varchar2,
                            outfile in varchar2,
                            updated out nocopy number);



-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for a single request.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   reqid     - Concurrent request id
--   node      - New node name
--
procedure set_request_node(which in number,
                           reqid in number,
                           node  in varchar2,
                           updated out nocopy number);



-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for a list of requests.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   requests  - List of request ids
--   node      - New node name
--
procedure set_request_node(which    in number,
                           requests in request_list,
                           node     in varchar2,
                           updated out nocopy number);

-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for requests within a
--   date range (inclusive). Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.

-- Arguments
--   which          - LOG, OUT or BOTH
--   min_compldate  - Minimum completion date of requests
--   max_compldate  - Maximum completion date of requests
--   node      - New node name
--   updated - number of requests updated
--
procedure set_request_node  (which         in  number,
                             min_compldate in  date,
                             max_compldate in  date,
                             node          in  varchar2,
                             updated       out nocopy number);
-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for a list of requests.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   requests  - List of request ids
--   node      - New node name
--
procedure set_request_node  (which         in  number,
                             min_reqid     in  number,
                             max_reqid     in  number,
                             node          in  varchar2,
                             updated       out nocopy number);


end FND_CONC_MAINTAIN;

/
