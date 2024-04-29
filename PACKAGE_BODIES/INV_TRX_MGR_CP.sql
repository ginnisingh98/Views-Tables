--------------------------------------------------------
--  DDL for Package Body INV_TRX_MGR_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRX_MGR_CP" AS
/* $Header: INVTRXCB.pls 120.1 2005/06/17 17:41:21 appldev  $ */


--      Name: PROCESS_LPN_TRX
--
--      Input parameters:
--
--      Output parameters:
--       x_proc_msg         Message from the Process-Manager
--       return_status      0 on Success, 1 on Error
--
--
--

PROCEDURE PROCESS_LPN_TRX(  x_retcode   OUT NOCOPY VARCHAR2,
                            x_errbuf         OUT NOCOPY VARCHAR2,
                            p_trx_id         IN NUMBER ) IS
v_commit varchar2(12) := fnd_api.g_true;
v_mesg varchar2(2000) ;
v_retval number;
ret boolean;
BEGIN
  v_retval := INV_LPN_TRX_PUB.PROCESS_LPN_TRX(
                p_trx_hdr_id => p_trx_id,
                p_commit     =>v_commit,
                x_proc_msg   => v_mesg,
                p_proc_mode  => 1 );  -- Online when called from Conc manager
  if (v_retval = 1) then
    ret := fnd_concurrent.set_completion_status('ERROR', v_mesg);
    x_retcode := 2;
    x_errbuf := v_mesg;
  else
    ret := fnd_concurrent.set_completion_status('NORMAL', v_mesg);
    x_retcode := 0;
  end if;

END;

END INV_TRX_MGR_CP;

/
