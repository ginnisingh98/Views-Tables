--------------------------------------------------------
--  DDL for Package Body JTF_IH_BULK_Q_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_BULK_Q_PKG" AS
/* $Header: JTFIHPQB.pls 115.3 2004/01/30 16:17:31 msista noship $ */

-- -------------------------------------------------------------
PROCEDURE CLOBENQUEUE(p_bulkWriterCode in  VARCHAR2,
                                        p_bulkBatchType  in  VARCHAR2,
                                        p_bulkBatchId    in  NUMBER,
                                        p_bulkInteractionId in NUMBER,
                                        enq_msgid        out NOCOPY RAW) as
  enq_userdata system.IH_BULK_TYPE;
  enqopt       dbms_aq.enqueue_options_t;
  msgprop      dbms_aq.message_properties_t;

  queue_disabled_exception exception;
  pragma exception_init(queue_disabled_exception,-25207);



BEGIN

  enq_userdata := system.IH_BULK_TYPE(p_bulkWriterCode, p_bulkBatchType, p_bulkBatchId, p_bulkInteractionId, empty_clob());
   dbms_aq.enqueue('JTF_IH_BULK_Q', enqopt, msgprop, enq_userdata, enq_msgid);

EXCEPTION
	WHEN queue_disabled_exception THEN
    dbms_aqadm.start_queue('JTF_IH_BULK_Q');
    dbms_aq.enqueue('JTF_IH_BULK_Q', enqopt, msgprop, enq_userdata, enq_msgid);

END CLOBENQUEUE;

PROCEDURE CLOBDEQUEUE AS

  dequeue_options    dbms_aq.dequeue_options_t;
  message_properties dbms_aq.message_properties_t;
  mid                raw(16);
  pload              system.IH_BULK_TYPE;
  lob_loc            clob;
  l_amount           number;
  n_amount           number;
  buffer             raw(4096);
  xmlfile            VARCHAR2(32767);

BEGIN


  dbms_aq.dequeue('JTF_IH_BULK_Q', dequeue_options, message_properties, pload, mid);

  commit;

END  CLOBDEQUEUE;
END JTF_IH_BULK_Q_PKG;

/
