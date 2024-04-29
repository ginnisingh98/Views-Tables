--------------------------------------------------------
--  DDL for Package Body QP_PRICE_REQUEST_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_REQUEST_CONTEXT" AS
/* $Header: QPXVPREB.pls 120.1 2006/03/24 14:47:15 jhkuo noship $ */

FUNCTION Request_Pricing_Lock return integer is
PRAGMA AUTONOMOUS_TRANSACTION;
lock_handle varchar2(128);
lock_result integer;
BEGIN
  DBMS_LOCK.ALLOCATE_UNIQUE(QP_JAVA_ENGINE_UTIL_PUB.G_QP_INT_TABLES_LOCK, lock_handle);
  lock_result := DBMS_LOCK.REQUEST(lock_handle, DBMS_LOCK.S_MODE, DBMS_LOCK.MAXWAIT, TRUE);
commit;
  return lock_result;
END Request_Pricing_Lock;

-- function to set request id
PROCEDURE Set_Request_Id  IS

l_request_id NUMBER;
lock_result integer;
BEGIN

  IF(QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Running = 'N') THEN
    -- changed for 5115618/5098611
    l_request_id := nvl(SYS_CONTEXT('QP_CONTEXT','REQUEST_ID'),0) + 1;
  ELSE
    select QP_REQUEST_ID_S.nextval into l_request_id from dual;
    --try to wait for S-Lock on Interface Tables before proceeding to request_price
    lock_result := Request_Pricing_Lock;

    --clear the interface tables stat info
    QP_PREQ_GRP.G_INT_LINES_NO := 0;
    QP_PREQ_GRP.G_INT_LDETS_NO := 0;
    QP_PREQ_GRP.G_INT_ATTRS_NO := 0;
    QP_PREQ_GRP.G_INT_RELS_NO := 0;
  END IF;
  QP_PREQ_GRP.G_REQUEST_ID := l_request_id;

  -- set request_id attribute under namespace 'qp_context'
  DBMS_SESSION.SET_CONTEXT('qp_context', 'request_id', l_request_id);

END Set_Request_Id;

FUNCTION Release_Pricing_Lock return integer is
lock_handle varchar2(128);
lock_result integer;
BEGIN
  DBMS_LOCK.ALLOCATE_UNIQUE(QP_JAVA_ENGINE_UTIL_PUB.G_QP_INT_TABLES_LOCK, lock_handle);
  lock_result := DBMS_LOCK.RELEASE(lock_handle);
  return lock_result;
END Release_Pricing_Lock;


FUNCTION Get_Request_Id return number is
l_request_id number;
BEGIN
  l_request_id := nvl(QP_PREQ_GRP.G_REQUEST_ID,fnd_api.g_miss_num);
  return l_request_id;
END Get_Request_id;

--needed for HTML Qualifiers UI
--return transaction_id attribute under namespace 'qp_context'
FUNCTION get_transaction_id RETURN NUMBER IS
BEGIN
RETURN nvl(SYS_CONTEXT('QP_CONTEXT','transaction_id'),-9999);
END get_transaction_id;

-- set transaction_id attribute under namespace 'qp_context'
PROCEDURE set_transaction_id(p_transaction_id IN NUMBER) IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('qp_context', 'transaction_id', p_transaction_id);
END set_transaction_id;
--needed for HTML Qualifiers UI

END QP_Price_Request_Context;

/
