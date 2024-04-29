--------------------------------------------------------
--  DDL for Package CSI_TRANSACTION_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TRANSACTION_LINES_PVT" AUTHID CURRENT_USER as
/* $Header: CSIVTLWS.pls 120.0.12000000.2 2007/07/11 16:57:19 ngoutam noship $ */
 -- Start of comments

 -- HISTORY

 -- End of comments

 TXN_LINE_ERROR  EXCEPTION;

  PROCEDURE process_txn_lines
  (
    errbuf                      OUT NOCOPY     VARCHAR2,
    retcode                     OUT NOCOPY     NUMBER,
    p_batch_id        IN      NUMBER
    ,p_purge_option  IN VARCHAR2
   );

END CSI_TRANSACTION_LINES_PVT;


 

/
