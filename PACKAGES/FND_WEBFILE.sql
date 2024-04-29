--------------------------------------------------------
--  DDL for Package FND_WEBFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEBFILE" AUTHID CURRENT_USER as
/* $Header: AFCPFILS.pls 120.2 2005/08/19 21:42:24 rckalyan ship $ */



/* Define file types for get_url */
process_log   constant number := 1;
icm_log       constant number := 2;
request_log   constant number := 3;
request_out   constant number := 4;
request_mgr   constant number := 5;
frd_log       constant number := 6;
generic_log   constant number := 7;
generic_trc   constant number := 8;
generic_ora   constant number := 9;
generic_cfg   constant number := 10;
context_file  constant number := 11;
generic_text  constant number := 12;
generic_binary constant number := 13;
request_xml_output constant number :=14;

/* Function: GET_URL
 *
 * Purpose: Constructs and returns the URL for a Concurrent Processing
 *          log or output file.
 *
 * Arguments:
 *  file_type - Specifies the type of file desired:
 *       fnd_webfile.process_log = The log of the concurrent process identified
 *                                 by the parameter ID.
 *       fnd_webfile.icm_log     = The log of the ICM process identified by ID.
 *                                 Or, the log of the ICM process that spawned
 *                                 the concurrent process identified by ID.
 *                                 Or, the log of the most recent ICM process
 *                                 if ID is null.
 *       fnd_webfile.request_log = The log of the request identified by ID.
 *       fnd_webfile.request_out = The output of the request identified by ID.
 *       fnd_webfile.request_mgr = The log of the concurrent process that ran
 *                                 the request identified by ID.
 *       fnd_webfile.frd_log     = The log of the forms process identified
 *                                 by ID.
 *       fnd_webfile.generic_log = The log file identified by ID.
 *       fnd_webfile.generic_trc = The trace file identified by ID.
 *       fnd_webfile.generic_ora = The ora file identified by ID.
 *       fnd_webfile.generic_cfg = The config file identified by ID.
 *       fnd_webfile.context_file= Applications Context file identified by ID.
 *       fnd_webfile.generic_text= Generic file using text transfer mode.
 *       fnd_webfile.generic_binary = Generic file using binary transfer mode.
 *       fnd_webfile.request_xml_output = The xml output of Concurrent Request.
 *
 *  id        - A concurrent process ID, concurrent request ID, or file ID
 *                 depending on the file type specified.
 *              For fnd_webfile.context_file,fnd_webfile.generic_text,
 *              fnd_webfile.generic_binary this value is null.
 *
 *  gwyuid    - The value of the environment variable GWYUID used in
 *                 constructing the URL.
 *
 *  two_task  - The database two_task, used in constructing the URL.
 *
 *  expire_time - The number of minutes for which this URL will remain
 *                   valid.
 *  source_file - Source file name with full patch
 *
 *  source_node - Source node name.
 *
 *  dest_file   - Destination file name
 *
 *  dest_node   - Destination node name
 *
 *  page_no	    - Current page number
 *
 *  page_size	- Number of lines in a page
 *
 *  Returns NULL on error.  Check the FND message stack.
 */
function get_url( file_type  IN number,
                         id  IN number,
                     gwyuid  IN varchar2,
                   two_task  IN varchar2,
                expire_time  IN number,
                source_file  IN varchar2 default null,
                source_node  IN varchar2 default null,
                  dest_file  IN varchar2 default null,
                  dest_node  IN varchar2 default null,
				    page_no  IN number   default null,
                  page_size  IN number   default null) return varchar2;



/* Function: get_req_log_urls
 *
 * Purpose: Constructs and returns the URLs for a concurrent request log
 *          and the log of the manager that ran the request..
 *
 * Arguments:
 *  request_id  - Desired request_id.
 *
 *  gwyuid    - The value of the environment variable GWYUID used in
 *                 constructing the URL.
 *
 *  two_task  - The database two_task, used in constructing the URL.
 *
 *  expire_time - The number of minutes for which this URL will remain
 *                valid.
 *
 *  req_log - Output URL for the request log.
 *
 *  mgr_log - Output URL for the manager log.
 *
 *  Returns FALSE on error.  Check the FND message stack.
 */

function get_req_log_urls( request_id IN  number,
                               gwyuid IN  varchar2,
                             two_task IN  varchar2,
                          expire_time IN  number,
                              req_log IN OUT NOCOPY varchar2,
                              mgr_log IN OUT NOCOPY varchar2) return boolean;



function create_id(   	name 	IN varchar2,
			node 	IN varchar2,
			lifetime IN number default 10,
			type	IN varchar2 default 'text/plain',
			req_id 	IN number default 0,
                        x_mode  IN varchar2 default 'TEXT',
                        ncenc   IN varchar2 default 'N') return varchar2;

procedure set_debug(dbg IN boolean);

end;

 

/
