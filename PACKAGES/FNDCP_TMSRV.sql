--------------------------------------------------------
--  DDL for Package FNDCP_TMSRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FNDCP_TMSRV" AUTHID CURRENT_USER as
/* $Header: AFCPTMSS.pls 120.5 2005/09/17 02:07:24 pferguso ship $ */

--
-- Data types
--

type return_val_type is table of
  varchar2 (480)
index by binary_integer;

--
-- Constants
--

DBG_OFF   constant varchar2(1)  := '0';    -- No debug on the transation
DBG_1     constant varchar2(1)  := '1';
DBG_2     constant varchar2(1)  := '2';

PK_TKN    constant varchar2(1)  := 'X';    -- Token
PK_TRN    constant varchar2(1)  := '0';    -- Transaction Request
PK_TRN_D1 constant varchar2(1)  := '1';    -- Transaction Request (debug 1)
PK_TRN_D2 constant varchar2(1)  := '2';    -- Transaction Request (debug 2)
PK_REP    constant varchar2(1)  := 'R';    -- Reply
PK_REPUTP constant varchar2(1)  := 'U';    -- Reply unlinked TP
PK_REPBAD constant varchar2(1)  := 'B';    -- Reply bad for unknown reason
PK_EXIT   constant varchar2(1)  := 'E';    -- Exit TM

E_SUCCESS constant number(4)    := 0;    -- success
E_TIMEOUT constant number(4)    := 1;    -- timeout
E_OTHER   constant number(4)    := 3;    -- other
E_OLDREQ  constant number(4)    := 4;    -- end date of req < sysdate
E_MAXVALS constant number(4)    := 5;    -- Max # of put vals exceeded

E_EXIT    constant number(4)    := 10;   -- Exit TM

SECOND    constant number(15)   := 1 / (24 * 60 * 60);    -- A second in days
MAXVALS   constant number(4)    := 20;                    -- Max # of retvals


--
-- Variables
--

P_RETURN_VALS    return_val_type;
P_RETVALCOUNT    binary_integer    := 0;
P_DEBUG         varchar2(1) := DBG_OFF;



--
--   debug_info
-- Purpose
--   If the debug flag is set, then write to
--   the debug table.
-- Arguments
--   IN:
--   the debug table.
-- Arguments
--   IN:
--    function_name - Name of the calling function
--    action_name   - Name of the current action being logged
--    message_text  - Any relevant info.
--    s_type        - Source Type ('C'- Client Send, 'M' - Manager Receive
--                                  'S' - Server Send, 'U' - Client Receive)
-- Notes
--   none.
--
procedure debug_info(function_name in varchar2,
                     action_name   in varchar2,
                     message_text  in varchar2,
                     s_type        in varchar2 default 'M');

--
-- Returns the oracle id, oracle username and the encripted password
-- for the TM (qapid, qid) to connect.
--
procedure get_oracle_account (e_code in out nocopy number,
                              qapid  in     number,
                              qid    in     number,
                              oid    in out nocopy number,
                              ouname in out nocopy varchar2,
                              opass  in out nocopy varchar2);

--
-- Initialization
--
procedure initialize (e_code in out nocopy number,
                      qid    in     number,
                      pid    in     number);

--
-- Read the request.
--
procedure read_message(e_code  in out nocopy number,
                   timeout in     number,
                   pktyp   in out nocopy varchar2,
                   enddate in out nocopy varchar2,
                   reqid   in out nocopy number,
                   return_id in out nocopy varchar2,
                   nlslang in out nocopy varchar2,
                   nls_num_chars in out nocopy varchar2,
                   nls_date_lang in out nocopy varchar2,
                   secgrpid in out nocopy number,
                   usrid   in out nocopy number,
                   rspapid in out nocopy number,
                   rspid   in out nocopy number,
                   logid   in out nocopy number,
                   apsname in out nocopy varchar2,
                   program in out nocopy varchar2,
                   numargs in out nocopy number,
                   org_type in out nocopy varchar2,
                   org_id  in out nocopy number,
                   arg_1   in out nocopy varchar2,
                   arg_2   in out nocopy varchar2,
                   arg_3   in out nocopy varchar2,
                   arg_4   in out nocopy varchar2,
                   arg_5   in out nocopy varchar2,
                   arg_6   in out nocopy varchar2,
                   arg_7   in out nocopy varchar2,
                   arg_8   in out nocopy varchar2,
                   arg_9   in out nocopy varchar2,
                   arg_10  in out nocopy varchar2,
                   arg_11  in out nocopy varchar2,
                   arg_12  in out nocopy varchar2,
                   arg_13  in out nocopy varchar2,
                   arg_14  in out nocopy varchar2,
                   arg_15  in out nocopy varchar2,
                   arg_16  in out nocopy varchar2,
                   arg_17  in out nocopy varchar2,
                   arg_18  in out nocopy varchar2,
                   arg_19  in out nocopy varchar2,
                   arg_20  in out nocopy varchar2);

--
-- This routine is called from a transaction program to put a return
-- to be sent back to the client.  This can be called at most, MAXVALS
-- times ane the values are stored in a table and written to the C pipe
-- when the TP completes.
--
procedure put_value (e_code in out nocopy number,
                     retval in     varchar2);

--
-- TPs call this routine to complete the transaction.
-- This writes the reply packet and the return values back to the client.
-- Also, resets the return values table.
--
procedure write_message (e_code    in out nocopy number,
                         return_id in   varchar2,
                         pktyp     in   varchar2,
                         reqid     in   number,
                         outcome   in   varchar2,
                         message   in   varchar2);

--
-- Monitor self (TM) to see if need to exit.
-- Exit if max procs is 0 or less than running, or current node is
-- different from the target when target i snot null (PCP).
-- Read in sleep seconds and manager debug flag a new.
--
procedure monitor_self (e_code in out nocopy number,
                        qapid  in     number,
                        qid    in     number,
                        cnode  in     varchar2,
                        slpsec in out nocopy number,
                        mgrdbg in out nocopy varchar2);

--
-- Use this routine to stop a TM when it's running online.
-- The routine writes an exit packet to the R pipe.
--
procedure stop_tm (qid in number);

--
-- Not used.
--
procedure debug    (dbg_level in number   default 0);

--
-- Not used.
--
function  debug return number;


--
-- Monitor self (TM) to see if need to exit.
-- Exit if max procs is 0 or less than running, or current node is
-- different from the target when target i snot null (PCP).
-- Read in sleep seconds and manager debug flag a new.
--
procedure monitor_self2 (e_code in out nocopy number,
                         qapid  in     number,
                         qid    in     number,
                         cnode  in     varchar2,
                         slpsec in out nocopy number,
                         mgrdbg in out nocopy varchar2,
                         procid in     number);




end FNDCP_TMSRV;

 

/
