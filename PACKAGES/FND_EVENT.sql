--------------------------------------------------------
--  DDL for Package FND_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EVENT" AUTHID CURRENT_USER as
/* $Header: AFAMEVTS.pls 120.2 2005/08/19 18:23:35 tkamiya ship $ */



-- Name : initialize
-- Description:
--       initialize sets the context for the event.
--       One has to call initialize before calling fnd_event.post.
--       Returns event_id if successfull otherwise 0.
-- Arguments:
--    source_application_id -
--    source_type - 'M'(manager)/'R'(Request)
--    source_id   - concurrent_process_id/concurrent_request_id
--    dest_type   - destination type
--    message_appl_short_name
--                - application short name of the message
--    name        - message name
--    severity    - ERROR/WARNING/FATAL
--    module      - source module name
--

FUNCTION initialize(source_application_id IN NUMBER default 0,
                   source_type IN VARCHAR2,
                   source_id   IN NUMBER,
                   dest_type   IN VARCHAR2 default '0',
		   message_appl_short_name IN VARCHAR2,
                   name        IN VARCHAR2,
                   severity    IN VARCHAR2  default 'WARNING',
		   module      IN VARCHAR2 default Null) return number;

-- Name : set_token
-- Description:
--     It sets the token name and token value.
--     Call this procedure for each token you have for a event.
--     call initialize before calling set_token
-- Arguments:
--     event_id - event_id value for which you are setting the token.
--     token - token name
--     value - token value
--   type - 'C' = Constant.   Value is used directly in the token
--                            substitution.
--          'S' = Select.     Value is a SQL statement which returns a single
--                            varchar2 value.  (e.g. A translated concurrent
--                            manager name.)  This statement is run when the
--                            even is retrieved, and the result is used in
--                            the token substitution.
--          'T' = Translate.  Value is a message name.  This message must
--                            belong to the same application as the
--                            message specified in the INITIALIZE function.
--                            The message text will be used in the token
--                            substitution.


PROCEDURE set_token(event_id IN number,
                    token    IN VARCHAR2,
                    value    IN VARCHAR2 default NULL,
                    type     IN VARCHAR2 default 'C');
-- Name : post
-- Description:
--     It inserts the cp_event into fnd_events table, fnd_event_tokens
--     Call this function after calling initialize and optionally set_token.
--     If successfull it returns TRUE else returns FALSE.
-- Arguments: event_id - event_id for which you want to post events.

FUNCTION post (event_id IN number )
            return boolean;


-- Name : get
-- Description:
--     Gets the event for a given source_id, source_type.
--     Also returns the # of unprocessed events that match
--     the source_id and source_type.
--     Be cautious while using this procedure in while or for loops.
--     It may lead to infinite loop.
--     Stop calling this procedure when you get remaining events = 0 for a
--     given source_id and source_type.
--     If successfull returns event_id else returns 0.
-- Arguments:
--     source_id    - event source id, IN parameter
--     source_type  - event source type, IN parameter
--     event_string - event message, OUT parameter
--     remaining    - Number of unprocessed events that match the source_id
--                    and source_type. OUT parameter

FUNCTION get ( source_id   IN number,
               source_type  IN varchar2,
               processed    IN boolean default FALSE,
               message      IN OUT NOCOPY varchar2,
               remaining    IN OUT NOCOPY number) return boolean;


--
-- Name
--   OEM_GET
--
-- Purpose
--   Retrieves the next unprocessed event with a destination type
--   of 'O' from the fnd_events table.  The retrieved event is marked
--   as processed.
--
-- Arguments
--   event_text     - Text of the event. (out)
--                    Buffer must be at least 2000 bytes.
--   event_time     - Date/time of event posting.
--   event_severity - 'WARNING' or 'ERROR'
--
-- Returns
--   0 - There are no unprocessed OEM events.
--   1 - An event was successfully retrieved.
--   2 - Error.  The event_text parameter will contain
--       the error message.
--
-- Notes
--   Error messages are returned in the event_text paramter.
--
function oem_get ( event_text     out NOCOPY varchar2,
                   event_time     out NOCOPY date,
                   event_severity out NOCOPY varchar2 ) return number;

-- New function to retrieve the event text, given the id
function oem_get_text ( event_id in number ) return varchar2;

-- New function to set an event as processed
function oem_set_processed ( event_id in number ) return number;

end FND_EVENT;

 

/
