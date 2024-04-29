--------------------------------------------------------
--  DDL for Package FND_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TRANSACTION" AUTHID CURRENT_USER as
/* $Header: AFCPTRNS.pls 120.2 2005/09/02 18:46:01 pferguso ship $ */


--
-- Constants
--

DAY_PER_SEC  constant number    := 1 / (24 * 60 * 60); -- Days in a second
SEC_PER_DAY  constant number    := (24 * 60 * 60);     -- Seconds in a day

E_SUCCESS constant number    := 0;           -- e_code is success
E_TIMEOUT constant number    := 1;           -- e_code is timeout
E_NOMGR   constant number    := 2;           -- e_code is no manager
E_OTHER   constant number    := 3;           -- e_code is other
E_ARGSIZE constant number    := 4;           -- arguments are too large

TYPE_REQUEST        constant varchar2(1) := '0'; -- Normal request
TYPE_REQUEST_DEBUG1 constant varchar2(1) := '1'; -- Request in debug mode 1
TYPE_REQUEST_DEBUG2 constant varchar2(1) := '2'; -- Request in debug mode 2

DEFAULT_TIMEOUT constant number := 10;     -- Default token timeout value in seconds

ARGMAX          constant number := 480;    -- Max size of single argument
ARGSTOTAL       constant number := 3072;   -- Max total size of all args



--
-- Types
--
type varchar_table is table of varchar(480) index by binary_integer;


--
-- Variables
--
debug_flag        boolean      := null;
conc_queue_id     number     := null;
return_values     varchar_table;




--
-- Function
--   synchronous
-- Purpose
--   Submit a sychronous transaction request.
-- Arguments
--   IN
--     timeout     - Number of seconds to wait for transaction completion.
--     application - Transaction program application short name.
--     program     - Transaction program short name.
--     arg_n       - Arguments 1 through 20 to the transaction program.
--
--                   Each argument is at most 480 characters.
--                   Individual arguments longer than 480 chars will be truncated.
--
--                   The sum of the argument lengths must be less than 3K.
--                   Note that this means that all 20 arguments can NOT be 480 bytes long.
--                   E_ARGSIZE will be returned if the sum is greater than 3K.
--
--                   If there are n arguments, where n is less than 20,
--                   then argument n+1 must be set to chr(0).
--   OUT
--     outcome     - varchar(30)  - Transaction program completion status.
--     message     - varchar(240) - Transaction program completion message.
--
function synchronous (timeout     in     number,
                      outcome     in out NOCOPY varchar2,
                      message     in out NOCOPY varchar2,
                      application in     varchar2,
                      program     in     varchar2,
                      arg_1       in     varchar2 default chr(0),
                      arg_2       in     varchar2 default chr(0),
                      arg_3       in     varchar2 default chr(0),
                      arg_4       in     varchar2 default chr(0),
                      arg_5       in     varchar2 default chr(0),
                      arg_6       in     varchar2 default chr(0),
                      arg_7       in     varchar2 default chr(0),
                      arg_8       in     varchar2 default chr(0),
                      arg_9       in     varchar2 default chr(0),
                      arg_10      in     varchar2 default chr(0),
                      arg_11      in     varchar2 default chr(0),
                      arg_12      in     varchar2 default chr(0),
                      arg_13      in     varchar2 default chr(0),
                      arg_14      in     varchar2 default chr(0),
                      arg_15      in     varchar2 default chr(0),
                      arg_16      in     varchar2 default chr(0),
                      arg_17      in     varchar2 default chr(0),
                      arg_18      in     varchar2 default chr(0),
                      arg_19      in     varchar2 default chr(0),
                      arg_20      in     varchar2 default chr(0))
                    return number;

--
-- Function
--   get_values
-- Purpose
--   Retrieve the last transaction's return
--   values from the global table.
-- Arguments
--   OUT
--     arg_n - Returned values 1 through 20
--
function get_values  (arg_1       in out NOCOPY varchar2,
                      arg_2       in out NOCOPY varchar2,
                      arg_3       in out NOCOPY varchar2,
                      arg_4       in out NOCOPY varchar2,
                      arg_5       in out NOCOPY varchar2,
                      arg_6       in out NOCOPY varchar2,
                      arg_7       in out NOCOPY varchar2,
                      arg_8       in out NOCOPY varchar2,
                      arg_9       in out NOCOPY varchar2,
                      arg_10      in out NOCOPY varchar2,
                      arg_11      in out NOCOPY varchar2,
                      arg_12      in out NOCOPY varchar2,
                      arg_13      in out NOCOPY varchar2,
                      arg_14      in out NOCOPY varchar2,
                      arg_15      in out NOCOPY varchar2,
                      arg_16      in out NOCOPY varchar2,
                      arg_17      in out NOCOPY varchar2,
                      arg_18      in out NOCOPY varchar2,
                      arg_19      in out NOCOPY varchar2,
                      arg_20      in out NOCOPY varchar2)
                    return number;





procedure debug_info(function_name in varchar2,
                     action_name   in varchar2,
                     message_text  in varchar2,
                     s_type        in varchar2 default 'C');

procedure post_tm_event( event_type  in number,
                         application in varchar2,
                         program     in varchar2,
                         queue_id    in number,
                         timeout     in number default null,
                         tm_pipe     in varchar2 default null );


end FND_TRANSACTION;

 

/
