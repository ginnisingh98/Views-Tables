--------------------------------------------------------
--  DDL for Package Body FV_IPA_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPA_PKG_PVT" AS
-- $Header: FVDCLBPB.pls 120.4 2005/10/21 11:16:36 kbhatt noship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_IPA_PKG_PVT.';

PROCEDURE IPA_TRX(x_transmission_id IN NUMBER) AS
  l_module_name VARCHAR2(200) := g_module_name || 'IPA_TRX';

 v_submit_id  NUMBER;
 call_status  BOOLEAN;
 rphase       VARCHAR2(30);
 dphase       VARCHAR2(30);
 rstatus      VARCHAR2(30);
 dstatus      VARCHAR2(30);
 message      VARCHAR2(240);

 l_org_id NUMBER;	-- MOAC Change

 submit_error EXCEPTION;

BEGIN

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING FVDCLCKB, LOCKBOX FINANCE CHARGE APPLICATION');
 END IF;
 -- submit Lockbox Finance Charge Application process

-- MOAC Changes
 l_org_id  := mo_global.get_current_org_id;    -- get org id
 fnd_request.set_org_id(l_org_id);             -- set org id

 v_submit_id := FND_REQUEST.SUBMIT_REQUEST('FV','FVDCLCKB',NULL, NULL, FALSE,
                  x_transmission_id);

 IF v_submit_id = 0 THEN
   -- failed to sumbit process
   RAISE submit_error;
 END IF;
 commit;

 -- do not exit this procedure until the Lockbox Finance Charge Application
 -- Process has completed processing.  Then control can return to the
 -- Lockbox Execution report.
 LOOP
   call_status := FND_CONCURRENT.GET_REQUEST_STATUS(v_submit_id, NULL, NULL,
          rphase,rstatus,dphase,dstatus,message);
   EXIt WHEN ((call_status and dphase = 'COMPLETE') or NOT(call_status));
   dbms_lock.sleep(5);
 END LOOP;


EXCEPTION
  WHEN submit_error THEN
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1','ERROR IN FEDERAL''S FV_IPA_PKG_PVT.IPA_TRX. COULD NOT SUBMIT FVDCLCKB');
     app_exception.raise_exception;

  WHEN OTHERS THEN
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception2','ERROR IN FEDERAL''S FV_IPA_PKG_PVT.IPA_TRX--'||SQLERRM);
      app_exception.raise_exception;

END IPA_TRX;

END FV_IPA_PKG_PVT;

/
