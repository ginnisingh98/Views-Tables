--------------------------------------------------------
--  DDL for Package JTF_IH_BULK_Q_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_BULK_Q_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFIHPQS.pls 115.2 2003/06/25 11:27:30 mpetrosi noship $ */
-- -------------------------------------------------------------
-- TYPE IH_BULK_TYPE as OBJECT(BulkWriterCode VARCHAR2(240),
--                            BulkBatchType  VARCHAR2(240),
--                            BulkBatchId    NUMBER,
--                            BulkInteractionId NUMBER,
--                            BulkInteractionRequest CLOB);

PROCEDURE CLOBENQUEUE(p_bulkWriterCode in  VARCHAR2,
                                        p_bulkBatchType  in  VARCHAR2,
                                        p_bulkBatchId    in  NUMBER,
                                        p_bulkInteractionId in NUMBER,
                                        enq_msgid        out NOCOPY RAW);

PROCEDURE CLOBDEQUEUE;
END JTF_IH_BULK_Q_PKG;

 

/
