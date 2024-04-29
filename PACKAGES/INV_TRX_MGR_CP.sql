--------------------------------------------------------
--  DDL for Package INV_TRX_MGR_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRX_MGR_CP" AUTHID CURRENT_USER AS
/* $Header: INVTRXCS.pls 120.1 2005/06/17 17:45:07 appldev  $ */

--
--      Name: PROCESS_LPN_TRX
--
--      Input parameters:
--
--       x_retcode       Return Code, as specified in ConcurrentUsersGuide
--       x_errbuf        Error Buffer, as specified in ConcurrentUsersGuide
--       p_trx_id        Transaction HeaderId of the batch of rows in MMTT
--                          that is to be processed
--

PROCEDURE PROCESS_LPN_TRX(  x_retcode   OUT NOCOPY VARCHAR2,
                            x_errbuf    OUT NOCOPY VARCHAR2,
                            p_trx_id     IN NUMBER   );
END INV_TRX_MGR_CP;

 

/
