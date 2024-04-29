--------------------------------------------------------
--  DDL for Package Body FND_CP_TMSRV_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_TMSRV_PIPE" as
/* $Header: AFCPTMPB.pls 120.1 2005/09/17 01:59:53 pferguso noship $ */


--
-- Constants
--
FNDCPRP   constant varchar2(10) := 'FNDCPTM:R:';    -- R pipe prefix
FNDCPTP   constant varchar2(10) := 'FNDCPTM:T:';    -- T pipe prefix


--
-- Private variables
--
P_DEBUG     varchar2(1)     := FNDCP_TMSRV.DBG_OFF;
P_R_PIPE    varchar2(30)    := null;
P_T_PIPE    varchar2(30)    := null;





procedure initialize (e_code in out nocopy number,
                      qid    in     number,
                      pid    in     number) is
begin

  P_T_PIPE := FNDCPTP || qid;
  P_R_PIPE := FNDCPRP || qid;

  e_code := FNDCP_TMSRV.E_SUCCESS;

end initialize;



procedure set_debug(dbgtype  in varchar2) is
begin
   P_DEBUG := dbgtype;
   FNDCP_TMSRV.P_DEBUG := dbgtype;
end set_debug;


--
-- Put the transaction token to indicate that the TM is ready to process
-- the next TP.
--

procedure put_token is

e_code number;

begin
  dbms_pipe.pack_message ( FNDCP_TMSRV.PK_TKN);
  e_code := dbms_pipe.send_message (P_T_PIPE);
end put_token;


--
-- Take the transaction token.
--

procedure take_token is

e_code number;

begin
  e_code := dbms_pipe.receive_message (P_T_PIPE, 0);
  if (e_code = FNDCP_TMSRV.E_SUCCESS) then
    dbms_pipe.reset_buffer;
  end if;
end take_token;


procedure read_message (e_code  in out nocopy number,
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
                        arg_20  in out nocopy varchar2) is
  end_date date;
  enable_trace varchar2(255);
  sql_stmt varchar2(255);
  ops_inst number;

begin

  -- Indicate that the TM is ready to process a TP.
  put_token;

  -- Read wait R_pipe.
  e_code := dbms_pipe.receive_message (P_R_PIPE, timeout);

  -- If timed out or other error, return
  if (e_code > FNDCP_TMSRV.E_SUCCESS) then
    take_token;
    return;
  end if;

  -- If packet type is not a Transaction request, return.
  dbms_pipe.unpack_message (pktyp);
  if (pktyp not in (FNDCP_TMSRV.PK_TRN, FNDCP_TMSRV.PK_TRN_D1, FNDCP_TMSRV.PK_TRN_D2)) then
    take_token;
    return;
  end if;

  -- Set debug level
  set_debug(pktyp);

  dbms_pipe.unpack_message (end_date);
  enddate := to_char (end_date, 'DD-MON-RR HH24:MI:SS');


  dbms_pipe.unpack_message (reqid);
  dbms_pipe.unpack_message (return_id);
  dbms_pipe.unpack_message (nlslang);
  dbms_pipe.unpack_message (nls_num_chars);
  dbms_pipe.unpack_message (nls_date_lang);
  dbms_pipe.unpack_message (secgrpid);
  dbms_pipe.unpack_message (ops_inst);
  dbms_pipe.unpack_message (enable_trace);
  dbms_pipe.unpack_message (usrid);
  dbms_pipe.unpack_message (rspapid);
  dbms_pipe.unpack_message (rspid);
  dbms_pipe.unpack_message (logid);
  dbms_pipe.unpack_message (apsname);
  dbms_pipe.unpack_message (program);
  dbms_pipe.unpack_message (org_type);
  dbms_pipe.unpack_message (org_id);

  numargs := 0;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_1);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_2);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_3);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_4);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_5);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_6);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_7);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_8);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_9);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_10);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_11);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_12);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_13);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_14);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_15);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_16);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_17);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_18);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_19);
  numargs := numargs + 1;
  if (dbms_pipe.next_item_type = 0) then goto end_args; end if;
  dbms_pipe.unpack_message (arg_20);
  numargs := numargs + 1;

  <<end_args>>


  if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
     fndcp_tmsrv.debug_info('TMSRV_PIPE.read_message',
                'Unpacked request details', NULL, 'M');

  end if;

  FND_CONC_GLOBAL.Override_OPS_INST_NUM(ops_inst);

  sql_stmt := 'ALTER SESSION SET SQL_TRACE = '|| enable_trace;
  EXECUTE IMMEDIATE sql_stmt ;

  if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
     fndcp_tmsrv.debug_info('TMSRV_PIPE.read_message',
                'SQL_TRACE:', enable_trace, 'M');

  end if;
  return;

exception
   when others then
     fndcp_tmsrv.debug_info('TMSRV_PIPE.read_message',
                'EXCEPTION', sqlerrm, 'M');
end read_message;



procedure write_message (e_code  in out nocopy number,
                         return_id  in     varchar2,
                         pktyp      in     varchar2,
                         reqid        in     number,
                         outcome    in     varchar2,
                         message    in     varchar2) is

begin
  e_code := FNDCP_TMSRV.E_SUCCESS;

  dbms_pipe.reset_buffer;

  dbms_pipe.pack_message (pktyp);

  -- Pack reply only if it's a valid reply
  if (pktyp = FNDCP_TMSRV.PK_REP) then
    dbms_pipe.pack_message (reqid);
    dbms_pipe.pack_message (outcome);
    dbms_pipe.pack_message (message);
    for i in 1..FNDCP_TMSRV.P_RETVALCOUNT loop
      dbms_pipe.pack_message (FNDCP_TMSRV.P_RETURN_VALS (i));
    end loop;
  end if;

  FNDCP_TMSRV.P_RETVALCOUNT := 0;    -- Reset the return values table.

  if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
     fndcp_tmsrv.debug_info('TMSRV_PIPE.write_message',
                'Packing return message' ,
                NULL, 'S');

  end if;

  e_code := dbms_pipe.send_message (return_id);

  if ( P_DEBUG <> FNDCP_TMSRV.DBG_OFF ) then
     fndcp_tmsrv.debug_info('TMSRV_PIPE.write_message',
                'Sent Message' ,
                NULL, 'S');

  end if;

  -- Turn off debug.
  set_debug(FNDCP_TMSRV.DBG_OFF);

end write_message;


end fnd_cp_tmsrv_pipe;

/
