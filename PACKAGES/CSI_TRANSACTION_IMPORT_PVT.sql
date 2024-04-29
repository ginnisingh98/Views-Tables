--------------------------------------------------------
--  DDL for Package CSI_TRANSACTION_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_TRANSACTION_IMPORT_PVT" AUTHID CURRENT_USER as
/* $Header: CSIVTXPS.pls 120.0.12000000.2 2007/07/11 17:05:54 ngoutam noship $*/

   -- Start of comments
   -- API name : PROCESS_TRANSACTION_ROWS
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_max_worker_number         IN      NUMBER := 10

   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Himal Karmacharya
   --
   -- End of comments

Current_Error_Code  Varchar2(9) := NULL;

PROCEDURE PROCESS_TRANSACTION_ROWS
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_max_worker_number IN NUMBER := 10
     ,p_purge_option IN varchar2
     );

END CSI_TRANSACTION_IMPORT_PVT;


 

/
